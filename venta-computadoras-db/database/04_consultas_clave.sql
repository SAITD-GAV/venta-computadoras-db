-- =====================================================================
-- 04_consultas_clave.sql — Consultas clave y reportes
-- =====================================================================

USE venta_computadoras;

-- 1. Catálogo de productos activos con categoría y proveedor
--    (GET /api/productos)
SELECT p.id_producto, p.codigo, p.nombre, p.marca, p.precio, p.stock,
       c.nombre AS categoria, pr.razon_social AS proveedor
  FROM productos p
  JOIN categorias  c  ON c.id_categoria = p.id_categoria
  JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
 WHERE p.activo = 1
 ORDER BY c.nombre, p.nombre;

-- 2. Productos con stock bajo (10 unidades o menos)
SELECT codigo, nombre, stock
  FROM productos
 WHERE activo = 1 AND stock <= 10
 ORDER BY stock;

-- 3. Listado de ventas con cliente y vendedor
--    (GET /api/ventas)
SELECT v.id_venta, v.fecha_venta, v.metodo_pago, v.estado, v.total,
       CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
       CONCAT(e.nombres, ' ', e.apellidos) AS vendedor
  FROM ventas v
  JOIN clientes c ON c.id_cliente  = v.id_cliente
  JOIN empleados e ON e.id_empleado = v.id_empleado
 ORDER BY v.fecha_venta DESC;

-- 4. Detalle de una venta (ejemplo: venta 1)
--    (GET /api/ventas/:id)
SELECT d.id_detalle, p.codigo, p.nombre, d.cantidad, d.precio_unitario, d.subtotal
  FROM detalle_ventas d
  JOIN productos p ON p.id_producto = d.id_producto
 WHERE d.id_venta = 1;

-- 5. Productos más vendidos (solo ventas no anuladas)
SELECT p.nombre, SUM(d.cantidad) AS unidades_vendidas, SUM(d.subtotal) AS ingresos
  FROM detalle_ventas d
  JOIN ventas   v ON v.id_venta    = d.id_venta
  JOIN productos p ON p.id_producto = d.id_producto
 WHERE v.estado = 'REGISTRADA'
 GROUP BY p.id_producto, p.nombre
 ORDER BY unidades_vendidas DESC, ingresos DESC;

-- 6. Ventas totales por vendedor
SELECT CONCAT(e.nombres, ' ', e.apellidos) AS vendedor,
       COUNT(v.id_venta) AS nro_ventas,
       COALESCE(SUM(v.total), 0) AS monto_vendido
  FROM empleados e
  LEFT JOIN ventas v ON v.id_empleado = e.id_empleado AND v.estado = 'REGISTRADA'
 GROUP BY e.id_empleado, vendedor
 ORDER BY monto_vendido DESC;

-- 7. Ventas por mes
SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS mes,
       COUNT(*) AS nro_ventas,
       SUM(total) AS total_mes
  FROM ventas
 WHERE estado = 'REGISTRADA'
 GROUP BY mes
 ORDER BY mes;

-- 8. Historial de compras por cliente
SELECT CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
       COUNT(v.id_venta) AS compras,
       COALESCE(SUM(v.total), 0) AS total_gastado
  FROM clientes c
  LEFT JOIN ventas v ON v.id_cliente = c.id_cliente AND v.estado = 'REGISTRADA'
 GROUP BY c.id_cliente, cliente
 ORDER BY total_gastado DESC;

-- 9. Vista reutilizable: detalle completo de ventas
CREATE OR REPLACE VIEW vw_detalle_venta AS
SELECT v.id_venta, v.fecha_venta, v.estado,
       CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
       p.codigo, p.nombre AS producto,
       d.cantidad, d.precio_unitario, d.subtotal
  FROM ventas v
  JOIN clientes c ON c.id_cliente = v.id_cliente
  JOIN detalle_ventas d ON d.id_venta = v.id_venta
  JOIN productos p ON p.id_producto = d.id_producto;

SELECT * FROM vw_detalle_venta WHERE id_venta = 2;

-- 10. Verificación de integridad: el total de cada venta debe igualar
--     la suma de sus subtotales (no debe devolver filas)
SELECT v.id_venta, v.total, SUM(d.subtotal) AS suma_detalle
  FROM ventas v
  JOIN detalle_ventas d ON d.id_venta = v.id_venta
 GROUP BY v.id_venta, v.total
HAVING v.total <> SUM(d.subtotal);
