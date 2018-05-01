
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


-- 
SELECT EXTRACT(CENTURY FROM TIMESTAMP '2000-12-16 12:21:13');
SELECT EXTRACT(CENTURY FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(HOUR FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(MINUTE FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(SECOND FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(SECOND FROM TIME '17:12:28.5');
SELECT EXTRACT(MICROSECONDS FROM TIME '17:12:28.5');
SELECT EXTRACT(MILLISECONDS FROM TIME '17:12:28.5');
SELECT EXTRACT(DAY FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(DAY FROM INTERVAL '40 days 1 minute');
SELECT EXTRACT(WEEK FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(MONTH FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(MONTH FROM INTERVAL '2 years 3 months');
SELECT EXTRACT(YEAR FROM TIMESTAMP '2001-02-16 20:38:40');
SELECT EXTRACT(DECADE FROM TIMESTAMP '2001-02-16 20:38:40'); -- The year field divided by 10
SELECT EXTRACT(DOW FROM TIMESTAMP '2001-02-16 20:38:40'); -- The day of the week as Sunday (0) to Saturday (6)
SELECT EXTRACT(DOY FROM TIMESTAMP '2001-02-16 20:38:40'); -- The day of the year (1 - 365/366)
SELECT EXTRACT(MILLENNIUM FROM TIMESTAMP '2001-02-16 20:38:40');


-- obtener nombre de mes
-- http://stackoverflow.com/questions/9094392/get-month-name-from-number-in-postgresql
SELECT to_char(to_timestamp(to_char(4, '999'), 'MM'), 'Mon')