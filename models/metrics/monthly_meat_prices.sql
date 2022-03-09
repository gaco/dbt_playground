{{ config(materialized='table', alias='meat_prices_per_year', tags=['meat', 'agg']) }}

SELECT  
    year(date) as year,
    ROUND(MIN(price), 2) min_price,
    ROUND(MAX(price), 2) max_price, 
    ROUND(AVG(price), 2) average_price
FROM {{ ref('stg_meat_prices') }}
WHERE 0=0
AND frequency = 'monthly' 
GROUP BY 1