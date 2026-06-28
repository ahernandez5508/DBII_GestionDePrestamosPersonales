-----------------------------------
-- CREACIÓN E INSERCIÓN DE DATOS --
-----------------------------------

CREATE DATABASE DBII_GestionDePrestamosPersonales;
GO

--CREACION
USE DBII_GestionDePrestamosPersonales
GO

CREATE TABLE Rol (
    idRol INT NOT NULL IDENTITY PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL UNIQUE
);
GO

CREATE TABLE EstadoPrestamo (
    idEstadoPrestamo INT NOT NULL IDENTITY PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL
);
GO

CREATE TABLE EstadoCuota (
    idEstadoCuota INT NOT NULL IDENTITY PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL
);
GO

CREATE TABLE Cliente (
    idCliente INT NOT NULL IDENTITY PRIMARY KEY,
    username VARCHAR(25) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255) NOT NULL
);
GO

CREATE TABLE MetodoPago (
    idMetodoPago INT NOT NULL IDENTITY PRIMARY KEY,
    descripcion VARCHAR(25) NOT NULL
);
GO

CREATE TABLE ProductoPrestamo (
    idProducto INT NOT NULL IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    montoMinimo DECIMAL(12,2) NOT NULL,
    montoMaximo DECIMAL(12,2) NOT NULL,
    cuotasMinimas INT NOT NULL,
    cuotasMaximas INT NOT NULL
);
GO

CREATE TABLE Usuario (
    idUsuario INT NOT NULL IDENTITY PRIMARY KEY,
    idRol INT NOT NULL,
    username VARCHAR(25) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    activo BIT NOT NULL,
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (idRol) REFERENCES Rol(idRol)
);
GO

CREATE TABLE Prestamo (
    idPrestamo INT NOT NULL IDENTITY PRIMARY KEY,
    idProducto INT NOT NULL,
    idCliente INT NOT NULL,
    idUsuarioAprobador INT,
    monto DECIMAL(12,2) NOT NULL,
    interesTotal DECIMAL(12,2) NOT NULL,
    cantidadCuotas SMALLINT NOT NULL,
    cuotasRestantes SMALLINT NOT NULL,
    fechaAprobacion DATE,
    fechaUltimaActualizacion DATE NOT NULL,
    idEstadoPrestamo INT NOT NULL,
    CONSTRAINT FK_Prestamo_ProductoPrestamo FOREIGN KEY (idProducto) REFERENCES ProductoPrestamo(idProducto),
    CONSTRAINT FK_Prestamo_Cliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    CONSTRAINT FK_Prestamo_Usuario FOREIGN KEY (idUsuarioAprobador) REFERENCES Usuario(idUsuario),
    CONSTRAINT FK_Prestamo_EstadoPrestamo FOREIGN KEY (idEstadoPrestamo) REFERENCES EstadoPrestamo(idEstadoPrestamo)
);
GO

CREATE TABLE Cuota (
    idCuota INT NOT NULL IDENTITY PRIMARY KEY,
    idPrestamo INT NOT NULL,
    idEstadoCuota INT NOT NULL,
    fechaVencimiento DATE NOT NULL,
    fechaPago DATE,
    monto DECIMAL(12,2) NOT NULL,
    idMetodoPago INT,
    CONSTRAINT FK_Cuota_Prestamo FOREIGN KEY (idPrestamo) REFERENCES Prestamo(idPrestamo),
    CONSTRAINT FK_Cuota_EstadoCuota FOREIGN KEY (idEstadoCuota) REFERENCES EstadoCuota(idEstadoCuota),
    CONSTRAINT FK_Cuota_MetodoPago FOREIGN KEY (idMetodoPago) REFERENCES MetodoPago(idMetodoPago)
);
GO

