-- select * from cat -- categoria
-- select * from pro -- producto
-- select * from kit -- kit
-- select * from kit_pro -- kit producto

SELECT * FROM clr LIMIT 10 OFFSET 0;
SELECT * FROM clr LIMIT 10 OFFSET 10;
SELECT * FROM clr LIMIT 10 OFFSET 20;
SELECT * FROM clr LIMIT 10 OFFSET 30;

SELECT * FROM clr 
ORDER BY id
LIMIT 10 OFFSET 40; -- recupera 10 registros saltando 40 registros