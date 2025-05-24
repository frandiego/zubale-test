{{ 
    config(
        materialized='view',
        schema='analysis',
    ) 
}}



SELECT
  created_date::DATE AS created_date, 
  COUNT(DISTINCT id) AS number_of_orders
FROM {{ ref('orders') }}
GROUP BY created_date
ORDER BY number_of_orders DESC
LIMIT 1