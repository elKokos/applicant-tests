-- PostgreSQL

-- Количество покупателей из Италии и Франции
WITH it_fr_table as (
  select 
    country_name, 
    country_code 
  from 
    Countries 
  where 
    country_name IN ('Italy', 'France')
) 
SELECT 
  c.country_name, 
  COUNT(DISTINCT cu.customer_id) AS CustomerCountDistinct 
FROM 
  Customer as cu 
  JOIN it_fr_table as c ON cu.country_code = c.country_code 
GROUP BY 
  c.country_name;

-- ТОП 10 покупателей по расходам
SELECT 
  cu.customer_name, 
  SUM(o.quantity * i.item_price) AS Revenue 
FROM 
  Orders o 
  JOIN Customer cu ON o.customer_id = cu.customer_id 
  JOIN Items i ON o.item_id = i.item_id 
GROUP BY 
  cu.customer_name 
ORDER BY 
  Revenue DESC 
LIMIT 
  10;

-- Общая выручка USD по странам, если нет дохода, вернуть NULL
WITH customer_revenue AS (
  SELECT 
    cu.country_code, 
    SUM(o.quantity * i.item_price) AS revenue 
  FROM 
    Customer cu 
    JOIN Orders o ON cu.customer_id = o.customer_id 
    JOIN Items i ON o.item_id = i.item_id 
  GROUP BY 
    cu.country_code
) 
SELECT 
  co.country_name, 
  cr.revenue AS RevenuePerCountry 
FROM 
  Countries co 
  LEFT JOIN customer_revenue cr ON co.country_code = cr.country_code;

-- Самый дорогой товар, купленный одним покупателем
WITH max_price_per_customer AS (
  SELECT 
    o.customer_id, 
    MAX(i.item_price) AS max_price 
  FROM 
    Orders o 
    JOIN Items i ON o.item_id = i.item_id 
  GROUP BY 
    o.customer_id
) 
SELECT 
  cu.customer_id, 
  cu.customer_name, 
  i.item_name AS MostExpensiveItemName 
FROM 
  Orders o 
  JOIN Customer cu ON o.customer_id = cu.customer_id 
  JOIN Items i ON o.item_id = i.item_id 
  JOIN max_price_per_customer mp ON o.customer_id = mp.customer_id 
  AND i.item_price = mp.max_price

-- Ежемесячный доход
SELECT 
  DATE_TRUNC('month', o.date_time) AS Month, 
  SUM(o.quantity * i.item_price) AS TotalRevenue 
FROM 
  Orders o 
  JOIN Items i ON o.item_id = i.item_id 
GROUP BY 
  DATE_TRUNC('month', o.date_time) 
ORDER BY 
  Month;

-- Найти дубликаты
SELECT 
  date_time, 
  customer_id, 
  item_id, 
  COUNT(*) 
FROM 
  Orders 
GROUP BY 
  date_time, 
  customer_id, 
  item_id 
HAVING 
  COUNT(*) > 1;

-- Найти "важных" покупателей
WITH first_order AS (
  SELECT 
    customer_id, 
    MIN(date_time) AS first_order_date 
  FROM 
    Orders 
  GROUP BY 
    customer_id
) 
SELECT 
  o.customer_id, 
  COUNT(*) AS TotalOrdersCount 
FROM 
  Orders o 
  JOIN first_order fo ON o.customer_id = fo.customer_id 
WHERE 
  o.date_time > fo.first_order_date 
GROUP BY 
  o.customer_id 
ORDER BY 
  TotalOrdersCount DESC;

-- Найти покупателей с "ростом" за последний месяц

-- Вычисляем выручку по каждому клиенту по месяцам
WITH monthly_revenue AS (
  SELECT 
    customer_id, 
    DATE_TRUNC('month', date_time) AS month, 
    SUM(quantity * item_price) AS revenue 
  FROM 
    Orders o 
    JOIN Items i ON o.item_id = i.item_id 
  GROUP BY 
    customer_id, 
    DATE_TRUNC('month', date_time)
), 

-- Получаем выручку за последний месяц для каждого клиента
last_month_revenue AS (
  SELECT 
    customer_id, 
    revenue AS last_month_revenue 
  FROM 
    monthly_revenue 
  WHERE 
    month = (
      SELECT 
        MAX(month) 
      FROM 
        monthly_revenue
    )
), 

-- Вычисляем среднюю выручку за все месяцы для каждого клиента
average_revenue AS (
  SELECT 
    customer_id, 
    AVG(revenue) AS avg_revenue 
  FROM 
    monthly_revenue 
  GROUP BY 
    customer_id
) 

SELECT 
  lm.customer_id, 
  lm.last_month_revenue AS TotalRevenue 
FROM 
  last_month_revenue lm 
  JOIN average_revenue ar ON lm.customer_id = ar.customer_id 
WHERE 
  lm.last_month_revenue > ar.avg_revenue;
