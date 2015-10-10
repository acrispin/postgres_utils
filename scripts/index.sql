

-- indexs
-- http://blog.endpoint.com/2013/06/postgresql-functional-indexes.html
-- https://devcenter.heroku.com/articles/postgresql-indexes#expression-indexes

-- normal index
CREATE INDEX i_test ON test (i);
SELECT * FROM test WHERE i < 100 ORDER BY i;

-- Functional Indexes
CREATE INDEX i_test_lower_i ON test (lower(i));
SELECT * FROM test WHERE lower(i) = 'aaa';

-- ejemplo
CREATE TABLE test(t timestamp);
-- generacion de data automaticamente
INSERT INTO test(t) SELECT generate_series(now() - '1 year'::interval, now(), '1 minute'); -- Query returned successfully: 525601 rows affected, 1631 ms execution time.

-- I can get the rows with dates from the last 10 days like
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date;
/*
"Seq Scan on test  (cost=0.00..14152.02 rows=175200 width=8) (actual time=357.041..367.095 rows=13996 loops=1)"
"  Filter: ((t)::date > ((now() - '10 days'::interval))::date)"
"  Rows Removed by Filter: 511605"
"Planning time: 0.127 ms"
"Execution time: 367.627 ms"
*/

-- create index
CREATE INDEX i_test_t ON test((t::date));
-- CREATE INDEX i_test_t ON test(date(t));

-- probando de nuevo el query anterior
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date;
/*
"Bitmap Heap Scan on test  (cost=3286.24..9554.24 rows=175200 width=8) (actual time=3.056..6.426 rows=13996 loops=1)"
"  Recheck Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"  Heap Blocks: exact=63"
"  ->  Bitmap Index Scan on i_test_t  (cost=0.00..3242.44 rows=175200 width=0) (actual time=3.024..3.024 rows=13996 loops=1)"
"        Index Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"Planning time: 0.430 ms"
"Execution time: 7.583 ms"

*/

-- This index will also be used when you want to sort the results using the same values as stored in index:
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date order by t::date asc;
/*
"Index Scan using i_test_t on test  (cost=0.43..14736.43 rows=175200 width=8) (actual time=0.031..9.244 rows=13996 loops=1)"
"  Index Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"Planning time: 0.208 ms"
"Execution time: 10.957 ms"
*/

-- desendentemente
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date order by t::date desc;
/*
"Index Scan Backward using i_test_t on test  (cost=0.43..14736.43 rows=175200 width=8) (actual time=0.090..8.222 rows=13996 loops=1)"
"  Index Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"Planning time: 0.173 ms"
"Execution time: 9.662 ms"
*/


-- extract year
SELECT extract( year from '2013-01-01'::date);
SELECT extract( year from now());

-- usando con la tabla test
select t from test where extract(year from t) = extract(year from now());

-- check the plan
explain analyze select t from test where extract(year from t) = extract(year from now());
/*
"Seq Scan on test  (cost=0.00..12838.02 rows=2628 width=8) (actual time=66.633..302.851 rows=407116 loops=1)"
"  Filter: (date_part('year'::text, t) = date_part('year'::text, now()))"
"  Rows Removed by Filter: 118485"
"Planning time: 0.111 ms"
"Execution time: 316.618 ms"
*/

-- creando index para extract year
CREATE INDEX i_test_t_year ON test (extract(year from t));

-- probando otra vez el plan
explain analyze select t from test where extract(year from t) = extract(year from now());
/*
"Bitmap Heap Scan on test  (cost=52.80..2542.04 rows=2628 width=8) (actual time=46.452..88.059 rows=407116 loops=1)"
"  Recheck Cond: (date_part('year'::text, t) = date_part('year'::text, now()))"
"  Heap Blocks: exact=1802"
"  ->  Bitmap Index Scan on i_test_t_year  (cost=0.00..52.14 rows=2628 width=0) (actual time=46.091..46.091 rows=407116 loops=1)"
"        Index Cond: (date_part('year'::text, t) = date_part('year'::text, now()))"
"Planning time: 0.182 ms"
"Execution time: 101.555 ms"
*/


-- uso de generate_series
-- http://www.postgresql.org/docs/9.4/static/functions-srf.html
SELECT * FROM generate_series(2,4);
SELECT * FROM generate_series(5,1,-2);
SELECT * FROM generate_series(4,3);
SELECT current_date + s.a AS dates FROM generate_series(0,14,7) AS s(a);
SELECT * FROM generate_series('2008-03-01 00:00'::timestamp, '2008-03-04 12:00', '10 hours');
SELECT generate_series(now() - '1 year'::interval, now(), '1 month')

