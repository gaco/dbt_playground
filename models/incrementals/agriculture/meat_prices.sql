{{ config(materialized='incremental', unique_key='date') }}

/* 
    How the international meat price changed over the years
*/
SELECT 
    "Variable" as variable,
    "Variable Name" as variable_name,
    "Variable Notes" as variable_notes,
    "Variable Unit" as variable_units,
    "Units" as units,
    "Scale" as scale,
    DECODE("Frequency", 'A', 'annual', 'M', 'monthly') as frequency,
    "Value" as price,
    "Date" as date
FROM {{ source('raw_aggriculture', 'FAOFPI2020JUL') }}
WHERE "Variable Name" = 'Meat Price Index'
AND "Date" <= current_date()

{% if is_incremental() %}
    and date > 
    (
        select max(date) from {{ this }}
        where "Variable Name" = 'Meat Price Index'
    )
{% endif %}