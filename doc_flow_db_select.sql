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