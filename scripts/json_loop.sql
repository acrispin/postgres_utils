
-- loop in json object
/*
fuentes:
http://withouttheloop.com/articles/2014-09-30-postgresql-nosql/
http://www.depesz.com/2014/03/25/waiting-for-9-4-introduce-jsonb-a-structured-format-for-storing-json/
http://clarkdave.net/2015/03/navigating-null-safety-with-json-and-postgresql/
https://chawlasumit.wordpress.com/2014/07/29/parsing-json-array-in-postgres-plpgsql-foreach-expression-must-yield-an-array-not-type-text/
http://andyfiedler.com/blog/querying-inside-postgres-json-arrays-260/
http://stackoverflow.com/questions/20272650/how-to-loop-over-json-arrays-in-postgresql-9-3
*/

-- 
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
$BODY$ language plpgsql;




-- 
DO
$BODY$
DECLARE
    -- omgjson json := '[{ "type": false }, { "type": "photo" }, {"type": "comment" }]';
    omgjson json := '[{"cum_date":"1979-03-13","nom":"Pablo","ocu":null,"est_civ":null,"celu":null,"dni":"00154874","id":12,"fijo":null,"sex":null,"email2":null,"email":"pmedina@hotmail.com","ape":"Medina"}]';
    omgjson2 json := '{"cum_date":"1979-03-13","nom":"Pablo","ocu":null,"est_civ":null,"celu":null,"dni":"00154874","id":12,"fijo":null,"sex":null,"email2":null,"email":"pmedina@hotmail.com","ape":"Medina"}';
    i json;
BEGIN
    RAISE NOTICE 'sss %', omgjson2->>'id';
  FOR i IN SELECT * FROM json_array_elements(omgjson)
  LOOP
    RAISE NOTICE 'output from space %', i->>'id';
    RAISE NOTICE 'output from space %', i->>'nom';
    RAISE NOTICE 'output from space %', i->>'ape';
    RAISE NOTICE 'output from space %', i->>'dni';
    RAISE NOTICE 'output from space %', i->>'email';
    RAISE NOTICE 'output from space %', i->>'email2';
    RAISE NOTICE 'output from space %', i->>'celu';
    RAISE NOTICE 'output from space %', i->>'fijo';
    RAISE NOTICE 'output from space %', i->>'ocu';
    RAISE NOTICE 'output from space %', i->>'sex';
    RAISE NOTICE 'output from space %', i->>'est_civ';
    RAISE NOTICE 'output from space %', i->>'cum_date';
  END LOOP;
END;
$BODY$ language plpgsql;




--
CREATE OR REPLACE FUNCTION parse_json () 
RETURNS VOID
AS $$
  DECLARE json_object json;
  DECLARE item json;
  BEGIN
    SELECT ('{ "Name":"My Name", "Items" :[{ "Id" : 1, "Name" : "Name 1"}, { "Id" : 2, "Name 2" : "Item2 Name"}]}')::json into json_object;
    RAISE NOTICE 'Parsing %', json_object->>'Name';
    --FOR item IN SELECT * FROM json_array_elements((json_object->>'Items')::json)
    FOR item IN SELECT * FROM json_array_elements((json_object->'Items'))
    LOOP
       RAISE NOTICE 'Parsing Item % %', item->>'Id', item->>'Name';
    END LOOP;
  END;
  $$ LANGUAGE 'plpgsql';

select parse_json();




-- 
CREATE OR REPLACE FUNCTION parse_jsonb() 
RETURNS VOID
AS $$
  DECLARE json_object jsonb;
  DECLARE item jsonb;
  BEGIN
    SELECT ('{ "Name":"My Name", "Items" :[{ "Id" : 1, "Name" : "Name 1"}, { "Id" : 2, "Name 2" : "Item2 Name"}]}')::jsonb into json_object;
    RAISE NOTICE 'Parsing %', json_object->>'Name';
    FOR item IN SELECT * FROM jsonb_array_elements((json_object->>'Items')::jsonb)
    LOOP
       RAISE NOTICE 'Parsing Item % %', item->>'Id', item->>'Name';
    END LOOP;
  END;
  $$ LANGUAGE 'plpgsql';
  
select parse_jsonb();




-----------------------------------------------------------
/* data en tabla orders
    
// Row 1, "json_field" column -----
{
   "products": [
      { "id": 1, "name": "Fish Tank" },
      { "id": 2, "name": "Bird Feeder" }
   ]
}

// Row 2, "json_field" column -----
{
   "products": [
      { "id": 2, "name": "Bird Feeder" },
      { "id": 3, "name": "Cat Pole" }
   ]
}

*/
-- 
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
    FOR rec IN SELECT json_array_elements#>path FROM json_array_elements(json_arr)
    LOOP
        ret := array_append(ret,rec);
    END LOOP;
    RETURN ret;
END $$;

-- uso
SELECT DISTINCT unnest(json_array_map(orders.json_field#>'{products}', '{id}'::text[]))::text AS "id" FROM orders;
