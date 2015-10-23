

-- indexs
-- http://blog.endpoint.com/2013/06/postgresql-functional-indexes.html
-- https://devcenter.heroku.com/articles/postgresql-indexes#expression-indexes

-- normal index
CREATE INDEX i_test ON test (i);
SELECT * FROM test WHERE i < 100 ORDER BY i;

-- Functional Indexes
CREATE INDEX i_test_lower_i ON test (lower(i));
SELECT * FROM test WHERE lower(i) = 'aaa';

-- ejemplo
CREATE TABLE test(t timestamp);
-- generacion de data automaticamente
INSERT INTO test(t) SELECT generate_series(now() - '1 year'::interval, now(), '1 minute'); -- Query returned successfully: 525601 rows affected, 1631 ms execution time.

-- I can get the rows with dates from the last 10 days like
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date;
/*
"Seq Scan on test  (cost=0.00..14152.02 rows=175200 width=8) (actual time=357.041..367.095 rows=13996 loops=1)"
"  Filter: ((t)::date > ((now() - '10 days'::interval))::date)"
"  Rows Removed by Filter: 511605"
"Planning time: 0.127 ms"
"Execution time: 367.627 ms"
*/

-- create index
CREATE INDEX i_test_t ON test((t::date));
-- CREATE INDEX i_test_t ON test(date(t));

-- probando de nuevo el query anterior
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date;
/*
"Bitmap Heap Scan on test  (cost=3286.24..9554.24 rows=175200 width=8) (actual time=3.056..6.426 rows=13996 loops=1)"
"  Recheck Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"  Heap Blocks: exact=63"
"  ->  Bitmap Index Scan on i_test_t  (cost=0.00..3242.44 rows=175200 width=0) (actual time=3.024..3.024 rows=13996 loops=1)"
"        Index Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"Planning time: 0.430 ms"
"Execution time: 7.583 ms"

*/

-- This index will also be used when you want to sort the results using the same values as stored in index:
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date order by t::date asc;
/*
"Index Scan using i_test_t on test  (cost=0.43..14736.43 rows=175200 width=8) (actual time=0.031..9.244 rows=13996 loops=1)"
"  Index Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"Planning time: 0.208 ms"
"Execution time: 10.957 ms"
*/

-- desendentemente
explain analyze select t from test where t::date > (now() - '10 days'::interval)::date order by t::date desc;
/*
"Index Scan Backward using i_test_t on test  (cost=0.43..14736.43 rows=175200 width=8) (actual time=0.090..8.222 rows=13996 loops=1)"
"  Index Cond: ((t)::date > ((now() - '10 days'::interval))::date)"
"Planning time: 0.173 ms"
"Execution time: 9.662 ms"
*/


-- extract year
SELECT extract( year from '2013-01-01'::date);
SELECT extract( year from now());

-- usando con la tabla test
select t from test where extract(year from t) = extract(year from now());

-- check the plan
explain analyze select t from test where extract(year from t) = extract(year from now());
/*
"Seq Scan on test  (cost=0.00..12838.02 rows=2628 width=8) (actual time=66.633..302.851 rows=407116 loops=1)"
"  Filter: (date_part('year'::text, t) = date_part('year'::text, now()))"
"  Rows Removed by Filter: 118485"
"Planning time: 0.111 ms"
"Execution time: 316.618 ms"
*/

-- creando index para extract year
CREATE INDEX i_test_t_year ON test (extract(year from t));

-- probando otra vez el plan
explain analyze select t from test where extract(year from t) = extract(year from now());
/*
"Bitmap Heap Scan on test  (cost=52.80..2542.04 rows=2628 width=8) (actual time=46.452..88.059 rows=407116 loops=1)"
"  Recheck Cond: (date_part('year'::text, t) = date_part('year'::text, now()))"
"  Heap Blocks: exact=1802"
"  ->  Bitmap Index Scan on i_test_t_year  (cost=0.00..52.14 rows=2628 width=0) (actual time=46.091..46.091 rows=407116 loops=1)"
"        Index Cond: (date_part('year'::text, t) = date_part('year'::text, now()))"
"Planning time: 0.182 ms"
"Execution time: 101.555 ms"
*/


