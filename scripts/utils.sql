
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




---------------------------------------------------------------------- proyecto decortinas
-- generar json desde postgres
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

---------------------------------------------------------------------- proyecto decortinas
