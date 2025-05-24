{{ 
    config(
        materialized='view',
        schema='silver',
        unique_key=['order_id', 'product_name']
    ) 
}}



SELECT  
  order_created_date, 
  order_id, 
  product_name, 
  quantity, 
  total_price as total_price_br,
  ROUND(CAST(total_price * rate.value AS NUMERIC), 2 ) AS total_price_us
  FROM {{ ref('order_full_information') }} 
    JOIN {{ ref('brl_to_usd') }} rate ON 1=1
