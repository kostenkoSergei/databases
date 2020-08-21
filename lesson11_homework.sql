USE shop;

/*
Практическое задание по теме “Оптимизация запросов”
Задание 1. 
Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users,
catalogs и products в таблицу logs помещается время и дата создания записи, название 
таблицы, идентификатор первичного ключа и содержимое поля name.
*/
DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
	id SERIAL,
	`date` 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'insertion date and time', 
	tbl_name VARCHAR(20) COMMENT 'the name of the table into which the data was inserted',
	str_id BIGINT UNSIGNED NOT NULL COMMENT 'id of the row into which the data was inserted',
	name_data VARCHAR(300) COMMENT 'content of the `name` column from table into which the data was inserted'
) COMMENT 'log table includes information about insert operation into `users`, `catalogs` and `products` tables'
ENGINE=Archive;

-- create a procedure that will inset data in a result of triggers work (try to implement DRY)
DROP PROCEDURE IF EXISTS sp_insert;

DELIMITER $

CREATE PROCEDURE sp_insert (tbl_name VARCHAR(20), str_id BIGINT, name_data VARCHAR(300))
BEGIN
	DECLARE tbl VARCHAR(20);
	DECLARE str BIGINT;
	DECLARE `data` VARCHAR(300);
	SET tbl = tbl_name;
	SET str = str_id;
	SET `data` = name_data;
	INSERT INTO logs (tbl_name, str_id, name_data)
	VALUES (tbl, str, `data`);
END $

DELIMITER ;

-- create trigger that will insert data in logs table after insert in users table
DROP TRIGGER IF EXISTS users_insert;

DELIMITER $

CREATE 
	TRIGGER users_insert AFTER INSERT ON users 
	FOR EACH ROW
	BEGIN
		CALL sp_insert ('users', NEW.id, NEW.name);
	END $
	
DELIMITER ;

-- to check
INSERT INTO users (name, birthday_at) VALUES
  ('Jim', '1990-10-05'),
  ('Joe', '1984-11-12');

-- create trigger that will insert data in logs table after insert in catalogs table
DROP TRIGGER IF EXISTS catalogs_insert;

DELIMITER $

CREATE 
	TRIGGER catalogs_insert AFTER INSERT ON catalogs 
	FOR EACH ROW
	BEGIN
		CALL sp_insert ('catalogs', NEW.id, NEW.name);
	END $
	
DELIMITER ;

-- to check
INSERT INTO catalogs VALUES
  (NULL, 'Some stuff'),
  (NULL, 'Unknown stuff');

-- create trigger that will insert data in logs table after insert in products table
DROP TRIGGER IF EXISTS products_insert;

DELIMITER $

CREATE 
	TRIGGER products_insert AFTER INSERT ON products 
	FOR EACH ROW
	BEGIN
		CALL sp_insert ('products', NEW.id, NEW.name);
	END $
	
DELIMITER ;

-- to check
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i9-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 17890.00, 1),
  ('Intel Core i7-7450', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 50700.00, 1);

/*Задание 2. 
(по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей
*/
DROP PROCEDURE IF EXISTS sp_insert_rand_users; 
 
DELIMITER $
 
CREATE PROCEDURE sp_insert_rand_users()
BEGIN
	DECLARE i INT DEFAULT 1;

  WHILE i < 1000001 DO
  	SET @MIN = '1987-04-30 14:53:27';
	SET @MAX = '2000-04-30 14:53:27';
	SET @birthday = (SELECT DATE(TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, @MIN, @MAX)), @MIN)));
    INSERT INTO users (name, birthday_at) VALUES ('abstract_user', @birthday);
    SET i = i + 1;
  END WHILE;
END $

-- cause it's very long process i checked it with 1000 rows 
CALL sp_insert_rand_users ();
