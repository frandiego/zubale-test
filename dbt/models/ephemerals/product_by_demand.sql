{{ 
    config(
        materialized='ephemeral',
    ) 
}}


SELECT 
product_name, 
SUM(quantity) AS quantity
FROM 
{{ ref('order_full_information') }}
GROUP BY product_name
ORDER BY quantity DESC