-- otro query filtrando con HH:MI
EXPLAIN ANALYZE
SELECT t 
FROM test 
WHERE t::DATE > (NOW() - '1 days'::INTERVAL)::DATE
      AND EXTRACT(HOUR FROM t) = 15
      AND EXTRACT(MINUTE FROM t) = 25;
/*
"Bitmap Heap Scan on test  (cost=3242.44..11262.44 rows=4 width=8) (actual time=0.774..0.834 rows=1 loops=1)"
"  Recheck Cond: ((t)::date > ((now() - '1 day'::interval))::date)"
"  Filter: ((date_part('hour'::text, t) = 15::double precision) AND (date_part('minute'::text, t) = 25::double precision))"
"  Rows Removed by Filter: 1035"
"  Heap Blocks: exact=5"
"  ->  Bitmap Index Scan on i_test_t  (cost=0.00..3242.44 rows=175200 width=0) (actual time=0.213..0.213 rows=1036 loops=1)"
"        Index Cond: ((t)::date > ((now() - '1 day'::interval))::date)"
"Planning time: 0.216 ms"
*/


-- uso de generate_series
-- http://www.postgresql.org/docs/9.4/static/functions-srf.html
SELECT * FROM generate_series(2,4);
SELECT * FROM generate_series(5,1,-2);
SELECT * FROM generate_series(4,3);
SELECT current_date + s.a AS dates FROM generate_series(0,14,7) AS s(a);
SELECT * FROM generate_series('2008-03-01 00:00'::timestamp, '2008-03-04 12:00', '10 hours');
SELECT generate_series(now() - '1 year'::interval, now(), '1 month')



---------------------------------------------------------------------------------------------------------------------------------------------------------
-- http://leopard.in.ua/2015/04/13/postgresql-indexes/
-- http://michael.otacoo.com/postgresql-2/postgres-9-5-feature-highlight-brin-indexes/
-- http://pythonsweetness.tumblr.com/post/119568339102/block-range-brin-indexes-in-postgresql-95

-- B-Tree index  (default)
/*
B-Tree is the default index that you get when you do CREATE INDEX. Virtually all databases will have some B-tree indexes. 
The B stands for Balanced (Boeing/Bayer/Balanced/Broad/Bushy-Tree), and the idea is that the amount of data on both sides of the tree is roughly the same. 
Therefore the number of levels that must be traversed to find rows is always in the same approximate number. 
B-Tree indexes can be used for equality and range queries efficiently. They can operate against all datatypes, 
and can also be used to retrieve NULL values. Btrees are designed to work very well with caching, even when only partially cached.
*/


-- R-Tree index
/*
R-Tree (rectangle-tree) index storing numeric type pairs of (X, Y) values (for example, the coordinates). R-Tree is very similar to B-Tree. 
The only difference is the information written to intermediate page in a tree. For the i-th value of the B-Tree node we write the most out of the i-th subtree. 
In R-Tree it is a minimum rectangle that encloses all the rectangles of the child
*/

-- Hash index
/*
Hash index doesn't store the values, but their hashes. Such indexing way reducing the size (and therefore increased speed and processing) 
of high index fields. In this case, when a query using Hash indexes will not be compared with the value of the field, but the hash value of the desired hash fields.
Because hash functions is non-linear, such index cannot be sorted. This causes inability to use the comparisons more/less and "IS NULL" with this index. 
In addition, since the hashes are not unique, then the matching hashes used methods of resolving conflicts.
*/

-- Bitmap index
/*
Bitmap index create a separate bitmap (a sequence of 0 and 1) for each possible value of the column, where each bit corresponds 
to a string with an indexed value. Bitmap indexes are optimal for data where bit unique values (example, gender field).
*/

