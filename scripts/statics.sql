

select pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::jsonb);

select pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::json);

select pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::text);

select pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::varchar(50));

select pg_column_size(2);

select pg_column_size(2.00);

select pg_column_size(5::smallint);

select pg_column_size(5::int);

select pg_column_size(NOW());

SELECT pg_column_size((1::integer, 2::smallint));

SELECT pg_column_size(1::integer) + pg_column_size(2::smallint) AS pg_column_size;

SELECT pg_column_size((1::smallint, 2::integer));

SELECT pg_column_size((1::smallint, FALSE, FALSE, 2::integer));

SELECT pg_column_size((NULL::smallint, 2::integer));

SELECT pg_column_size(NULL::smallint) +  pg_column_size(2::integer) AS pg_column_size;

select pg_relation_size('public.mar');

select pg_total_relation_size('public.mar');

select pg_database_size('casa23_db');

select pg_size_pretty(40960::bigint);

select pg_size_pretty(pg_database_size('casa23_db'));