CREATE TABLE HistorialEstadoPrestamo (
    idHistorial INT NOT NULL IDENTITY PRIMARY KEY,
    idPrestamo INT NOT NULL,
    idEstadoPrestamo INT NOT NULL,
    fechaCambio DATE NOT NULL,
    idUsuario INT,
    observaciones VARCHAR(255),
    CONSTRAINT FK_HistorialEstadoPrestamo_Prestamo FOREIGN KEY (idPrestamo) REFERENCES Prestamo(idPrestamo),
    CONSTRAINT FK_HistorialEstadoPrestamo_EstadoPrestamo FOREIGN KEY (idEstadoPrestamo) REFERENCES EstadoPrestamo(idEstadoPrestamo),
    CONSTRAINT FK_HistorialEstadoPrestamo_Usuario FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);
GO

CREATE TABLE TasaInteres (
    idTasaInteres INT NOT NULL IDENTITY PRIMARY KEY,
    idProducto INT NOT NULL,
    cuotasDesde INT NOT NULL,
    cuotasHasta INT NOT NULL,
    tasaMensual DECIMAL(7,4) NOT NULL,
    CONSTRAINT FK_TasaInteres_ProductoPrestamo FOREIGN KEY (idProducto) REFERENCES ProductoPrestamo(idProducto)
);
GO


--INSERCION
USE DBII_GestionDePrestamosPersonales
GO

INSERT INTO EstadoPrestamo (descripcion) VALUES ('Solicitado');
INSERT INTO EstadoPrestamo (descripcion) VALUES ('Aprobado');
INSERT INTO EstadoPrestamo (descripcion) VALUES ('Rechazado');
INSERT INTO EstadoPrestamo (descripcion) VALUES ('En Curso');
INSERT INTO EstadoPrestamo (descripcion) VALUES ('Finalizado');
INSERT INTO EstadoPrestamo (descripcion) VALUES ('Cancelado');

INSERT INTO EstadoCuota (descripcion) VALUES ('Pendiente');
INSERT INTO EstadoCuota (descripcion) VALUES ('Pagada');
INSERT INTO EstadoCuota (descripcion) VALUES ('Vencida');

INSERT INTO Rol (descripcion) VALUES ('Administrador');
INSERT INTO Rol (descripcion) VALUES ('Operador');

INSERT INTO MetodoPago (descripcion) VALUES ('Efectivo');
INSERT INTO MetodoPago (descripcion) VALUES ('Transferencia');
INSERT INTO MetodoPago (descripcion) VALUES ('Tarjeta de Credito');
INSERT INTO MetodoPago (descripcion) VALUES ('Tarjeta de Debito');
INSERT INTO MetodoPago (descripcion) VALUES ('Criptomoneda');

INSERT INTO ProductoPrestamo (nombre, descripcion, montoMinimo, montoMaximo, cuotasMinimas, cuotasMaximas)
    VALUES ('Prestamo Personal', 'Credito de libre destino a sola firma, sin garantia real requerida.', 50000.00, 5000000.00, 3, 36);
INSERT INTO ProductoPrestamo (nombre, descripcion, montoMinimo, montoMaximo, cuotasMinimas, cuotasMaximas)
    VALUES ('Prestamo Prendario', 'Credito para financiacion de vehiculos. El bien adquirido queda como garantia hasta la cancelacion total.', 500000.00, 20000000.00, 12, 60);
INSERT INTO ProductoPrestamo (nombre, descripcion, montoMinimo, montoMaximo, cuotasMinimas, cuotasMaximas)
    VALUES ('Prestamo Hipotecario', 'Credito para adquisicion de inmuebles. La propiedad queda como garantia hasta la cancelacion total.', 5000000.00, 150000000.00, 24, 240);

INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (1, 3, 6, 0.0450);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (1, 7, 12, 0.0500);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (1, 13, 24, 0.0575);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (1, 25, 36, 0.0650);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (2, 12, 24, 0.0350);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (2, 25, 36, 0.0400);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (2, 37, 48, 0.0475);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (2, 49, 60, 0.0525);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (3, 24, 60, 0.0250);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (3, 61, 120, 0.0300);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (3, 121, 180, 0.0350);
INSERT INTO TasaInteres (idProducto, cuotasDesde, cuotasHasta, tasaMensual) VALUES (3, 181, 240, 0.0400);
GO






