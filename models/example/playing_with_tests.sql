SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER WHERE C_CUSTKEY IN (
    select C_CUSTKEY
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER
    GROUP BY C_CUSTKEY
    having sum(c_acctbal) < 100000000
)