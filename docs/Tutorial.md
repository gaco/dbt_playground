

## DBT Initial Setup



### 1. Instalallation on MAC:

```shell
brew update
brew install git
brew tap dbt-labs/dbt
brew install dbt-snowflake
```

### 2. Create DBT Project

- Initalize your dbt project like below:

`dbt init <project_name>`.  

> In our case: dbt init dbt_playground 

- And fill the required information as requested. It will create a `profiles.yml` with the informations required so that DBT is able to connect to Snowflake and perform its transformation:

```yaml
gabriel@Gabriels-Air dbt-playground % dbt init dbt-playground
14:34:10  Running with dbt=1.0.3
dbt-playground is not a valid project name.
Enter a name for your project (letters, digits, underscore): dbt_playground
Which database would you like to use?
[1] snowflake

(Don't see the one you want? https://docs.getdbt.com/docs/available-adapters)

Enter a number: 1
account (https://<this_value>.snowflakecomputing.com): hz85786.us-east-2.aws
user (dev username): transform_user
[1] password
[2] keypair
[3] sso
Desired authentication type option (enter a number): 1
password (dev password): 
role (dev role): transform_role
warehouse (warehouse name): transform_wh
database (default database that dbt will build objects in): analytics
schema (default schema that dbt will build objects in): dbt
threads (1 or more) [1]: 
14:59:11  Profile dbt_playground written to /Users/gabriel/.dbt/profiles.yml using target's profile_template.yml and your supplied values. Run 'dbt debug' to validate the connection.
14:59:11  
Your new dbt project "dbt_playground" was created!

For more information on how to configure the profiles.yml file,
please consult the dbt documentation here:

  https://docs.getdbt.com/docs/configure-your-profile

One more thing:

Need help? Don't hesitate to reach out to us via GitHub issues or on Slack:

  https://community.getdbt.com/

Happy modeling!

gabriel@Gabriels-Air dbt-playground % 

```

- Your profile should be something like this:

```yaml
gabriel@Gabriels-Air dbt-playground % cat /Users/gabriel/.dbt/profiles.yml
dbt_playground:
  outputs:
    dev:
      account: hz85786.us-east-2.aws
      database: analytics
      password: ********
      role: transform_role
      schema: dbt
      threads: 1
      type: snowflake
      user: transform_user
      warehouse: transform_wh
  target: dev
```

- And a new directory called dbt-playground should have a structure like below:

![image-20220307122444840](images/image-20220307122444840.png)



### 3. Test DBT initial configuration

1. Run `dbt debug` to check if dbt is able to connect to the database:

```yaml
gabriel@Gabriels-Air dbt_playground % dbt debug
15:45:34  Running with dbt=1.0.3
dbt version: 1.0.3
python version: 3.9.10
python path: /opt/homebrew/Cellar/dbt-snowflake/1.0.0_2/libexec/bin/python3.9
os info: macOS-12.2.1-arm64-arm-64bit
Using profiles.yml file at /Users/gabriel/.dbt/profiles.yml
Using dbt_project.yml file at /Users/gabriel/dev/meus/dbt-playground/dbt_playground/dbt_project.yml

Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  account: hz85786.us-east-2.aws
  user: transform_user
  database: analytics
  schema: dbt
  warehouse: transform_wh
  role: transform_role
  client_session_keep_alive: False
  Connection test: [OK connection ok]

All checks passed!
gabriel@Gabriels-Air dbt_playground % 
```

2. Run `dbt run`to run SQLs against our Snowflake database:

> **dbt run** executes compiled sql model files against the current `target` database. dbt connects to the target database and runs the relevant SQL required to materialize all data models using the specified materialization strategies.
>
> Reference: https://docs.getdbt.com/reference/commands/run

   ```python
   gabriel@Gabriels-Air dbt_playground % dbt run       
   16:10:50  Running with dbt=1.0.3
   16:10:50  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 179 macros, 0 operations, 0 seed files, 0 sources, 0 exposures, 0 metrics
   16:10:50  
   16:10:55  Encountered an error:
   Database Error
     003041 (42710): SQL compilation error:
     Schema 'DBT' already exists, but current role has no privileges on it. If this is unexpected and you cannot resolve this problem, contact your system administrator. ACCOUNTADMIN role may be required to manage the privileges on the object.
   gabriel@Gabriels-Air dbt_playground % 
   ```

