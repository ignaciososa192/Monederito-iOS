# Monederito — cierre como billetera

## Dirección vigente

Solicitud del propietario del 25/09/2026: cerrar una app SwiftUI de billetera estándar para práctica profesional; retirar bloqueo antifraude, aprobación de tutor y control parental como lógica central. Conservar el historial de investigación y posponer el rediseño.

Alcance confirmado por el propietario: **sandbox persistente, sin dinero real**, para portfolio. En versiones posteriores podrá evaluarse dinero real y la acreditación de ganancias desde otra app, como Pasito.

Usuario principal: titular de su cuenta. Promesa: consultar su saldo, ingresar fondos de prueba, enviar/pagar, comprender el resultado y recuperar el comprobante. No presentarse como banco ni afirmar integraciones reales que no existen.

## Recorrido de cierre

1. Onboarding breve → registro/login → verificación/recuperación → restauración de sesión.
2. Inicio → saldo disponible en ARS, actividad reciente, ingreso de fondos sandbox y accesos a operaciones.
3. Transferir → seleccionar/resolver destinatario sandbox → monto → revisar → confirmar → resultado/recibo.
4. Saldo e historial reflejan exactamente el mismo movimiento. Reintentar no duplica cargos.
5. QR, recargas y servicios reutilizan el contrato de operación con datos de destino persistidos y etiqueta sandbox.
6. Perfil → edición persistida, preferencias, biometría, logout y eliminación verificable.

No mezclar ingreso sandbox con una transferencia bancaria real. Las operaciones fallidas no descuentan saldo; las pendientes tienen estado visible; fondos insuficientes y doble confirmación se manejan en dominio/backend, además de la UI.

## Backlog por orden de ejecución

| ID | Prioridad | Rama sugerida | Resultado y aceptación |
|---|---|---|---|
| W01 | P0 | chore/reproducible-ios-build | Checkout nuevo compila sin configuración privada en modo mock; scheme compartido; build CI; target de tests; Release/sandbox configurables explícitamente |
| W02 | P0 | fix/supabase-auth-session | Registro con/sin confirmación, login, Google, relanzamiento, expiración, recuperación y logout probados; autenticación no cambia roles |
| W03 | P0 | chore/firebase-environments | Mock no depende de Firebase; sandbox configurado; evidencia de Crashlytics/App Check; dependencias justificadas |
| W04 | P0 | feat/wallet-navigation | Una cuenta y tabs Inicio/Operar/Actividad/Perfil; no control parental, aprobación ni bloqueo educativo en recorrido; enlaces antiguos manejados |
| W05 | P0 | feat/wallet-ledger | Wallet, moneda, dinero exacto, movimientos y operación atómica con idempotency key; tests de saldo insuficiente, concurrencia y reintentos |
| W06 | P0 | feat/wallet-transfers | Destinatario persistido, revisión previa, resultado recuperable y recibo; historial/saldo refrescados desde fuente única |
| W07 | P0 | fix/profile-persistence | Guardado y errores reales; logout limpia sesión/rutas/cache; eliminar cuenta tiene resultado verificable |
| W08 | P0 | chore/supabase-contracts | Migraciones y seed versionados; políticas verificadas con dos usuarios; cliente no puede modificar saldo directamente |
| W09 | P1 | feat/wallet-payments | QR sandbox, recargas celular/SUBE y servicios completos usando contrato de W05; sin mensajes de éxito falso |
| W10 | P1 | feat/analytics-wallet-events | Eventos en acciones reales: login, operación iniciada/confirmada/fallida, recibo visto; sin destinatarios ni datos personales; assertions con mock |
| W11 | P1 | feat/wallet-notifications | Notificación de resultado y deep link al movimiento correcto; respeta sesión y usuario |
| W12 | P1 | chore/beta-readiness | E2E, VoiceOver/Dynamic Type, escenarios offline/error, TestFlight y checklist de cierre; políticas/copy alineadas con sandbox |
| W13 | P2 | chore/legacy-cleanup | Retirar módulos/dependencias sin uso después de cerrar navegación; conservar decisiones históricas |
| W14 | P2 | design/wallet-refresh | Rediseño basado en flujos terminados y evidencia visual |

W08 debe completarse antes de exponer W05/W06 a usuarios externos. Cada fila se divide en PR pequeños cuando empiece; no abrir ramas vacías por todas las tareas.

## Arquitectura y práctica deliberada

Mantener MVVM + repositorios + DI. Agregar tipos de dominio Money, Wallet y Operation con responsabilidades claras, sin introducir capas por moda. Aislar estado observable UI en MainActor; cancelación y carga concurrente estructurada; inyección de reloj/UUID cuando facilite pruebas de idempotencia. Probar reglas y contratos, no reflejar cada línea de implementación.

El desafío profesional está en consistencia de datos, concurrencia, recuperación de errores, observabilidad y entrega reproducible. No hace falta una reescritura para practicar a nivel de cinco años de experiencia.

## Criterio de 1.0.0 sandbox

Todo P0 y los flujos visibles de P1 terminados; ningún botón simula éxito sin persistir; saldo e historial consistentes al relanzar; acceso entre usuarios denegado; CI de build/tests verde; recorrido en dispositivo/TestFlight documentado; límites sandbox visibles. Los módulos que no se cierren deben quedar fuera de la navegación antes de lanzar.

## Evolución hacia integraciones externas

Preparar el dominio de créditos con `source`, `externalReference`, moneda, importe exacto, estado e idempotency key. El backend valida el origen y aplica el asiento atómicamente; la app iOS no acredita dinero por sí misma. Un evento repetido con la misma referencia no duplica saldo; rechazar reutilización de referencia con importe diferente.

Para el portfolio, un adaptador sandbox puede simular `external_earning_credited` y mostrar el origen en el historial. No se asume un contrato público de Pasito ni se crea una integración con esa app en esta etapa. Una versión posterior requerirá contrato acordado, autenticación entre servicios, conciliación y reversos, además de infraestructura para dinero real.
