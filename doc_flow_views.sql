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

-- 2. view to show all unfinished documentation at the moment and people who are responsible
DROP VIEW IF EXISTS unfinished_doc;
CREATE VIEW unfinished_doc
AS
	SELECT code, d.name AS documentation, s.name AS stage, e.fullname AS curator, p.name AS project, c.name AS customer
	FROM 
		documentation d
	INNER JOIN employees e ON d.curator_id = e.id
	INNER JOIN projects p ON d.project_id = p.id
	INNER JOIN customers c ON p.customer_id = c.id
	INNER JOIN stages s ON d.stage_id = s.id
	WHERE d.finished_at > NOW();	
	
-- 3. view to show all controlled projects
DROP VIEW IF EXISTS project_info;
CREATE VIEW project_info
AS
	SELECT p.name AS title, c.name AS customer, g.name AS gencontractor, s.name AS subcontractor, e.name AS expertise
	FROM 
		projects p
	INNER JOIN customers c ON p.customer_id = c.id 
	INNER JOIN gencontractors g ON p.gencontractor_id = g.id 
	INNER JOIN subcontractors s ON p.subcontractor_id = s.id 
	INNER JOIN expertises e ON p.expertise_id = e.id;
		
		
		