# Modelo Relacional

Notación: **PK** = llave primaria (subrayada conceptualmente), `#` = llave foránea, `UK` = único.

## Esquema relacional

```
CATEGORIAS      (id_categoria PK, nombre UK, descripcion)

PROVEEDORES     (id_proveedor PK, ruc UK, razon_social, telefono, email, direccion)

PRODUCTOS       (id_producto PK, codigo UK, nombre, marca, modelo, especificaciones,
                 precio, stock, activo,
                 #id_categoria → CATEGORIAS, #id_proveedor → PROVEEDORES)

CLIENTES        (id_cliente PK, dni UK, nombres, apellidos, telefono, email UK,
                 direccion, fecha_registro)

EMPLEADOS       (id_empleado PK, dni UK, nombres, apellidos, cargo, email UK)

VENTAS          (id_venta PK, fecha_venta, metodo_pago, estado, total,
                 #id_cliente → CLIENTES, #id_empleado → EMPLEADOS)

DETALLE_VENTAS  (id_detalle PK, cantidad, precio_unitario, subtotal,
                 #id_venta → VENTAS, #id_producto → PRODUCTOS,
                 UK (id_venta, id_producto))
```

## Llaves foráneas

| Tabla origen     | Columna        | Tabla destino | Columna destino | ON DELETE | ON UPDATE |
|------------------|----------------|---------------|-----------------|-----------|-----------|
| productos        | id_categoria   | categorias    | id_categoria    | RESTRICT  | CASCADE   |
| productos        | id_proveedor   | proveedores   | id_proveedor    | RESTRICT  | CASCADE   |
| ventas           | id_cliente     | clientes      | id_cliente      | RESTRICT  | CASCADE   |
| ventas           | id_empleado    | empleados     | id_empleado     | RESTRICT  | CASCADE   |
| detalle_ventas   | id_venta       | ventas        | id_venta        | CASCADE   | CASCADE   |
| detalle_ventas   | id_producto    | productos     | id_producto     | RESTRICT  | CASCADE   |

## Normalización (3FN)

- **1FN**: todos los atributos son atómicos (nombres y apellidos separados, sin listas en una celda).
- **2FN**: en `detalle_ventas` todos los atributos dependen de la llave completa (venta + producto).
- **3FN**: no hay dependencias transitivas; los datos del cliente, producto, categoría y proveedor viven en sus propias tablas y se referencian por llave foránea.
- `precio_unitario` se guarda en el detalle a propósito: conserva el precio al momento de la venta aunque el precio del producto cambie después.
- `ventas.total` es un dato derivado (suma de subtotales) que se mantiene por rendimiento y lo actualizan los procedimientos almacenados.

## Reglas de negocio (restricciones)

- `precio > 0`, `stock >= 0`, `cantidad > 0`.
- `metodo_pago` ∈ {EFECTIVO, TARJETA, YAPE, PLIN, TRANSFERENCIA}.
- `estado` de la venta ∈ {REGISTRADA, ANULADA}.
- Un producto no se repite dentro de la misma venta (`UNIQUE (id_venta, id_producto)`).
- Un producto no se elimina físicamente: se da de baja con `activo = 0` (baja lógica).
