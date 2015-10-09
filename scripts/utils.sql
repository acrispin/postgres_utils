
----------------------------------------------------------------------
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

-- loop de json
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

-- loop de json
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
$BODY$ language plpgsql

-- validacion de llaves en el json
DO
$BODY$
DECLARE
    v_id int := 0;
    cad json := '{"cum_date":"1979-03-13","nom":"Pablo","ocu":"c","est_civ":null,"celu":null,"dni":"00154874","id":678,"fijo":null,"sex":null,"email2":null,"email":"pmedina@hotmail.com","ape":"Medina"}';
BEGIN
    RAISE NOTICE 'id: %', cad->>'id';
    if (cad->'id') is null or coalesce(cad->>'id','') = '' then
        RAISE NOTICE 'BAD';
    else
        RAISE NOTICE 'OK';
    end if;
    v_id = cad->>'id';
    RAISE NOTICE 'v_id: %', v_id;
END;
$BODY$ language plpgsql


-- verificacion de codigo
DO
$BODY$
DECLARE
    v_count INT = 0;
    v_dni VARCHAR(50) = '87321050';
BEGIN
    select count(id) into v_count from cli
    where dni = v_dni;
    RAISE NOTICE 'v_count: %', v_count;
END;
$BODY$ language plpgsql




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


CREATE OR REPLACE FUNCTION parse_json () 
RETURNS VOID
AS $$
  DECLARE json_object json;
  DECLARE item json;
  BEGIN
    SELECT ('{ "Name":"My Name", "Items" :[{ "Id" : 1, "Name" : "Name 1"}, { "Id" : 2, "Name 2" : "Item2 Name"}]}')::json into json_object;
    RAISE NOTICE 'Parsing %', json_object->>'Name';
    FOR item IN SELECT * FROM json_array_elements((json_object->>'Items')::json)
    LOOP
       RAISE NOTICE 'Parsing Item % %', item->>'Id', item->>'Name';
    END LOOP;
  END;
  $$ LANGUAGE 'plpgsql';
  
select parse_json();




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







----------------------------------------------------------------------
-- generar json desde postgres de proyecto decortinas
/*
fuentes
http://hashrocket.com/blog/posts/faster-json-generation-with-postgresql
*/


select row_to_json(mtr) from mtr ;


select row_to_json(t)
from (
  select cod, anc, alt, pri from mtr limit 1
) t;


select array_to_json(array_agg(row_to_json(t)))
    from (
      select cod, anc, alt, pri from mtr
    ) t;
    

select array_to_json(array_agg(t))
    from (
      select cod, anc, alt, pri from mtr
    ) t;    


SELECT ARRAY_TO_JSON(ARRAY_AGG(t))
FROM (
SELECT id, nom, col_id
              FROM clr
              WHERE act 
              
) T;              


SELECT ARRAY_TO_JSON(ARRAY_AGG(t))::TEXT
FROM (
SELECT id, nom, col_id
              FROM clr
              WHERE act 
              
) T;          



SELECT COALESCE(ARRAY_TO_JSON(ARRAY_AGG(T))::TEXT,'[]')
-- SELECT ARRAY_TO_JSON(ARRAY_AGG(T))::TEXT
FROM (
    SELECT id, nom, col_id
    FROM clr
    WHERE NOT act 
) T; 


-- 0002
SELECT ROW_TO_JSON(t)::TEXT
FROM (
    SELECT id, 
           mar_id, 
           nom,
           (SELECT COALESCE(ARRAY_TO_JSON(ARRAY_AGG(c)),'[]')
            FROM (
                SELECT id, nom
                FROM col
                WHERE lin_id = lin.id
             ) c) AS cols,
            (SELECT COALESCE(ARRAY_TO_JSON(ARRAY_AGG(a)),'[]')
             FROM (
                 SELECT id, nom
                 FROM acn
                 WHERE lin_id = lin.id
             ) a) AS acns
    FROM lin
    WHERE id = 'LUMI'
) t

