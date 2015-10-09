
-- JSON
-- http://www.postgresql.org/docs/9.3/static/functions-json.html

-- Get JSON array element
select '[1,2,3]'::json->2 as val;

-- Get JSON object field
select '{"a":1,"b":2}'::json->'b' as val;

-- Get JSON array element as text
select '[1,2,3]'::json->>2 as val;

-- Get JSON object field as text
select '{"a":1,"b":223}'::json->>'b' as val;

-- Get JSON object at specified path
select '{"a":[1,2,3],"b":[4,5,6]}'::json #>'{a,2}' as val;

-- Get JSON object at specified path as text
select '{"a":[1,2,3],"b":[4,5,6]}'::json #>>'{a,2}' as val;

select * from json_each('{"a":"foo", "b":"bar"}');

select * from json_each_text('{"a":"foo", "b":"bar"}');

CREATE TYPE aat AS (a int, b text);

select * from json_populate_record(null::aat, '{"a":1,"b":2}');
select * from json_populate_recordset(null::aat, '[{"a":1,"b":2},{"a":3,"b":4}]');



-- json types
select '[1,2,3]'::json->2; -- retorna tipo json
select '[1,2,3]'::json->>2 -- retorna tipo text
select '{"a":1,"b":2}'::json->'b'; -- retorna tipo json
select '{"a":1,"b":2}'::json->>'b'; -- retorna tipo text
select coalesce('{"a":1,"b":2}'::json->'c','0');
select coalesce('{"a":1,"b":2}'::json->>'c','0');
select json_array_length('[1,2]');




-- http://michael.otacoo.com/postgresql-2/postgres-9-3-feature-highlight-json-parsing-functions/
DO LANGUAGE plpgsql $$
DECLARE v_json text;
BEGIN
    BEGIN 
        CREATE TEMPORARY TABLE tmp_json (
            a int,
            b json
        );
    EXCEPTION WHEN OTHERS THEN
        TRUNCATE TABLE tmp_json; 
    END;
    INSERT INTO tmp_json VALUES (1, '{"f1":1,"f2":true,"f3":"Hi I''m \"Daisy\""}');
    INSERT INTO tmp_json VALUES (2, '{"f1":2,"f2":false,"f3":"Hi I''m \"Dave\""}');
    INSERT INTO tmp_json VALUES (3, '{"f1":3,"f2":true,"f3":"Hi I''m \"Popo\""}');
    INSERT INTO tmp_json VALUES (4, '{"f1":{"f11":11,"f12":12},"f2":2}');
    INSERT INTO tmp_json VALUES (5, '{"f1":[1,"Robert \"M\""],"f2":[2,"Kevin \"K\"",false]}');
END
$$;

SELECT * FROM json_each((SELECT b FROM tmp_json WHERE a = 1));
SELECT * FROM json_each_text((SELECT b FROM tmp_json WHERE a = 1));
SELECT * FROM json_each((SELECT b FROM tmp_json WHERE a = 4)) WHERE key = 'f1';
SELECT * FROM json_each((SELECT b->'f1' FROM tmp_json WHERE a = 4));
SELECT json_extract_path(b, 'f1') AS f1a, b->'f1' AS f1b FROM tmp_json WHERE a = 4;
SELECT json_object_keys(b) FROM tmp_json GROUP BY 1 ORDER BY 1;
SELECT json_object_keys(b->'f1') FROM tmp_json WHERE a = 4;
-- CREATE TYPE tmp_json_type AS (f1 int, f2 bool, f3 text);
SELECT * FROM json_populate_record(null::tmp_json_type, (SELECT b FROM tmp_json WHERE a = 1)) AS popo;
SELECT * FROM json_populate_recordset(null::tmp_json_type, (SELECT json_agg(b) FROM tmp_json WHERE a < 4)) AS popo;
SELECT json_array_length(b->'f1') FROM tmp_json WHERE a = 5;
SELECT json_array_length(b->'f2') FROM tmp_json WHERE a = 5;
SELECT json_array_elements(b->'f1') FROM tmp_json WHERE a = 5;




-- http://osdir.com/ml/postgresql-pgsql-general/2014-04/msg00511.html
-- drop table t;
-- create table t(id SERIAL, cad json);
insert into t(cad) VALUES ('{"type":"show", "products": [ { "id" : 1, "name" : "p1"}] }'::json);
insert into t(cad) VALUES ('{"type":"show", "products": [ { "id" : 2, "name" : "p2" , "stock" : [ {"XL" : 1}] }] }'::json);
-- create type product as (id int, name text );
select * from t;
select rs.* from (select * from t where id=1) e   CROSS JOIN LATERAL json_populate_recordset(null::product, e.cad->'products') rs;
select rs.* from (select * from t where id=2) e   CROSS JOIN LATERAL json_populate_recordset(null::product, e.cad->'products') rs;
select rs.* from (select * from t) e   CROSS JOIN LATERAL json_populate_recordset(null::product, e.cad->'products') rs;
SELECT (p->>'id')::int AS id, p->>'name' AS name FROM (SELECT json_array_elements(cad->'products') AS p FROM t) t1;



