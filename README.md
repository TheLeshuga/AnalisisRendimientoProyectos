# Análisis del rendimiento de los proyectos en base a presupuestos
Desarrollo de un proyecto en Power BI que incluye la creación de una base de datos en Microsoft SQL Server Management Studio para almacenar la información de la empresa y explorarla mediante consultas. Posteriormente, se conecta la base de datos con Power BI para transformar los datos y elaborar un panel de control interactivo. A través del análisis de la información, se obtienen resultados y conclusiones sobre posibles riesgos financieros, además de sugerencias para optimizar la gestión.

![image](https://github.com/user-attachments/assets/bc7bf40a-3f03-4503-8fac-36af3d6a60d7)

## Resumen

El objetivo de este análisis es explorar las fuentes de datos públicos disponibles, para obtener conocimientos sobre la distribución de presupuestos por proyecto y departamentos de la empresa y su correcto o incorrecto uso. Este análisis proporcionará una base sólida para orientar el trabajo de un equipo de finanzas. Centrándonos en los salarios, costes de los proyectos y presupuestos.

## Conclusiones generales

Después del análisis exhaustivo, hemos llegado a las siguientes conclusiones:

- Hemos identificado que **ninguno de los departamentos excede el presupuesto**. Sin embargo, **todos ellos están rindiendo al menos un 33% por debajo de lo esperado**.
- El **60,41% del total de presupuestos entre todos los departamentos en un año se está desaprovechando**. Existe una oportunidad interesante empezar reestructurando el departamento de Engineering, ya que es el que mayor presupuesto y excedente tiene, dando a entender que la empresa busca potenciar dicho sector. Se podrían **contratar nuevos empleados** para acelerar los proyectos, **revalorizar a los empleados del departamento** y/o **iniciar nuevos proyectos** para aumentar el valor de la empresa.
- Todos los departamentos, excepto **Human Resources**, tienen proyectos pendientes de inicio. Estos representan el **64,04%** del total, lo que brinda a la empresa una oportunidad clave para aplicar las estrategias mencionadas anteriormente y optimizar el desarrollo de los proyectos.
- **No existe una relación de presupuesto otorgado a cada departamento en base a salarios y proyectos**. Esto provoca que una parte significativa del presupuesto asignado para agotarse en un año permanezca sin utilizar. Por ello, una buena estrategia sería implementar un **sistema de distribución del presupuesto por departamento**, priorizando primero los **salarios** y luego los **proyectos pendientes de inicio**.
- La **diferencia de salarios entre departamentos es mínima**, de un **9,6%** entre el de mayor salario y el que menos.


## Trabajo realizado

### Creación de una base de datos, carga y transformación de los datos

Se crea la base de datos mediante New Database en Microsoft SQL Server para subir los archivos .csv. 

<p align="center">
  <img src="https://github.com/user-attachments/assets/58246cdb-3f57-4cac-8f23-92454afb7d83" width="590">
</p>

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
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title,
employees.salary, departments.Department_Name, departments.Department_Budget, departments.Department_Goals
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID;
```

Buscando adjuntar los proyectos a cada departamento, podemos hacerlo mediante la tabla project_assignments, ya que, tiene el ID del empleado y del proyecto:

```sql
SELECT employees.employee_id, employees.first_name, employees.last_name,
employees.job_title, employees.salary, departments.Department_Name, departments.Department_Budget,
departments.Department_Goals, project_assignments.project_id
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
SELECT employees.employee_id, employees.first_name, employees.last_name, employees.job_title,
employees.salary, departments.Department_Name, departments.Department_Budget, departments.Department_Goals,
project_assignments.project_id, project_status.project_name, project_status.project_budget, project_status.status
FROM employees
JOIN departments ON employees.department_id = departments.Department_ID
JOIN project_assignments ON employees.employee_id = project_assignments.employee_id
JOIN project_status ON project_assignments.project_id = project_status.project_id;
```

### Conexión con PowerBI

Mediante la opción SQL Server, conectamos PowerBI con la BBDD y usando las opciones avanzadas añadimos la consulta previamente creada para empezar con una tabla con únicamente los datos necesarios para empezar a transformarlos.

<p align="center">
  <img src="https://github.com/user-attachments/assets/34fc09f4-5011-4c2b-8579-4d43d732cdc9" width="500">
</p>



### Tranformación de datos en PowerBI

Para asegurar datos de calidad, seguiremos una estandarización de nombres y se transformarán los tipos de las variables que estén mal formateadas. Aquellas columnas que venían de la tabla departments, se cambian sus nombres a todo en minúsculas.

Además, el salario, el presupuesto de departamento y de proyecto se cambian al tipo número decimal fijo (para simbolizar el dinero). El ID de empleado se cambia a número entero.

Por último, se crea una nueva consulta referencia desde la consulta inicial. Queremos crear una tabla donde se calcule el rendimiento (capital) por objetivo de departamento. Para ello, agrupamos por departamento y objetivo, manteniendo la información pertinente que sería presupuesto_departamento, coste_salario y coste_proyecto. Estos valores son necesarios para calcular el rendimiento por año. 

![image](https://github.com/user-attachments/assets/01e0596c-40b3-4412-85e3-656b5cc68441)

Se añade una columna calculada llamada capital para medir el rendimiento.

Cada departamento cuenta con un objetivo y un presupuesto destinado a subvencionar sus proyectos. Sin embargo, pueden existir varios proyectos enfocados en el mismo objetivo, y cada uno de ellos tiene un presupuesto o coste distinto.

El rendimiento anual se calculará como la mitad del presupuesto total del departamento (ya que este se asigna para un período de dos años), menos la suma de los salarios de los empleados del departamento y el presupuesto asignado a sus proyectos.
```
[department_budget]*0.5 - ([salary_cost] + [project_cost])
```

Se cambia el tipo a número decimal fijo de todas las columnas menos la de department_name y department_goals. La última columna necesaria para esta consulta será 1-year_budget, que es la mitad del presupuesto.

![image](https://github.com/user-attachments/assets/340c7345-e716-430e-b8fc-0783d74c35b5)


### Creación del dashboard

Tras la limpieza final de datos y la consulta nueva, se crea un dashboard usando elementos como gráficos de barras, tarjetas, gráfico de anillos y segmentadores. Se visualiza toda la información recogida en el documento de los requerimientos funcionales. [Ver documento](https://github.com/TheLeshuga/AnalisisRendimientoProyectos/blob/main/requerimientos_proyecto.pdf).

<p align="center">
  <img src="https://github.com/user-attachments/assets/67f0eee3-da35-4957-87cd-f5b4abeef14e" width="600">
</p>


## Fase de análisis

### Primer insight 

Al analizar los valores de la tabla de cálculo de rendimiento, observamos que ningún proyecto presenta un capital en rojo, lo que indica que el presupuesto asignado para un año es suficiente para cubrir todos los proyectos y salarios. Cabe destacar que el departamento de Engineering, a pesar de contar con solo dos proyectos (60.000 y 50.000 de presupuesto), es el que tiene el mayor excedente de presupuesto (un 77,5%). En contraste, el departamento de Human Resources, también con dos proyectos (55.000 y 50.000 de presupuesto), es el que estuvo más cerca de agotar su presupuesto anual (un 33,75%).

Al analizar la fila de totales, se observa que, de los 3.450.000€ asignados anualmente, 2.084.000€ quedarían sin utilizar, lo que representa un 60,41% del presupuesto total destinado a los departamentos. Este excedente indica que, aunque no hay riesgo de pérdidas por costes elevados, una gran parte de los fondos asignados no se está aprovechando de manera óptima, están rindiendo por debajo de lo esperado.

Además, los sueldos anuales representan solo un 23,07% del presupuesto total, lo que sugiere una oportunidad para revalorizar a los empleados. Se podrían implementar bonificaciones o aumentos salariales para incentivar y motivar al equipo. Otra alternativa sería reequilibrar la contratación, ya sea incorporando nuevos empleados para acelerar el desarrollo de proyectos existentes o para iniciar nuevos proyectos que optimicen el uso del presupuesto disponible. Estas implementaciones podrían iniciar en el departamento de Engineering, el cual pareció ser de prioridad para la empresa por el gran presupuesto dado. 

![image](https://github.com/user-attachments/assets/d161ffa1-6664-4b41-8094-eef9e5226047)


### Segundo insight

El departamento con el mayor presupuesto destinado a proyectos es Sales, que cuenta con dos proyectos. Además, es el departamento con el mayor coste anual en salarios, con dos empleados. A pesar de ello, ha inutilizado el 47,17% de su presupuesto anual.

<p align="center">
  <img src="https://github.com/user-attachments/assets/14b4c29c-592b-409b-bf29-3e01860f55e5" width="700">
</p>

Por otro lado, el departamento que ha utilizado el menor presupuesto en proyectos es IT, también con dos proyectos y dos empleados. Aun así, su porcentaje de presupuesto no utilizado es 46,44%, lo que indica una situación similar a la de Sales en términos de eficiencia en el uso de fondos. 

Con este resultado podríamos decir que el presupuesto total otorgado a cada departamento no parece estar determinado ni por el número de empleados ni por un criterio basado en proyectos de mayor coste. Un dato que refuerza esta observación es que el departamento de Engineering recibió un presupuesto anual de 1.200.000€, a pesar de que el coste de sus proyectos ocupa el tercer lugar entre los departamentos con mayor inversión en proyectos. Esto indica que la distribución del presupuesto no sigue un patrón estrictamente basado en el gasto en proyectos ni salarios. Por lo tanto, una acción recomendable sería ajustar el presupuesto en función de las variables de salarios y los proyectos futuros. De esta manera, podremos asignar los presupuestos de forma más estratégica, garantizando que cada departamento reciba los fondos necesarios para sus actividades, sin exceder la inversión disponible para otras áreas de la empresa.

<p align="center">
  <img src="https://github.com/user-attachments/assets/e4289e8f-c2bf-4098-b560-b8a9a41702b9" width="700">
</p>


### Tercer insight

El 64,04% de los proyectos aún están en desarrollo o por iniciarse, por lo que existen oportunidades para optimizar los presupuestos. Se podrían realizar algunas reestructuraciones que permitan aumentar los costes en los proyectos, ya sea para beneficiar a la empresa o para contratar a especialistas que aporten un mayor valor a los proyectos.

<p align="center">
  <img src="https://github.com/user-attachments/assets/61c1c5c9-1baf-4b90-b481-2a92b972eaef" width="400">
</p>



### Cuarto insight

En cuanto a la estructura de empleados, cada departamento cuenta con dos empleados. El departamento con el mayor coste en salarios es Sales, mientras que el de menor coste es IT, con una diferencia de apenas 9,6%. Esta variación se debe a que en Sales se encuentran un Data Scientist y un Sales Executive, mientras que en IT hay un IT Specialist y un Finance Analyst. No obstante, no se observa una disparidad significativa de salarios entre los empleados dentro de un mismo departamento.

![image](https://github.com/user-attachments/assets/deb73c6b-76a2-4bac-89b5-c5745e78a66a)


