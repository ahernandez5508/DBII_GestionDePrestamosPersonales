USE DBII_GestionDePrestamosPersonales
GO

-- =============================================
-- DATOS DUMMY PARA VIDEO DEMO
-- =============================================

-- ---------------------------------------------
-- CLIENTES Y USUARIOS
-- ---------------------------------------------
INSERT INTO Cliente (username, password, email, telefono, direccion)
VALUES ('jperez', '1234', 'jperez@mail.com', '1122334455', 'Av. Corrientes 1234');

INSERT INTO Cliente (username, password, email, telefono, direccion)
VALUES ('mgarcia', '1234', 'mgarcia@mail.com', '1155667788', 'Calle Falsa 123');

INSERT INTO Cliente (username, password, email, telefono, direccion)
VALUES ('lrodriguez', '1234', 'lrodriguez@mail.com', '1144556677', 'Av. Santa Fe 456');

INSERT INTO Usuario (idRol, username, password, activo)
VALUES (1, 'admin1', '1234', 1);

INSERT INTO Usuario (idRol, username, password, activo)
VALUES (2, 'operador1', '1234', 1);
GO

-- ---------------------------------------------
-- PRESTAMO 1: FINALIZADO (idCliente = 1)
-- Prestamo Personal, $100.000, 3 cuotas
-- tasa 4.5% mensual
-- interesTotal = 100000 * 0.045 * 3 = $13.500
-- montoCuota = (100000 + 13500) / 3 = $37.833,33
-- ---------------------------------------------
INSERT INTO Prestamo (idProducto, idCliente, idUsuarioAprobador, monto, interesTotal, cantidadCuotas, cuotasRestantes, fechaAprobacion, fechaUltimaActualizacion, idEstadoPrestamo)
VALUES (1, 1, 1, 100000.00, 13500.00, 3, 0, '2025-01-10', '2025-04-10', 5);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (1, 2, '2025-03-10', '2025-03-05', 37833.33, 1);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (1, 2, '2025-04-10', '2025-04-03', 37833.33, 2);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (1, 2, '2025-05-10', '2025-05-08', 37833.33, 1);

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (1, 2, '2025-01-10', 1, 'Documentacion verificada. Prestamo aprobado.');

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (1, 4, '2025-01-10', NULL, NULL);

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (1, 5, '2025-05-08', NULL, NULL);
GO

-- ---------------------------------------------
-- PRESTAMO 2: EN CURSO, 2 cuotas pagas, 1 pendiente (idCliente = 2)
-- Prestamo Personal, $200.000, 3 cuotas
-- tasa 4.5% mensual
-- interesTotal = 200000 * 0.045 * 3 = $27.000
-- montoCuota = (200000 + 27000) / 3 = $75.666,67
-- ---------------------------------------------
INSERT INTO Prestamo (idProducto, idCliente, idUsuarioAprobador, monto, interesTotal, cantidadCuotas, cuotasRestantes, fechaAprobacion, fechaUltimaActualizacion, idEstadoPrestamo)
VALUES (1, 2, 1, 200000.00, 27000.00, 3, 1, '2025-03-15', '2025-05-10', 4);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (2, 2, '2025-05-10', '2025-05-08', 75666.67, 3);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (2, 2, '2025-06-10', '2025-06-07', 75666.67, 1);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (2, 1, '2025-07-10', NULL, 75666.67, NULL);

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (2, 2, '2025-03-15', 1, 'Ingresos suficientes. Prestamo aprobado.');

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (2, 4, '2025-03-15', NULL, NULL);
GO

-- ---------------------------------------------
-- PRESTAMO 3: EN CURSO CON CUOTA VENCIDA (idCliente = 3)
-- Prestamo Personal, $150.000, 6 cuotas
-- tasa 4.5% mensual
-- interesTotal = 150000 * 0.045 * 6 = $40.500
-- montoCuota = (150000 + 40500) / 6 = $31.750
-- ---------------------------------------------
INSERT INTO Prestamo (idProducto, idCliente, idUsuarioAprobador, monto, interesTotal, cantidadCuotas, cuotasRestantes, fechaAprobacion, fechaUltimaActualizacion, idEstadoPrestamo)
VALUES (1, 3, 2, 150000.00, 40500.00, 6, 5, '2025-04-01', '2025-06-10', 4);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (3, 3, '2025-06-10', NULL, 31750.00, NULL);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (3, 1, '2025-07-10', NULL, 31750.00, NULL);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (3, 1, '2025-08-10', NULL, 31750.00, NULL);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (3, 1, '2025-09-10', NULL, 31750.00, NULL);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (3, 1, '2025-10-10', NULL, 31750.00, NULL);

INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
VALUES (3, 1, '2025-11-10', NULL, 31750.00, NULL);

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (3, 2, '2025-04-01', 2, 'Todo en orden. Prestamo aprobado.');

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (3, 4, '2025-04-01', NULL, NULL);
GO

-- ---------------------------------------------
-- PRESTAMO 4: RECHAZADO (idCliente = 2)
-- Prestamo Personal, $500.000, 12 cuotas
-- tasa 5% mensual
-- interesTotal = 500000 * 0.05 * 12 = $300.000
-- ---------------------------------------------
INSERT INTO Prestamo (idProducto, idCliente, idUsuarioAprobador, monto, interesTotal, cantidadCuotas, cuotasRestantes, fechaAprobacion, fechaUltimaActualizacion, idEstadoPrestamo)
VALUES (1, 2, 1, 500000.00, 300000.00, 12, 12, NULL, '2025-02-20', 3);

INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
VALUES (4, 3, '2025-02-20', 1, 'Capacidad de pago insuficiente. Prestamo rechazado.');
GO

-- ---------------------------------------------
-- VERIFICACION FINAL
-- ---------------------------------------------
SELECT * FROM Cliente;
SELECT * FROM Usuario;
SELECT * FROM Prestamo;
SELECT * FROM Cuota;
SELECT * FROM HistorialEstadoPrestamo;
GO

SELECT * FROM vista_PrestamosActivos;
SELECT * FROM vista_CuotasVencidas;
SELECT * FROM vista_CobrosRegistrados;
GO