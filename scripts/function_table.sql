-- function return generic table result set

-- http://stackoverflow.com/questions/27066906/generic-set-returning-function
-- http://stackoverflow.com/questions/11740256/refactor-a-pl-pgsql-function-to-return-the-output-of-various-select-queries/11751557#11751557
-- http://postgresql.nabble.com/PL-pgSQL-stored-procedure-returning-multiple-result-sets-SELECTs-td1909125.html
-- http://stackoverflow.com/questions/10723006/return-a-select-from-a-plpgsql-function/10723796#10723796
-- http://www.postgresql.org/docs/current/static/xfunc-sql.html

--------
CREATE OR REPLACE FUNCTION data_of(_tbl_type anyelement, _id int)
  RETURNS SETOF anyelement AS
$func$
BEGIN
   RETURN QUERY EXECUTE format('
      SELECT *
      FROM   %s  -- pg_typeof returns regtype, quoted automatically
      WHERE  id = $1
      ORDER  BY datahora'
    , pg_typeof(_tbl_type))
   USING  _id;
END
$func$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION data_of2(_tbl_type anyelement)
  RETURNS SETOF anyelement AS
$func$
BEGIN
    
   RETURN QUERY EXECUTE format('
      select * from %s'
    , pg_typeof(_tbl_type));
END
$func$ LANGUAGE plpgsql;

SELECT * FROM data_of2(NULL::polls_choice);
SELECT * FROM data_of2(NULL::polls_question);
SELECT * FROM data_of2(NULL::auth_user);


--------
create or replace function srf (OUT a int, OUT b int) 
returns setof record as 
$$
begin 
    a:=1;b:=1;
    return next;
    a:=2;b:=3;
    return next; 
end;
$$language plpgsql; 


select * from srf(); 


--------
CREATE TABLE foo (fooid int, foosubid int, fooname text);
INSERT INTO foo VALUES (1, 1, 'Joe');
INSERT INTO foo VALUES (1, 2, 'Ed');
INSERT INTO foo VALUES (2, 1, 'Mary');

CREATE OR REPLACE FUNCTION getfoo(int) RETURNS foo AS $$
    SELECT * FROM foo WHERE fooid = $1;
$$ LANGUAGE SQL;

SELECT *, upper(fooname) FROM getfoo(1) AS t1;


--------
CREATE OR REPLACE FUNCTION getfoo2(int) RETURNS SETOF foo AS $$
    SELECT * FROM foo WHERE fooid = $1;
$$ LANGUAGE SQL;

SELECT *, upper(fooname) FROM getfoo2(1) AS t1;


--------
CREATE TABLE tab (y int, z int);
INSERT INTO tab VALUES (1, 2), (3, 4), (5, 6), (7, 8);

CREATE OR REPLACE FUNCTION sum_n_product_with_tab (x int, OUT sum int, OUT product int)
RETURNS SETOF record
AS $$
    SELECT $1 + tab.y, $1 * tab.y FROM tab;
$$ LANGUAGE SQL;

SELECT * FROM sum_n_product_with_tab(10);


--------
CREATE FUNCTION sum_n_product_with_tab2 (x int)
RETURNS TABLE(sum int, product int) AS $$
    SELECT $1 + tab.y, $1 * tab.y FROM tab;
$$ LANGUAGE SQL;


--------
CREATE OR REPLACE FUNCTION test_dynamic ()
RETURNS TABLE(code int, question TEXT, fecha timestamp WITH TIME ZONE) AS $$
    SELECT * from polls_question ;
$$ LANGUAGE SQL;

SELECT * FROM test_dynamic();


--------
CREATE OR REPLACE FUNCTION qa_scf(cname character varying, tname character varying)
RETURNS SETOF RECORD AS
$BODY$
BEGIN
    RETURN QUERY EXECUTE 'SELECT * from ' || tname || ' where ' || cname ||' != ''AL''';
END;
$BODY$
LANGUAGE plpgsql;

SELECT *
FROM qa_scf('foo', 'bar') AS t(col1_name col1_type, ...);

CREATE OR REPLACE FUNCTION qa_scf()
RETURNS SETOF RECORD AS
$BODY$
BEGIN
    RETURN QUERY EXECUTE 'SELECT * from polls_question';
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM qa_scf() AS t(code int, question VARCHAR(200), fecha timestamp WITH TIME ZONE);


-- 
CREATE OR REPLACE FUNCTION test_dynamicA()
RETURNS TABLE(code int, question TEXT, fecha date) AS $$
    SELECT id, nom, cum_date from cli ;
$$ LANGUAGE SQL;

SELECT * FROM test_dynamicA();


-- 
CREATE OR REPLACE FUNCTION test_dynamicB()
RETURNS TABLE(code int, question varchar(50), fecha date) AS $$
BEGIN
   RETURN QUERY 
    SELECT id, nom, cum_date from cli ;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM test_dynamicB();


-- cli es una tabla de bd
CREATE OR REPLACE FUNCTION test_dynamicC()
RETURNS SETOF cli AS $$
BEGIN
   RETURN QUERY 
    SELECT * from cli ;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM test_dynamicC();


-- http://select-into.blogspot.pe/2011/01/more-elegant-forms-of-returning-records.html
CREATE OR REPLACE FUNCTION squares(ct INT)
   RETURNS SETOF RECORD
AS $$
DECLARE
  v_rec RECORD;
BEGIN
  FOR i IN 0..ct-1 LOOP
    SELECT i, POWER(i,2)::INT INTO v_rec;
    RETURN NEXT v_rec;
  END LOOP;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;
 
SELECT * FROM squares(5) AS (A INT, B INT);

-- 
CREATE TYPE square_type AS (a INT, b INT); 
CREATE OR REPLACE FUNCTION squares2(ct INT)
   RETURNS SETOF square_type
AS $$
DECLARE
  v_rec square_type;
BEGIN
  FOR i IN 0..ct-1 LOOP
    SELECT i, POWER(i,2)::INT INTO v_rec;
    RETURN NEXT v_rec;
  END LOOP;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;
 
SELECT * FROM squares2(5);

