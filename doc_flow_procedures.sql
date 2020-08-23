USE doc_flow;
/* 1. procedure to request some list of documentation knowing
 part of project name and stage
 */
DROP PROCEDURE IF EXISTS sp_show_docs;

DELIMITER $
CREATE PROCEDURE sp_show_docs (proj_name_part VARCHAR(50), stage_name VARCHAR(3))
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

CALL sp_show_docs ('Псков', 'РД'); -- select working documentation corresponding 'ВЛ 330 кВ Псков-Лужская' project
CALL sp_show_docs ('Харан', 'ПД'); -- select project documentation corresponding 'Строительство ВЛ 220 кВ Харанорская ГЭС - Бугдаинская - Быстринская'

/* 2. procedure to add some customer, or subcontractor, or gencontractor
(this three tables have the same structure)
 */
DROP PROCEDURE IF EXISTS sp_insert_csg;

DELIMITER $
CREATE PROCEDURE sp_insert_csg (tbl_name VARCHAR(30), name VARCHAR(255), city_id BIGINT,
address VARCHAR(255), email VARCHAR(50), phone BIGINT, cio VARCHAR(100), cto VARCHAR(100))
BEGIN
	SET @sql = CONCAT('INSERT INTO ', tbl_name, ' VALUES', '(', 'NULL', ', ', name, ', ', city_id, ', ', address, ', ', 
	email, ', ', phone, ', ' , cio, ', ' , cto, ');');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;

END $

DELIMITER ;

-- to check
CALL sp_insert_csg ('customers', '"МЭС Юга"', '5', '"пер. Дарницкий 2"', '"org@umes.kmv.ru"', '88793343611', 
'"Петров А.А."', '"Иванов Б.Б."'); -- add a customer
CALL sp_insert_csg ('subcontractors', '"НТЦ ФСК ЕЭС"', '1', '"Каширское ш., д.22к3"', '"info@ntc-power.ru"', '74957271909', 
'"Стулов А.А."', '"Столов Б.Б."'); -- add a subcontractor

-- 3. procedure to add some new project
DROP PROCEDURE IF EXISTS sp_add_project;

DELIMITER $
CREATE PROCEDURE sp_add_project (title VARCHAR(500), contract VARCHAR(30), cust VARCHAR(100), gen VARCHAR(100), sub VARCHAR(100),
`start` DATE, expertise VARCHAR(100), OUT tran_result VARCHAR(200))
BEGIN
	DECLARE `_rollback` BOOL DEFAULT 0;
	DECLARE error_code VARCHAR(100);
	DECLARE error_string VARCHAR(100);
	DECLARE cust_id BIGINT;
	DECLARE gen_id BIGINT;
	DECLARE sub_id BIGINT;
	DECLARE exp_id BIGINT;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		SET `_rollback` = 1;
		GET stacked DIAGNOSTICS CONDITION 1
			error_code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result := CONCAT('Error occured. Code: ', error_code, '. Text: ', error_string);
	END;

	SET cust_id = (SELECT id FROM customers WHERE name = cust);
	SET gen_id = (SELECT id FROM gencontractors WHERE name = gen);
	SET sub_id = (SELECT id FROM subcontractors WHERE name = sub);
	SET exp_id = (SELECT id FROM expertises WHERE name = expertise);

	START TRANSACTION;
		INSERT INTO projects (name, contract_number, customer_id, gencontractor_id, subcontractor_id, started_at, expertise_id) 
		VALUES (title, contract, cust_id, gen_id, sub_id, `start`, exp_id);
		IF `_rollback` THEN
			ROLLBACK;
		ELSE
			SET tran_result = 'Successfully';
			COMMIT;
		END IF;

END $

-- insert some valid data
CALL sp_add_project ('ПС 220 кВ Озерная с заходами ВЛ 220 кВ', 'ПИР-175', 'ПАО ФСК ЕЭС МЭС Сибири', 'ООО АРСЕНАЛ ПЛЮС',
'ЗАО Энергопроект', '2020-08-06', 'ГАУ Госэкспертиза Кузбасса', @tran_result);

SELECT @tran_result; -- check if insert was successfull (yes)

-- try to insert some invalid data
CALL sp_add_project ('ПС 220 кВ Озерная с заходами ВЛ 220 кВ', 'ПИР-175', 'ПАО ФСК ЕЭС МЭС Сибири', 'ООО АРСЕНАЛ ПЛЮС',
'ЗАО Энергопроект', '2020-08-06', 'ГАУ Госэкспертиза Китая', @tran_result);

SELECT @tran_result; -- check if insert was successfull (no)

-- 4. procedure to add some new documentation
DROP PROCEDURE IF EXISTS sp_add_docum;

DELIMITER $
CREATE PROCEDURE sp_add_docum (code VARCHAR(30), name VARCHAR(255), p_id BIGINT, stage VARCHAR(10), 
`start` DATE, cur VARCHAR(30), OUT tran_result VARCHAR(200))
BEGIN
	DECLARE `_rollback` BOOL DEFAULT 0;
	DECLARE error_code VARCHAR(100);
	DECLARE error_string VARCHAR(100);
	DECLARE stg_id BIGINT;
	DECLARE cur_id BIGINT;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		SET `_rollback` = 1;
		GET stacked DIAGNOSTICS CONDITION 1
			error_code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result := CONCAT('Error occured. Code: ', error_code, '. Text: ', error_string);
	END;

	SELECT id INTO stg_id FROM stages WHERE stages.name = stage;
	SELECT id INTO cur_id  FROM employees WHERE fullname = cur;
	
	START TRANSACTION;
		INSERT INTO documentation (code, name, project_id, stage_id, started_at, curator_id) VALUES
		(code, name, p_id, stg_id, `start`, cur_id);
		IF `_rollback` THEN
			ROLLBACK;
		ELSE
			SET tran_result = 'Successfully';
			COMMIT;
		END IF;

END $

DELIMITER ;

/* add some new documentation for project 'ПС 220 кВ Озерная с заходами ВЛ 220 кВ'
 which has project_id = 16 after calling previous sp_add_project procedure
 */
CALL sp_add_docum 
('П0750-ИОС4.1', 'Автоматизированная система управления технологическими процессами', 16, 'ПД', '2020-08-01', 'Соколов Владимир', @tran_result);
CALL sp_add_docum 
('П0750-ИОС4.2', 'Релейная защита и противоаварийная автоматика', 16, 'ПД', '2020-08-01', 'Соколов Владимир', @tran_result);
CALL sp_add_docum 
('П0750-ИОС4.3', 'Сети связи', 16, 'ПД', '2020-08-01', 'Соколов Владимир', @tran_result);
CALL sp_add_docum
('П0750-ППО', 'Предпроектное обследование', 16, 'ППО', '2020-07-20', 'Соколов Владимир', @tran_result);

SELECT @tran_result; -- check if last insert was successfull (yes)

-- try to insert some invalid data
CALL sp_add_docum
('П0750-КД', 'Предпроектное обследование', 16, 'ППО', '2020-07-20', 'Неизвестная личность', @tran_result);

SELECT @tran_result; -- check if last insert was successfull (no)


