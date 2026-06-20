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