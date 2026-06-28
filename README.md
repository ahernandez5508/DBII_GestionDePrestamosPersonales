# DBII — Sistema de Gestión de Préstamos Personales

Base de Datos II — Tecnicatura Universitaria en Programación  
Facultad Regional General Pacheco — UTN

---

## Descripción

Sistema de gestión de préstamos personales desarrollado sobre **SQL Server**. Cubre el ciclo completo de un préstamo: solicitud, aprobación, generación automática del plan de cuotas y seguimiento de pagos hasta la finalización.

---

## Ejecución rápida

Para tener la base de datos creada y lista con datos de ejemplo, ejecutar el siguiente script:

```
Todos_Scripts_En_Uno.sql
```

Este script incluye la creación de la base de datos, todas las tablas, vistas, procedimientos almacenados, triggers y datos dummy para pruebas.

---

## Scripts individuales

Si se prefiere ejecutar por partes, el orden correcto es:

| # | Archivo | Descripción |
|---|---------|-------------|
| 1 | `creacion_insercionDatosIniciales_DB.sql` | Crea la base de datos, tablas y datos iniciales |
| 2 | `vistas.sql` | Crea las 3 vistas del sistema |
| 3 | `Store_Procedures.sql` | Crea los 3 procedimientos almacenados |
| 4 | `triggers.sql` | Crea los 3 triggers |
| 5 | `datosDummy.sql` | Inserta datos de ejemplo para pruebas |

---

## Pruebas

El archivo `Uso_Del_Sistema.sql` contiene ejemplos de uso del sistema: solicitud de un préstamo, aprobación, generación de cuotas y registro de pagos. Ejecutar después del paso anterior.

---

## Objetos principales

**Vistas**
- `vista_PrestamosActivos` — préstamos en estado En Curso
- `vista_CuotasVencidas` — cuotas en estado Vencida
- `vista_CobrosRegistrados` — cuotas pagadas

**Procedimientos almacenados**
- `sp_SolicitarPrestamo` — solicitud de un préstamo con validaciones
- `sp_CambiarEstadoPrestamo` — aprobación o rechazo por parte de un operador
- `sp_RegistrarPagoCuota` — registro del pago de una cuota

**Triggers**
- `trg_PasoAEnCurso` — pasa el préstamo a En Curso al aprobarse
- `trg_GenerarCuotas` — genera el plan de cuotas al pasar a En Curso
- `trg_ActualizarCuotasRestantes` — descuenta cuotas al registrar un pago y finaliza el préstamo al llegar a cero
