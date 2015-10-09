
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