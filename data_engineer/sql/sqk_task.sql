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