
show data_directory; -- /var/lib/postgresql/9.4/main
SELECT * FROM pg_tablespace; -- 
SELECT oid from pg_database where datname = 'casa23_db';

select oid, datname
from pg_database;

select cl.relfilenode, nsp.nspname as schema_name, cl.relname, cl.relkind
from pg_class cl
  join pg_namespace nsp on cl.relnamespace = nsp.oid;
