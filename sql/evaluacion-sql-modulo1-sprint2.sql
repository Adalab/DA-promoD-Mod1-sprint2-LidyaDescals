

/*Evaluación de SQL

Para esta evaluación usaremos la BBDD de northwind con la que ya estamos familiarizadas de los ejercicios de pair programming. En esta evaluación tendréis que contestar a las siguientes preguntas:*/

USE northwind;

/* 1. Selecciona todos los campos de los productos, que pertenezcan a los proveedores con códigos: 1, 3, 7, 8 y 9, que tengan stock en el almacén, y al mismo tiempo que sus precios unitarios estén entre 50 y 100. Por último, ordena los resultados por código de proveedor de forma ascendente.*/

SELECT *
	FROM products
    WHERE supplier_id IN (1, 3, 7, 8, 9) AND units_in_stock > 0 AND unit_price BETWEEN 50 AND 100
    ORDER BY supplier_id;
	

/* 2. Devuelve el nombre y apellidos y el id de los empleados con códigos entre el 3 y el 6, además que hayan vendido a clientes que tengan códigos que comiencen con las letras de la A hasta la G. Por último, en esta búsqueda queremos filtrar solo por aquellos envíos que la fecha de pedido este comprendida entre el 22 y el 31 de Diciembre de cualquier año.*/

SELECT employees.first_name, employees.last_name, employees.employee_id, orders.customer_id, orders.order_date
	FROM employees INNER JOIN orders
	ON employees.employee_id = orders.employee_id
	WHERE employees.employee_id BETWEEN 3 AND 6 
	      AND orders.customer_id REGEXP '^[A-G]' 
		  AND DAY(order_date) BETWEEN 22 AND 31 
          AND MONTH(order_date) = 12
	GROUP BY employees.employee_id, orders.customer_id, orders.order_date;


/* 3. Calcula el precio de venta de cada pedido una vez aplicado el descuento. Muestra el id del la orden, el id del producto, el nombre del producto, el precio unitario, la cantidad, el descuento y el precio de venta después de haber aplicado el descuento.*/

SELECT order_details.order_id, order_details.product_id, products.product_name, order_details.unit_price, order_details.quantity, order_details.discount, 
ROUND(order_details.unit_price * order_details.quantity * (1 - order_details.discount), 2) AS PrecioVenta
	FROM order_details NATURAL JOIN products;
 

/* 4. Usando una subconsulta, muestra los productos cuyos precios estén por encima del precio medio total de los productos de la BBDD.*/

SELECT p1.product_id, p1.product_name, p1.unit_price
	FROM products AS p1  
	WHERE p1.unit_price > (	SELECT AVG(unit_price)
							FROM products AS p2);
                        
                        
/* 5. ¿Qué productos ha vendido cada empleado y cuál es la cantidad vendida de cada uno de ellos?*/

SELECT products.product_id, products.product_name, orders.employee_id, SUM(order_details.quantity) AS UnidadesVendidas
	FROM order_details 
    NATURAL JOIN products
    NATURAL JOIN orders
	GROUP BY products.product_id, products.product_name, orders.employee_id;


/* 6. Basándonos en la query anterior, ¿qué empleado es el que vende más productos? Soluciona este ejercicio con una subquery*/

SELECT VentasPorEmpleado.IdEmpleado, employees.first_name, employees.last_name, SUM(VentasPorEmpleado.UnidadesVendidas) AS UnidadesTotalesVendidas
	FROM (SELECT products.product_id AS IdProducto, products.product_name AS NombreProducto, orders.employee_id AS IdEmpleado, SUM(order_details.quantity) AS UnidadesVendidas
		  FROM order_details 
		  NATURAL JOIN products
		  NATURAL JOIN orders
		  GROUP BY products.product_id, products.product_name, orders.employee_id) AS VentasPorEmpleado
	INNER JOIN employees
	ON VentasPorEmpleado.IdEmpleado = employees.employee_id   
	GROUP BY VentasPorEmpleado.IdEmpleado
	ORDER BY UnidadesTotalesVendidas DESC
	LIMIT 1;


/* BONUS ¿Podríais solucionar este mismo ejercicio con una CTE?*/

WITH VentasPorEmpleado
AS (SELECT products.product_id AS IdProducto, products.product_name AS NombreProducto, orders.employee_id AS IdEmpleado, SUM(order_details.quantity) AS UnidadesVendidas
	  FROM order_details 
	  NATURAL JOIN products
	  NATURAL JOIN orders
	  GROUP BY products.product_id, products.product_name, orders.employee_id)
SELECT VentasPorEmpleado.IdEmpleado, employees.first_name, employees.last_name, SUM(VentasPorEmpleado.UnidadesVendidas) AS UnidadesTotalesVendidas
	FROM employees 
	INNER JOIN VentasPorEmpleado 
    ON VentasPorEmpleado.IdEmpleado = employees.employee_id
	GROUP BY VentasPorEmpleado.IdEmpleado
	ORDER BY UnidadesTotalesVendidas DESC
	LIMIT 1;