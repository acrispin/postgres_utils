
-- http://www.postgresql.org.ar/trac/wiki/sql-vacuum.html
-- http://www.techonthenet.com/postgresql/vacuum.php
-- http://www.techonthenet.com/postgresql/autovacuum.php
-- https://lob.com/blog/supercharge-your-postgresql-performance/

-- check properties vacuum
SELECT *
FROM pg_settings 
WHERE name LIKE 'autovacuum%'

-- check tables that was do vacuum operation
SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze  
FROM pg_stat_all_tables  
WHERE schemaname = 'public'; 


/*


Parameters or Arguments
FULL
Optional. If specified, the database writes the full contents of the table into a new file. This reclaims all unused space and requires an exclusive lock on each table that is vacuumed.
FREEZE
Optional. If specified, the tuples are aggressively frozen when the table is vacuumed. This is the default behavior when FULLis specified, so it is redundant to specify both FULL and FREEZE.
VERBOSE
Optional. If specified, an activity report will be printed detailing the vacuum activity for each table.
ANALYZE
Optional. If specified, the statistics used by the planner will be updated. These statistics are used to determine the most efficient plan for executing a particular query.
table_name
Optional. If specified, only the table listed will be vacuumed. If not specified, all tables in the database will be vacuumed.
col1, col2, ... col_n
Optional. If specified, these are the columns that will be analyzed.
Note

Each time you perform an update on a table, the original record is kept in the database. A vacuum will remove these old records (ie: tuples) and reduce the size of the PostgreSQL database.
You can only those vacuum tables in which you have VACUUM permissions.
You can not run a VACUUM command within a transaction.
Example

In PostgreSQL, the process of vacuuming is a regular activity that must be performed to remove old, obsolete tuples and minimize the size of your database file.

Let's look at an example of how to use the VACUUM statement in PostgreSQL.

Reclaim Space to be Reused by Same Table

This first example shows how to reclaim space so that the unused space can be used by the same table. It does not reduce the size of the PostgreSQL database file as the space is not reclaimed by the operating system, only by the table from which the space was allocated.

For example:

VACUUM;
This example would vacuum all tables within the database. It would free up the space within each table and leave the space available to be reused by the same table. It does not return the space to the operating system, therefore, the size of the database file would not be reduced.

Reclaim Space and Minimize Database File

If you wanted to vacuum all tables and minimize the database file by returning the unused space to the operating system, you would run the following vacuum statement:

VACUUM FULL;
This example would rewrite all tables into a new file, thus requiring an exclusive lock on each table. The database file would be minimized as all of the unused space is reclaimed back to the operating system.

Reclaim Space on a Table

Next, let's look at how to vacuum a specific table, instead of the entire database.

For example:

VACUUM products;
This example would vacuum only the products table. It would free up the space within the products table and leave the space available to be used by only the products table. The size of the database file would not be reduced.

If you wanted to allocate the unused space back to the operating system, you would have to add the FULL option to the VACUUM statement as follows:

VACUUM FULL products;
This would not only free up the unused space in the products table, but it would also allow the operating system to reclaim the space and reduce the database size.

Vacuum Activity Report

Finally, you can add the VERBOSE option to the VACUUM command to display an activity report of the vacuum process.

For example:

VACUUM FULL VERBOSE products;
This would perform a full vacuum of the products table. Let's show you what you can expect to see as output for a vacuum activity report:

totn=# VACUUM FULL VERBOSE products;
INFO:  vacuuming "public.products"
INFO:  "products": found 4 removable, 5 nonremovable row versions in 1 pages
DETAIL:  0 dead row versions cannot be removed yet.
CPU 0.00s/0.00u sec elapsed 0.04 sec.
VACUUM
This activity report will display the tables that are vacuumed as well as the details and time taken to perform the vacuum operation.

--
Current Settings
You can view the AUTOVACUUM settings by one of two ways. You can either open the postgresql.conf file and view the AUTOVACUUM parameters (like above). Or if you are logged into the database, you can run the following query:

SELECT *
FROM pg_settings 
WHERE name LIKE 'autovacuum%'
This query will return the current system settings for the AUTOVACUUM daemon, but it is important to note that you can not update these settings using a query.

Update Settings

To change the settings for the AUTOVACUUM daemon, you will need to find and edit the settings stored within thepostgresql.conf file. The location of the postgresql.conf file will vary depending on the system that you are on.

Once you have edited the settings within the postgresql.conf file, you will be required to restart the database for the changes to take effect.

Disable AUTOVACUUM on a Table

When the system settings for AUTOVACUUM are turned on, you can disable the autovacuum for a specific table, if you choose. This is done by running a query within the database.

The syntax to disable the autovacuum for a table in PostgreSQL is:

ALTER TABLE table_name SET (autovacuum_enabled = false);
table_name
The table that you do not wish to autovacuum.
For example:

ALTER TABLE products SET (autovacuum_enabled = false);
In this example, the AUTOVACUUM daemon would be overriden so that the products table is not vacuumed automatically.

If you are not sure whether a table's AUTOVACUUM feature has been disabled, you can run the following query:

SELECT reloptions
FROM pg_class
WHERE relname = 'products';
This would return the AUTOVACUUM setting for the products table. If AUTOVACUUM has been disabled, your query will return something like this:

         reloptions         
----------------------------
 {autovacuum_enabled=false}
(1 row)
In this example, the products table has autovacuum_enabled set to false. This means that the AUTOVACUUM daemon will not try to vacuum the products table.


--
Make sure your largest database tables are vacuumed and analyzed frequently by setting stricter table-level auto-vacuum settings. Below is an example which will VACUUM and ANALYZE after 5,000 inserts, updates, or deletes.

ALTER TABLE table_name SET (autovacuum_vacuum_scale_factor = 0.0);  
ALTER TABLE table_name SET (autovacuum_vacuum_threshold = 5000);  
ALTER TABLE table_name SET (autovacuum_analyze_scale_factor = 0.0);  
ALTER TABLE table_name SET (autovacuum_analyze_threshold = 5000);  
--
You can check the last time your tables were vacuumed and analyzed with the query below. In our case, we had tables that hadn’t been cleaned up in weeks.

SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze  
FROM pg_stat_all_tables  
WHERE schemaname = 'public';  
To prevent our tables from continually getting messy in the future and having to manually VACUUM ANALYZE, we made the default auto-vacuum settings stricter. Postgres runs a daemon to regularly vacuum and analyze itself. Tables are auto-vacuumed when 20% of the rows plus 50 rows are inserted, updated or deleted, and auto-analyzed similarly at 10%, and 50 row thresholds. These settings work fine for smaller tables, but as a table grows to have millions of rows, there can be tens of thousands of inserts or updates before the table is vacuumed and analyzed.

In our case, we set much more aggressive thresholds for our largest tables, using the commands below. With these settings, a table is vacuumed and analyzed after 5,000 inserts, updates, or deletes.

ALTER TABLE table_name  
SET (autovacuum_vacuum_scale_factor = 0.0);

ALTER TABLE table_name  
SET (autovacuum_vacuum_threshold = 5000);

ALTER TABLE table_name  
SET (autovacuum_analyze_scale_factor = 0.0);

ALTER TABLE table_name  
SET (autovacuum_vacuum_threshold = 5000);  


*/