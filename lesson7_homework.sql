USE shop;
/*Задание 1. 
Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине
*/
-- in attached file table orders is empty so add some orders in it:
INSERT INTO orders (user_id) VALUES (1), (3), (2), (3), (5);
SELECT name, COUNT(*) AS amount
FROM 
	users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY name
ORDER BY amount;

/*Задание 2. 
Выведите список товаров products и разделов catalogs, который соответствует товару
*/
SELECT p.name AS product, c.name AS `catalog`
FROM 
	products p 
INNER JOIN catalogs c ON p.catalog_id = c.id;

/*Задание 3. 
(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label,
name). Поля from, to и label содержат английские названия городов, поле name — русское.
Выведите список рейсов flights с русскими названиями городов.
*/
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
	id SERIAL,
	`from` VARCHAR(30) DEFAULT 'unknown',
	`to` VARCHAR(30) DEFAULT 'unknown'
);

INSERT INTO flights VALUES
	(NULL, 'moscow', 'omsk'), (NULL, 'novgorod', 'kazan'), (NULL, 'irkutsk', 'moscow'),
	(NULL, 'omsk', 'irkutsk'), (NULL, 'moscow', 'kazan');

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	label VARCHAR(30),
	name VARCHAR(30)
);

INSERT INTO cities VALUES
	('moscow', 'Москва'), ('irkutsk', 'Иркутск'), ('novgorod', 'Новгород'), ('kazan', 'Казань'), ('omsk', 'Омск');

SELECT
	id,
	(SELECT name FROM cities c WHERE c.label = f.from) AS `from`,
	(SELECT name FROM cities c WHERE c.label = f.to) AS `to`
FROM flights f;



