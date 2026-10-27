# Rutas / Endpoints de la Base de Datos

Mapeo entre las rutas de la API REST del sistema y las operaciones sobre la base de datos `venta_computadoras`.

- **Base URL:** `/api`
- **Formato:** JSON (`Content-Type: application/json`)
- **Moneda:** soles (S/)

## Resumen

| Método | Ruta                      | Operación en BD                                  | Códigos de respuesta |
|--------|---------------------------|--------------------------------------------------|----------------------|
| GET    | `/api/productos`          | `SELECT` con JOIN a categorías y proveedores     | 200                  |
| GET    | `/api/productos/:id`      | `SELECT ... WHERE id_producto = ?`               | 200, 404             |
| POST   | `/api/productos`          | `INSERT INTO productos`                          | 201, 400, 409        |
| PUT    | `/api/productos/:id`      | `UPDATE productos`                               | 200, 400, 404        |
| DELETE | `/api/productos/:id`      | Baja lógica: `UPDATE productos SET activo = 0`   | 200, 404             |
| GET    | `/api/clientes`           | `SELECT * FROM clientes`                         | 200                  |
| POST   | `/api/clientes`           | `INSERT INTO clientes`                           | 201, 400, 409        |
| GET    | `/api/ventas`             | `SELECT` ventas + cliente + vendedor             | 200                  |
| GET    | `/api/ventas/:id`         | Cabecera + `detalle_ventas`                      | 200, 404             |
| POST   | `/api/ventas`             | Transacción con `sp_crear_venta` + `sp_agregar_detalle` | 201, 400, 409 |
| PATCH  | `/api/ventas/:id/anular`  | `CALL sp_anular_venta(?)`                        | 200, 404, 409        |

---

## Productos

### GET `/api/productos`
Lista los productos activos. Filtros opcionales: `?categoria=3`, `?q=laptop`.

```sql
SELECT p.id_producto, p.codigo, p.nombre, p.marca, p.precio, p.stock,
       c.nombre AS categoria, pr.razon_social AS proveedor
  FROM productos p
  JOIN categorias c   ON c.id_categoria  = p.id_categoria
  JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
 WHERE p.activo = 1;
```

**Respuesta 200**
```json
[
  { "id_producto": 1, "codigo": "LAP-001", "nombre": "Laptop HP Pavilion 15",
    "marca": "HP", "precio": 2899.00, "stock": 14,
    "categoria": "Laptops", "proveedor": "Tecnomundo Perú S.A.C." }
]
```

### GET `/api/productos/:id`
```sql
SELECT * FROM productos WHERE id_producto = ?;
```
Devuelve **404** si no existe.

### POST `/api/productos`
**Body**
```json
{
  "codigo": "PER-004", "nombre": "Webcam Logitech C920", "marca": "Logitech",
  "modelo": "C920", "especificaciones": "Full HD 1080p",
  "precio": 259.00, "stock": 20, "id_categoria": 4, "id_proveedor": 2
}
```
```sql
INSERT INTO productos
  (codigo, nombre, marca, modelo, especificaciones, precio, stock, id_categoria, id_proveedor)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
```
**201** `{ "id_producto": 9 }` · **409** si el `codigo` ya existe · **400** si precio ≤ 0 o stock < 0.

### PUT `/api/productos/:id`
```sql
UPDATE productos
   SET nombre = ?, marca = ?, modelo = ?, especificaciones = ?,
       precio = ?, stock = ?, id_categoria = ?, id_proveedor = ?
 WHERE id_producto = ?;
```

### DELETE `/api/productos/:id`
Baja lógica (no se borra la fila para conservar el historial de ventas).
```sql
UPDATE productos SET activo = 0 WHERE id_producto = ?;
```

---

## Clientes

### GET `/api/clientes`
```sql
SELECT id_cliente, dni, nombres, apellidos, telefono, email FROM clientes;
```

### POST `/api/clientes`
**Body**
```json
{ "dni": "47852136", "nombres": "Sofía", "apellidos": "Medina Rivas",
  "telefono": "932145678", "email": "sofia.medina@mail.com",
  "direccion": "Av. Mariscal Castilla 100, Huancayo" }
```
```sql
INSERT INTO clientes (dni, nombres, apellidos, telefono, email, direccion)
VALUES (?, ?, ?, ?, ?, ?);
```
**201** `{ "id_cliente": 6 }` · **409** si el DNI o email ya existen.