- We can see that it failed due to grant previleges.

- To check the SQL statements that were executed. We can see the logs in `logs/dbt.log`:

  ![image-20220307131629784](images/image-20220307131629784.png)

- We can see the query executed on line 19 that ended sucessfuly (see line 22) as well as the create schema statement on line 28 that failed with the snowflake query id shown on line 31. We can see this query id on snowflake as well:

![image-20220307131908814](images/image-20220307131908814.png)

3. Fix that by granting the needed permissions and try again:

```sql
-- DDL grants
grant create schema on database analytics to role transform_role;
-- Usage grants
grant usage on all schemas in database analytics to role transform_role;
grant usage on future schemas in database analytics to role transform_role;
grant usage on warehouse transform_wh to role transform_role;
grant usage on database analytics to role transform_role;
-- Query grants
grant select on all tables in database analytics to role transform_role;
grant select on future tables in database analytics to role transform_role;
grant select on all views in database analytics to role transform_role;
grant select on future views in database analytics to role transform_role;
```

```python
gabriel@Gabriels-Air dbt_playground % dbt run 
16:58:31  Running with dbt=1.0.3
16:58:31  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 179 macros, 0 operations, 0 seed files, 0 sources, 0 exposures, 0 metrics
16:58:31  
16:58:36  Concurrency: 1 threads (target='dev')
16:58:36  
16:58:36  1 of 2 START table model dbt.my_first_dbt_model................................. [RUN]
16:58:40  1 of 2 OK created table model dbt.my_first_dbt_model............................ [SUCCESS 1 in 3.30s]
16:58:40  2 of 2 START view model dbt.my_second_dbt_model................................. [RUN]
16:58:42  2 of 2 OK created view model dbt.my_second_dbt_model............................ [SUCCESS 1 in 2.22s]
16:58:42  
16:58:42  Finished running 1 table model, 1 view model in 11.26s.
16:58:42  
16:58:42  Completed successfully
16:58:42  
16:58:42  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
gabriel@Gabriels-Air dbt_playground % 

```

- We should be able to see two models in snowflake created by DBT. One table and one view:

![image-20220307140637867](images/image-20220307140637867.png)

## Snowflake Initial Setup

### 1. Create new Data Warehouse

![image-20220307112422439](images/image-20220307112422439.png)

Create Snowflake table:

```sql
CREATE WAREHOUSE TRANSFORM_WH WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE MIN_CLUSTER_COUNT = 1 MAX_CLUSTER_COUNT = 2 SCALING_POLICY = 'STANDARD';
```

change auto_suspend to 60s.

```sql
ALTER WAREHOUSE "TRANSFORM_WH" SET WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE MIN_CLUSTER_COUNT = 1 MAX_CLUSTER_COUNT = 2 SCALING_POLICY = 'STANDARD' COMMENT = '';
```

### 2. Create user to perform the transformations

![image-20220307113716597](images/image-20220307113716597.png)

### 3. Create role and grant access

![image-20220307113938305](images/image-20220307113938305.png)

And grant access to the previous created user (as well for ourselves) to this new role:

![image-20220307115500979](images/image-20220307115500979.png)

### 4. Create database and grant priveleges

![image-20220307114447179](images/image-20220307114447179.png)

```sql
-- DDL grants
grant create schema on database analytics to role transform_role;
-- Usage grants
grant usage on all schemas in database analytics to role transform_role;
grant usage on future schemas in database analytics to role transform_role;
grant usage on warehouse transform_wh to role transform_role;
grant usage on database analytics to role transform_role;
-- Query grants
grant select on all tables in database analytics to role transform_role;
grant select on future tables in database analytics to role transform_role;
grant select on all views in database analytics to role transform_role;
grant select on future views in database analytics to role transform_role;
```

