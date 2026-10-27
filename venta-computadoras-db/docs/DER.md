# Diagrama Entidad-Relación (DER)

> GitHub renderiza Mermaid automáticamente. Si tu docente pide una imagen, puedes pegar este código en <https://mermaid.live> y exportar PNG/SVG, y guardarla en `docs/DER.png`.

```mermaid
erDiagram
    CATEGORIAS ||--o{ PRODUCTOS : clasifica
    PROVEEDORES ||--o{ PRODUCTOS : suministra
    CLIENTES ||--o{ VENTAS : realiza
    EMPLEADOS ||--o{ VENTAS : atiende
    VENTAS ||--|{ DETALLE_VENTAS : contiene
    PRODUCTOS ||--o{ DETALLE_VENTAS : "se vende en"

    CATEGORIAS {
        int id_categoria PK
        varchar nombre UK
        varchar descripcion
    }
    PROVEEDORES {
        int id_proveedor PK
        varchar ruc UK
        varchar razon_social
        varchar telefono
        varchar email
        varchar direccion
    }
    PRODUCTOS {
        int id_producto PK
        varchar codigo UK
        varchar nombre
        varchar marca
        varchar modelo
        text especificaciones
        decimal precio
        int stock
        boolean activo
        int id_categoria FK
        int id_proveedor FK
    }
    CLIENTES {
        int id_cliente PK
        varchar dni UK
        varchar nombres
        varchar apellidos
        varchar telefono
        varchar email UK
        varchar direccion
        datetime fecha_registro
    }
    EMPLEADOS {
        int id_empleado PK
        varchar dni UK
        varchar nombres
        varchar apellidos
        varchar cargo
        varchar email UK
    }
    VENTAS {
        int id_venta PK
        datetime fecha_venta
        varchar metodo_pago
        varchar estado
        decimal total
        int id_cliente FK
        int id_empleado FK
    }
    DETALLE_VENTAS {
        int id_detalle PK
        int cantidad
        decimal precio_unitario
        decimal subtotal
        int id_venta FK
        int id_producto FK
    }
```

## Cardinalidades

| Relación                     | Cardinalidad | Explicación                                           |
|------------------------------|--------------|-------------------------------------------------------|
| Categorías – Productos       | 1 : N        | Una categoría tiene muchos productos                  |
| Proveedores – Productos      | 1 : N        | Un proveedor suministra muchos productos              |
| Clientes – Ventas            | 1 : N        | Un cliente puede realizar muchas ventas               |
| Empleados – Ventas           | 1 : N        | Un empleado atiende muchas ventas                     |
| Ventas – Detalle_Ventas      | 1 : N        | Una venta tiene uno o más ítems                       |
| Productos – Detalle_Ventas   | 1 : N        | Un producto aparece en muchos detalles                |
| Ventas – Productos           | N : M        | Resuelta con la tabla intermedia `detalle_ventas`     |
