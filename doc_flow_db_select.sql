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
SET @contract_number = 'ПИР-118';
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
SELECT code FROM documentation WHERE project_id = 4;

-- 7. select documentation are not finished on current date and persons responsible for it
SELECT 
	d.code AS doc_code, d.name AS doc_name, employees.fullname AS responsible 
FROM 
	documentation d
INNER JOIN
	employees ON d.curator_id = employees.id
WHERE 
	d.finished_at > NOW();


