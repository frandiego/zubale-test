{{ 
    config(
        materialized='ephemeral',
    ) 
}}


select 
    p.category AS product_category, 
    SUM(pd.quantity) AS quantity
FROM {{ ref('product_by_demand') }} pd
JOIN {{ ref('products') }} p ON pd.product_name = p.name
GROUP BY p.category
ORDER BY  quantity DESC
