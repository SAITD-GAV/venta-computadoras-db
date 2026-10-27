-- =====================================================================
-- 02_dml.sql — Datos de prueba
-- Ejecutar después de 01_ddl.sql
-- Precios en soles (S/). El stock ya refleja las ventas de ejemplo.
-- =====================================================================

USE venta_computadoras;

-- Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Laptops',      'Computadoras portátiles'),
('PC Escritorio','Computadoras de escritorio'),
('Monitores',    'Pantallas y monitores'),
('Periféricos',  'Teclados, mouse, almacenamiento y accesorios');

-- Proveedores
INSERT INTO proveedores (ruc, razon_social, telefono, email, direccion) VALUES
('20100100101', 'Tecnomundo Perú S.A.C.',   '014445566', 'ventas@tecnomundo.pe',  'Av. Arequipa 1234, Lima'),
('20200200202', 'Distribuidora Andina S.R.L.','064223344', 'contacto@dandina.pe',   'Jr. Real 456, Huancayo'),
('20300300303', 'Global Hardware E.I.R.L.',  '014778899', 'info@globalhw.pe',      'Av. Javier Prado 890, Lima');

-- Productos (8)
INSERT INTO productos
    (codigo, nombre, marca, modelo, especificaciones, precio, stock, activo, id_categoria, id_proveedor) VALUES
('LAP-001','Laptop HP Pavilion 15',        'HP',      'Pavilion 15-eg3', 'Intel Core i5 13va, 16GB RAM, 512GB SSD, 15.6" FHD', 2899.00, 14, 1, 1, 1),
('LAP-002','Laptop Lenovo IdeaPad 3',      'Lenovo',  'IdeaPad 3 15',    'Ryzen 5 7520U, 8GB RAM, 256GB SSD, 15.6" FHD',      2299.00, 19, 1, 1, 2),
('PC-001', 'PC Dell OptiPlex Torre',       'Dell',    'OptiPlex 3000',   'Intel Core i5 12va, 8GB RAM, 1TB HDD',               2599.00,  9, 1, 2, 3),
('MON-001','Monitor Samsung 24"',          'Samsung', 'S24C310',         '24" Full HD, IPS, 75Hz, HDMI',                        549.00, 28, 1, 3, 1),
('MON-002','Monitor LG UltraGear 27"',     'LG',      '27GN750',         '27" Full HD, 240Hz, 1ms, HDMI/DP',                   1099.00, 12, 1, 3, 3),
('PER-001','Teclado Logitech K380',        'Logitech','K380',            'Inalámbrico Bluetooth, multidispositivo',             149.00, 49, 1, 4, 2),
('PER-002','Mouse Logitech M185',          'Logitech','M185',            'Inalámbrico 2.4GHz',                                   59.00, 98, 1, 4, 2),
('PER-003','Disco SSD Kingston 1TB',       'Kingston','NV2 1TB',         'NVMe M.2 PCIe 4.0',                                   289.00, 39, 1, 4, 3);

-- Clientes
INSERT INTO clientes (dni, nombres, apellidos, telefono, email, direccion) VALUES
('45678912','Carlos Alberto','Quispe Mendoza', '987654321','carlos.quispe@mail.com', 'Jr. Ica 123, Huancayo'),
('70123456','María Fernanda', 'Rojas Huamán',   '976543210','maria.rojas@mail.com',   'Av. Giráldez 456, Huancayo'),
('41234567','Luis Miguel',    'Salazar Paucar', '965432109','luis.salazar@mail.com',  'Calle Real 789, Huancayo'),
('72345678','Ana Lucía',      'Vargas Cóndor',  '954321098','ana.vargas@mail.com',    'Psje. Los Pinos 12, El Tambo'),
('43219876','Jorge Enrique',  'Ramos Tapia',    '943210987', NULL,                    'Av. Ferrocarril 345, Huancayo');

-- Empleados
INSERT INTO empleados (dni, nombres, apellidos, cargo, email) VALUES
('46789123','Pedro José',   'Gamarra Lazo',   'Vendedor',   'pgamarra@tiendapc.pe'),
('48901234','Rosa Elena',   'Castro Ñahui',   'Vendedor',   'rcastro@tiendapc.pe'),
('40123987','Miguel Ángel', 'Torres Yauri',   'Supervisor', 'mtorres@tiendapc.pe');

-- Ventas (cabecera) — los totales corresponden a la suma de sus detalles
INSERT INTO ventas (fecha_venta, metodo_pago, estado, total, id_cliente, id_empleado) VALUES
('2026-10-05 10:30:00','TARJETA',      'REGISTRADA', 3017.00, 1, 1),
('2026-10-12 15:45:00','YAPE',         'REGISTRADA', 1247.00, 2, 2),
('2026-10-19 11:10:00','EFECTIVO',     'REGISTRADA', 2588.00, 3, 1),
('2026-10-24 17:20:00','TRANSFERENCIA','REGISTRADA', 2599.00, 4, 3);

-- Detalle de ventas (subtotal se calcula automáticamente)
INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 2899.00),   -- Laptop HP
(1, 7, 2,   59.00),   -- 2 Mouse
(2, 4, 2,  549.00),   -- 2 Monitores Samsung
(2, 6, 1,  149.00),   -- Teclado
(3, 2, 1, 2299.00),   -- Laptop Lenovo
(3, 8, 1,  289.00),   -- SSD
(4, 3, 1, 2599.00);   -- PC Dell
