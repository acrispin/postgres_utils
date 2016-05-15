
-- formatear numeros a monedas
-- http://www.postgresql.org/message-id/20010420095432.C21932@ara.zf.jcu.cz
select to_char(123456, '9,999,999');
select to_char(123456, 'FM9,999,999.99');
select to_char(123456, 'FM9,999,999.00');
select to_char(123, 'FM0,999,999.00');
select to_char(123456, 'LFM9,999,999.00');
select to_char(123456, 'LFM 9,999,999');
select to_char(123456, 'FM$999,999,999,990D00')