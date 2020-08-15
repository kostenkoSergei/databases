USE shop;
/*
 “Хранимые процедуры и функции, триггеры"
Задание 1. 
Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна 
возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать 
фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
*/
DROP FUNCTION IF EXISTS hello;
DELIMITER $

CREATE FUNCTION hello ()
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
	DECLARE greeting VARCHAR(20);
	CASE
		WHEN CURRENT_TIME() BETWEEN '06:00:00' AND '11:59:59' THEN SET greeting = 'Дорое утро';
		WHEN CURRENT_TIME() BETWEEN '12:00:00' AND '17:59:59' THEN SET greeting = 'Добрый день';
		WHEN CURRENT_TIME() BETWEEN '18:00:00' AND '23:59:59' THEN SET greeting = 'Добрый вечер';
		ELSE SET greeting = 'Доброй ночи';
	END CASE;
	RETURN greeting;
END $

DELIMITER ;

SELECT hello();

/*
Задание 2. 
В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное 
значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля 
были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/
DROP TRIGGER IF EXISTS prod_ins;
DELIMITER $

CREATE TRIGGER prod_ins BEFORE INSERT ON products 
FOR EACH ROW
BEGIN 
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
  	END IF;
END $

-- to check:
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  (NULL, NULL, 7890.00, 2);
 
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', NULL, 7890.00, 1);

SELECT * FROM products;
 
/*
Задание 3. 
(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи
 называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции 
 FIBONACCI(10) должен возвращать число 55
*/
-- first way using recursion
DROP PROCEDURE IF EXISTS FIBONACCI_REC;

DELIMITER $
CREATE PROCEDURE FIBONACCI_REC(n INT, OUT out_fib INT)
BEGIN
  DECLARE n_1 INT;
  DECLARE n_2 INT;

  IF (n = 0) THEN
    SET out_fib = 0;
  ELSEIF (n = 1) then
    SET out_fib=1;
  ELSE
    CALL FIBONACCI_REC(n-1, n_1);
    CALL FIBONACCI_REC(n-2, n_2);
    SET out_fib = (n_1 + n_2);
  END IF;
END $

DELIMITER ;

SET max_sp_recursion_depth = 255;
CALL FIBONACCI_REC(10, @fib);
SELECT @fib;

-- second way using cycle
DROP PROCEDURE IF EXISTS FIBONACCI_WHILE;
DELIMITER $

CREATE PROCEDURE FIBONACCI_WHILE(n INT, OUT out_fib INT)
BEGIN
	DECLARE m INT default 0;
	DECLARE k INT DEFAULT 1;
	DECLARE i INT;
	DECLARE tmp INT;
	
	SET m = 0;
	SET k = 1;
	SET i = 1;

	WHILE (i <= n) DO
	    SET tmp = m + k;
	    SET m = k;
	    SET k = tmp;
	    SET i = i + 1;
	END WHILE;
  	SET out_fib = m;
END $
 
DELIMITER ;

CALL FIBONACCI_WHILE(10, @fib_w);
SELECT @fib_w;

/*tried to create a function not a procedure but Recursive stored functions and triggers are not allowed.
MySQL does not allow recursive FUNCTIONs, even if you set max_sp_recursion_depth.

DROP FUNCTION IF EXISTS FIBONACCI;
DELIMITER $

CREATE FUNCTION FIBONACCI(n_in INT)
RETURNS INT DETERMINISTIC
BEGIN
	IF n_in = 0 THEN 
		RETURN 0;
	ELSEIF n_in = 1 THEN 
		RETURN 1;
	ELSE
	 	RETURN (FIBONACCI (n_in - 1) + FIBONACCI (n_in - 2));
	END IF;
END $
*/
