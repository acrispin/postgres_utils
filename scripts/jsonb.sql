
select '{"a":"abc","d":"def","z":[1,2,3]}'::jsonb;

select '{"a":"abc","d":"def","z":[1,2,3],"d":"overwritten"}'::json;

select '{"a":"abc","d":"def","z":[1,2,3],"d":"overwritten"}'::jsonb;

select pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::jsonb);

select pg_column_size('{"a":"abc","d":"def","z":[1,2,3]}'::json);

select '{"a":1, "b":2}'::jsonb = '{"b":2, "a":1}'::jsonb;

create table test (data jsonb);

CREATE INDEX ix_test_01 ON test using gin (data);

explain analyze select * from test where data ? 'r';

explain analyze select * from test where data @> '{"i":150}';

explain analyze select * from test where data @> '{"i":150, "r":4}';

CREATE INDEX ix_test_02 ON test ((data->'a'));