-- json output for 0002
/*
{
  "id": "LUMI",
  "mar_id": "DEC",
  "nom": "LUMINETTE",
  "cols": [
    {
      "id": "ARGL",
      "nom": "Argelia"
    },
    {
      "id": "CORD",
      "nom": "Cordico"
    }
  ],
  "acns": [
    {
      "id": "Q118",
      "nom": "Accionamiento Q118"
    },
    {
      "id": "Q117",
      "nom": "Accionamiento Q117"
    },
    {
      "id": "Q116",
      "nom": "Accionamiento Q116"
    }
  ]
}
*/


-- json types
select '[1,2,3]'::json->2; -- retorna tipo json
select '[1,2,3]'::json->>2 -- retorna tipo text
select '{"a":1,"b":2}'::json->'b'; -- retorna tipo json
select '{"a":1,"b":2}'::json->>'b'; -- retorna tipo text
select coalesce('{"a":1,"b":2}'::json->'c','0');
select coalesce('{"a":1,"b":2}'::json->>'c','0');
select json_array_length('[1,2]');


-- dates
-- http://www.postgresql.org/docs/9.4/static/functions-formatting.html
select TO_CHAR(NOW(), 'YYYY-mm-dd');
select TO_CHAR(NOW(), 'dd/mm/YYYY');
select TO_CHAR(NOW(), 'dd/mm/YYYY HH24:MI:SS:MS');
select TO_CHAR(NOW(), 'dd/mm/YYYY HH24:MI AM'); -- indicador de meridiano, setea AM o PM segun la hora y no la del formato inicado, se puede poner cualquiera de los 2
select TO_CHAR(NOW(), 'dd/mm/YYYY HH12:MI AM');
select TO_CHAR(NOW(), 'dd/mm/YYYY HH12:MI PM');



-- operaciones con fechas
-- http://www.postgresql.org/docs/9.4/static/functions-datetime.html
select date '2001-09-28' + integer '7';
select date '2001-09-28' - interval '1 hour'; -- genera un timestamp
select date '2001-10-01' - date '2001-09-28';
select now() + interval '1 day';
select now() - interval '30 days';
select now() + interval '1 hour';
select now() - interval '1 hour';
select now() + interval '22 hours';
select now() + interval '1 month';
select now() + interval '1 year';
select timestamp '2001-09-28 01:00' + interval '23 hours';

-- obtener date de un timestamp
select now()::date;
select date(now());
select (now() - interval '20 year')::date;
select date(now() - interval '20 year');



-- para manejar funciones de insert, update y delete y que retornen un result generico
CREATE TYPE result_type AS (rs INT, msg TEXT, id INT); 

CREATE OR REPLACE FUNCTION fn_test_rs()
   RETURNS SETOF result_type
AS $$
DECLARE
  v_rec result_type;
  v_rs INT = -1;
  v_msg TEXT = 'OK';
  v_id INT = 0;
BEGIN
  -- SELECT 0, 'OK', 0 INTO v_rec;
  -- SELECT 0, 'OK' INTO v_rec;
  SELECT v_rs, v_msg, v_id INTO v_rec;
  RETURN NEXT v_rec;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

select * from fn_test_rs();
select rs, msg from fn_test_rs();

SELECT ROW_TO_JSON(T)
FROM (
    select * from fn_test_rs()
) T; 


-- json para cotizacion

