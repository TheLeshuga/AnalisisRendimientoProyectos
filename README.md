# Análisis del rendimiento de los proyectos en base a presupuestos
Desarrollo de un proyecto en Power BI que incluye la creación de una base de datos en Microsoft SQL Server Management Studio para almacenar la información de la empresa y explorarla mediante consultas. Posteriormente, se conecta la base de datos con Power BI para transformar los datos y elaborar un panel de control interactivo. A través del análisis de la información, se obtienen resultados y conclusiones sobre posibles riesgos financieros, además de sugerencias para optimizar la gestión.

![image](https://github.com/user-attachments/assets/bc7bf40a-3f03-4503-8fac-36af3d6a60d7)

## Resumen

El objetivo de este análisis es explorar las fuentes de datos públicos disponibles, para obtener conocimientos sobre la distribución de presupuestos por proyecto y departamentos de la empresa y su correcto o incorrecto uso. Este análisis proporcionará una base sólida para orientar el trabajo de un equipo de finanzas. Centrándonos en los salarios, costes de los proyectos y presupuestos.

## Conclusiones generales

## Trabajo realizado

### Creación de una base de datos, carga y transformación de los datos

Se crea la base de datos mediante New Database en Microsoft SQL Server para subir los archivos .csv. 

![image](https://github.com/user-attachments/assets/58246cdb-3f57-4cac-8f23-92454afb7d83)

Se importan los 6 archivos Excel como archivos planos a la nueva base de datos.

![image](https://github.com/user-attachments/assets/3ba1427e-c5ab-4e92-ba1c-ce86883b4c1e)

Mediante las queries básicas de SQL (```SELECT * FROM <tabla>;```) se comprueban los datos de todas las tablas para comprobar si hay valores nulos, están mal formateados o hay campos inservibles. En la tabla dbo.projects encontramos una colummna "column1" que parece ser basura, así que se elimina. El resto de datos está completo y estructurada.

### Exploración de los datos

Queremos identificar qué departamentos o proyectos exceden el presupuesto o están rindiendo debajo de lo esperado. Además, queremos la información pertinente de los empleados como el ID, nombre, apellido, cargo, departamento y salario, el resto de datos se limpian:

```sql
SELECT employee_id, first_name, last_name, job_title, salary
FROM employees;
```

Como cada empleado está en un departamento, podemos adjuntarle en cuál trabajan usando la tabla de departamentos para añadir más información sobre cada uno:

```sql
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title, employees.salary, departments.Department_Name, departments.Department_Budget, departments.Department_Goals
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID;
```

Buscando adjuntar los proyectos a cada departamento, podemos hacerlo mediante la tabla project_assignments, ya que, tiene el ID del empleado y del proyecto:

```sql
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title, employees.salary, departments.Department_Name, departments.Department_Budget, departments.Department_Goals, project_assignments.project_id
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID
JOIN project_assignments ON employees.employee_id = project_assignments.employee_id;
```

Por último, queremos explorar los proyectos según su estado. La única información que tenemos para saber si un proyecto está completado o no, es mediante las tablas upcoming_projects y completed_projects. Uniremos ambas tablas (que resultarían como la tabla projects) pero añadiendo una columna de estado. Así mismo haremos esta consulta una tabla para añadirla a nuestra consulta anterior:

```sql
with project_status as(
SELECT project_id, project_name, project_budget, 'upcoming' as status
FROM upcoming_projects
union all
SELECT project_id, project_name, project_budget, 'completed' as status
FROM completed_projects)
```

Nuestra consulta final contendrá también el estado de cada proyecto con su nombre y presupuesto, información pertinente sobre los proyectos necesarios para el análisis. Esta consulta será usada en PowerBI a la hora de transportar los datos de la BBDD a el programa:

```sql
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title, employees.salary, 
departments.Department_Name, departments.Department_Budget, departments.Department_Goals, project_assignments.project_id, project_status.project_name, project_status.project_budget, project_status.status
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID
JOIN project_assignments ON employees.employee_id = project_assignments.employee_id
JOIN project_status ON project_assignments.project_id = project_status.project_id;
```



