# SRS â€” Nexum (POS Core + MÃ³dulo FlowFix)

## Feature: Venta con mÃºltiples mÃ©todos de pago
Scenario: Ticket con pago mixto
  Given un catÃ¡logo con "Protector" a $200
  And una caja abierta
  When agrego "Protector" x1 al ticket
  And aplico pago "efectivo" $100 y "tarjeta" $100
  Then el ticket se marca como "pagado"
  And se imprime el comprobante

## Feature: Control de inventario con alertas
Scenario: No permitir stock negativo
  Given "BaterÃ­a iPhone" stock 0
  When intento vender 1 unidad
  Then el sistema rechaza la venta por falta de stock

## FlowFix â€” Orden de reparaciÃ³n
Scenario: Crear orden y pasar a "En reparaciÃ³n"
  Given cliente "Juan" y equipo "iPhone 12 IMEI 123"
  When creo la orden con diagnÃ³stico
  Then la orden queda en "Ingresado"
  When el tÃ©cnico la toma y cambia a "En reparaciÃ³n"
  Then queda auditado