/*

{
  "username": "vendedor",
  "cot": {
    "cli_id": 10,
    "total": 287,
    "rate": 3.2504,
    "cot_date": "2015-10-08",
    "token": "01359100632047720151008053545"
  },
  "dcot": [
    {
      "mar_id": "DEC",
      "acn_id": "Q34",
      "col_id": "MORO",
      "anc": 900,
      "alt": 1200,
      "clr_id": 100,
      "mtr_cost": 64,
      "acc_cost": 0,
      "total": 64,
      "acot": []
    },
    {
      "mar_id": "DEC",
      "acn_id": "Q40",
      "col_id": "WABO",
      "anc": 800,
      "alt": 1000,
      "clr_id": 91,
      "mtr_cost": 86,
      "acc_cost": 0,
      "total": 86,
      "acot": []
    },
    {
      "mar_id": "DEC",
      "acn_id": "Q53",
      "col_id": "MORO",
      "anc": 700,
      "alt": 1200,
      "clr_id": 91,
      "mtr_cost": 79,
      "acc_cost": 58,
      "total": 137,
      "acot": [
        {
          "acc_id": 4,
          "pri": 40
        },
        {
          "acc_id": 27,
          "pri": 18
        }
      ]
    }
  ]
}


{"username":"vendedor","cot":{"cli_id":3,"total":287,"rate":3.2504,"cot_date":"2015-10-08","token":"01359100632047720151008053545"},"dcot":[{"mar_id":"DEC","acn_id":"Q34","col_id":"MORO","anc":900,"alt":1200,"clr_id":100,"mtr_cost":64,"acc_cost":0,"total":64,"acot":[]},{"mar_id":"DEC","acn_id":"Q40","col_id":"WABO","anc":800,"alt":1000,"clr_id":91,"mtr_cost":86,"acc_cost":0,"total":86,"acot":[]},{"mar_id":"DEC","acn_id":"Q53","col_id":"MORO","anc":700,"alt":1200,"clr_id":91,"mtr_cost":79,"acc_cost":58,"total":137,"acot":[{"acc_id":4,"pri":40},{"acc_id":27,"pri":18}]}]}

*/


-- bloque para trabajar la creacion de cotizacion
DO
$BODY$
DECLARE
    v_id int := 0;
    item json;
    ditem json;
    cad json := '{"username":"vendedor","cot":{"cli_id":3,"total":287,"rate":3.2504,"cot_date":"2015-10-08"},"dcot":[{"mar_id":"DEC","acn_id":"Q34","col_id":"MORO","anc":900,"alt":1200,"clr_id":100,"mtr_cost":64,"acc_cost":0,"total":64,"acot":[]},{"mar_id":"DEC","acn_id":"Q40","col_id":"WABO","anc":800,"alt":1000,"clr_id":91,"mtr_cost":86,"acc_cost":0,"total":86,"acot":[]},{"mar_id":"DEC","acn_id":"Q53","col_id":"MORO","anc":700,"alt":1200,"clr_id":91,"mtr_cost":79,"acc_cost":58,"total":137,"acot":[{"acc_id":4,"pri":40},{"acc_id":27,"pri":18}]}]}';
BEGIN
    RAISE NOTICE 'username: %', cad->>'username';
    --RAISE NOTICE 'cot: %', cad->>'cot'; -- obtiene como texto
    RAISE NOTICE 'cot: %', cad->'cot'; -- obtiene como json
    RAISE NOTICE 'cli_id: %', cad->'cot'->>'cli_id';
    RAISE NOTICE 'total: %', cad->'cot'->>'total';
    RAISE NOTICE 'rate: %', cad->'cot'->>'rate';
    RAISE NOTICE 'cot_date: %', cad->'cot'->>'cot_date';    
    RAISE NOTICE 'dcot: %', cad->'dcot';
    RAISE NOTICE '';
    FOR item IN SELECT * FROM json_array_elements(cad->'dcot')
    LOOP
        RAISE NOTICE '--------------------------';
        RAISE NOTICE 'mar_id: %', item->>'mar_id';
        RAISE NOTICE 'acn_id: %', item->>'acn_id';
        RAISE NOTICE 'col_id: %', item->>'col_id';
        RAISE NOTICE 'anc: %', item->>'anc';
        RAISE NOTICE 'alt: %', item->>'alt';
        RAISE NOTICE 'clr_id: %', item->>'clr_id';
        RAISE NOTICE 'mtr_cost: %', item->>'mtr_cost';
        RAISE NOTICE 'acc_cost: %', item->>'acc_cost';
        RAISE NOTICE 'total: %', item->>'total';
        RAISE NOTICE 'acot: %', item->'acot';
        IF (item->'acot') IS NULL OR json_array_length(item->'acot') = 0 THEN
            RAISE NOTICE 'Sin accesorios';
        ELSE
            RAISE NOTICE 'OK';
            FOR ditem IN SELECT * FROM json_array_elements(item->'acot')
            LOOP
                RAISE NOTICE '*****************************';
                RAISE NOTICE 'acc_id: %', ditem->>'acc_id';
                RAISE NOTICE 'pri: %', ditem->>'pri';
            END LOOP;
        END IF;
    END LOOP;    
    
