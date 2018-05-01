-- https://gist.github.com/acrispin/aeb51a6611d5268b9f8a8734f5afc506



/* cambiar el timezone, verificar el timezone */
SHOW timezone;
select current_timestamp - current_timestamp AT TIME ZONE 'UTC' As TimeZoneOffSet;
-- segun el resultado que se obtiene en el query anterior, ejm : '-05:00:00'
select * from pg_timezone_names where utc_offset = '-05:00:00';
select * from pg_timezone_names where name like '%America/Lima%';
-- cambiar el timezone y volver a conectarse para verificar el cambio
ALTER DATABASE db_name SET timezone TO 'America/Lima';




/* timestamp with timezone column like date index */
-- DROP TABLE IF EXISTS test;
-- CREATE TABLE test(i BIGSERIAL NOT NULL, t TIMESTAMP WITH TIME ZONE DEFAULT TIMEOFDAY()::TIMESTAMPTZ NOT NULL);
-- INSERT INTO test(t) SELECT generate_series(now() - '7 year'::interval, now(), '3 minute'); 

-- explain analyze
select * from test where date(t) between '2015-01-01' and '2015-01-15'

-- explain analyze
select * from test where date(t) = date('2015-01-01')

-- drop index ix_test_i;
-- CREATE INDEX ix_test_i ON test (i);

-- drop index ix_test_t;
-- CREATE INDEX ix_test_t ON test((t));
CREATE INDEX ix_test_t ON test(DATE(t AT TIME ZONE 'UTC'));

-- explain analyze
select * from test where DATE(TIMEZONE('UTC'::text, t)) between '2015-01-01' and '2015-01-15'

-- explain analyze
select * from test where DATE(TIMEZONE('UTC'::text, t)) = '2015-01-01'

-- explain analyze
select * from test where TIMEZONE('UTC'::text, t)::DATE = '2015-01-01'




/* timestamp with timezone column like index */
DROP TABLE IF EXISTS test2;
CREATE TABLE test2(i BIGSERIAL NOT NULL, t TIMESTAMP WITH TIME ZONE DEFAULT TIMEOFDAY()::TIMESTAMPTZ NOT NULL);
INSERT INTO test2(t) SELECT generate_series(now() - '7 year'::interval, now(), '3 minute'); 
CREATE INDEX ix_test2_t ON test2(t);
select count(1) from test2;

explain analyze
select * from test2 where t between '2015-01-15 -05:00'::TIMESTAMPTZ AND '2015-01-16 -05:00'::TIMESTAMPTZ;

explain analyze
select * from test2 where t between '2015-01-15'::TIMESTAMPTZ AND '2015-01-15'::TIMESTAMPTZ;

explain analyze
select * from test2 where t between '2015-01-15' AND '2015-01-16';

explain analyze
select * from test2 where t between '2015-01-15 -05:00' AND '2015-01-16 -05:00';

explain analyze
select * from test2 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00';

explain analyze
select * from test2 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' order by t;

explain analyze
select i, TO_CHAR(t AT TIME ZONE 'America/Lima', 'YYYY-mm-dd HH24:MI:SS') AS "date to timezone off app"
from test2 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;

explain analyze
select i, TIMEZONE('America/Lima'::text, t) AS "date to timezone off app"
from test2 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;

explain analyze
select i, TIMEZONE('America/Lima'::text, t) AS "date to timezone off app"
from test2 
where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-15 00:00:00 -05:00'::TIMESTAMPTZ + INTERVAL '1 DAY'
order by t;  



/* timestamp with timezone column like primary key */
-- CREATE TABLE test3(i BIGSERIAL NOT NULL, t TIMESTAMP WITH TIME ZONE PRIMARY KEY DEFAULT TIMEOFDAY()::TIMESTAMPTZ NOT NULL);
-- INSERT INTO test3(t) SELECT generate_series(now() - '7 year'::interval, now(), '3 minute'); 
-- select count(1) from test3;

