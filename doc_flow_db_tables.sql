DROP DATABASE IF EXISTS doc_flow;
CREATE DATABASE doc_flow;
USE doc_flow;

DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
	id SERIAL,
	name VARCHAR(100) 
) COMMENT 'departments of the controlling organization';

DROP TABLE IF EXISTS divisions;
CREATE TABLE divisions (
	id SERIAL,
	name VARCHAR(100),
	department_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (department_id) REFERENCES departments(id)
) COMMENT 'divisions of the controlling organization';

DROP TABLE IF EXISTS positions;
CREATE TABLE positions (
	id SERIAL,
	name VARCHAR(100)
) COMMENT 'positions in the controlling organisation';

DROP TABLE IF EXISTS phone_numbers;
CREATE TABLE phone_numbers (
	id SERIAL,
	phone_number BIGINT UNSIGNED NOT NULL
) COMMENT 'phone numbers of employees of the controlling organization';

DROP TABLE IF EXISTS stages;
CREATE TABLE stages(
	id SERIAL,
	name ENUM ('ПД', 'РД', 'КД', 'ППО') NOT NULL
	COMMENT 'ПД-project documentation, РД-working documentation, КД-tender documentation, ППО-pre-project survey'
) COMMENT 'stages of controlled documentation';

DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
	id SERIAL,
	city VARCHAR(50)
);

DROP TABLE IF EXISTS expertises;
CREATE TABLE expertises (
	id SERIAL,
	name VARCHAR(200),
	city_id BIGINT UNSIGNED NOT NULL,
	address VARCHAR(255),
	email VARCHAR(50),
	phone_number BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (city_id) REFERENCES cities(id)
) COMMENT 'expert organization issuing a conclusion of project\'s correctness';

DROP TABLE IF EXISTS subcontractors;
CREATE TABLE subcontractors(
	id SERIAL,
	name VARCHAR(255),
	city_id BIGINT UNSIGNED NOT NULL,
	address VARCHAR(255),
	email VARCHAR(50),
	phone_number BIGINT UNSIGNED NOT NULL,
	CIO VARCHAR(100) COMMENT 'general director of project organization',
	CTO VARCHAR(100) COMMENT 'technical director of project organization',
	FOREIGN KEY (city_id) REFERENCES cities(id)
) COMMENT 'project institutions or organizations which makes documentation for project';

DROP TABLE IF EXISTS gencontractors;
CREATE TABLE gencontractors (
	id SERIAL,
	name VARCHAR(255),
	city_id BIGINT UNSIGNED NOT NULL,
	address VARCHAR(255),
	email VARCHAR(50),
	phone_number BIGINT UNSIGNED NOT NULL,
	CIO VARCHAR(100) COMMENT 'general director of organization',
	CTO VARCHAR(100) COMMENT 'technical director of organization',
	FOREIGN KEY (city_id) REFERENCES cities(id)
) COMMENT 'organization which won tender on project';

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
	id SERIAL,
	name VARCHAR(255),
	city_id BIGINT UNSIGNED NOT NULL,
	address VARCHAR(255),
	email VARCHAR(50),
	phone_number BIGINT UNSIGNED NOT NULL,
	CIO VARCHAR(100) COMMENT 'general director of organization',
	CTO VARCHAR(100) COMMENT 'technical director of organization',
	FOREIGN KEY (city_id) REFERENCES cities(id)
) COMMENT 'organization which ordered the development of project';

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
	id SERIAL,
	lastname VARCHAR(30) NOT NULL,
	firstname VARCHAR(30) NOT NULL,
	middlename VARCHAR(30), -- a foreign worker may not have a middle name
	department_id BIGINT UNSIGNED NOT NULL,
	division_id BIGINT UNSIGNED NOT NULL,
	email VARCHAR(50) UNIQUE,
	phone_id BIGINT UNSIGNED NOT NULL,
	position_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (department_id) REFERENCES departments(id),
	FOREIGN KEY (division_id) REFERENCES divisions(id),
	FOREIGN KEY (phone_id) REFERENCES phone_numbers(id),
	FOREIGN KEY (position_id) REFERENCES positions(id),
	INDEX idx_employees_name (firstname, lastname),
	CHECK (RIGHT(email, 12) = '@cius-ees.ru')
) COMMENT 'employees of the controlling organization';

DROP TABLE IF EXISTS projets;
CREATE TABLE projects (
	id SERIAL,
	name VARCHAR(500) COMMENT 'official title of controlled project',
	contract_number VARCHAR(30) UNIQUE COMMENT 'contract number for support of the project',
	customer_id BIGINT UNSIGNED NOT NULL,
	gencontractor_id BIGINT UNSIGNED NOT NULL,
	subcontractor_id BIGINT UNSIGNED NOT NULL,
	started_at DATE NOT NULL,
	finished_at DATE DEFAULT '2099-12-31',
	expertise_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES customers(id),
	FOREIGN KEY (gencontractor_id) REFERENCES gencontractors(id),
	FOREIGN KEY (subcontractor_id) REFERENCES subcontractors(id),
	FOREIGN KEY (expertise_id) REFERENCES expertises(id)
) COMMENT 'list of all projects controlled by controlling organization';

DROP TABLE IF EXISTS documentation;
CREATE TABLE documentation(
	id SERIAL,
	code VARCHAR(30) UNIQUE COMMENT 'unique code for book or volume of documentation',
	name VARCHAR(255) COMMENT 'name of book or volume of documentation',
	project_id BIGINT UNSIGNED NOT NULL COMMENT 'id of project that this book or volume of documentation belongs',
	stage_id BIGINT UNSIGNED NOT NULL COMMENT 'stage of documetation such as \'ПД\', \'РД\' and so on',
	started_at DATE NOT NULL,
	finished_at DATE DEFAULT '2099-12-31',
	curator_id BIGINT UNSIGNED NOT NULL COMMENT 'employee who is in charge of controlling of making of documentation',
	note VARCHAR(500),
	FOREIGN KEY (project_id) REFERENCES projects(id),
	FOREIGN KEY (stage_id) REFERENCES stages(id),
	FOREIGN KEY (curator_id) REFERENCES employees(id)
) COMMENT 'all controlled documentation (books, volumes for all projects';

DROP TABLE IF EXISTS versions;
CREATE TABLE versions (
	id SERIAL,
	documentation_id BIGINT UNSIGNED NOT NULL,
	version_number TINYINT UNSIGNED COMMENT 'version number of book or volume of documentation',
	version_date DATE NOT NULL,
	is_sent ENUM ('no', 'yes') NOT NULL COMMENT 'is this book or volume of documentation sent to customer',
	FOREIGN KEY (documentation_id) REFERENCES documentation(id)
) COMMENT 'list of all documentation with versions';

DROP TABLE IF EXISTS dispatches;
CREATE TABLE dispatches (
	id SERIAL,
	disp_number CHAR(20) NOT NULL COMMENT 'delivery note number',
	documentation_id BIGINT UNSIGNED NOT NULL COMMENT 'documentation that was sent by this delivery note',
	address VARCHAR(255) NOT NULL,
	amount TINYINT UNSIGNED NOT NULL,
	customer_id BIGINT UNSIGNED NOT NULL,
	disp_date DATE NOT NULL,
	signed_by BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (documentation_id) REFERENCES versions(id),
	FOREIGN KEY (customer_id) REFERENCES customers(id),
	FOREIGN KEY (signed_by) REFERENCES employees(id)
) COMMENT 'dispatches of documentation';



