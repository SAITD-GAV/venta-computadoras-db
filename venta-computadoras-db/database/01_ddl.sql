-- =====================================================================
-- 01_ddl.sql — Sistema para Venta de Computadoras
-- Creación de la base de datos, tablas, llaves y restricciones
-- Motor: MySQL 8.0+
-- ADVERTENCIA: elimina y recrea la base `venta_computadoras`.
-- =====================================================================

DROP DATABASE IF EXISTS venta_computadoras;
CREATE DATABASE venta_computadoras
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE venta_computadoras;

-- ---------------------------------------------------------------------
-- Categorías
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
    id_categoria INT          NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(50)  NOT NULL,
    descripcion  VARCHAR(150) NULL,
    CONSTRAINT pk_categorias        PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categorias_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Proveedores
-- ---------------------------------------------------------------------
CREATE TABLE proveedores (
    id_proveedor INT          NOT NULL AUTO_INCREMENT,
    ruc          CHAR(11)     NOT NULL,
    razon_social VARCHAR(120) NOT NULL,
    telefono     VARCHAR(15)  NULL,
    email        VARCHAR(100) NULL,
    direccion    VARCHAR(150) NULL,
    CONSTRAINT pk_proveedores     PRIMARY KEY (id_proveedor),
    CONSTRAINT uq_proveedores_ruc UNIQUE (ruc)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Productos
-- ---------------------------------------------------------------------
CREATE TABLE productos (
    id_producto      INT           NOT NULL AUTO_INCREMENT,
    codigo           VARCHAR(20)   NOT NULL,
    nombre           VARCHAR(120)  NOT NULL,
    marca            VARCHAR(50)   NOT NULL,
    modelo           VARCHAR(60)   NULL,
    especificaciones TEXT          NULL,
    precio           DECIMAL(10,2) NOT NULL,
    stock            INT           NOT NULL DEFAULT 0,
    activo           TINYINT(1)    NOT NULL DEFAULT 1,
    id_categoria     INT           NOT NULL,
    id_proveedor     INT           NOT NULL,
    CONSTRAINT pk_productos        PRIMARY KEY (id_producto),
    CONSTRAINT uq_productos_codigo UNIQUE (codigo),
    CONSTRAINT ck_productos_precio CHECK (precio > 0),
    CONSTRAINT ck_productos_stock  CHECK (stock >= 0),
    CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_productos_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedores (id_proveedor)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_productos_nombre ON productos (nombre);

-- ---------------------------------------------------------------------
-- Clientes
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente     INT          NOT NULL AUTO_INCREMENT,
    dni            CHAR(8)      NOT NULL,
    nombres        VARCHAR(80)  NOT NULL,
    apellidos      VARCHAR(80)  NOT NULL,
    telefono       VARCHAR(15)  NULL,
    email          VARCHAR(100) NULL,
    direccion      VARCHAR(150) NULL,
    fecha_registro DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_clientes       PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_dni   UNIQUE (dni),
    CONSTRAINT uq_clientes_email UNIQUE (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Empleados
-- ---------------------------------------------------------------------
CREATE TABLE empleados (
    id_empleado INT          NOT NULL AUTO_INCREMENT,
    dni         CHAR(8)      NOT NULL,
    nombres     VARCHAR(80)  NOT NULL,
    apellidos   VARCHAR(80)  NOT NULL,
    cargo       VARCHAR(40)  NOT NULL DEFAULT 'Vendedor',
    email       VARCHAR(100) NULL,
    CONSTRAINT pk_empleados       PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleados_dni   UNIQUE (dni),
    CONSTRAINT uq_empleados_email UNIQUE (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Ventas (cabecera)
-- ---------------------------------------------------------------------
CREATE TABLE ventas (
    id_venta    INT           NOT NULL AUTO_INCREMENT,
    fecha_venta DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(20)   NOT NULL,
    estado      VARCHAR(12)   NOT NULL DEFAULT 'REGISTRADA',
    total       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    id_cliente  INT           NOT NULL,
    id_empleado INT           NOT NULL,
    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT ck_ventas_metodo CHECK
        (metodo_pago IN ('EFECTIVO','TARJETA','YAPE','PLIN','TRANSFERENCIA')),
    CONSTRAINT ck_ventas_estado CHECK (estado IN ('REGISTRADA','ANULADA')),
    CONSTRAINT ck_ventas_total  CHECK (total >= 0),
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleados (id_empleado)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_ventas_fecha ON ventas (fecha_venta);

-- ---------------------------------------------------------------------
-- Detalle de ventas
-- ---------------------------------------------------------------------
CREATE TABLE detalle_ventas (
    id_detalle      INT           NOT NULL AUTO_INCREMENT,
    id_venta        INT           NOT NULL,
    id_producto     INT           NOT NULL,
    cantidad        INT           NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal        DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    CONSTRAINT pk_detalle_ventas PRIMARY KEY (id_detalle),
    CONSTRAINT uq_detalle_venta_producto UNIQUE (id_venta, id_producto),
    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio   CHECK (precio_unitario > 0),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
        REFERENCES ventas (id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
