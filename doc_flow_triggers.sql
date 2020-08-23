USE doc_flow;

/* 1. Trigger to automatically set `is_sent` value to 1 in `versions` table 
when corresponding documentation is added to `dispatches` table
 */
DROP TRIGGER IF EXISTS change_is_sent_status;

DELIMITER $
CREATE 
	TRIGGER change_is_sent_status
	AFTER INSERT 
	ON dispatches FOR EACH ROW 
		BEGIN 
			UPDATE versions v
			INNER JOIN dispatches d ON d.documentation_id = v.id
			SET v.is_sent = 1;
		END $
		
DELIMITER ;

/* To check: add versions of documentation in `version` table (before doing you have to execute
procedures 3 and 4 to add new project (project_id = 16) and new documetation) with `is_sent` value = default (0)
 */
INSERT INTO versions VALUES
	-- 'ПС 220 кВ Озерная с заходами ВЛ 220 кВ' project_id = 16
	(NULL, 153, 0, '2020-08-01', DEFAULT), (NULL, 154, 0, '2020-08-01', DEFAULT),
	(NULL, 155, 0, '2020-08-01', DEFAULT), (NULL, 156, 0, '2020-07-20', DEFAULT);

-- Check that `is_sent` in last four new added versions equal 0 now
SELECT * FROM versions ORDER BY id DESC LIMIT 4;

-- Now create new invoice to send our last new added documentation to customer 
INSERT INTO invoices VALUES
	(NULL, 'ПИР-175-И-2020-003', '2020-08-14', DEFAULT, 5, 21); -- 'ПС 220 кВ Озерная с заходами ВЛ 220 кВ' project_id = 16
	
-- Now create new dispatches to sent our 4 books of new added documentation
INSERT INTO dispatches VALUES
	(NULL, 29, 232), (NULL, 29, 233), (NULL, 29, 234), (NULL, 29, 235); -- project_id 16	

-- Now check to be sure trigger `change_is_sent_status` did it's work
SELECT * FROM versions ORDER BY id DESC LIMIT 4;
-- `is_sent` automatically changed from 0 to 1 after adding new dicumentation in dispatches
	

/* 2. trigger to automatically set an email for new employee. trigger works jointly with convert_func
 */
DROP FUNCTION IF EXISTS convert_func;

-- Function to convert russian letters into english 
DELIMITER $$
CREATE FUNCTION convert_func (original VARCHAR(512)) RETURNS VARCHAR(512) CHARSET utf8 READS SQL DATA
	BEGIN
		DECLARE translit VARCHAR(512) DEFAULT '';
		DECLARE len INT(3) DEFAULT 0;
		DECLARE pos INT(3) DEFAULT 1;
		DECLARE letter CHAR(4);     
		
		SET original = original;
		SET len = CHAR_LENGTH(original);
		 
		WHILE (pos <= len) DO
			SET letter = SUBSTRING(original, pos, 1);
		
			CASE TRUE
				WHEN letter = 'а' THEN SET letter = 'a';		
				WHEN letter = 'б' THEN SET letter = 'b';
				WHEN letter = 'в' THEN SET letter = 'v';
				WHEN letter = 'г' THEN SET letter = 'g';
				WHEN letter = 'д' THEN SET letter = 'd';
				WHEN letter = 'е' THEN SET letter = 'e';
				WHEN letter = 'ж' THEN SET letter = 'zh';
				WHEN letter = 'з' THEN SET letter = 'z';
				WHEN letter = 'и' THEN SET letter = 'i';
				WHEN letter = 'й' THEN SET letter = 'i';
				WHEN letter = 'к' THEN SET letter = 'k';
				WHEN letter = 'л' THEN SET letter = 'l';
				WHEN letter = 'м' THEN SET letter = 'm';
				WHEN letter = 'н' THEN SET letter = 'n';
				WHEN letter = 'о' THEN SET letter = 'o';
				WHEN letter = 'п' THEN SET letter = 'p';
				WHEN letter = 'р' THEN SET letter = 'r';
				WHEN letter = 'т' THEN SET letter = 't';
				WHEN letter = 'ф' THEN SET letter = 'f';
				WHEN letter = 'х' THEN SET letter = 'ch';
				WHEN letter = 'ц' THEN SET letter = 'c';
				WHEN letter = 'ч' THEN SET letter = 'ch';
				WHEN letter = 'ш' THEN SET letter = 'sh';
				WHEN letter = 'щ' THEN SET letter = 'shch';
				WHEN letter = 'ъ' THEN SET letter = '';
				WHEN letter = 'ы' THEN SET letter = 'y';
				WHEN letter = 'э' THEN SET letter = 'e';
				WHEN letter = 'ю' THEN SET letter = 'ju';
				WHEN letter = 'я' THEN SET letter = 'ja';
				ELSE SET letter = '_';
			END CASE;
		
			SET translit = CONCAT(translit, letter);
			SET pos = pos + 1;
		
		END WHILE;
		RETURN CONCAT(translit, '@cius-ees.ru');
 
	END $$
 
