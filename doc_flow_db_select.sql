USE doc_flow;

-- select all projects and corresponding customers
SELECT 
	p.name AS projects_list , c.name AS customers_list
FROM 
	projects p
INNER JOIN customers c ON p.customer_id = c.id
ORDER BY c.name;

-- select all working documentation corresponding with project 'Строительство ПС 330 кВ Мурманская'
SELECT code, name, started_at, finished_at FROM documentation 
WHERE 
	project_id = (SELECT id FROM projects WHERE name LIKE '%Мурманская%')
AND 
	stage_id = (SELECT id FROM stages WHERE name = 'РД');



