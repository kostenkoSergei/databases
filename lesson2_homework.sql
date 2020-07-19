/* Задача 1 Установите СУБД MySQL. Создайте в домашней директории файл .my.cnf,
задав в нем логин и пароль, который указывался при установке. 
Решение: Cоздал my.cnf с содержимым: 
[mysql] 
user=root 
password="""тут мой пароль""" 
положил файл в: 
C:\ */

/* Задача 2
Создайте базу данных example, разместите в ней таблицу users, 
состоящую из двух столбцов, числового id и строкового name.
*/
-- create database example 
create database if not exists example;
use example;
-- create a table users that consists of two columns
drop table if exists users;
create table if not exists users (
id serial primary key,
name varchar(50) COMMENT 'User\'s name'
);
-- add some users in table
insert into users values
(default, 'Ivan'),
(default, 'Peter'),
(default, 'Ann');

select * from users;

/* Задача 3
Создайте дамп базы данных example из предыдущего задания, 
разверните содержимое дампа в новую базу данных sample.
Решение:
Подкорректировал my.cnf:
[client]
user=root
password="""тут мой пароль"""
-----------------------------
C:\Program Files\MySQL\MySQL Server 8.0\bin>mysqldump example > D:\example.sql
C:\Program Files\MySQL\MySQL Server 8.0\bin>mysql
mysql> create database sample;
mysql> exit
C:\Program Files\MySQL\MySQL Server 8.0\bin>mysql sample < D:\example.sql
mysql> use sample
mysql> select * from users;
+----+-------+
| id | name  |
+----+-------+
|  1 | Ivan  |
|  2 | Peter |
|  3 | Ann   |
+----+-------+
3 rows in set (0.00 sec)
*/

/* Задача 4
(по желанию) Ознакомьтесь более подробно с документацией утилиты mysqldump. 
Создайте дамп единственной таблицы help_keyword базы данных mysql. 
Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.
Решение:
C:\Program Files\MySQL\MySQL Server 8.0\bin>mysqldump mysql help_keyword --where="true limit 100" > D:\help_keyword_100.sql
*/
