-- общее количество покупателей из таблицы customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- Отчет 1,топ 10 продавцов с наибольшей выручкой
SELECT 
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
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

-- Отчет 1, Количество покупателей по возрастным группам
WITH age_groups AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category
    FROM customers
)
SELECT 
    age_category,
    COUNT(*) AS age_count
FROM age_groups
GROUP BY age_category
ORDER BY 
    CASE age_category
        WHEN '16-25' THEN 1
        WHEN '26-40' THEN 2
        WHEN '40+' THEN 3
    END;

-- Отчет 2, Количество уникальных покупателей и выручка по месяцам
WITH monthly_data AS (
    SELECT 
        TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
        s.customer_id,
        FLOOR(p.price * s.quantity) AS income
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
)
SELECT 
    selling_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(income) AS income
FROM monthly_data
GROUP BY selling_month
ORDER BY selling_month ASC;

-- Отчет 3, Первая покупка которых была в ходе проведения акций
WITH first_purchase AS (
    SELECT 
        s.customer_id,
        MIN(s.sale_date) AS first_sale_date
    FROM sales s
    GROUP BY s.customer_id
)
SELECT DISTINCT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM first_purchase fp
JOIN sales s 
    ON s.customer_id = fp.customer_id 
    AND s.sale_date = fp.first_sale_date
JOIN customers c 
    ON s.customer_id = c.customer_id
JOIN employees e 
    ON s.sales_person_id = e.employee_id
JOIN products p 
    ON s.product_id = p.product_id
WHERE p.price * s.quantity = 0
ORDER BY c.customer_id;