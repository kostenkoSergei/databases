USE doc_flow;
/* 1. procedure to request some list of documentation knowing
 part of project name and stage
 */
DROP PROCEDURE IF EXISTS show_docs;
DELIMITER $
CREATE PROCEDURE show_docs (proj_name_part VARCHAR(50), stage_name VARCHAR(3))
BEGIN
	SELECT 
		p.name AS title, d.code AS code, d.name AS documentation, 
		s.name AS stage, v.version_number AS `version`, DATE_FORMAT(v.version_date,'%d.%m.%Y') AS `version date`,
		e.fullname AS responsible, ph.phone_number AS `phone number`
	FROM 
		projects p
	INNER JOIN documentation d ON p.id = d.project_id
	INNER JOIN stages s ON d.stage_id = s.id
	INNER JOIN versions v ON d.id = v.documentation_id
	INNER JOIN employees e ON d.curator_id = e.id 
	INNER JOIN phone_numbers ph ON e.phone_id = ph.id
	WHERE p.name LIKE CONCAT('%', proj_name_part, '%') AND s.name = stage_name;
END $
DELIMITER ;

CALL show_docs ('Псков', 'РД');
CALL show_docs ('Харан', 'ПД');

/* 2. to add some customer, or subcontractor, or gencontractor
(this three tables have the same structure)
 */
DROP PROCEDURE IF EXISTS insert_csg;
DELIMITER $
CREATE PROCEDURE insert_csg (tbl_name VARCHAR(30), name VARCHAR(255), city_id BIGINT,
address VARCHAR(255), email VARCHAR(50), phone BIGINT, cio VARCHAR(100), cto VARCHAR(100))
BEGIN
	SET @sql = CONCAT('INSERT INTO ', tbl_name, ' VALUES', '(', 'NULL', ', ', name, ', ', city_id, ', ', address, ', ', 
	email, ', ', phone, ', ' , cio, ', ' , cto, ');');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
END $
DELIMITER ;

CALL insert_csg ('customers', '"МЭС Юга"', '5', '"пер. Дарницкий 2"', '"org@umes.kmv.ru"', '88793343611', 
'"Петров А.А."', '"Иванов Б.Б."');
CALL insert_csg ('subcontractors', '"НТЦ ФСК ЕЭС"', '1', '"Каширское ш., д.22к3"', '"info@ntc-power.ru"', '74957271909', 
'"Стулов А.А."', '"Столов Б.Б."');










