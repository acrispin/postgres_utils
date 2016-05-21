-- limpiar tablas
select id from cot;
select id from dcot;
select id from acot;
select cot_id from cot_pdf;

delete from cot_pdf;
delete from acot;
delete from dcot;
delete from cot;


-- reiniciar las secuencias asociadas
-- http://stackoverflow.com/questions/4678110/how-to-reset-sequence-in-postgres-and-fill-id-column-with-new-data
ALTER SEQUENCE cot_id_seq RESTART WITH 1;
-- UPDATE cot SET id=nextval('cot_id_seq');
ALTER SEQUENCE dcot_id_seq RESTART WITH 1;
ALTER SEQUENCE acot_id_seq RESTART WITH 1;

/*
SELECT setval('cot_id_seq', 0);
SELECT setval('dcot_id_seq', 0);
SELECT setval('acot_id_seq', 0);

insert into cot (cli_id, cot_date, total, token)
values (1, now()::date, 100.00, 'abcde')

select * from cot
*/