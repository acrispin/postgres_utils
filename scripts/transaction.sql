
-- http://www.tutorialspoint.com/postgresql/postgresql_transactions.htm
-- BEGIN; = BEGIN TRANSACTION;
-- COMMIT; = END TRANSACTION;

BEGIN;
DELETE FROM COMPANY WHERE AGE = 25;
ROLLBACK;

-- https://kaiv.wordpress.com/2007/11/02/getting-current-time-inside-a-transaction/
-- now() da la misma fecha dentro de una transaccion
BEGIN;
select now();
select now();
COMMIT;

-- obtencion de la fecha exacta dentro de una transaccion
BEGIN;
select timeofday()::timestamptz;
select timeofday()::timestamptz;
COMMIT;