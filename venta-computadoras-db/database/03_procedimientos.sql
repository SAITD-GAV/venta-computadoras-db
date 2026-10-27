-- =====================================================================
-- 03_procedimientos.sql — Procedimientos almacenados del proceso de venta
-- Ejecutar después de 01_ddl.sql y 02_dml.sql
-- =====================================================================

USE venta_computadoras;

DROP PROCEDURE IF EXISTS sp_crear_venta;
DROP PROCEDURE IF EXISTS sp_agregar_detalle;
DROP PROCEDURE IF EXISTS sp_anular_venta;

DELIMITER //

-- ---------------------------------------------------------------------
-- sp_crear_venta: crea la cabecera de una venta (total = 0).
-- Devuelve el id generado en p_id_venta.
-- Endpoint: POST /api/ventas (paso 1)
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_crear_venta (
    IN  p_id_cliente  INT,
    IN  p_id_empleado INT,
    IN  p_metodo_pago VARCHAR(20),
    OUT p_id_venta    INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_empleado = p_id_empleado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe';
    END IF;

    INSERT INTO ventas (metodo_pago, id_cliente, id_empleado)
    VALUES (p_metodo_pago, p_id_cliente, p_id_empleado);

    SET p_id_venta = LAST_INSERT_ID();
END //

-- ---------------------------------------------------------------------
-- sp_agregar_detalle: agrega un producto a la venta, valida stock,
-- descuenta el stock y actualiza el total.
-- IMPORTANTE: debe ejecutarse dentro de una transacción abierta por el
-- llamador (START TRANSACTION ... COMMIT) para que la venta sea atómica.
-- Endpoint: POST /api/ventas (paso 2, una llamada por producto)
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_agregar_detalle (
    IN p_id_venta    INT,
    IN p_id_producto INT,
    IN p_cantidad    INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_stock  INT;
    DECLARE v_activo TINYINT(1);
    DECLARE v_estado VARCHAR(12);

    SELECT estado INTO v_estado FROM ventas WHERE id_venta = p_id_venta FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
    ELSEIF v_estado <> 'REGISTRADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no admite cambios (anulada)';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0';
    END IF;

    SELECT precio, stock, activo
      INTO v_precio, v_stock, v_activo
      FROM productos
     WHERE id_producto = p_id_producto
       FOR UPDATE;                       -- bloquea la fila para evitar sobreventa

    IF v_precio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    ELSEIF v_activo = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto está dado de baja';
    ELSEIF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;

    INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (p_id_venta, p_id_producto, p_cantidad, v_precio);

    UPDATE productos
       SET stock = stock - p_cantidad
     WHERE id_producto = p_id_producto;

    UPDATE ventas
       SET total = total + (p_cantidad * v_precio)
     WHERE id_venta = p_id_venta;
END //

-- ---------------------------------------------------------------------
-- sp_anular_venta: marca la venta como ANULADA y devuelve el stock.
-- Maneja su propia transacción.
-- Endpoint: PATCH /api/ventas/:id/anular
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_anular_venta (
    IN p_id_venta INT
)
BEGIN
    DECLARE v_estado VARCHAR(12);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM ventas WHERE id_venta = p_id_venta FOR UPDATE;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
    ELSEIF v_estado = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta ya está anulada';
    END IF;

    -- Devolver stock de cada producto de la venta
    UPDATE productos p
      JOIN detalle_ventas d ON d.id_producto = p.id_producto
       SET p.stock = p.stock + d.cantidad
     WHERE d.id_venta = p_id_venta;

    UPDATE ventas SET estado = 'ANULADA' WHERE id_venta = p_id_venta;

    COMMIT;
END //

DELIMITER ;

-- =====================================================================
-- EJEMPLO DE USO (descomentar para probar)
-- Registrar una venta de 1 Laptop HP (id 1) y 1 Teclado (id 6):
--
-- START TRANSACTION;
--   CALL sp_crear_venta(1, 1, 'YAPE', @id_venta);
--   CALL sp_agregar_detalle(@id_venta, 1, 1);
--   CALL sp_agregar_detalle(@id_venta, 6, 1);
-- COMMIT;
-- SELECT * FROM ventas WHERE id_venta = @id_venta;
--
-- Anular la venta y devolver el stock:
-- CALL sp_anular_venta(@id_venta);
-- =====================================================================
