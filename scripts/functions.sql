


-- http://stackoverflow.com/questions/955167/return-setof-record-virtual-table-from-function

CREATE OR REPLACE FUNCTION storeopeninghours_tostring(open_id numeric, a OUT text, b OUT text, c OUT text)
 RETURNS SETOF RECORD STABLE STRICT AS $$
BEGIN
 RETURN QUERY SELECT '1'::text, '2'::text, '3'::text;
 RETURN QUERY SELECT '3'::text, '4'::text, '5'::text;
 RETURN QUERY SELECT '3'::text, '4'::text, '5'::text;
END;
$$ LANGUAGE 'plpgsql';
select * from storeopeninghours_tostring(1);





CREATE TYPE storeopeninghours_tostring_rs AS
(colone text,
 coltwo text,
 colthree text
);

CREATE OR REPLACE FUNCTION "public"."storeopeninghours_tostring1" () 
RETURNS setof storeopeninghours_tostring_rs AS
$BODY$
DECLARE
  returnrec storeopeninghours_tostring_rs;
BEGIN
    BEGIN 
        CREATE TEMPORARY TABLE tmpopeninghours (
            colone text,
            coltwo text,
            colthree text
        );
    EXCEPTION WHEN OTHERS THEN
        TRUNCATE TABLE tmpopeninghours; -- TRUNCATE if the table already exists within the session.
    END;
    insert into tmpopeninghours VALUES ('1', '2', '3');
    insert into tmpopeninghours VALUES ('3', '4', '5');
    insert into tmpopeninghours VALUES ('3', '4', '5');

    FOR returnrec IN SELECT * FROM tmpopeninghours LOOP
        RETURN NEXT returnrec;
    END LOOP;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE;

select * from storeopeninghours_tostring1();





CREATE OR REPLACE FUNCTION public.foo(open_id numeric)
  RETURNS TABLE (a int, b int, c int) AS
$func$
BEGIN
   -- whatever open_id is for ...
   RETURN QUERY VALUES
    (1,2,3)
   ,(3,4,5)
   ,(3,4,5);
END
$func$ LANGUAGE plpgsql;

SELECT * FROM public.foo(1);





CREATE OR REPLACE FUNCTION foobar(open_id numeric, OUT p1 varchar, OUT p2 varchar, OUT p3 varchar) 
RETURNS SETOF RECORD AS $$
BEGIN
  p1 := '1'; p2 := '2'; p3 := '3';
  RETURN NEXT; 
  p1 := '3'; p2 := '4'; p3 := '5';
  RETURN NEXT; 
  p1 := '3'; p2 := '4'; p3 := '5';
  RETURN NEXT; 
  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM public.foobar(1);




-- select dentro de bloque anonimo
DO LANGUAGE plpgsql $$ DECLARE
BEGIN
execute '
create temporary table t2
as
SELECT NOW()
';
END $$;

select * from t2;

