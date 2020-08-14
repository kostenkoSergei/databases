USE shop;
/*
 “Транзакции, переменные, представления”
Задание 1. 
В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
*/
SELECT id, name FROM users;
SELECT id, name FROM sample.users;
START TRANSACTION;
INSERT INTO sample.users (id, name) VALUES (1, (SELECT name FROM shop.users WHERE id = 1));
COMMIT;

SELECT id, name FROM sample.users;

/*
Задание 2. 
Создайте представление, которое выводит название name товарной позиции из 
таблицы products и соответствующее название каталога name из таблицы catalogs.
*/
CREATE OR REPLACE VIEW prod_cat AS
SELECT p.name AS product, c.name AS `catalog`
FROM products p
INNER JOIN catalogs c ON p.catalog_id = c.id;

/*
Задание 3. 
(по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены 
разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' 
и 2018-08-17. Составьте запрос, который выводит полный список дат за август, выставляя в 
соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
*/
DROP TABLE IF EXISTS august_dates;
-- create table with four dates to check
CREATE TABLE august_dates (
	id SERIAL,
	created_at DATE
) COMMENT 'some test table with dates';
-- fill table
INSERT INTO august_dates VALUES
	(NULL, '2018-08-01'), (NULL, '2018-08-04'), (NULL, '2018-08-16'), (NULL, '2018-08-17');

-- create table with full list of august 2018 dates
DROP TABLE IF EXISTS august;
CREATE TABLE august (
	dates DATE
);
-- create procedure that fills table with full list of dates
DROP PROCEDURE IF EXISTS fill_august_table;
DELIMITER $
CREATE PROCEDURE fill_august_table()
BEGIN
	SET @step := 1;
		WHILE @step <= 31 DO
			INSERT INTO august VALUES (
				CONCAT('2018-08-', LPAD(@step, 2, '0'))
			);
			
			SET @step = @step + 1;
		END WHILE;
END $
DELIMITER ;

-- call procedure and get table with full list of august dates
CALL fill_august_table();

-- get select with column is_included that shows if date from full list of dates is corresponding with our four dates
SELECT dates, 
CASE 
    WHEN dates IN (SELECT created_at FROM august_dates) THEN '1'
    ELSE '0'
END AS is_included
FROM august;

/*
Задание 4. 
(по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос,
который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
*/
DROP TABLE IF EXISTS time_table;
CREATE TABLE time_table (
	created_at TIMESTAMP DEFAULT NOW()
); 

DROP PROCEDURE IF EXISTS fill_time_table;
DELIMITER $
CREATE PROCEDURE fill_time_table()
BEGIN
	SET @step = 1;
	WHILE @step <= 10 DO
		INSERT INTO time_table VALUES (DEFAULT);
		SET @step = @step + 1;
		DO SLEEP(1);
	END WHILE;
END $
DELIMITER ;

CALL fill_time_table();

-- before delete:
SELECT * FROM time_table ORDER BY created_at DESC;

SET @start := 0; 

DELETE FROM time_table 
WHERE created_at < (SELECT created_at FROM 
(SELECT @start := @start + 1 AS id, created_at FROM time_table ORDER BY created_at) AS tmp WHERE id = 5);

-- after delete:
SELECT * FROM time_table ORDER BY created_at DESC;

