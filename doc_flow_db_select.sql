USE doc_flow;

-- 1. select all projects and corresponding customers
SELECT 
	p.name AS projects_list , c.name AS customers_list
FROM 
	projects p
INNER JOIN customers c ON p.customer_id = c.id
ORDER BY c.name;

-- 2. select all working documentation corresponding with project 'Строительство ПС 330 кВ Мурманская'
SELECT code, name, started_at, finished_at FROM documentation 
WHERE 
	project_id = (SELECT id FROM projects WHERE name LIKE '%Мурманская%')
AND 
	stage_id = (SELECT id FROM stages WHERE name = 'РД');

-- 3. to analyze what documentation is more time consuming for development
SET @some_project_id = 1;
SELECT 
	code, d.name, s.name, DATEDIFF(finished_at, started_at) AS `time_to_develop(days)`
FROM 
	documentation d
INNER JOIN stages s ON s.id = d.stage_id
WHERE 
	d.project_id = @some_project_id
ORDER BY 
	`time_to_develop(days)` DESC;
	
-- 4. to check how many projects were ordered by every customer
SELECT
	IF(GROUPING(c.name)=1,'totally', c.name) AS customer,
	COUNT(*) AS total_number
FROM
	customers c
INNER JOIN projects p ON p.customer_id = c.id
GROUP BY c.name WITH ROLLUP;

-- 5. to check which customers don't have any orders in the past and right now
SELECT 
	c.name AS customer
FROM
	customers c
LEFT JOIN projects p ON p.customer_id = c.id
WHERE p.name IS NULL;

-- 6. to check list of documentation that was sent by some invoice knowing number of contract
SET @contract_number = 'ПИР-118'; -- you can choose other contract_number from projects table
SELECT 
	documentation.code AS doc_code, versions.version_number AS doc_version, 
	documentation.name AS doc_name, IF(versions.is_sent, 'true', 'false') completed 
FROM
	dispatches 
INNER JOIN	
	versions ON dispatches.documentation_id = versions.id
INNER JOIN	
	documentation ON documentation.id = versions.documentation_id
WHERE 
	dispatches.invoice_id IN (SELECT id FROM invoices WHERE invoice_number LIKE CONCAT (@contract_number,'%'))
ORDER BY doc_code DESC;

-- to check (project_id = 4 belongs to ПИР-118)
SELECT code FROM documentation WHERE project_id = 4; -- you can choose other project_id from projects table

-- 7. select documentation are not finished on current date and persons responsible for it
SELECT 
	d.code AS doc_code, d.name AS doc_name, employees.fullname AS responsible 
FROM 
	documentation d
INNER JOIN
	employees ON d.curator_id = employees.id
WHERE 
	d.finished_at > NOW();

-- 8. to find the invoice for which the documentation was sent and what exact version was sent
SET @some_code = '0115-004-СС'; -- you can choose other code from documentation table
SELECT 
	i.invoice_number AS invoice, 
	DATE_FORMAT(i.invoice_date,'%d.%m.%Y') AS `date`, doc.name AS documentation, v.version_number AS `version`
FROM 
	documentation doc
INNER JOIN versions v ON v.documentation_id = doc.id
INNER JOIN dispatches disp ON disp.documentation_id = v.id
INNER JOIN invoices i ON i.id = disp.invoice_id
WHERE 
	v.documentation_id = (SELECT id FROM documentation WHERE code = @some_code) AND is_sent = true;

-- 9. to find what documentation was sent in some period of time
SET @some_time = 140; -- you can set other value in days
SELECT
	d.code AS code, d.name AS documentation,
	v.version_number AS `version`, i.invoice_number AS invoice, DATE_FORMAT(i.invoice_date,'%d.%m.%Y') AS `date`
FROM 
	invoices i
INNER JOIN dispatches disp ON i.id = disp.invoice_id
INNER JOIN versions v ON disp.documentation_id = v.id
INNER JOIN documentation d ON v.documentation_id = d.id
WHERE 
	DATEDIFF(CURDATE(), i.invoice_date) <= @some_time;

-- 10. select with derived table
-- find an amount of working documentation finished at 2018 and 2019 and corresponding projects
SET @stage = 'РД'; -- you can choose other stage such as 'ПД', 'КД', 'ППО'
SELECT 
	p.name AS title, working_doc_2018_2019.amount 
FROM
	(SELECT 
		d.project_id AS project, COUNT(*) AS amount
	FROM
		documentation d
	INNER JOIN stages s ON d.stage_id = s.id 
	WHERE s.name = @stage and YEAR(d.finished_at) IN (2018, 2019)
	GROUP BY d.project_id) working_doc_2018_2019 
INNER JOIN projects p ON p.id = working_doc_2018_2019.project;



