/*
    Test that the sum of the c_acctbal field is less than 100,000,000
*/
SELECT sum(c_acctbal) as total
FROM {{ ref('playing_with_tests') }}
GROUP BY c_custkey
HAVING sum(c_acctbal) >= 100000000