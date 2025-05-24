{{ 
    config(
        materialized='view',
        schema='analysis',
    ) 
}}


WITH 

  most_demanded_product AS 
  
(
  SELECT *
  FROM 
    {{ ref('product_by_demand') }}
  LIMIT 1
)
 
  
SELECT 
  p.id::INT AS product_id, 
  mdp.product_name::TEXT, 
  p.category::TEXT AS product_category, 
  p.price::FLOAT AS unit_price_br, 
  ROUND(CAST(mdp.quantity * p.price AS NUMERIC), 2) AS total_sold_br, 
  ROUND(CAST(p.price * rate.value AS NUMERIC), 2) AS unit_price_us,
  ROUND(CAST(p.price * rate.value * mdp.quantity AS NUMERIC), 2) AS total_sold_us
  
FROM most_demanded_product mdp
JOIN {{ ref('products') }} AS p 
  ON p.name = mdp.product_name
JOIN {{ ref('brl_to_usd') }} rate ON 1=1 
