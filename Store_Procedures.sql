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