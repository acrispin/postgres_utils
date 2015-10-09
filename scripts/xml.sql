
-- XML
-- http://www.postgresonline.com/journal/archives/116-Loading-and-Processing-GPX-XML-files-using-PostgreSQL.html

CREATE OR REPLACE FUNCTION somefuncname1() RETURNS TABLE(id int, name text) LANGUAGE plpgsql AS $$
DECLARE
  one int;
  two int;
  cadxml xml;
BEGIN
  one := 1;
  two := 2;
  RAISE NOTICE 'i want to print % and %', 200,60; -- es como print
  cadxml := '<Customers><Customer><ID>23</ID><Name>Google</Name>
 <Partners><ID>120</ID><ID>243</ID><ID>245</ID></Partners>
</Customer>
<Customer><ID>24</ID><Name>HP</Name><Partners><ID>44</ID></Partners></Customer>
<Customer><ID>25</ID><Name>IBM</Name></Customer></Customers>';
RETURN QUERY
SELECT (xpath('/Customer/ID/text()', node))[1]::text::int AS id,
  (xpath('/Customer/Name/text()', node))[1]::text AS name
FROM unnest(xpath('/Customers/Customer',
cadxml)) node
;
  -- RETURN one + two;
END
$$;
SELECT * from somefuncname1();




SELECT (xpath('/Customer/ID/text()', node))[1]::text::int AS id,
  (xpath('/Customer/Name/text()', node))[1]::text AS name
FROM unnest(xpath('/Customers/Customer',
'<Customers><Customer><ID>23</ID><Name>Google</Name>
 <Partners><ID>120</ID><ID>243</ID><ID>245</ID></Partners>
</Customer>
<Customer><ID>24</ID><Name>HP</Name><Partners><ID>44</ID></Partners></Customer>
<Customer><ID>25</ID><Name>IBM</Name></Customer></Customers>'::xml
)) node
;




CREATE OR REPLACE FUNCTION dup(in int, out f1 int, out f2 text)
AS $$ 

    SELECT (xpath('/Customer/ID/text()', node))[1]::text::int AS id,
  (xpath('/Customer/Name/text()', node))[1]::text AS name
FROM unnest(xpath('/Customers/Customer',
'<Customers><Customer><ID>23</ID><Name>Google</Name>
 <Partners><ID>120</ID><ID>243</ID><ID>245</ID></Partners>
</Customer>
<Customer><ID>24</ID><Name>HP</Name><Partners><ID>44</ID></Partners></Customer>
<Customer><ID>25</ID><Name>IBM</Name></Customer></Customers>'::xml
)) node
;

$$ LANGUAGE sql;

SELECT * FROM dup(42);


