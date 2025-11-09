-- общее количество покупателей из таблицы customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- Отчет 1,топ 10 продавцов с наибольшей выручкой
SELECT 
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(p.price * s.quantity) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;

-- Отчет 2, Продавцы выручка за сделку меньше средней выручки за сделку по всем продавцам
WITH seller_avg AS (
    SELECT 
        e.first_name || ' ' || e.last_name AS seller,
        ROUND(SUM(p.price * s.quantity) / COUNT(s.sales_id)) AS average_income
    FROM sales s
    JOIN employees e ON s.sales_person_id = e.employee_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY e.first_name, e.last_name
),
overall_avg AS (
    SELECT AVG(average_income) AS avg_all
    FROM seller_avg
)
SELECT seller, average_income
FROM seller_avg, overall_avg
WHERE average_income < overall_avg.avg_all
ORDER BY average_income ASC;

-- Отчет 3, Выручка по дням недели
SELECT 
    e.first_name || ' ' || e.last_name AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,
    ROUND(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name, day_of_week, EXTRACT(DOW FROM s.sale_date)
ORDER BY EXTRACT(DOW FROM s.sale_date), seller;