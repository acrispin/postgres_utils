-- https://gist.github.com/acrispin/aeb51a6611d5268b9f8a8734f5afc506

-- DROP TABLE test;
-- CREATE TABLE test(i BIGSERIAL NOT NULL, t TIMESTAMP WITH TIME ZONE DEFAULT TIMEOFDAY()::TIMESTAMPTZ NOT NULL);

-- INSERT INTO test(t) SELECT generate_series(now() - '4 year'::interval, now(), '5 minute'); 

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





-- cambiar el timezone
-- verificar el timezone
SHOW timezone;

select current_timestamp - current_timestamp AT TIME ZONE 'UTC' As TimeZoneOffSet;

-- segun el resultado que se obtiene en el query anterior, ejm : '-05:00:00'
select * from pg_timezone_names where utc_offset = '-05:00:00';
select * from pg_timezone_names where name like '%America/Lima%';

-- cambiar el timezone y volver a conectarse para verificar el cambio
ALTER DATABASE db_name SET timezone TO 'America/Lima';
