
-- verificar el time zone y cambiarlo
-- consulta de timezones
SELECT * FROM pg_timezone_names;

-- cambiar el timezone y volver a conectarse para verificar el cambio
ALTER DATABASE db_name SET timezone TO 'Europe/Istanbul';

-- verificar el timezone
SHOW timezone;

Select current_timestamp - current_timestamp AT TIME ZONE 'UTC' As TimeZoneOffSet;

-- segun el resultado que se obtiene en el query anterior, ejm : 03:00:00
select * from pg_timezone_names where utc_offset = '03:00:00';
select * from pg_timezone_names where name like '%Istanbul%';


-- cambiar en db de heroku
-- conectarse en la terminal
    $ psql -h ip_servidor_heroku -p puerto_heroku -d dbname_heroku -U usuario_heroku

-- verificar
    dbname_heroku=> show timezone;

    dbname_heroku=> Select current_timestamp - current_timestamp AT TIME ZONE 'UTC' As TimeZoneOffSet;

-- cambiar el timezone
    dbname_heroku=> ALTER DATABASE dbname_heroku SET timezone TO 'America/Lima';

-- salir
    dbname_heroku=> \q

-- volver a conectarse y verificar el cambio
    dbname_heroku=> show timezone;
