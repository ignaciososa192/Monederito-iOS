# W03 — Firebase por entorno

## Comportamiento

| Scheme / configuración | Firebase | App Check | Crashlytics |
|---|---|---|---|
| Monederito-Mock / Debug y Release | No se inicializa; analytics mock | No solicita tokens | Sin recolección ni subida de símbolos |
| Monederito-Sandbox / SandboxDebug | Plist local validado | Debug provider | Recolección sandbox y pruebas explícitas |
| Monederito-Sandbox / SandboxRelease | Plist local validado | App Attest, DeviceCheck si el dispositivo no soporta App Attest | Recolección sandbox; símbolos en Archive |

Mock no necesita credenciales ni inicialización de Firebase. El target compartido conserva el enlace a los cuatro SDK utilizados y SwiftPM los resuelve al compilar; esto no significa un build sin descarga de dependencias. El test hosted existente comprueba `FirebaseApp.app() == nil` en Mock.

Sandbox valida campos obligatorios, plataforma iOS, bundle ID y client ID cuando el plist lo incluye, antes de `FirebaseApp.configure()`. Un plist de otra app muestra el error de configuración. `GoogleService-Info.plist` y `Config/Sandbox.local.xcconfig` siguen ignorados; copiarlos desde el checkout local al checkout W03 para una prueba Sandbox, sin commitearlos.

El entitlement App Attest `production` sólo se aplica a Sandbox. Registrar la app y App Attest en Firebase y habilitar la capability para su App ID/provisioning en Apple Developer antes de Archive de dispositivo. Release no usa el proveedor Debug, tampoco en simulador: la atestación real necesita un dispositivo compatible. No se habilita enforcement remoto como parte de este PR. Obtener un token App Check no protege por sí solo las llamadas a Supabase; Auth/RLS y sus contratos siguen siendo la protección del backend. No se agrega Firebase como fuente de datos de la wallet.

La recolección Crashlytics parte deshabilitada en Info.plist y se habilita después de inicializar Sandbox. Sandbox genera dSYM y desactiva el debug dylib para que los inputs existentes cubran el binario. El script de símbolos sólo corre en Archive Sandbox, con la ruta SwiftPM documentada. Un build de simulador no demuestra la subida de símbolos.

## Dependencias

Se conservan cuatro productos Firebase directos: Core (inicialización), Analytics (servicio existente, W10 instrumentará acciones), Crashlytics (errores y crashes) y App Check (atestación). Se eliminan veinte productos directos sin uso: AI/AILogic, AnalyticsCore/IdentitySupport, AppDistribution, Auth/AuthCombine, Database, Firestore/FirestoreCombine, Functions/FunctionsCombine, InAppMessaging, Installations, MLModelDownloader, Messaging, Performance, RemoteConfig, Storage/StorageCombine. Dependencias internas necesarias las resuelve Firebase; no se remueven manualmente. Supabase y GoogleSignIn quedan fuera de esta limpieza. Package.resolved y versiones permanecen intactos.

## Recorrido local y evidencia real

1. Abrir este checkout en Xcode; seleccionar Monederito-Mock y Cmd-U sin configuración local. La app no inicializa Firebase.
2. Seleccionar Monederito-Sandbox. Confirmar que el plist corresponde al proyecto y bundle correcto.
3. En Edit Scheme → Run → Arguments agregar temporalmente `--monederito-verify-firebase` y `-FIRDebugEnabled`. Correr SandboxDebug. Registrar el token Debug que emite el SDK en Firebase → App Check → app iOS → Manage debug tokens. El token es privado: no pegarlo en PR, logs compartidos ni screenshots. Volver a correr. Nuestro diagnóstico debe mostrar `W03: App Check token exchange succeeded.`; no imprime tokens ni detalles de errores del SDK.
4. El mismo argumento encola un error no fatal fijo `Monederito.Sandbox.W03`, sin usuario ni información de una operación. Quitar el argumento, relanzar y verificar recepción en Crashlytics. Registrar versión/build y fecha, con captura de la consola sin datos privados. “Queued” por sí solo no demuestra recepción.
5. Para crash fatal: agregar temporalmente `--monederito-test-crash`, ejecutar una vez sin debugger conectado, quitar el argumento y relanzar sin él. Verificar el crash `W03 sandbox Crashlytics verification` en consola. Este código sólo existe en DEBUG y sólo se llama en Sandbox.
6. Para evidencia de símbolos y atestación Release: Archive SandboxRelease en dispositivo con provisioning correcto; verificar stack simbolicado y token App Attest. El probe Debug no está disponible en Release.
7. Quitar todos los argumentos de diagnóstico. Confirmar que Mock sigue offline y Sandbox vuelve a su recorrido normal.

Referencias oficiales: [Debug provider](https://firebase.google.com/docs/app-check/ios/debug-provider), [App Attest](https://firebase.google.com/docs/app-check/ios/app-attest-provider), [test Crashlytics](https://firebase.google.com/docs/crashlytics/ios/test-implementation), [símbolos](https://firebase.google.com/docs/crashlytics/ios/get-deobfuscated-reports).

## Estado de verificación

- Parse Swift y plutil de proyecto/Info/entitlements: correctos.
- diff --check y Package.resolved sin cambios: correctos.
- Tests nuevos rechazan plist incompleto, de otro bundle/client y de plataforma Android; aceptan plist Firebase sin OAuth client cuando GoogleSignIn usa el xcconfig independiente.
- CI local intentado con Scripts/ci-ios.sh; el entorno del agente no conecta a CoreSimulator. CI GitHub pendiente hasta ver resultado del PR.
- Validador compilado y probado contra el plist/xcconfig reales del checkout: correcto, sin imprimir credenciales.
- Consola inspeccionada: proyecto coincidente, Crashlytics detecta la app y espera un crash; App Check indica Sin registrar. El usuario pidió dejar el registro remoto pendiente; no se guardaron cambios ni se habilitó enforcement.
- Recepción en Crashlytics, registro de App Attest/Debug token y atestación de dispositivo: pendientes de recorrido y evidencia en consola. DeviceCheck como fallback también necesita su registro y clave Apple en Firebase. No dar W03 por cerrado únicamente por compilar.
