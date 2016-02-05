#csc343prep4.sql

#Report the eid of every employee who manages at least two different people. 
#Use the usual technique of table renaming and self-join, 
#except use CROSS JOIN to take the Cartesian product of the two tables:
select m.manager
from manages m CROSS JOIN manages n
where m.manager = n.manager and m.junior != n.junior;

#Report the name and sales of everyone with a salary over 50, 
#using the keywords NATURAL JOIN (plus a WHERE clause, of course):
select name,day,amount 
from employee NATURAL JOIN sales
where employee.eid = sales.eid and employee.salary > 50;

#Report the salaries of everyone in every department, 
#using the keywords INNER JOIN ... ON (equivalent to theta join):
select employee.name,department.name as department,salary
from employee INNER JOIN department 
ON employee.dept = department.did;

select employee.name,department.name as department,salary
from employee LEFT OUTER JOIN department
ON employee.dept = department.did;

select employee.name,department.name as department,salary
from employee FULL OUTER JOIN department
ON employee.dept = department.did;

#\o result.log
#\i sample_query.sql
#\o