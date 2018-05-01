
-- http://big-elephants.com/2013-09/exploring-query-locks-in-postgres/

-- RowExclusiveLock

-- 1 promt, bloquear todas las filas
BEGIN; SELECT * FROM toys FOR UPDATE; 

-- 2 promt
UPDATE toys SET usage = usage+1 WHERE id = 2;
-- no lo podra realizar hasta que en el primer promt se haya hecho commit o rollback

-- proyecto casa_23
-- 1 promt, bloquear conjunto de filas
BEGIN; SELECT * FROM mtr WHERE cod = 4 FOR UPDATE;

-- 2 promt
-- puede hacer esta actualizacion
UPDATE mtr SET mod_user = 'B' WHERE cod = 1;
-- no puede hacer esta actualizacion hasta que en el 1 promt haya hecho commit o rollback
UPDATE mtr SET mod_user = 'B' WHERE cod = 4;




-- otra forma de hacer bloqueos a nivel de tabla
-- bloque la tabla sin que otro usuario pueda hacer select
BEGIN; LOCK TABLE test_int IN ACCESS EXCLUSIVE MODE;

-- similar al BEGIN; SELECT * FROM toys FOR UPDATE; 
BEGIN; LOCK TABLE test_int IN SHARE MODE;




-- queries para ver la actividad de los bloqueos
SELECT locktype, relation::regclass, mode, transactionid AS tid,
virtualtransaction AS vtid, pid, granted
FROM pg_catalog.pg_locks l LEFT JOIN pg_catalog.pg_database db
ON db.oid = l.database WHERE (db.datname = 'sandbox' OR db.datname IS NULL)
AND NOT pid = pg_backend_pid();


SELECT query,state,waiting,pid FROM pg_stat_activity
WHERE datname='sandbox' AND NOT (state='idle' OR pid=pg_backend_pid());




-- http://walterslog.blogspot.pe/2010/10/postgresql-select-for-update-example.html
-- create table
CREATE TABLE "public"."test_lock" (
    "id" INTEGER
);

INSERT INTO test_lock VALUES (180);

-- function test
CREATE OR REPLACE FUNCTION "public"."for_update_test" ()
RETURNS integer AS
$body$
DECLARE 
    id_query INTEGER; 
BEGIN 
    RAISE NOTICE 'START AT: %',timeofday()::timestamp;

    SELECT id FROM test_lock LIMIT 1 INTO id_query FOR UPDATE;
    -- con la sentencia NOWAIT, lanzaria error en la segunda llamada de esta funcion
    -- SELECT id FROM test_lock LIMIT 1 INTO id_query FOR UPDATE NOWAIT;

    RAISE NOTICE 'SELECT PERFORMED AT: %',timeofday()::timestamp;

    PERFORM pg_sleep(50);

    RAISE NOTICE 'END AT: %',timeofday()::timestamp;

    RETURN 0;
END;
$body$
LANGUAGE 'plpgsql';


-- function test2
CREATE OR REPLACE FUNCTION "public"."for_update_test2" ()
RETURNS integer AS
$body$
DECLARE 
    id_query INTEGER = 0; 
BEGIN 
    RAISE NOTICE 'START AT: %',timeofday()::timestamp;

    LOCK TABLE test_int IN SHARE MODE;

    RAISE NOTICE 'LOCK PERFORMED AT: %',timeofday()::timestamp;

    insert into test_int (ran) values(999999999);

    RAISE NOTICE 'INSERT PERFORMED AT: %',timeofday()::timestamp;

    PERFORM pg_sleep(20);

    RAISE NOTICE 'END AT: %',timeofday()::timestamp;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN 
    RAISE NOTICE '% | % | %', SQLERRM, SQLSTATE, current_query();
    RETURN -1;
END;
$body$
LANGUAGE 'plpgsql';