-- loop json
-- http://stackoverflow.com/questions/20272650/how-to-loop-over-json-arrays-in-postgresql-9-3
DO
$BODY$
DECLARE
    omgjson json := '[{ "type": false }, { "type": "photo" }, {"type": "comment" }]';
    i json;
BEGIN
  FOR i IN SELECT * FROM json_array_elements(omgjson)
  LOOP
    RAISE NOTICE 'output from space %', i->>'type';
  END LOOP;
END;
$BODY$ language plpgsql



-- https://chawlasumit.wordpress.com/2014/07/29/parsing-json-array-in-postgres-plpgsql-foreach-expression-must-yield-an-array-not-type-text/
CREATE OR REPLACE FUNCTION parse_json () 
RETURNS VOID
AS $$
  DECLARE json_object json;
  DECLARE item json;
  BEGIN
    SELECT ('{ "Name":"My Name", "Items" :[{ "Id" : 1, "Name" : "Name 1"}, { "Id" : 2, "Name" : "Item2 Name"}]}')::json into json_object;
    RAISE NOTICE 'Parsing %', json_object->>'Name';
    FOR item IN SELECT * FROM json_array_elements((json_object->>'Items')::json)
    LOOP
       RAISE NOTICE 'Parsing Item Id: % - Name: %', item->>'Id', item->>'Name';
    END LOOP;
  END;
  $$ LANGUAGE 'plpgsql';
select parse_json();



-- http://andyfiedler.com/blog/querying-inside-postgres-json-arrays-260/
DROP TABLE orders;
CREATE TABLE orders (json_field JSON);
INSERT INTO orders VALUES('{"products":[{"id":1,"name":"Fish Tank"},{"id":2,"name":"Bird Feeder"}]}');
INSERT INTO orders VALUES('{"products":[{"id":2,"name":"Bird Feeder"},{"id":3,"name":"Cat Pole"}]}');

SELECT * FROM orders;

CREATE OR REPLACE FUNCTION json_array_map(json_arr json, path TEXT[]) RETURNS json[]
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    rec json;
    len int;
    ret json[];
BEGIN
    -- If json_arr is not an array, return an empty array as the result
    BEGIN
        len := json_array_length(json_arr);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN ret;
    END;
 
    -- Apply mapping in a loop
    FOR rec IN SELECT json_array_elements #> path FROM json_array_elements(json_arr)
    LOOP
        ret := array_append(ret,rec);
    END LOOP;
    RETURN ret;
END $$;

