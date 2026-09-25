# Diagnóstico — 25 de septiembre de 2026

Commit analizado: `c1b2c60490c5c8843290af58744756a84c150c66`.

Revisión estática del repositorio y de sus documentos, ramas, tags, issues y PR. No se inspeccionó la base Supabase desplegada ni las consolas Firebase. Las conversaciones y proyectos accesibles en esta sesión no expusieron el historial de ChatGPT sobre Monederito; no se atribuyen decisiones a conversaciones que no se pudieron leer.

## Conclusión

Existe un prototipo avanzado de interfaz y arquitectura. Falta convertirlo en un sistema de billetera coherente: identidad individual, fuente única del saldo, operaciones persistidas y consistencia entre comprobante e historial. Reutilizar SwiftUI, MVVM, protocolos, repositorios y DI. Objetivo 0.1.0; 1.0.0 todavía no está justificado.

## Inventario

| Área | Evidencia existente | Trabajo pendiente |
|---|---|---|
| Arquitectura | Domain/Data/Presentation/Core; @Observable; DI; protocolos y mocks | Aislamiento de estado UI, inyección consistente y tests |
| Autenticación | Email/password, Google→Supabase, repositorio de sesión y reset | Restauración conectada al arranque; confirmación de correo; recuperación completa; no mutar rol al autenticar |
| Navegación | Onboarding y tabs por benefactor/beneficiary | Una cuenta individual; Inicio, Operar, Actividad, Perfil; quitar decisiones de tutela del flujo |
| Dashboard | Tarjetas, gráficos, transacciones, metas | Saldo e historial del usuario desde la misma fuente persistida |
| Operaciones | Formularios de transferencia, QR, celular, SUBE y servicios | Motor sandbox, validación, confirmación, idempotencia, saldo y recibo |
| Perfil | Pantallas, preferencias y servicios de biometría | Guardado real, errores, eliminación de cuenta y bloqueo de sesión verificable |
| Firebase | Inicialización, Analytics, Crashlytics y App Check | Configuración por entorno, evidencia de funcionamiento, simplificar paquetes |
| Notificaciones | Notificaciones locales y deep links | Recibos de billetera; push remoto no acreditado por este código |
| Calidad | Package.resolved | Sin target de tests, scheme compartido o workflow CI en baseline |
| Backend | Repositorios Supabase y documentación de tablas | Esquema/migraciones/RLS reproducibles y pruebas de acceso; no confirmados en entorno remoto |

## Hallazgos prioritarios

1. **P0 — Operaciones sin circuito de saldo.** `Data/Repositories/Operations/SupabaseOperationsRepository.swift` convierte todas las operaciones en inserts de Transaction. No ejecuta débito/crédito atómico, control de saldo ni idempotencia. En transferencia no persiste la cuenta destino; las recargas tampoco conservan todos los datos operativos. Un insert exitoso no demuestra pago o transferencia.
2. **P0 — Dashboard desconectado.** `Presentation/Dashboard/Beneficiary/BeneficiaryDashboardViewModel.swift` ignora userID y carga MockData aun fuera del repositorio mock. El usuario no verá el resultado real de sus operaciones en el saldo.
3. **P0 — Login puede cambiar el rol existente.** En `SupabaseAuthRepository.swift`, signIn/getCurrentUser llaman fetchOrCreateProfile con rol por defecto benefactor; si el perfil tiene otro rol, intentan actualizarlo. La autenticación no debería modificar atributos de dominio. La posibilidad de escribir ese cambio depende de RLS, que no se verificó.
4. **P0 — Arranque no restaura la sesión de la app.** getCurrentUser no tiene consumidores de presentación; MonederitoApp solo restaura Google y registra el resultado. RootView depende de isAuthenticated, inicialmente false.
5. **P0 — Compilación reproducible pendiente.** FirebaseApp.configure se ejecuta incluso en Debug mock; GoogleService-Info.plist está ignorado y falta en el checkout. El proyecto incluye una fase de subida de símbolos Crashlytics. No hay scheme compartido ni tests. Debug mock y Release Supabase cambian a la vez backend y optimización: separar entorno de configuración de compilación.
6. **P1 — Decodificación de gasto mensual incompatible con la consulta.** getMonthlySpending selecciona category/amount y decodifica SupabaseTransaction, que exige id/userID/merchant/date/status. Introducir un DTO de agregación o realizar la agregación en backend; filtrar estados contables adecuados.
7. **P1 — Perfil muestra un éxito no persistido.** SettingsViewModel.saveProfile no llama repo.updateProfile; deleteAccount solo espera. Evitar confirmaciones de éxito hasta verificar la operación.
8. **P1 — Modelo monetario/estado insuficiente.** Transaction usa Double y raw values localizados; valores desconocidos se convierten a completed y UUID inválidos se reemplazan por UUID aleatorios. Adoptar centavos Int64 o Decimal con contrato explícito, moneda, dirección, estados estables y errores de decodificación.
9. **P1 — QR y destinatarios son simulaciones.** QRPaymentViewModel.startScanning carga un comercio fijo; TransferViewModel tiene contactos fijos y no resuelve alias. Marcar sandbox y proveer destinos/QR de prueba coherentes. Cancelar escaneo debe cancelar su tarea.
10. **P1 — Analytics tiene abstracción, no recorrido instrumentado.** La búsqueda de trackLogin/trackTransfer/trackTransaction solo encontró definiciones. Además trackTransfer admite destinatario y monto: sustituir identificadores personales por atributos no sensibles y una taxonomía mínima.
11. **P1 — Backend no reproducible.** .gitignore excluye supabase/. Los documentos afirman que existe RLS y mencionan hallazgos de seguridad antiguos; eso es contexto histórico, no validación actual. Versionar migraciones y políticas saneadas cuando se inspeccione el proyecto correcto.
12. **P2 — Reducir superficie.** El target enlaza numerosos productos Firebase sin uso demostrado, y mantiene alertas/riesgo/educación/control parental del producto anterior. Retirar dependencias y módulos en PR específicos con compilación, sin reescribir toda la arquitectura.

## Verificación y límites

- Git: baseline solo main; sin tags; búsquedas de issues y PR vacías.
- Xcode local disponible: 27.1 (27A9269); deployment target del proyecto: iOS 26.2.
- Intento de xcodebuild -list encontró restricciones de cachés/CoreSimulator durante resolución de paquetes. Con permisos de caché concedidos se reintentó; la evaluación de manifiestos falló con `sandbox-exec: sandbox_apply: Operation not permitted` (exit 74). No se obtuvo evidencia de build ni de ejecución en simulador. No se afirma que el código compile o que las integraciones estén operativas.
- Firebase 12.17.0, GoogleSignIn 9.2.0 y Supabase Swift 2.43.1 según Package.resolved; no se actualizaron dependencias.
- No se realizó auditoría visual: este documento evalúa implementación y flujo inferido del código, no apariencia en dispositivo.
