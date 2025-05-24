{{ 
    config(
        materialized='table',
        schema='silver',
        unique_key=['order_id', 'product_name']
    ) 
}}


SELECT 

  o.created_date::DATE as order_created_date, 
  o.id::INT AS order_id, 
  p.name::TEXT AS product_name,
  o.quantity::INT AS quantity, 
  ROUND(CAST((o.quantity * p.price)::FLOAT AS NUMERIC), 2) AS total_price


FROM {{ ref('orders') }}  o
join {{ ref('products') }} p
  on p.id = o.product_id
  
  
  