
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




-----------------------------------------------------------
/* data
    
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
