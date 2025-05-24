{{ 
    config(
        materialized='ephemeral'
    ) 
}}


SELECT rate::float AS value
FROM dbt.currency_rates
WHERE base_currency = 'BRL' AND currency = 'USD'
ORDER BY fetched_at DESC
LIMIT 1
