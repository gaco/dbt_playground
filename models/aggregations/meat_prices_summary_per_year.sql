{{ config(materialized='table', alias='meat_prices_summary') }}

SELECT  
    year(date) as year,
    ROUND(MAX(price), 2) max_price, 
    ROUND(AVG(price), 2) average_price
FROM {{ ref('meat_prices') }}
WHERE 0=0
AND frequency = 'monthly' 
GROUP BY 1