USE vk;

/* Задание 1. Заполнить все таблицы БД vk данными (по 10-100 записей в каждой таблице)*/
INSERT INTO users VALUES
	(NULL, 'Tom', 'Hanks', 'test1@example.com', NULL, 5555555),
	(NULL, 'Ann', 'Swan', 'test2@example.com', NULL, 5555556),
	(NULL, 'Jack', 'Vorobiev', 'test3@example.com', NULL, 5555557),
	(NULL, 'Jim', 'Pupkin', 'test4@example.com', NULL, 5555558),
	(NULL, 'Donald', 'Trump', 'test5@example.com', NULL, 5555559),
	(NULL, 'Conor', 'McGregor', 'test6@example.com', NULL, 5555560),
	(NULL, 'Dana', 'White', 'test7@example.com', NULL, 5555561),
	(NULL, 'Jana', 'Petrova', 'test8@example.com', NULL, 5555562),
	(NULL, 'Steven', 'Thompson', 'test9@example.com', NULL, 5555563),
	(NULL, 'Kevin', 'Kattar', 'test10@example.com', NULL, 5555564),
	(NULL, 'Vasya', 'Pupkin', 'test11@example.com', NULL, 5555565),
	(NULL, 'Grishka', 'Otrepiev', 'test12@example.com', NULL, 5555568);
	
INSERT INTO photo_albums VALUES
	(NULL, 'vacation', 1), (NULL, 'me', 1), (NULL, 'pets', 1), (NULL, 'cats', 1),
	(NULL, 'job', 2), (NULL, 'me', 2), (NULL, 'cars', 2), (NULL, 'nature', 2),
	(NULL, 'girls', 3), (NULL, 'girls 2', 3), (NULL, 'girls 3', 2), (NULL, 'girls 4', 3), 
	(NULL, 'me', 4), (NULL, 'some people', 4), (NULL, 'family', 2), (NULL, 'cars', 3); 

INSERT INTO media_types (id, name) VALUES
	(NULL, 'photos'), (NULL, 'video'), (NULL, 'text'), (NULL, 'gif');

INSERT INTO media (id, media_type_id, user_id, body, filename, `size`, metadata) VALUES
	(NULL, 1, 1, 'some_photo', 'picture_1.jpeg', 512, NULL), (NULL, 1, 1, 'new_photo', 'picture_2.jpeg', 512, '{"some_key": "some_value"}'),
	(NULL, 2, 1, 'video_1', 'video_1.mpeg', 51200, NULL), (NULL, 2, 2, 'video_2', 'video_2.mpeg', 51200, NULL),
	(NULL, 3, 2, 'some_text', 'story.txt', 51, '{"some_book": "some_text"}'), (NULL, 4, 3, 'some_gif', 'video_1.gif', 512, NULL),
	(NULL, 1, 1, 'my_photo', 'picture_5.jpeg', 512, NULL), (NULL, 1, 5, 'my_photo_1', 'picture_35.jpeg', 512, NULL),
	(NULL, 1, 6, 'her_photo', 'picture_55.jpeg', 1024, NULL), (NULL, 2, 6, 'movie', 'video_2.mpeg', 15512, NULL),
	(NULL, 1, 5, 'pet_photo', 'picture_12.jpeg', 1024, NULL), (NULL, 1, 8, 'his_photo', 'picture_555.jpeg', 1024, NULL);
	
INSERT INTO messages (id, from_user_id, to_user_id, body) VALUES 
	(NULL, 1, 2, 'hello, how are you?'), (NULL, 2, 1, 'i am fine'), 
	(NULL, 1, 3, 'yo, brother'), (NULL, 3, 1, 'go away'),
	(NULL, 5, 6, 'bye'), (NULL, 5, 6, 'good morning'),
	(NULL, 8, 7, 'hi'), (NULL, 9, 10, 'are you ok?'), 
	(NULL, 1, 4, 'good night'), (NULL, 3, 4, 'hey'),
	(NULL, 4, 6, 'bye'), (NULL, 5, 7, 'how much does it costs?');

