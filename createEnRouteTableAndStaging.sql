A1.1. Create a table in mysql:

mysql> CREATE TABLE employees_export (
  emp_no int(11) NOT NULL,
  birth_date date NOT NULL,
  first_name varchar(14) NOT NULL,
  last_name varchar(16) NOT NULL,
  gender enum('M','F') NOT NULL,
  hire_date date NOT NULL,
  PRIMARY KEY (emp_no)
);

A1.2. Create a stage table in mysql:

mysql > CREATE TABLE employees_exp_stg (
  emp_no int(11) NOT NULL,
  birth_date date NOT NULL,
  first_name varchar(14) NOT NULL,
  last_name varchar(16) NOT NULL,
  gender enum('M','F') NOT NULL,
  hire_date date NOT NULL,
  PRIMARY KEY (emp_no)
);