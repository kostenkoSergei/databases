/* Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение*/
/*Задание 1. 
Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
Заполните их текущими датой и временем
*/
USE shop;
UPDATE users SET created_at = NOW(), updated_at = NOW();

/*Задание 2. 
Таблица users была неудачно спроектирована. Записи created_at и updated_at 
были заданы типом VARCHAR и в них долгое время помещались значения в формате 
"20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения
*/
-- created new table TEST cause didn't want to destroy table users that was created during lesson5
DROP TABLE IF EXISTS test;
CREATE TABLE test (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at varchar(255),
  updated_at varchar(255)
) COMMENT = 'Покупатели';

INSERT INTO test (name, birthday_at, created_at, updated_at) 
	VALUES ('Геннадий', '1990-10-05', '20.10.2017 8:10', '20.10.2017 8:10');

UPDATE test SET created_at = (STR_TO_DATE(created_at,'%d.%m.%Y %H:%i')), updated_at = (STR_TO_DATE(updated_at,'%d.%m.%Y %H:%i'));
ALTER TABLE test MODIFY created_at DATETIME;
ALTER TABLE test MODIFY updated_at DATETIME;

/*Задание 3. 
В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, 
если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи 
таким образом, чтобы они выводились в порядке увеличения значения value. Однако, нулевые запасы должны 
выводиться в конце, после всех записей
*/
INSERT INTO storehouses_products (value) VALUES
	(0), (2500), (0), (30), (500), (1);
SELECT value from storehouses_products ORDER BY value = 0 ASC, value; 

/*Задание 4. 
(по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
Месяцы заданы в виде списка английских названий ('may', 'august')
*/
SELECT * FROM users WHERE MONTHNAME(birthday_at) = 'may' OR MONTHNAME(birthday_at) = 'august';

/*Задание 5. 
(по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN
*/
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

/* Практическое задание теме “Агрегация данных”*/
/*Задание 1. 
Подсчитайте средний возраст пользователей в таблице users
*/
SELECT ROUND(AVG((DATEDIFF(CURDATE(), birthday_at)) / 365.25), 1) AS average_age FROM users; 

/*Задание 2. 
Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
Следует учесть, что необходимы дни недели текущего года, а не года рождения.
*/
SELECT
	COUNT(*), 
	CASE
		WHEN DAYNAME(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) = 'monday' THEN 'понедельник'
		WHEN DAYNAME(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) = 'tuesday' THEN 'вторник'
		WHEN DAYNAME(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) = 'wednesday' THEN 'среда'
		WHEN DAYNAME(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) = 'thursday' THEN 'четверг'
		WHEN DAYNAME(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) = 'friday' THEN 'пятница'
		WHEN DAYNAME(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) = 'saturday' THEN 'суббота'
		ELSE 'воскресенье'
  	END AS weekdays
FROM
  users
GROUP BY weekdays;

-- just to check. added two more people with the same birthdays
INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12');

/*Задание 3. 
(по желанию) Подсчитайте произведение чисел в столбце таблицы.
*/
DROP TABLE IF EXISTS test2;
CREATE TABLE test2 (
  number TINYINT PRIMARY KEY AUTO_INCREMENT
);
INSERT INTO test2 VALUES (NULL), (NULL), (NULL), (NULL), (NULL);
SELECT EXP(SUM(LOG(number))) FROM test2;