SELECT DISTINCT unnest(json_array_map(orders.json_field #> '{products}', '{id}'::text[]))::text AS "id" FROM orders;




-- http://clarkdave.net/2015/03/navigating-null-safety-with-json-and-postgresql/
DROP TABLE books;
CREATE TABLE books (id int, author json);
INSERT INTO books VALUES (1, null),
  (2, '{ "first_name": "Mary" }'),
  (3, '{ "address": { "street_name": "19 Red Avenue" } }'),
  (4, '{ "address": null }');

SELECT author->'address'->'street_name' AS Street FROM books where id = 1;
SELECT author->'address'->'street_name' AS Street FROM books where id = 2;
SELECT author->'address'->'street_name' AS Street FROM books where id = 3;
SELECT author->'address'->'street_name' AS Street FROM books where id = 4;

SELECT id,
  coalesce(
    case
      when (author->>'address') IS NULL then null
      else (author->'address'->>'street_name')
    end,
  'No street name') AS author_street_name
FROM books
WHERE id = 4;

CREATE OR REPLACE FUNCTION json_fetch(object json, variadic nodes text[])
RETURNS json AS $$
DECLARE
  result json := object;
  k text;
BEGIN
  foreach k in array nodes loop
    if (result ->> k) is null then
      result := null;
      exit;
    end if;

    result := result -> k;
  end loop;

  return result;
END;
$$ LANGUAGE plpgsql;

SELECT id,
  coalesce(
    json_fetch(author, 'address', 'street_name')::text, 'No address'
  ) AS street_name
FROM books;



-- http://clarkdave.net/2013/06/what-can-you-do-with-postgresql-and-json/

DROP TABLE books;
CREATE TABLE books ( id integer, data json );

INSERT INTO books VALUES (1,
  '{ "name": "Book the First", "author": { "first_name": "Bob", "last_name": "White" } }');
INSERT INTO books VALUES (2,
  '{ "name": "Book the Second", "author": { "first_name": "Charles", "last_name": "Xavier" } }');
INSERT INTO books VALUES (3,
  '{ "name": "Book the Third", "author": { "first_name": "Jim", "last_name": "Brown" } }');

-- You can use the JSON operators to pull values out of JSON columns:
SELECT id, data->>'name' AS name FROM books;
-- The -> operator returns the original JSON type (which might be an object), whereas ->> returns text. You can use the -> to return a nested object and thus chain the operators:
SELECT id, data->'author'->>'first_name' as author_first_name FROM books;
-- Of course, you can also select rows based on a value inside your JSON:
SELECT * FROM books WHERE data->>'name' = 'Book the First';
-- You can also find rows based on the value of a nested JSON object:
SELECT * FROM books WHERE data->'author'->>'first_name' = 'Charles';
-- You can add indexes on any of these using PostgreSQL’s expression indexes, which means you can even add unique constraints based on your nested JSON data:
CREATE UNIQUE INDEX books_author_first_name ON books ((data->'author'->>'first_name'));
-- debe lanzar error por unique key
INSERT INTO books VALUES (4,'{ "name": "Book the Fourth", "author": { "first_name": "Charles", "last_name": "Davis" } }');


CREATE TABLE events (
  name varchar(200),
  visitor_id varchar(200),
  properties json,
  browser json
);

INSERT INTO events VALUES (
  'pageview', '1',
  '{ "page": "/" }',
  '{ "name": "Chrome", "os": "Mac", "resolution": { "x": 1440, "y": 900 } }'
);
INSERT INTO events VALUES (
  'pageview', '2',
  '{ "page": "/" }',
  '{ "name": "Firefox", "os": "Windows", "resolution": { "x": 1920, "y": 1200 } }'
);
INSERT INTO events VALUES (
  'pageview', '1',
  '{ "page": "/account" }',
  '{ "name": "Chrome", "os": "Mac", "resolution": { "x": 1440, "y": 900 } }'
);
INSERT INTO events VALUES (
  'purchase', '5',
  '{ "amount": 10 }',
  '{ "name": "Firefox", "os": "Windows", "resolution": { "x": 1024, "y": 768 } }'
);
INSERT INTO events VALUES (
  'purchase', '15',
  '{ "amount": 200 }',
  '{ "name": "Firefox", "os": "Windows", "resolution": { "x": 1280, "y": 800 } }'
);
INSERT INTO events VALUES (
  'purchase', '15',
  '{ "amount": 500 }',
  '{ "name": "Firefox", "os": "Windows", "resolution": { "x": 1280, "y": 800 } }'
);

SELECT browser->>'name' AS browser, count(browser)
FROM events
GROUP BY browser->>'name';

SELECT visitor_id, SUM(CAST(properties->>'amount' AS integer)) AS total
FROM events
WHERE CAST(properties->>'amount' AS integer) > 0
GROUP BY visitor_id;

SELECT AVG(CAST(browser->'resolution'->>'x' AS integer)) AS width,
  AVG(CAST(browser->'resolution'->>'y' AS integer)) AS height
FROM events;

-----------------------------------------------------------------------------------------------

-- create table person
create table test ( data json NOT NULL );

-- create index
CREATE UNIQUE INDEX ux_test_01 ON test ((data->>'_id'));

-- query ejemplo
select data from test where data->>'_id' = 'A158CCB9-BB68-4FC2-8123-79B32053B2A3';


-- manejar null en json
CREATE TABLE books (id int, author json);
INSERT INTO books VALUES (1, null),
  (2, '{ "first_name": "Mary" }'),
  (3, '{ "address": { "street_name": "19 Red Avenue" } }'),
  (4, '{ "address": null }');

SELECT author->'address'->'street_name' FROM books where id = 1;

SELECT author->'address'->'street_name' FROM books where id = 4; -- ERROR:  cannot extract element from a scalar

SELECT id,
  COALESCE(
    CASE
      WHEN (author->>'address') IS NULL THEN null
      ELSE (author->'address'->>'street_name')
    END,
  'No street name') AS author_street_name
FROM books
WHERE id = 4;

-- funcion
CREATE OR REPLACE FUNCTION json_fetch(object json, variadic nodes text[])
RETURNS json AS $$
DECLARE
  result json := object;
  k text;
BEGIN
  foreach k in array nodes loop
    if (result ->> k) is null then
      result := null;
      exit;
    end if;

    result := result -> k;
  end loop;

  return result;
END;
$$ LANGUAGE plpgsql;

-- uso
SELECT id,
  coalesce(
    json_fetch(author, 'address', 'street_name')::text, 'No address'
  ) AS street_name
FROM books;


