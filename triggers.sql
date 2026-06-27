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