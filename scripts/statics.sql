

SELECT pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::jsonb);

SELECT pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::json);

SELECT pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::text);

SELECT pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::varchar(50));

SELECT pg_column_size(2);

SELECT pg_column_size(2.00);

SELECT pg_column_size(5::smallint);

SELECT pg_column_size(5::int);

SELECT pg_column_size(NOW());

SELECT pg_column_size((1::integer, 2::smallint));

SELECT pg_column_size(1::integer) + pg_column_size(2::smallint) AS pg_column_size;

SELECT pg_column_size((1::smallint, 2::integer));

SELECT pg_column_size((1::smallint, FALSE, FALSE, 2::integer));

SELECT pg_column_size((NULL::smallint, 2::integer));

SELECT pg_column_size(NULL::smallint) +  pg_column_size(2::integer) AS pg_column_size;

SELECT pg_relation_size('public.mar');

SELECT pg_total_relation_size('public.mar');

SELECT pg_database_size('casa23_db');

SELECT pg_size_pretty(40960::bigint);

SELECT pg_size_pretty(pg_database_size('casa23_db'));

SELECT pg_total_relation_size('public.ven') = pg_table_size('public.ven') + pg_indexes_size('public.ven');

SELECT pg_size_pretty(pg_total_relation_size('public.ven')), pg_size_pretty(pg_total_relation_size('public.dven'));

SELECT pg_size_pretty(pg_table_size ('public.ven')), pg_size_pretty(pg_indexes_size ('public.ven')),
       pg_size_pretty(pg_table_size ('public.dven')), pg_size_pretty(pg_indexes_size ('public.dven'));

SELECT pg_size_pretty(pg_database_size('dbname')), pg_database_size('dbname');