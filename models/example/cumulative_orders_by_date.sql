select distinct
    o_orderdate,
    sum(o.o_totalprice) over ( order by o_orderdate) as cummulative_sales
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
where 0=0
order by 1 asc
