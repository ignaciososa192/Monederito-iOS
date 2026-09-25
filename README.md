# Monederito iOS

Aplicación SwiftUI de práctica profesional: una billetera virtual con una experiencia coherente de cuenta, saldo, operaciones e historial.

**Estado:** desarrollo temprano; objetivo de versión `0.1.0`. No hay una release verificada todavía.

El alcance confirmado para esta etapa es **sandbox, sin dinero real**. Las pantallas existentes no implican integración con bancos, PSP, SUBE o prestadores de servicios. El rediseño visual se abordará después de cerrar los flujos.

## Documentación vigente

- [Diagnóstico del código y alcance de verificación](docs/BASELINE_AUDIT.md)
- [Producto y backlog de billetera](docs/WALLET_PLAN.md)
- [Gitflow, versiones y revisión](CONTRIBUTING.md)
- [Decisiones](docs/DECISIONS.md)

Los documentos MVP de agosto describen la hipótesis anterior de protección familiar. La nueva dirección reemplaza ese objetivo; se conservan como contexto histórico.

## Abrir el proyecto

Abrir `Monederito-iOS.xcodeproj` en Xcode con SDK compatible con el deployment target actual iOS 26.2. Resolver Swift Packages respetando `Package.resolved`.

La selección actual usa mocks en Debug y Supabase en Release. Firebase se inicializa en ambos: hoy se requiere una configuración válida `GoogleService-Info.plist` del entorno correspondiente, no incluida en el repositorio. El modo mock aún no es completamente autónomo.

No introducir claves privadas, service-role ni credenciales de firma en Git. La configuración reproducible por entorno y la compilación CI son tareas P0 del backlog.

## Colaboración

Ramas permanentes: `master` y `develop`. Cambios mediante ramas cortas y PR a `develop`. `main` permanece temporalmente como rama predeterminada durante la transición. Ver [CONTRIBUTING.md](CONTRIBUTING.md).