-- GiST index
/*
Generalized Search Tree (GiST) indexes allow you to build general balanced tree structures, and can be used for operations 
beyond equality and range comparisons. The tree structure is not changed, still no elevators in each node pair stored value (the page number) 
and the number of children with the same amount of steam in the node.
The essential difference lies in the organization of the key. B-Tree trees sharpened by search ranges, and hold a maximum subtree-child. 
R-Tree - the region on the coordinate plane. GiST offers as values ​​in the non-leaf nodes store the information that we consider essential, 
and which will determine if we are interested in values ​​(satisfying the predicate) in the subtree-child. The specific form of information 
stored depends on the type of search that we wish to pursue. Thus parameterize R-Tree and B-Tree tree predicates and values ​​we automatically 
receive specialized for the task index (examples: PostGiST, pg_trgm, hstore, ltree, etc.). They are used to index the geometric data types, as well as full-text search.
*/

-- GIN index
/*
Generalized Inverted Indexes (GIN) are useful when an index must map many values to one row, whereas B-Tree indexes are optimized 
for when a row has a single key value. GINs are good for indexing array values as well as for implementing full-text search.
*/

-- Block Range (BRIN) Index (9.5+)
/*
BRIN stands for Block Range INdexes, and store metadata on a range of pages. At the moment this means the minimum and maximum values per block.

This results in an inexpensive index that occupies a very small amount of space, and can speed up queries in extremely large tables. 
This allows the index to determine which blocks are the only ones worth checking, and all others can be skipped. 
So if a 10GB table of order contained rows that were generally in order of order date, a BRIN index on the order_date column would allow 
the majority of the table to be skipped rather than performing a full sequential scan. This will still be slower than a regular BTREE index 
on the same column, but with the benefits of it being far smaller and requires less maintenance.
*/


-- Partial Indexes
/*
A partial index covers just a subset of a table's data. It is an index with a WHERE clause. The idea is to increase 
the efficiency of the index by reducing its size. A smaller index takes less storage, is easier to maintain, and is faster to scan.
For example, suppose you log in table some information about network activity and very often you need check logs from local IP range. You may want to create an index like so:
*/
CREATE INDEX access_log_client_ip_ix ON access_log (client_ip)
        WHERE (client_ip > inet '192.168.100.0' AND
                   client_ip < inet '192.168.100.255');
SELECT * FROM access_log WHERE client_ip = '192.168.100.45';


-- Expression Indexes
/*
Expression indexes are useful for queries that match on some function or modification of your data. 
Postgres allows you to index the result of that function so that searches become as efficient as searching by raw data values.
For example, suppose you doing very often search by first leter in lower case from name field. You may want to create an index like so:
*/
CREATE INDEX users_name_first_idx ON foo ((lower(substr(name, 1, 1))));
SELECT * FROM users WHERE lower(substr(name, 1, 1)) = 'a';


-- Unique Indexes
/*
A unique index guarantees that the table won’t have more than one row with the same value. It's advantageous to create unique indexes 
for two reasons: data integrity and performance. Lookups on a unique index are generally very fast.
There is little distinction between unique indexes and unique constraints. Unique indexes can be though of as lower level, 
since expression indexes and partial indexes cannot be created as unique constraints. Even partial unique indexes on expressions are possible.
*/


-- Multi-column Indexes
/*
While Postgres has the ability to create multi-column indexes, it's important to understand when it makes sense to do so. 
The Postgres query planner has the ability to combine and use multiple single-column indexes in a multi-column query 
by performing a bitmap index scan ("Bitmap index" for more info). 
In general, you can create an index on every column that covers query conditions and in most cases Postgres will use them, 
so make sure to benchmark and justify the creation of a multi-column index before you create them. 
As always, indexes come with a cost, and multi-column indexes can only optimize the queries that reference the columns 
in the index in the same order, while multiple single column indexes provide performance improvements to a larger number of queries.

However there are cases where a multi-column index clearly makes sense. An index on columns (a, b) can be used by queries containing 
WHERE a = x AND b = y, or queries using WHERE a = x only, but will not be used by a query using WHERE b = y. 
So if this matches the query patterns of your application, the multi-column index approach is worth considering. 
Also note that in this case creating an index on a alone would be redundant.
*/