------------------------
-- CREACIÓN DE VISTAS --
------------------------

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






----------------------------------
-- CREACIÓN DE STORE PROCEDURES --
----------------------------------
USE DBII_GestionDePrestamosPersonales
GO


-- SP 1:
-- Usado por un cliente para solicitar un prestamo sobre un producto.
-- Valida que el monto y la cantidad de cuotas esten dentro de los rangos permitidos por el producto,
-- calcula la tasa de interes correspondiente al tramo de cuotas seleccionado, el interes total y deja el prestamo generado en estado Solicitado.
CREATE PROCEDURE sp_SolicitarPrestamo (
    @idCliente INT,
    @idProducto INT,
    @monto DECIMAL(12,2),
    @cantidadCuotas SMALLINT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Valido que el cliente no tenga un prestamo activo
        IF EXISTS (
            SELECT 1 FROM Prestamo p
            INNER JOIN EstadoPrestamo ep ON p.idEstadoPrestamo = ep.idEstadoPrestamo
            WHERE p.idCliente = @idCliente
                AND ep.descripcion IN ('Solicitado', 'Aprobado', 'En Curso')
        )
        BEGIN
            RAISERROR('EL CLIENTE YA TIENE UN PRESTAMO ACTIVO', 16, 1)
        END

        -- Valido que el producto exista y obtengo sus rangos
        DECLARE @montoMinimo DECIMAL(12,2)
        DECLARE @montoMaximo DECIMAL(12,2)
        DECLARE @cuotasMinimas INT
        DECLARE @cuotasMaximas INT

        SELECT
            @montoMinimo = montoMinimo,
            @montoMaximo = montoMaximo,
            @cuotasMinimas = cuotasMinimas,
            @cuotasMaximas = cuotasMaximas
        FROM ProductoPrestamo
        WHERE idProducto = @idProducto

        IF @montoMinimo IS NULL
        BEGIN
            RAISERROR('EL PRODUCTO INDICADO NO EXISTE', 16, 1)
        END

        -- Valido que el monto este dentro del rango permitido
        IF @monto < @montoMinimo OR @monto > @montoMaximo
        BEGIN
            RAISERROR('EL MONTO SOLICITADO NO SE ENCUENTRA DENTRO DEL RANGO PERMITIDO POR EL PRODUCTO', 16, 1)
        END

        -- Valido que la cantidad de cuotas este dentro del rango permitido
        IF @cantidadCuotas < @cuotasMinimas OR @cantidadCuotas > @cuotasMaximas
        BEGIN
            RAISERROR('LA CANTIDAD DE CUOTAS NO SE ENCUENTRA DENTRO DEL RANGO PERMITIDO POR EL PRODUCTO', 16, 1)
        END

        -- Busco la tasa mensual correspondiente al tramo de cuotas
        DECLARE @tasaMensual DECIMAL(7,4)

        SELECT @tasaMensual = tasaMensual
        FROM TasaInteres
        WHERE idProducto = @idProducto
          AND @cantidadCuotas BETWEEN cuotasDesde AND cuotasHasta

        IF @tasaMensual IS NULL
        BEGIN
            RAISERROR('NO EXISTE UNA TASA DE INTERES DEFINIDA PARA LA CANTIDAD DE CUOTAS SOLICITADA', 16, 1)
        END

        -- Calculo el interes total
        DECLARE @interesTotal DECIMAL(12,2)
        SET @interesTotal = @monto * @tasaMensual * @cantidadCuotas

        -- Busco el idEstadoPrestamo correspondiente a 'Solicitado'.
        DECLARE @idEstadoSolicitado INT
        SELECT @idEstadoSolicitado = idEstadoPrestamo
        FROM EstadoPrestamo
        WHERE descripcion = 'Solicitado'

        -- Doy de alta el prestamo
        INSERT INTO Prestamo (
            idProducto, idCliente, idUsuarioAprobador, monto, interesTotal,
            cantidadCuotas, cuotasRestantes, fechaAprobacion,
            fechaUltimaActualizacion, idEstadoPrestamo
        )
        VALUES (
            @idProducto, @idCliente, NULL, @monto, @interesTotal,
            @cantidadCuotas, @cantidadCuotas, NULL,
            GETDATE(), @idEstadoSolicitado
        )

        COMMIT TRANSACTION
        PRINT 'Prestamo solicitado con exito.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Error al solicitar el prestamo: ' + ERROR_MESSAGE()
    END CATCH
END;
GO


-- SP 2:
-- Lo usa un operador aprobar o rechazar un prestamo que se encuentra en estado Solicitado.
CREATE PROCEDURE sp_CambiarEstadoPrestamo (
    @idPrestamo INT,
    @idUsuarioOperador INT,
    @nuevoEstado VARCHAR(20),
    @observaciones VARCHAR(255)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Solo permito aprobar o rechazar
        IF @nuevoEstado NOT IN ('Aprobado', 'Rechazado')
        BEGIN
            RAISERROR('EL ESTADO INDICADO NO ES VALIDO PARA ESTE PROCEDIMIENTO', 16, 1)
        END

        -- Verifico que el prestamo exista y este en estado Solicitado
        DECLARE @idEstadoActual INT
        DECLARE @descripcionEstadoActual VARCHAR(20)

        SELECT
            @idEstadoActual = p.idEstadoPrestamo,
            @descripcionEstadoActual = ep.descripcion
        FROM Prestamo p
        INNER JOIN EstadoPrestamo ep ON p.idEstadoPrestamo = ep.idEstadoPrestamo
        WHERE p.idPrestamo = @idPrestamo

        IF @idEstadoActual IS NULL
        BEGIN
            RAISERROR('EL PRESTAMO INDICADO NO EXISTE', 16, 1)
        END

        IF @descripcionEstadoActual <> 'Solicitado'
        BEGIN
            RAISERROR('SOLO SE PUEDEN APROBAR O RECHAZAR PRESTAMOS QUE ESTEN EN ESTADO SOLICITADO', 16, 1)
        END

        -- Busco el id del nuevo estado
        DECLARE @idNuevoEstado INT
        
        SELECT
            @idNuevoEstado = idEstadoPrestamo
        FROM EstadoPrestamo
        WHERE descripcion = @nuevoEstado

        
        -- Agrego el registro al historial de cambios de estado de prestamo.
        INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
            VALUES (@idPrestamo, @idNuevoEstado, GETDATE(), @idUsuarioOperador, @observaciones)
        
        -- Actualizo el prestamo.
        UPDATE Prestamo
        SET
            idEstadoPrestamo = @idNuevoEstado,
            idUsuarioAprobador = @idUsuarioOperador,
            fechaAprobacion = CASE
                                WHEN @nuevoEstado = 'Aprobado' THEN GETDATE()
                                ELSE fechaAprobacion
                              END,
            fechaUltimaActualizacion = GETDATE()
        WHERE idPrestamo = @idPrestamo

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('NO SE PUDO ACTUALIZAR EL PRESTAMO', 16, 1)
        END

        COMMIT TRANSACTION
        PRINT 'Estado del prestamo actualizado con exito.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Error al cambiar el estado del prestamo: ' + ERROR_MESSAGE()
    END CATCH
END;
GO


-- SP 3:
-- Lo puede usar un operador para registrar el pago de una cuota (pendiente o vencida), indicando el metodo de pago utilizado.
-- Luego del UPDATE de la cuota se dispara el trigger "trg_ActualizarCuotasRestantes", que actualiza las cuotas en el prestamo.
CREATE PROCEDURE sp_RegistrarPagoCuota (
    @idCuota INT,
    @idMetodoPago INT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Verifico que la cuota exista y este pendiente de pago
        DECLARE @descripcionEstadoCuota VARCHAR(20)

        SELECT
            @descripcionEstadoCuota = ec.descripcion
        FROM Cuota cu
        INNER JOIN EstadoCuota ec ON cu.idEstadoCuota = ec.idEstadoCuota
        WHERE cu.idCuota = @idCuota

        IF @descripcionEstadoCuota IS NULL
        BEGIN
            RAISERROR('LA CUOTA INDICADA NO EXISTE', 16, 1)
        END

        IF @descripcionEstadoCuota NOT IN ('Pendiente', 'Vencida')
        BEGIN
            RAISERROR('LA CUOTA INDICADA YA SE ENCUENTRA PAGADA', 16, 1)
        END

        -- Busco el idEstadoCuota correspondiente a 'Pagada'.
        DECLARE @idEstadoPagada INT
        SELECT @idEstadoPagada = idEstadoCuota
        FROM EstadoCuota
        WHERE descripcion = 'Pagada'

        -- Registro el pago.
        UPDATE Cuota
        SET
            idEstadoCuota = @idEstadoPagada,
            fechaPago = GETDATE(),
            idMetodoPago = @idMetodoPago
        WHERE idCuota = @idCuota

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('NO SE PUDO REGISTRAR EL PAGO DE LA CUOTA', 16, 1)
        END

        COMMIT TRANSACTION
        PRINT 'Pago de cuota registrado con exito.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Error al registrar el pago de la cuota: ' + ERROR_MESSAGE()
    END CATCH
END;
GO






--------------------------
-- CREACIÓN DE TRIGGERS --
--------------------------
USE DBII_GestionDePrestamosPersonales
GO

-- TRIGGER 1:
-- Ejecuto despues de cualquier UPDATE sobre la tabla Cuota.
-- Cuando una cuota pasa al estado Pagada hago un UPDATE a Prestamo para descontarle las cuotasRestantes.
-- Si las cuotasRestantes llegan a 0 actualizo el estado del prestamo a Finalizado (y agrego ese cambio al historial).
CREATE TRIGGER trg_ActualizarCuotasRestantes ON Cuota
AFTER UPDATE
AS
BEGIN
    DECLARE @idEstadoPagada INT
    SELECT @idEstadoPagada = idEstadoCuota FROM EstadoCuota WHERE descripcion = 'Pagada'
 
    DECLARE @idPrestamo INT
    SELECT @idPrestamo = idPrestamo FROM inserted
 
    -- Solo procedo si la cuota paso a Pagada en este UPDATE
    IF (SELECT idEstadoCuota FROM inserted) = @idEstadoPagada
    BEGIN
        -- Descuento en uno las cuotasREstantes del prestamo enc uestion.
        UPDATE Prestamo
        SET cuotasRestantes = cuotasRestantes - 1,
            fechaUltimaActualizacion = GETDATE()
        WHERE idPrestamo = @idPrestamo
 
        -- Si el prestamo se quedo sin cuotas restantes lo paso a Finalizado
        DECLARE @idEstadoFinalizado INT
        SELECT @idEstadoFinalizado = idEstadoPrestamo FROM EstadoPrestamo WHERE descripcion = 'Finalizado'

        DECLARE @cuotasRestantes INT
        SELECT @cuotasRestantes = cuotasRestantes FROM Prestamo WHERE idPrestamo = @idPrestamo
 
        IF (@cuotasRestantes = 0)
        BEGIN
            UPDATE Prestamo
            SET idEstadoPrestamo = @idEstadoFinalizado,
                fechaUltimaActualizacion = GETDATE()
            WHERE idPrestamo = @idPrestamo
 
            -- Registro el pase a Finalizado en el historial
            INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
                VALUES (@idPrestamo, @idEstadoFinalizado, GETDATE(), NULL, NULL)
        END
    END
END;
GO


-- TRIGGER 2
-- Ejecuto despues de cualquier UPDATE sobre Prestamo.
-- Si el prestamo paso a estado Aprobado, lo pasa automaticamente a En Curso.
CREATE TRIGGER trg_PasoAEnCurso ON Prestamo
AFTER UPDATE
AS
BEGIN
    DECLARE @idEstadoAprobado INT
    SELECT @idEstadoAprobado = idEstadoPrestamo FROM EstadoPrestamo WHERE descripcion = 'Aprobado'

    -- Solo paso a EnCurso si se esta aprobando
    IF (SELECT idEstadoPrestamo FROM inserted) = @idEstadoAprobado
    BEGIN
        DECLARE @idPrestamo INT
        SELECT @idPrestamo = idPrestamo FROM inserted

        DECLARE @idEstadoEnCurso INT
        SELECT @idEstadoEnCurso = idEstadoPrestamo FROM EstadoPrestamo WHERE descripcion = 'En Curso'

        -- Paso el prestamo a En Curso
        UPDATE Prestamo
        SET idEstadoPrestamo = @idEstadoEnCurso,
            fechaUltimaActualizacion = GETDATE()
        WHERE idPrestamo = @idPrestamo

        -- Registro el cambio de estado en el historial
        INSERT INTO HistorialEstadoPrestamo (idPrestamo, idEstadoPrestamo, fechaCambio, idUsuario, observaciones)
            VALUES (@idPrestamo, @idEstadoEnCurso, GETDATE(), NULL, NULL)
    END
END;
GO



-- TRIGGER 3:
-- Lo ejecuto despues de cualquier UPDATE sobre Prestamo.
-- Si el prestamo paso a En Curso genero todas las cuotas.
-- La primer cuota vence dos meses despues de la aprobacion y las siguientes se generan mes a mes a partir de ahi
CREATE TRIGGER trg_GenerarCuotas ON Prestamo
AFTER UPDATE
AS
BEGIN
    DECLARE @idEstadoEnCurso INT
    SELECT @idEstadoEnCurso = idEstadoPrestamo FROM EstadoPrestamo WHERE descripcion = 'En Curso'

    -- Ejecuto solo si el prestamo esta pasando a En Curso
    IF (SELECT idEstadoPrestamo FROM inserted) = @idEstadoEnCurso
        AND (SELECT idEstadoPrestamo FROM deleted) <> @idEstadoEnCurso
    BEGIN
        DECLARE @idPrestamo INT
        DECLARE @cantidadCuotas SMALLINT
        DECLARE @montoCuota DECIMAL(12,2)
        DECLARE @fechaBase DATE

        SELECT
            @idPrestamo = idPrestamo,
            @cantidadCuotas = cantidadCuotas,
            @montoCuota = (monto + interesTotal) / cantidadCuotas,
            @fechaBase = DATEADD(month, 2, fechaAprobacion)
        FROM inserted

        DECLARE @idEstadoPendiente INT
        SELECT @idEstadoPendiente = idEstadoCuota FROM EstadoCuota WHERE descripcion = 'Pendiente'

        DECLARE @cuotaActual SMALLINT
        SET @cuotaActual = 1

        DECLARE @fechaVencimiento DATE
        WHILE @cuotaActual <= @cantidadCuotas
        BEGIN
            -- Calculo el mes de vencimiento de esta cuota
            SET @fechaVencimiento = DATEADD(month, @cuotaActual - 1, @fechaBase)
    
            -- Ajusto al dia 10 (restando o agregando dias al dia en que se pidio el prestamo)
            SET @fechaVencimiento = DATEADD(day, 10 - DAY(@fechaVencimiento), @fechaVencimiento)

            INSERT INTO Cuota (idPrestamo, idEstadoCuota, fechaVencimiento, fechaPago, monto, idMetodoPago)
                VALUES (@idPrestamo, @idEstadoPendiente, @fechaVencimiento, NULL, @montoCuota, NULL)

            SET @cuotaActual = @cuotaActual + 1
        END
    END
END;
GO




------------------------------
-- INSERCIÓN DE DATOS DUMMY --
------------------------------
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