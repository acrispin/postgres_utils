-- create table person
create table Person ( data json NOT NULL );

-- create index
CREATE UNIQUE INDEX people_id ON Person ((data->>'_id'));

-- query ejemplo
select data from Person where data->>'_id' = 'A158CCB9-BB68-4FC2-8123-79B32053B2A3'