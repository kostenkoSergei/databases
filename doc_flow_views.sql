USE doc_flow;

-- 1. view to represent all employees in convinient form
DROP VIEW IF EXISTS employees_info;
CREATE VIEW employees_info
AS
	SELECT fullname, p.name AS `position`, de.name AS department, di.name AS division, email, n.phone_number
	FROM 
		employees e
	INNER JOIN departments de ON e.department_id = de.id 
	INNER JOIN divisions di ON e.division_id = di.id
	INNER JOIN positions p ON e.position_id = p.id
	INNER JOIN phone_numbers n ON e.phone_id = n.id
	ORDER BY fullname;