-- Postgres 9.5 feature highlight: BRIN indexes
/*
BRIN is a new index access method intended to accelerate scans of very
large tables, without the maintenance overhead of btrees or other
traditional indexes.  They work by maintaining "summary" data about
block ranges.  Bitmap index scans work by reading each summary tuple and
comparing them with the query quals; all pages in the range are returned
in a lossy TID bitmap if the quals are consistent with the values in the
summary tuple, otherwise not.  Normal index scans are not supported
because these indexes do not store TIDs.

By nature, using a BRIN index for a query scan is a kind of mix between a sequential scan and an index scan because 
what such an index scan is storing a range of data for a given fixed number of data blocks. 
So this type of index finds its advantages in very large relations that cannot sustain the size of for example 
a btree where all values are indexed, and that is even better with data that has a high ordering across the relation blocks. 
For example let's take the case of a simple table where the data is completely ordered across data pages 
like this one with 100 million tuples:
=# CREATE TABLE brin_example AS SELECT generate_series(1,100000000) AS id;
SELECT 100000000
=# CREATE INDEX btree_index ON brin_example(id);
CREATE INDEX
Time: 239033.974 ms
=# CREATE INDEX brin_index ON brin_example USING brin(id);
CREATE INDEX
Time: 42538.188 ms
=# \d brin_example
Table "public.brin_example"
 Column |  Type   | Modifiers
--------+---------+-----------
 id     | integer |
Indexes:
    "brin_index" brin (id)
    "btree_index" btree (id)


Note that the creation of the BRIN index was largely faster: it has less index entries to write so it generates less traffic. 
By default, 128 blocks are used to calculate a range of values for a single index entry, this can be set with 
the new storage parameter pages_per_range using a WITH clause.
=# CREATE INDEX brin_index_64 ON brin_example USING brin(id)
    WITH (pages_per_range = 64);
CREATE INDEX
=# CREATE INDEX brin_index_256 ON brin_example USING brin(id)
   WITH (pages_per_range = 256);
CREATE INDEX
=# CREATE INDEX brin_index_512 ON brin_example USING brin(id)
   WITH (pages_per_range = 512);
   CREATE INDEX


Having a look at the relation sizes, BRIN indexes are largely smaller in size.
=# SELECT relname, pg_size_pretty(pg_relation_size(oid))
    FROM pg_class WHERE relname LIKE 'brin_%' OR
         relname = 'btree_index' ORDER BY relname;
    relname     | pg_size_pretty
----------------+----------------
 brin_example   | 3457 MB
 brin_index     | 104 kB
 brin_index_256 | 64 kB
 brin_index_512 | 40 kB
 brin_index_64  | 192 kB
 btree_index    | 2142 MB
(6 rows)


Let's have a look at what kind of plan is generated then for scans using the btree index and the BRIN index on the previous table.
=# EXPLAIN ANALYZE SELECT id FROM brin_example WHERE id = 52342323;
                                      QUERY PLAN
---------------------------------------------------------------------------------
Index Only Scan using btree_index on brin_example
      (cost=0.57..8.59 rows=1 width=4) (actual time=0.031..0.033 rows=1 loops=1)
   Index Cond: (id = 52342323)
   Heap Fetches: 1
 Planning time: 0.200 ms
 Execution time: 0.081 ms
(5 rows)
=# EXPLAIN ANALYZE SELECT id FROM brin_example WHERE id = 52342323;
                                       QUERY PLAN
--------------------------------------------------------------------------------------
 Bitmap Heap Scan on brin_example
       (cost=20.01..24.02 rows=1 width=4) (actual time=11.834..30.960 rows=1 loops=1)
   Recheck Cond: (id = 52342323)
   Rows Removed by Index Recheck: 115711
   Heap Blocks: lossy=512
   ->  Bitmap Index Scan on brin_index_512
       (cost=0.00..20.01 rows=1 width=0) (actual time=1.024..1.024 rows=5120 loops=1)
          Index Cond: (id = 52342323)
 Planning time: 0.196 ms
 Execution time: 31.012 ms
(8 rows)


The btree index is or course faster, in this case an index only scan is even doable. Now remember that BRIN indexes are lossy, 
meaning that not all the blocks fetched back after scanning the range entry may contain a target tuple.
A last thing to notice is that pageinspect has been updated with a set of functions to scan pages of a BRIN index:
=# SELECT itemoffset, value
   FROM brin_page_items(get_raw_page('brin_index', 5), 'brin_index') LIMIT 5;
 itemoffset |         value
------------+------------------------
          1 | {35407873 .. 35436800}
          2 | {35436801 .. 35465728}
          3 | {35465729 .. 35494656}
          4 | {35494657 .. 35523584}
          5 | {35523585 .. 35552512}
(5 rows)

*/