explain analyze
select * from test3 where t between '2015-01-15 -05:00'::TIMESTAMPTZ AND '2015-01-16 -05:00'::TIMESTAMPTZ;

explain analyze
select * from test3 where t between '2015-01-15'::TIMESTAMPTZ AND '2015-01-15'::TIMESTAMPTZ;

explain analyze
select * from test3 where t between '2015-01-15' AND '2015-01-16';

explain analyze
select * from test3 where t between '2015-01-15 -05:00' AND '2015-01-16 -05:00';

explain analyze
select * from test2 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00';

explain analyze
select * from test3 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' order by t;

explain analyze
select i, TO_CHAR(t AT TIME ZONE 'America/Lima', 'YYYY-mm-dd HH24:MI:SS') AS "date to timezone off app"
from test3 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;

explain analyze
select i, TIMEZONE('America/Lima'::text, t) AS "date to timezone off app"
from test3 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;




/* timestamp with timezone column like primary key 2 */
-- CREATE TABLE test4(i BIGSERIAL NOT NULL, t TIMESTAMP WITH TIME ZONE DEFAULT TIMEOFDAY()::TIMESTAMPTZ NOT NULL, PRIMARY KEY(t, i) );
-- INSERT INTO test4(t) SELECT generate_series(now() - '7 year'::interval, now(), '3 minute'); 
-- select count(1) from test4;

explain analyze
select * from test4 where t between '2015-01-15 -05:00'::TIMESTAMPTZ AND '2015-01-16 -05:00'::TIMESTAMPTZ;

explain analyze
select * from test4 where t between '2015-01-15'::TIMESTAMPTZ AND '2015-01-15'::TIMESTAMPTZ;

explain analyze
select * from test4 where t between '2015-01-15' AND '2015-01-16';

explain analyze
select * from test4 where t between '2015-01-15 -05:00' AND '2015-01-16 -05:00';

explain analyze
select * from test4 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00';

explain analyze
select * from test4 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' order by t;

explain analyze
select i, TO_CHAR(t AT TIME ZONE 'America/Lima', 'YYYY-mm-dd HH24:MI:SS') AS "date to timezone off app"
from test4 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;

explain analyze
select i, TIMEZONE('America/Lima'::text, t) AS "date to timezone off app"
from test4 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;




/* timestamp with timezone column like index with cluster */
CREATE TABLE test5(i BIGSERIAL NOT NULL, t TIMESTAMP WITH TIME ZONE DEFAULT TIMEOFDAY()::TIMESTAMPTZ NOT NULL);
INSERT INTO test5(t) SELECT generate_series(now() - '7 year'::interval, now(), '3 minute'); 
CREATE INDEX ix_test5_t ON test5(t);
select count(1) from test5;
-- https://www.postgresql.org/docs/current/static/sql-cluster.html
-- When a table is clustered, it is physically reordered based on the index information. Clustering is a one-time operation: when the table is subsequently updated, the changes are not clustered. 
-- If one wishes, one can periodically recluster by issuing the command again
CLUSTER test5 USING ix_test5_t; 

explain analyze
select * from test5 where t between '2015-01-15 -05:00'::TIMESTAMPTZ AND '2015-01-16 -05:00'::TIMESTAMPTZ;

explain analyze
select * from test5 where t between '2015-01-15'::TIMESTAMPTZ AND '2015-01-15'::TIMESTAMPTZ;

explain analyze
select * from test5 where t between '2015-01-15' AND '2015-01-16';

explain analyze
select * from test5 where t between '2015-01-15 -05:00' AND '2015-01-16 -05:00';

explain analyze
select * from test5 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00';

explain analyze
select * from test5 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' order by t;

explain analyze
select i, TO_CHAR(t AT TIME ZONE 'America/Lima', 'YYYY-mm-dd HH24:MI:SS') AS "date to timezone off app"
from test5 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;

explain analyze
select i, TIMEZONE('America/Lima'::text, t) AS "date to timezone off app"
from test5 where t between '2015-01-15 00:00:00 -05:00' AND '2015-01-16 00:00:00 -05:00' 
order by t;