---

## Ventas

### GET `/api/ventas`
```sql
SELECT v.id_venta, v.fecha_venta, v.metodo_pago, v.estado, v.total,
       CONCAT(c.nombres,' ',c.apellidos) AS cliente,
       CONCAT(e.nombres,' ',e.apellidos) AS vendedor
  FROM ventas v
  JOIN clientes c  ON c.id_cliente  = v.id_cliente
  JOIN empleados e ON e.id_empleado = v.id_empleado
 ORDER BY v.fecha_venta DESC;
```

### GET `/api/ventas/:id`
Devuelve la cabecera y su detalle.
```sql
-- Cabecera
SELECT * FROM ventas WHERE id_venta = ?;

-- Detalle
SELECT d.id_detalle, p.codigo, p.nombre, d.cantidad, d.precio_unitario, d.subtotal
  FROM detalle_ventas d
  JOIN productos p ON p.id_producto = d.id_producto
 WHERE d.id_venta = ?;
```

**Respuesta 200**
```json
{
  "id_venta": 1, "fecha_venta": "2026-10-05T10:30:00", "metodo_pago": "TARJETA",
  "estado": "REGISTRADA", "total": 3017.00,
  "cliente": "Carlos Alberto Quispe Mendoza", "vendedor": "Pedro José Gamarra Lazo",
  "detalle": [
    { "codigo": "LAP-001", "nombre": "Laptop HP Pavilion 15", "cantidad": 1, "precio_unitario": 2899.00, "subtotal": 2899.00 },
    { "codigo": "PER-002", "nombre": "Mouse Logitech M185",   "cantidad": 2, "precio_unitario": 59.00,   "subtotal": 118.00 }
  ]
}
```

### POST `/api/ventas`  ← transacción principal del proceso de venta
**Body**
```json
{
  "id_cliente": 1, "id_empleado": 1, "metodo_pago": "YAPE",
  "items": [
    { "id_producto": 1, "cantidad": 1 },
    { "id_producto": 6, "cantidad": 1 }
  ]
}
```
El backend ejecuta todo dentro de **una sola transacción**:
```sql
START TRANSACTION;
  CALL sp_crear_venta(1, 1, 'YAPE', @id_venta);
  CALL sp_agregar_detalle(@id_venta, 1, 1);   -- una llamada por ítem
  CALL sp_agregar_detalle(@id_venta, 6, 1);
COMMIT;
SELECT @id_venta;
```
Si cualquier procedimiento falla (stock insuficiente, producto inexistente, etc.), el backend ejecuta `ROLLBACK` y no se guarda nada.

| Código | Motivo                                                     |
|--------|------------------------------------------------------------|
| 201    | Venta registrada → `{ "id_venta": 5, "total": 3048.00 }`   |
| 400    | Datos inválidos (cantidad ≤ 0, método de pago no permitido)|
| 409    | `Stock insuficiente` o producto dado de baja               |

### PATCH `/api/ventas/:id/anular`
Cambia el estado a `ANULADA` y devuelve el stock de cada producto.
```sql
CALL sp_anular_venta(?);
```
**200** `{ "mensaje": "Venta anulada" }` · **404** si no existe · **409** si ya estaba anulada.

---

## Ejemplo de implementación (Node.js + Express + mysql2)

```js
// routes/ventas.js — esquema de referencia
router.post('/', async (req, res) => {
  const { id_cliente, id_empleado, metodo_pago, items } = req.body;
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query('CALL sp_crear_venta(?, ?, ?, @id_venta)',
                     [id_cliente, id_empleado, metodo_pago]);
    const [[{ id_venta }]] = await conn.query('SELECT @id_venta AS id_venta');
    for (const it of items) {
      await conn.query('CALL sp_agregar_detalle(?, ?, ?)',
                       [id_venta, it.id_producto, it.cantidad]);
    }
    await conn.commit();
    res.status(201).json({ id_venta });
  } catch (err) {
    await conn.rollback();
    res.status(err.sqlState === '45000' ? 409 : 400).json({ error: err.message });
  } finally {
    conn.release();
  }
});
```
