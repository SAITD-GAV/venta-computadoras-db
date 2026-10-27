# Diccionario de Datos

Base de datos: `venta_computadoras` · Motor: MySQL 8.0+ · Charset: `utf8mb4`

## categorias
Clasificación de los productos (Laptops, Monitores, etc.).

| Columna        | Tipo         | Nulo | Llave | Descripción                      |
|----------------|--------------|------|-------|----------------------------------|
| id_categoria   | INT          | No   | PK    | Identificador (autoincremental)  |
| nombre         | VARCHAR(50)  | No   | UK    | Nombre de la categoría           |
| descripcion    | VARCHAR(150) | Sí   |       | Descripción breve                |

## proveedores
Empresas que abastecen los productos.

| Columna        | Tipo         | Nulo | Llave | Descripción                      |
|----------------|--------------|------|-------|----------------------------------|
| id_proveedor   | INT          | No   | PK    | Identificador (autoincremental)  |
| ruc            | CHAR(11)     | No   | UK    | RUC del proveedor                |
| razon_social   | VARCHAR(120) | No   |       | Razón social                     |
| telefono       | VARCHAR(15)  | Sí   |       | Teléfono de contacto             |
| email          | VARCHAR(100) | Sí   |       | Correo de contacto               |
| direccion      | VARCHAR(150) | Sí   |       | Dirección fiscal                 |

## productos
Catálogo de computadoras, monitores y periféricos.

| Columna          | Tipo          | Nulo | Llave | Descripción                                   |
|------------------|---------------|------|-------|-----------------------------------------------|
| id_producto      | INT           | No   | PK    | Identificador (autoincremental)               |
| codigo           | VARCHAR(20)   | No   | UK    | Código interno / SKU                          |
| nombre           | VARCHAR(120)  | No   |       | Nombre comercial                              |
| marca            | VARCHAR(50)   | No   |       | Marca                                         |
| modelo           | VARCHAR(60)   | Sí   |       | Modelo                                        |
| especificaciones | TEXT          | Sí   |       | CPU, RAM, almacenamiento, pantalla, etc.      |
| precio           | DECIMAL(10,2) | No   |       | Precio de venta en soles (S/), mayor a 0      |
| stock            | INT           | No   |       | Unidades disponibles, mayor o igual a 0       |
| activo           | TINYINT(1)    | No   |       | 1 = disponible, 0 = dado de baja              |
| id_categoria     | INT           | No   | FK    | → categorias.id_categoria                     |
| id_proveedor     | INT           | No   | FK    | → proveedores.id_proveedor                    |

## clientes
Compradores registrados.

| Columna        | Tipo         | Nulo | Llave | Descripción                      |
|----------------|--------------|------|-------|----------------------------------|
| id_cliente     | INT          | No   | PK    | Identificador (autoincremental)  |
| dni            | CHAR(8)      | No   | UK    | Documento de identidad           |
| nombres        | VARCHAR(80)  | No   |       | Nombres                          |
| apellidos      | VARCHAR(80)  | No   |       | Apellidos                        |
| telefono       | VARCHAR(15)  | Sí   |       | Teléfono                         |
| email          | VARCHAR(100) | Sí   | UK    | Correo electrónico               |
| direccion      | VARCHAR(150) | Sí   |       | Dirección                        |
| fecha_registro | DATETIME     | No   |       | Fecha de alta (por defecto: ahora) |

## empleados
Vendedores que registran las ventas.

| Columna        | Tipo         | Nulo | Llave | Descripción                      |
|----------------|--------------|------|-------|----------------------------------|
| id_empleado    | INT          | No   | PK    | Identificador (autoincremental)  |
| dni            | CHAR(8)      | No   | UK    | Documento de identidad           |
| nombres        | VARCHAR(80)  | No   |       | Nombres                          |
| apellidos      | VARCHAR(80)  | No   |       | Apellidos                        |
| cargo          | VARCHAR(40)  | No   |       | Vendedor, Supervisor, etc.       |
| email          | VARCHAR(100) | Sí   | UK    | Correo institucional             |

## ventas
Cabecera de cada venta.

| Columna      | Tipo          | Nulo | Llave | Descripción                                              |
|--------------|---------------|------|-------|----------------------------------------------------------|
| id_venta     | INT           | No   | PK    | Identificador (autoincremental)                          |
| fecha_venta  | DATETIME      | No   |       | Fecha y hora (por defecto: ahora)                        |
| metodo_pago  | VARCHAR(20)   | No   |       | EFECTIVO, TARJETA, YAPE, PLIN o TRANSFERENCIA            |
| estado       | VARCHAR(12)   | No   |       | REGISTRADA (defecto) o ANULADA                           |
| total        | DECIMAL(12,2) | No   |       | Suma de subtotales del detalle                           |
| id_cliente   | INT           | No   | FK    | → clientes.id_cliente                                    |
| id_empleado  | INT           | No   | FK    | → empleados.id_empleado                                  |

## detalle_ventas
Líneas (productos) de cada venta.

| Columna         | Tipo          | Nulo | Llave | Descripción                                          |
|-----------------|---------------|------|-------|------------------------------------------------------|
| id_detalle      | INT           | No   | PK    | Identificador (autoincremental)                      |
| id_venta        | INT           | No   | FK    | → ventas.id_venta                                    |
| id_producto     | INT           | No   | FK    | → productos.id_producto                              |
| cantidad        | INT           | No   |       | Unidades vendidas, mayor a 0                         |
| precio_unitario | DECIMAL(10,2) | No   |       | Precio del producto al momento de la venta           |
| subtotal        | DECIMAL(12,2) | No   |       | Columna generada: cantidad × precio_unitario         |

Restricción única: `(id_venta, id_producto)`.