/*
Tables

As a quick recap, table rows in PostgreSQL are stored into an on-disk structure known as the heap. 
The heap is an array that is logically partitioned into 8kb “pages”, with each page containing one or 
more “tuples” (rows). To ease management, as the heap grows it is additionally split into 1GB-sized files on disk, 
however the overall structure is still essentially just one big logical array.

When you ask PostgreSQL to insert a row into a table, it uses an auxilliary structure known as the free space map 
to locate the first available heap page for your relation (“table”) that has sufficient space to store the data for your row. 
If your row is larger than a pre-set limit (2kb), large columns are split out of the row’s data and stored in a 
series of rows in an internal table (the so-called TOAST tables).

The net result is that each data row exists entirely within one page, and that row lives at a particular 
logical index (the “item ID”) within its page. If PostgreSQL must refer to a row, it can uniquely identify 
it using just its page number, and its index within the page. The combination of this pair of numbers is known as the row’s ctid, 
or its tuple ID. Tuple IDs can thus be used as a small, efficient, unique locator for every row in a database, 
and they exist regardless of your schema design.

[Side note: that’s not entirely true! If a row has been updated since the database was last VACUUMed, 
multiple versions will exist, chained together using some special fields in each version’s on-disk data. 
For simplicity let’s just assume only one version exists.]

In the current PostgreSQL implementation, 32 bits are used for the page number, and 16 bits for the item number 
(placing an absolute upper bound on a single database table to somewhere around 32 PiB), allowing the ctid to fit comfortably in 64 bits.

Using just the name of a relation and a ctid, PG can first split the page number from the ctid and use that 
to efficiently locate the physical database file and offset where the page lives:

page_size = 8KiB
pages_per_segment = 1GiB / page_size
segment, index = divmod(page_number, pages_per_segment)
page_offset = page_size * index

Finally to locate the tuple within the page, a small, constant-sized lookup table exists at the start of each page 
that maps its item IDs to byte offsets within the page:

item_offset = page.lookup_table[item_id]


Indexes
Without further help, answering a query such as SELECT * FROM person WHERE age BETWEEN 18 AND 23 would require 
PG to visit every page in the heap, decoding each row in turn, and comparing its age column to the WHERE predicate. 
Naturally for larger tables, we prefer to avoid that, and an index is necessary to allow PostgreSQL to avoid scanning the full table.


Btree Indexes

The most common index type in PG is the btree, which maintains an efficient map from column value to ctid. Given the imaginary table:

Person table heap layout
Page Number | Item ID | ctid  |  Name  |  Age | Creation Date
1   1   (1, 1)  John    10  1998-01
    2   (1, 2)  Jack    99  1998-02
    3   (1, 3)  Jill    70  1998-03
    4   (1, 4)  Jemma   19  1998-04
2   1   (2, 1)  George  60  1998-05
    2   (2, 2)  James   44  1998-05
    3   (2, 3)  Jocelyn 55  1998-06
    4   (2, 4)  Jemima  22  1998-07
3   1   (3, 1)  Jerry   60  1999-01
    2   (3, 2)  Jarvis  44  1999-02
    3   (3, 3)  Jasper  55  1999-03
    4   (3, 4)  Josh    24  1999-04
4   1   (4, 1)  Jacob   60  2000-01
    2   (4, 2)  Jesse   44  2000-02
    3   (4, 3)  Janet   55  2000-03
    4   (4, 4)  Justine 24  2000-04

A btree index created using CREATE INDEX person_age ON person(age) might resemble:

person(age) btree index layout
Age ctid
10  (1, 1)
19  (1, 4)
22  (2, 4)
24  (3, 4)
24  (4, 4)
44  (3, 2)
44  (4, 2)
44  (2, 2)
55  (3, 3)
55  (4, 3)
55  (2, 3)
60  (3, 1)
60  (4, 1)
60  (2, 1)
80  (1, 3)
99  (1, 2)

This is getting too long already, so skipping to the chase we can see that PG can now efficiently locate an exact 
row given its associated indexed column value, and that value in turn is stored in a data structure that permits fast lookup.

For our SELECT query from above, PG can jump to btree key 18 and scan out ctids until it reaches a key with an entry 
larger than 23. In the demo table, this means PG must only visit 2 rows from our set of 16, and prior to accessing the row data, 
it already knows the row definitely matches the predicate.

For some other queries, such as SELECT COUNT(*) FROM person WHERE age = 22, PG may not even need to visit the row data itself, 
since it can infer from index entries how many data rows exist. [Another MVCC caveat! This is not entirely true, 
since index entries may exist pointing to deleted rows, or rows created in later transactions]

The crucial point to note, though, is that one exact index entry is produced for every row, which usually doesn’t amount to much, 
maybe no more than 5-15% overhead relative to the source table, however for a large table, that overhead may be the difference 
between a dataset that fits in RAM, and one in which common queries end up hitting disk, or IO is doubled due to index access, 
since the dataset was already vastly larger than available RAM. It’s easy to imagine indexes quickly adding up, such that perhaps 
half of an application’s storage is wasted on them.


BRIN Indexes

Finally enough verbiage is spilled so that we can reach the point: BRIN indexes introduce a cool tradeoff where instead of covering individual rows, index entries cover one or more heap pages:

person(age) BRIN index with group size 1

Page Number | Has NULL values?  |  Lowest Age | Highest Age
1   No  10  99
2   No  22  60
3   No  24  60
4   No  24  60

The structure is used like so: given a query such as SELECT * FROM person WHERE age BETWEEN 10 AND 15, 
PG will visit every index entry in turn, comparing its minimum/maximum values against the query predicate. 
If the index entry indicates that a range of pages contains at least one record matching the query, 
those pages will be scanned for matching rows. For this query, only one page contains rows whose age fields 
overlap the desired region, and so PG can avoid visiting 75% of the table.

Notice that in order to find just one row, PG must now scan a full page and compare each of its 4 rows 
against the query predicates. While index size is reduced, query time has increased! There is also little 
pattern in our age column: in fact, it is quite lucky that our index described only a single page covering 
the range 10..15. Had users signed up in a slightly different order, the distribution of ages across 
physical storage pages may have resulted in PG having to scan many more pages.

[Another side note: unlike our dummy table above, a typical PG heap page may contain over 200 rows, 
depending on how many columns are present, and how many of those are strings. Our dummy BRIN index above 
looks as if it contains just as much information as the original btree index, but that’s just because my example 
only has 16 rows instead of 800].

BRIN also permits configuring how many heap pages contribute to an index entry. For example, 
we can halve the size of our first index while also halving its precision:

person(age) BRIN index with group size 2
Page Number | Has NULL values?  |  Lowest Age | Highest Age
1-2 No  10  99
3-4 No  24  60

Due to the work-increasing factor, and also since every index entry must be visited (resulting in a potentially 
high fixed cost for any query), BRIN is probably never useful for “hot” queries against a table, or even much use 
at all in a typical “hot” database, however for auxilliary queries, such as producing once-per-month reports or 
bulk queries against archival data, where reduced runtime or IO is desired without the storage costs of an exact index, 
BRIN may be just the tool.

Finally, notice in the original table how as new records were inserted, their creation date roughly 
tracked which database page they ended up on. This is quite a natural outcome since as the table grows, 
newer items will occupy later pages in the array, and so there is quite a reliable correlation between 
page number and the creation date column value. A BRIN index over this column would work very well.

*/