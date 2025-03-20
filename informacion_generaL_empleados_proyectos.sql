--Estado de proyecto
SELECT project_id, project_name, project_budget, 'upcoming' as status
FROM upcoming_projects
union all
SELECT project_id, project_name, project_budget, 'completed' as status
FROM completed_projects;


--Informacion empleados con departamento y proyecto asignado
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title, employees.salary, 
departments.Department_Name, project_assignments.project_id
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID
JOIN project_assignments ON employees.employee_id = project_assignments.employee_id;


--Estado de proyecto con columna de estado añadida
with project_status as(
SELECT project_id, project_name, project_budget, 'upcoming' as status
FROM upcoming_projects
union all
SELECT project_id, project_name, project_budget, 'completed' as status
FROM completed_projects)


--Informacion empleados con departamento, proyecto asignado y estado del proyecto
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title, employees.salary, 
departments.Department_Name, departments.Department_Budget, departments.Department_Goals, project_assignments.project_id, project_status.project_name, project_status.project_budget, project_status.status
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID
JOIN project_assignments ON employees.employee_id = project_assignments.employee_id
JOIN project_status ON project_assignments.project_id = project_status.project_id;