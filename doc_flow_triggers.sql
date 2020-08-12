USE doc_flow;

/* 1. trigger to automatically set `is_sent` value to 1 in `versions` table 
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

/* to check: add versions of documentation in `version` table (before doing you have to execute
procedures 3 and 4 to add new project (project_id = 16) and new documetation) with `is_sent` value = default (0)
 */
INSERT INTO versions VALUES
	-- 'ПС 220 кВ Озерная с заходами ВЛ 220 кВ' project_id = 16
	(NULL, 153, 0, '2020-08-01', DEFAULT), (NULL, 154, 0, '2020-08-01', DEFAULT),
	(NULL, 155, 0, '2020-08-01', DEFAULT), (NULL, 156, 0, '2020-07-20', DEFAULT);

-- check that `is_sent` in last four new added versions equal 0
SELECT * FROM versions ORDER BY id DESC LIMIT 4;

-- now create new invoice to send our new added documentation to customer 
INSERT INTO invoices VALUES
	(NULL, 'ПИР-175-И-2020-003', '2020-08-14', DEFAULT, 5, 21); -- 'ПС 220 кВ Озерная с заходами ВЛ 220 кВ' project_id = 16
	
-- now create new dispatches to sent our 4 books of new added documentation
INSERT INTO dispatches VALUES
	(NULL, 29, 232), (NULL, 29, 233), (NULL, 29, 234), (NULL, 29, 235); -- project_id 16	

-- now check to be sure trigger `change_is_sent_status` did it's work
SELECT * FROM versions ORDER BY id DESC LIMIT 4;
-- `is_sent` automatically changed from 0 to 1 after adding new dicumentation in dispatches
	