USE DBII_GestionDePrestamosPersonales
GO


-- VISTA 1: Prestamos Activos
-- Muestra los prestamos que se encuentran en curso, junto con los datos del cliente, el producto contratado y las cuotas restantes.
CREATE VIEW vista_PrestamosActivos AS
SELECT
    p.idPrestamo,
    c.idCliente,
    c.username AS clienteUsername,
    c.email AS clienteEmail,
    pp.nombre AS producto,
    p.monto,
    p.interesTotal,
    p.cantidadCuotas,
    p.cuotasRestantes,
    p.fechaAprobacion,
    p.fechaUltimaActualizacion
FROM Prestamo p
INNER JOIN Cliente c ON p.idCliente = c.idCliente
INNER JOIN ProductoPrestamo pp ON p.idProducto = pp.idProducto
INNER JOIN EstadoPrestamo ep ON p.idEstadoPrestamo = ep.idEstadoPrestamo
WHERE ep.descripcion = 'En Curso';
GO


-- VISTA 2: Cuotas Vencidas
-- Muestra las cuotas marcadas como vencidas, junto con los datos del prestamo y del cliente.
CREATE VIEW vista_CuotasVencidas AS
SELECT
    cu.idCuota,
    cu.idPrestamo,
    cl.idCliente,
    cl.username AS clienteUsername,
    cl.email AS clienteEmail,
    cl.telefono,
    cu.fechaVencimiento,
    cu.monto
FROM Cuota cu
INNER JOIN Prestamo p ON cu.idPrestamo = p.idPrestamo
INNER JOIN Cliente cl ON p.idCliente = cl.idCliente
INNER JOIN EstadoCuota ec ON cu.idEstadoCuota = ec.idEstadoCuota
WHERE ec.descripcion = 'Vencida';
GO


-- VISTA 3: Cobros Registrados
-- Muestra las cuotas que ya fueron pagadas, junto con la fecha de pago y el metodo de pago utilizado
CREATE VIEW vista_CobrosRegistrados AS
SELECT
    cu.idCuota,
    cu.idPrestamo,
    cl.idCliente,
    cl.username AS clienteUsername,
    cu.fechaPago,
    cu.monto,
    mp.descripcion AS metodoPago
FROM Cuota cu
INNER JOIN Prestamo p ON cu.idPrestamo = p.idPrestamo
INNER JOIN Cliente cl ON p.idCliente = cl.idCliente
INNER JOIN EstadoCuota ec ON cu.idEstadoCuota = ec.idEstadoCuota
INNER JOIN MetodoPago mp ON cu.idMetodoPago = mp.idMetodoPago
WHERE ec.descripcion = 'Pagada';
GO