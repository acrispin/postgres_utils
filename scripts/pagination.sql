
-- http://leopard.in.ua/2014/10/11/postgresql-paginattion/

-- A query to fetch the 10 most recent news
SELECT * FROM news WHERE category_id = 1234 ORDER BY date, id DESC LIMIT 10;


-- Worst Case: No index for ORDER BY
EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234 ORDER BY id LIMIT 10;
/*
Limit  (cost=27678.15..27678.18 rows=10 width=8) (actual time=393.361..393.363 rows=10 loops=1)
   ->  Sort  (cost=27678.15..28922.17 rows=497609 width=8) (actual time=393.359..393.360 rows=10 loops=1)
         Sort Key: id
         Sort Method: top-N heapsort  Memory: 25kB
         ->  Seq Scan on foo  (cost=0.00..16925.00 rows=497609 width=8) (actual time=0.024..277.040 rows=499071 loops=1)
               Filter: (category_id = 1234::integer)
               Rows Removed by Filter: 500929
 Total runtime: 233.021 ms
(8 rows)
*/



-- To get next resent 10 news in most cases using OFFSET
SELECT * FROM news WHERE category_id = 1234 ORDER BY date, id DESC OFFSET 10 LIMIT 10;

-- Worst Case: No index for ORDER BY
EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234 ORDER BY id OFFSET 10 LIMIT 10;
/*
Limit  (cost=30166.22..30166.25 rows=10 width=8) (actual time=388.711..388.714 rows=10 loops=1)
   ->  Sort  (cost=30166.20..31410.22 rows=497609 width=8) (actual time=388.706..388.711 rows=20 loops=1)
         Sort Key: id
         Sort Method: top-N heapsort  Memory: 25kB
         ->  Seq Scan on foo  (cost=0.00..16925.00 rows=497609 width=8) (actual time=0.020..271.130 rows=499071 loops=1)
               Filter: (category_id = 1234::integer)
               Rows Removed by Filter: 500929
 Total runtime: 388.761 ms
(8 rows)
*/

EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234 ORDER BY id OFFSET 100 LIMIT 10;
/*
Limit  (cost=36285.62..36285.65 rows=10 width=8) (actual time=389.534..389.536 rows=10 loops=1)
   ->  Sort  (cost=36285.37..37529.40 rows=497609 width=8) (actual time=389.512..389.524 rows=110 loops=1)
         Sort Key: id
         Sort Method: top-N heapsort  Memory: 30kB
         ->  Seq Scan on news  (cost=0.00..16925.00 rows=497609 width=8) (actual time=0.029..274.907 rows=499071 loops=1)
               Filter: (category_id = 1234::integer)
               Rows Removed by Filter: 500929
 Total runtime: 389.588 ms
(8 rows)
*/

EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234 ORDER BY id OFFSET 1000 LIMIT 10;
/*
Limit  (cost=44246.58..44246.61 rows=10 width=8) (actual time=389.982..389.986 rows=10 loops=1)
   ->  Sort  (cost=44244.08..45488.10 rows=497609 width=8) (actual time=389.765..389.930 rows=1010 loops=1)
         Sort Key: id
         Sort Method: top-N heapsort  Memory: 96kB
         ->  Seq Scan on news  (cost=0.00..16925.00 rows=497609 width=8) (actual time=0.024..271.414 rows=499071 loops=1)
               Filter: (category_id = 1234::integer)
               Rows Removed by Filter: 500929
 Total runtime: 390.049 ms
(8 rows)
*/

-- Improvement #1: Indexed ORDER BY
CREATE INDEX index_news_on_id_type ON news USING btree (id);
CREATE INDEX index_news_on_category_id ON news USING btree (category_id);

-- The same index can be using in WHERE and ORDER BY
EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234  ORDER BY id OFFSET 10 LIMIT 10;
/*
Limit  (cost=1.07..1.71 rows=10 width=8) (actual time=0.087..0.112 rows=10 loops=1)
   ->  Index Only Scan using index_news_on_id_type on news  (cost=0.42..31872.47 rows=497609 width=8) (actual time=0.057..0.109 rows=20 loops=1)
         Index Cond: (category_id = 1234::integer)
         Heap Fetches: 20
 Total runtime: 0.158 ms
(5 rows)
*/

EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234  ORDER BY id OFFSET 100 LIMIT 10;
/*
Limit  (cost=6.83..7.47 rows=10 width=8) (actual time=0.315..0.338 rows=10 loops=1)
   ->  Index Only Scan using index_news_on_id_type on news  (cost=0.42..31872.47 rows=497609 width=8) (actual time=0.058..0.318 rows=110 loops=1)
         Index Cond: (category_id = 1234::integer)
         Heap Fetches: 110
 Total runtime: 0.409 ms
(5 rows)
*/

EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234  ORDER BY id OFFSET 1000 LIMIT 10;
/*
Limit  (cost=64.48..65.12 rows=10 width=8) (actual time=1.651..1.663 rows=10 loops=1)
   ->  Index Only Scan using index_news_on_id_type on news  (cost=0.42..31872.47 rows=497609 width=8) (actual time=0.041..1.596 rows=1010 loops=1)
         Index Cond: (category_id = 1234::integer)
         Heap Fetches: 1010
 Total runtime: 1.698 ms
(5 rows)
*/

-- Improvement #2: The Seek Method
-- To remove the rows from previous pages we can use WHERE filter instead of OFFSET.
SELECT * FROM news WHERE category_id = 1234 AND (date, id) < (prev_date, prev_id) ORDER BY date DESC, id DESC LIMIT 10;

EXPLAIN ANALYZE SELECT * FROM news WHERE category_id = 1234 AND id < 12345678 ORDER BY id DESC LIMIT 10;
/*
Limit  (cost=0.42..1.09 rows=10 width=8) (actual time=0.036..0.060 rows=10 loops=1)
   ->  Index Only Scan Backward using index_news_on_id_type on news  (cost=0.42..33116.37 rows=497603 width=8) (actual time=0.035..0.053 rows=10 loops=1)
         Index Cond: ((category_id = 1234::integer) AND (id < 12345678::integer))
         Heap Fetches: 10
 Total runtime: 0.098 ms
(5 rows)
*/
























