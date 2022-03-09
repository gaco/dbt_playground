{{ config(materialized='table', alias='rice_prices_per_year', tags=['rice', 'agg']) }}

SELECT  
    year(date) as year,
    ROUND(MAX(price), 2) max_price, 
    ROUND(AVG(price), 2) average_price
FROM {{ ref('stg_rice_prices') }}
WHERE 0=0
AND frequency = 'monthly' 
GROUP BY 1