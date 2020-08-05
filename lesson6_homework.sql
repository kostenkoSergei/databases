USE vk;
/*Задание 1. 
Пусть задан некоторый пользователь. Из всех пользователей соц. сети 
найдите человека, который больше всех общался с выбранным пользователем
*/
-- first way:
SET @some_user = 1; -- will find a man who has the biggest number of messages to user with id = 1
SELECT 
	(SELECT CONCAT_WS(' ', firstname, lastname) FROM users WHERE users.id = from_user_id) AS the_most_talkative, 
	COUNT(*) AS amount_outgoing_messages 
FROM 
	messages WHERE to_user_id =1
GROUP BY from_user_id
ORDER BY amount_outgoing_messages DESC LIMIT 1;

-- second way:
SET @some_user = 1; -- will find a man who has the biggest number of messages to user with id = 1
SELECT 
	CONCAT_WS(' ', u.firstname, u.lastname) AS the_most_talkative, 
	COUNT(*) AS amount_outgoing_messages 
FROM 
	messages m
INNER JOIN users u ON u.id = m.from_user_id
WHERE to_user_id =1
GROUP BY from_user_id
ORDER BY amount_outgoing_messages DESC LIMIT 1;

/*Задание 2. 
Подсчитать общее количество лайков, которые получили пользователи младше 10 лет
*/
-- first way:
SELECT
	COUNT(*) AS child_likes
FROM 
	likes
WHERE 
	media_id 
IN
	(SELECT id FROM media WHERE user_id IN (SELECT user_id FROM profiles WHERE (DATEDIFF(NOW(), birthday) / 365.25) < 10));

-- second way:
SELECT 
	COUNT(*) AS child_likes
FROM 
	likes l
INNER JOIN media m ON l.media_id = m.id
INNER JOIN profiles p ON m.user_id = p.user_id
WHERE (DATEDIFF(NOW(), birthday) / 365.25) < 10;

/*Задание 3. 
Определить кто больше поставил лайков (всего): мужчины или женщины
*/
-- first way:
SELECT
	'male' AS 'gender',
	COUNT(*) AS likes_amount
FROM likes WHERE user_id IN (SELECT user_id FROM profiles WHERE gender = 'm')
	UNION 
SELECT
	'female' AS 'gender',
	COUNT(*) AS likes_amount
FROM likes WHERE user_id IN (SELECT user_id FROM profiles WHERE gender = 'f');

-- second way:
SELECT
	'male' AS 'gender',
	COUNT(*) AS likes_amount
FROM 
	likes l
INNER JOIN profiles p ON l.user_id = p.user_id
WHERE p.gender = 'm'
	UNION 
SELECT
	'female' AS 'gender',
	COUNT(*) AS likes_amount
FROM 
	likes l
INNER JOIN profiles p ON l.user_id = p.user_id
WHERE p.gender = 'f';