INSERT INTO profiles (user_id, gender, birthday, photo_id, created_at, hometown) VALUES
	(1, 'M', '1990-07-21', 1, DEFAULT, 'MOSCOW'), (2, 'F', '1990-08-05', 2, DEFAULT, 'SAINT-PETERSBURG'), 
	(3, 'M', '1985-02-21', 1, DEFAULT, 'TOKIO'), (4, 'M', '1951-08-05', 1, DEFAULT, 'LOS ANGELES'), 
	(5, 'M', '1925-02-21', 1, DEFAULT, 'MEXICO'), (6, 'M', '1951-08-05', 1, DEFAULT, 'LONDON'), 
	(7, 'M', '1995-02-11', 2, DEFAULT, 'LONDON'), (8, 'M', '2008-08-05', 1, DEFAULT, 'LONDON'), 
	(9, 'M', '2009-02-11', 2, DEFAULT, 'NEW YORK'), (10, 'M', '1965-09-05', 1, DEFAULT, 'LONDON'), 
	(11, 'M', '2005-08-11', 2, DEFAULT, 'MUMBAI'), (12, 'M', '2008-08-05', 1, DEFAULT, 'MINSK');
	
INSERT INTO photos VALUES
	(NULL, 1, 1), (NULL, 1, 2), (NULL, 2, 1), (NULL, 2, 2), (NULL, 4, 11), (NULL, 5, 2), 
	(NULL, 5, 12), (NULL, 3, 2), (NULL, 2, 11), (NULL, 7, 1), (NULL, 8, 2), (NULL, 6, 12);

INSERT INTO communities VALUES
	(NULL, 'community_1', 1), (NULL, 'community_2', 1), (NULL, 'community_3', 1), (NULL, 'community_4', 3), 
	(NULL, 'community_5', 3), (NULL, 'community_6', 7), (NULL, 'community_7', 3), (NULL, 'community_8', 11), 
	(NULL, 'community_9', 1), (NULL, 'community_10', 6), (NULL, 'community_11', 1), (NULL, 'community_12', 1);

INSERT INTO users_communities VALUES
	(1, 2), (2, 2), (11, 7), (12, 3), (5, 6), (1, 4), (4, 2), (5, 5), (11, 2), (12, 2), (1, 7), (7, 2);

INSERT INTO friend_requests VALUES
	(1, 2, 'requested', DEFAULT, DEFAULT), (1, 3, 'requested', DEFAULT, DEFAULT), (1, 4, 'requested', DEFAULT, DEFAULT),
	(1, 5, 'requested', DEFAULT, DEFAULT), (1, 6, 'requested', DEFAULT, DEFAULT), (1, 7, 'requested', DEFAULT, DEFAULT), 
	(1, 8, 'requested', DEFAULT, DEFAULT), (1, 9, 'requested', DEFAULT, DEFAULT), (1, 10, 'requested', DEFAULT, DEFAULT),
	(1, 11, 'requested', DEFAULT, DEFAULT), (3, 2, 'requested', DEFAULT, DEFAULT), (1, 12, 'requested', DEFAULT, DEFAULT);

UPDATE friend_requests -- just to check how it works
	SET status='approved'
	WHERE INITIATOR_USER_ID = 1 and TARGET_USER_ID = 3;

/* Задание 2. Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке*/
INSERT INTO users VALUES (NULL, 'Tom', 'Bobin', 'test13@example.com', NULL, 5555570); -- created user who has the same firstname with user1
SELECT DISTINCT firstname FROM users;

/* Задание 3. 
Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false). 
Предварительно добавить такое поле в таблицу profiles со значением по умолчанию = true (или 1)
*/
ALTER TABLE profiles 
	ADD COLUMN is_active TINYINT UNSIGNED DEFAULT 1;
UPDATE 	profiles 
	SET is_active=0 
	WHERE DATEDIFF(CURDATE(), birthday) < 18*365;

/* Задание 4. Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней)*/
INSERT INTO messages (id, from_user_id, to_user_id, body, created_at) VALUES
	(NULL, 1, 2, 'message from future 1', DATE_ADD(NOW(), INTERVAL 15 DAY)), -- created 'future messages'
	(NULL, 1, 3, 'message from future 2', DATE_ADD(NOW(), INTERVAL 20 DAY));
DELETE FROM messages
	WHERE created_at > NOW();


