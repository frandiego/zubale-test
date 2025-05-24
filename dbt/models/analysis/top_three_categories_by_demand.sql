{{ 
    config(
        materialized='view',
        schema='analysis',
    ) 
}}


SELECT *
FROM {{ ref('category_by_demand') }}
LIMIT 3