DELIMITER ;

-- Trigger automatically sets an email for new added employee using convert_func
DROP TRIGGER IF EXISTS set_emp_email;

DELIMITER $
CREATE 
	TRIGGER set_emp_email
	BEFORE INSERT 
	ON employees FOR EACH ROW 
		BEGIN
			SET @lastname = NEW.lastname;
			SET @firstname = NEW.firstname;
			SET @middlename = NEW.middlename;
			SET @rus_mail = LOWER(CONCAT(@lastname, '_', SUBSTRING(@firstname, 1, 1), SUBSTRING(@middlename, 1, 1)));
			SET NEW.email = convert_func (@rus_mail);
		END $
		
DELIMITER ;

-- To check. Email was automatically established
INSERT INTO employees (id,  lastname, firstname, middlename, department_id, division_id, phone_id, position_id) VALUES
	(NULL, 'Андреев', 'Борис', 'Владимирович', 1, 1, 1, 5);

SELECT * FROM employees WHERE lastname = 'Андреев';

/* 3. Trigger to validate a number of invoice before adding it in invoice table.
number of invoice has to correspond with first seven digits of contract number
 */
DROP TRIGGER IF EXISTS check_invoice_insert;

DELIMITER $
CREATE 
	TRIGGER check_invoice_insert
	BEFORE INSERT 
	ON invoices FOR EACH ROW 
		BEGIN 
			DECLARE warn_msg varchar(128);
			IF (SELECT LEFT(NEW.invoice_number, 7)) NOT IN (SELECT contract_number FROM projects) THEN
				SET warn_msg = CONCAT('TriggerError: Trying to insert not valid number for invoice: ', NEW.invoice_number);
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = warn_msg;
			END IF;
		END $
		
DELIMITER ;
	
-- To check. Add new invoice with invoice number that doesn't correspond to any project contract number
INSERT INTO invoices VALUES
	(NULL, 'ПИР-274-И-2020-002', '2020-06-25', DEFAULT, 1, 21); -- ПИР-274 doesn't exists in projcts table

/* 4. Trigger to validate a number of invoice before updating it in invoice table.
number of invoice has to correspond with first seven digits of contract number.
This trigger has to protect from changing present invoice numbers in table
 */

DROP TRIGGER IF EXISTS check_invoice_update;

DELIMITER $
CREATE 
	TRIGGER check_invoice_update
	BEFORE UPDATE 
	ON invoices FOR EACH ROW 
		BEGIN 
			DECLARE warn_msg varchar(128);
			IF (SELECT LEFT(NEW.invoice_number, 7)) NOT IN (SELECT contract_number FROM projects) THEN
				SET warn_msg = CONCAT('TriggerError: Trying to update to not valid number for invoice: ', NEW.invoice_number);
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = warn_msg;
			END IF;
		END $
		
DELIMITER ;

-- To check. Update existing invoice with invoice number that doesn't correspond to any project contract number
UPDATE invoices 
	SET invoice_number = 'ПИР-375-И-2018-002' WHERE id = 1; -- ПИР-375 doesn't exists in projcts table