END;
$BODY$ language plpgsql

-- con jsonb
DO
$BODY$
DECLARE
    v_id int := 0;
    item jsonb;
    ditem jsonb;
    cad jsonb := '{"username":"vendedor","cot":{"cli_id":3,"total":287,"rate":3.2504,"cot_date":"2015-10-08"},"dcot":[{"mar_id":"DEC","acn_id":"Q34","col_id":"MORO","anc":900,"alt":1200,"clr_id":100,"mtr_cost":64,"acc_cost":0,"total":64,"acot":[]},{"mar_id":"DEC","acn_id":"Q40","col_id":"WABO","anc":800,"alt":1000,"clr_id":91,"mtr_cost":86,"acc_cost":0,"total":86,"acot":[]},{"mar_id":"DEC","acn_id":"Q53","col_id":"MORO","anc":700,"alt":1200,"clr_id":91,"mtr_cost":79,"acc_cost":58,"total":137,"acot":[{"acc_id":4,"pri":40},{"acc_id":27,"pri":18}]}]}';
BEGIN
    RAISE NOTICE 'username: %', cad->>'username';
    --RAISE NOTICE 'cot: %', cad->>'cot'; -- obtiene como texto
    RAISE NOTICE 'cot: %', cad->'cot'; -- obtiene como json
    RAISE NOTICE 'cli_id: %', cad->'cot'->>'cli_id';
    RAISE NOTICE 'total: %', cad->'cot'->>'total';
    RAISE NOTICE 'rate: %', cad->'cot'->>'rate';
    RAISE NOTICE 'cot_date: %', cad->'cot'->>'cot_date';    
    RAISE NOTICE 'dcot: %', cad->'dcot';
    RAISE NOTICE '';
    FOR item IN SELECT * FROM jsonb_array_elements(cad->'dcot')
    LOOP
        RAISE NOTICE '--------------------------';
        RAISE NOTICE 'mar_id: %', item->>'mar_id';
        RAISE NOTICE 'acn_id: %', item->>'acn_id';
        RAISE NOTICE 'col_id: %', item->>'col_id';
        RAISE NOTICE 'anc: %', item->>'anc';
        RAISE NOTICE 'alt: %', item->>'alt';
        RAISE NOTICE 'clr_id: %', item->>'clr_id';
        RAISE NOTICE 'mtr_cost: %', item->>'mtr_cost';
        RAISE NOTICE 'acc_cost: %', item->>'acc_cost';
        RAISE NOTICE 'total: %', item->>'total';
        RAISE NOTICE 'acot: %', item->'acot';
        IF (item->'acot') IS NULL OR jsonb_array_length(item->'acot') = 0 THEN
            RAISE NOTICE 'Sin accesorios';
        ELSE
            RAISE NOTICE 'OK';
            FOR ditem IN SELECT * FROM jsonb_array_elements(item->'acot')
            LOOP
                RAISE NOTICE '*****************************';
                RAISE NOTICE 'acc_id: %', ditem->>'acc_id';
                RAISE NOTICE 'pri: %', ditem->>'pri';
            END LOOP;
        END IF;
    END LOOP;    
    
END;
$BODY$ language plpgsql


