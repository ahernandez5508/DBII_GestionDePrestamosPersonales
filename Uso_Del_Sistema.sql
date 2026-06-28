USE DBII_GestionDePrestamosPersonales
GO

-- =================
-- ESTADO INICIAL
-- =================

SELECT * FROM vista_PrestamosActivos;
SELECT * FROM vista_CuotasVencidas;
SELECT * FROM vista_CobrosRegistrados;




-- ==========================================================================================
-- SOLICITUD DE PRESTAMO
-- Cliente 1 solicita un Prestamo Personal (producto 1) de $300.000 en 6 cuotas.
-- ==========================================================================================

EXEC sp_SolicitarPrestamo 1, 1, 300000.00, 6;
SELECT * FROM Prestamo WHERE idPrestamo = 5;




-- ====================================================================================================
-- APROBACION DE PRESTAMO
-- El operador 1 aprueba el prestamo recien solicitado.
-- Automaticamente pasa a En Curso (trg_PasoAEnCruso) y se generan las 6 cuotas (trg_GenerarCuotas).
-- ====================================================================================================

EXEC sp_CambiarEstadoPrestamo 5, 1, 'Aprobado', 'Documentacion verificada.';
SELECT * FROM Prestamo WHERE idPrestamo = 5;
SELECT * FROM Cuota WHERE idPrestamo = 5;
SELECT * FROM HistorialEstadoPrestamo WHERE idPrestamo = 5;



-- =============================================
-- PAGO LA ULTIMA CUOTA DEL PRESTAMO
-- Al prestamo 2 solo le queda 1 cuota restante (idCuota = 6).
-- Al pagarla, cuotasRestantes llega a 0 y el prestamo pasa automaticamente a Finalizado (trg_ActualizarCuotasRestantes).
-- =============================================

EXEC sp_RegistrarPagoCuota 6, 2;
SELECT * FROM Prestamo WHERE idPrestamo = 2;
SELECT * FROM HistorialEstadoPrestamo WHERE idPrestamo = 2;




-- =============================================
-- 5. ESTADO FINAL DE LA BASE DE DATOS
-- =============================================

-- EXEC sp_RegistrarPagoCuota 7, 3;

SELECT * FROM vista_PrestamosActivos;
SELECT * FROM vista_CuotasVencidas;
SELECT * FROM vista_CobrosRegistrados;