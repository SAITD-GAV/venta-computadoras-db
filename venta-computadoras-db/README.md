# 💻 Sistema para Venta de Computadoras — Diseño y Rutas de Base de Datos

## 👤 Datos de identificación

| Campo       | Detalle                                   |
|-------------|-------------------------------------------|
| Nombre      | Gavilan Arestegui Saitd Diraks            |
| Carrera     | Ingeniería de Sistemas e Informática      |
| Universidad | Universidad Continental                   |
| Asignatura  | Ingeniería Web                            |
| Docente     | Gamarra Moreno Daniel                     |

## 📝 Descripción técnica

Base de datos relacional para un sistema de **venta de computadoras** (laptops, PC de escritorio, monitores y periféricos). Permite gestionar:

- **Catálogo**: productos, categorías y proveedores.
- **Clientes** y **empleados** (vendedores).
- **Ventas** con sus **detalles**, control de stock y total de la venta.

**Motor:** MySQL 8.0+ (compatible con MariaDB 10.5+ con ajustes menores).

## 📁 Estructura del repositorio

```
venta-computadoras-db/
├── README.md
├── docs/
│   ├── DER.md                  # Diagrama Entidad-Relación (Mermaid)
│   ├── modelo-relacional.md    # Modelo relacional
│   └── diccionario-datos.md    # Diccionario de datos
├── database/
│   ├── 01_ddl.sql              # Creación de BD, tablas, PK, FK, restricciones
│   ├── 02_dml.sql              # Datos de prueba
│   ├── 03_procedimientos.sql   # Procedimientos almacenados de la venta
│   └── 04_consultas_clave.sql  # Consultas clave / reportes
└── routes/
    └── endpoints.md            # Mapeo de rutas/endpoints ↔ operaciones de BD
```

## 🚀 Instrucciones de ejecución / despliegue

### Requisitos
- MySQL Server 8.0+ y cliente `mysql` (o MySQL Workbench / DBeaver).

### Opción 1: línea de comandos

```bash
git clone https://github.com/<tu-usuario>/venta-computadoras-db.git
cd venta-computadoras-db/database

mysql -u root -p < 01_ddl.sql
mysql -u root -p < 02_dml.sql
mysql -u root -p < 03_procedimientos.sql
mysql -u root -p < 04_consultas_clave.sql   # opcional (consultas de prueba)
```

### Opción 2: MySQL Workbench
1. Abrir una conexión → `File > Open SQL Script`.
2. Ejecutar en orden: `01_ddl.sql`, `02_dml.sql`, `03_procedimientos.sql`.

### Verificación rápida

```sql
USE venta_computadoras;
SHOW TABLES;
SELECT COUNT(*) FROM productos;   -- debe devolver 8
```

> ⚠️ `01_ddl.sql` elimina y recrea la base `venta_computadoras`. No lo ejecutes sobre datos que quieras conservar.

## 🗂️ Documentación

- [Diagrama Entidad-Relación](docs/DER.md)
- [Modelo Relacional](docs/modelo-relacional.md)
- [Diccionario de Datos](docs/diccionario-datos.md)
- [Rutas / Endpoints](routes/endpoints.md)

## 🔗 Resumen de rutas

| Método | Ruta                    | Descripción                    |
|--------|-------------------------|--------------------------------|
| GET    | `/api/productos`        | Listar productos               |
| GET    | `/api/productos/:id`    | Detalle de un producto         |
| POST   | `/api/productos`        | Registrar producto             |
| PUT    | `/api/productos/:id`    | Actualizar producto            |
| DELETE | `/api/productos/:id`    | Baja lógica de producto        |
| GET    | `/api/clientes`         | Listar clientes                |
| POST   | `/api/clientes`         | Registrar cliente              |
| GET    | `/api/ventas`           | Listar ventas                  |
| GET    | `/api/ventas/:id`       | Venta con su detalle           |
| POST   | `/api/ventas`           | Registrar venta (transacción)  |
| PATCH  | `/api/ventas/:id/anular`| Anular venta y devolver stock  |

Detalle completo en [`routes/endpoints.md`](routes/endpoints.md).
