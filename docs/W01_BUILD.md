# W01 — Compilación reproducible y revisión local

## Schemes y configuraciones

| Scheme | Run/Test | Archive/Profile | Backend |
|---|---|---|---|
| Monederito-Mock | Debug | Release | Repositorios mock y analytics mock; no Firebase/Google/Supabase al arrancar |
| Monederito-Sandbox | SandboxDebug | SandboxRelease | Integraciones configuradas explícitamente |

Debug/Release indican optimización, no el backend. No existe selección automática de producción. El modo Mock no necesita cuenta de Apple Developer paga, credenciales de backend ni GoogleService-Info.plist para simulador. La primera resolución de paquetes sí necesita Internet.

## Probar W01 localmente

```sh
git fetch origin
git switch --track origin/chore/reproducible-ios-build
open Monederito-iOS.xcodeproj
```

Seleccionar **Monederito-Mock**, un simulador iOS 26.2 o posterior y ejecutar. Para el recorrido de UI: completar onboarding, elegir cuenta y usar `elena@example.com` o `lucas@example.com` con contraseña no vacía. Estos son accesos mock; los flujos de tutela existentes se modificarán en W04.

Con Cmd+U se ejecuta Monederito-iOSTests. El test hosted verifica que la app mock arranca sin inicializar Firebase; además se prueban la selección de repositorios, validación de Sandbox, rechazo de entornos desconocidos y login mock.

Para ejecutar la misma validación de GitHub en un Mac con Xcode y simulador:

```sh
bash Scripts/ci-ios.sh
```

La validación respeta Package.resolved, ejecuta tests en Debug mock y compila Release mock, SandboxDebug y SandboxRelease para simulador sin credenciales. Los builds de Sandbox verifican compilación, **no acceso a los servicios**. Los resultados quedan en `.ci/MockTests.xcresult`.

## Configurar Sandbox cuando se necesite

1. Copiar `Config/Sandbox.local.example.xcconfig` como `Config/Sandbox.local.xcconfig` y completar los valores del proyecto de pruebas. En xcconfig, escribir URLs como `https:/$()/...` para evitar el comentario `//`.
2. Agregar el `GoogleService-Info.plist` de ese entorno dentro de `Monederito-iOS/`. El grupo sincronizado de Xcode lo incluye como recurso. El archivo está ignorado por Git.
3. Seleccionar Monederito-Sandbox. La app muestra configuración pendiente si faltan valores, en lugar de crear repositorios de red con configuración incompleta.

Solo usar claves publishable/anon de cliente, nunca service-role. Firebase/Google/Supabase conservan las mismas versiones del lockfile. Las pruebas reales de auth, App Check y Crashlytics corresponden a W02/W03. La subida de símbolos solo se ejecuta en archive Sandbox para dispositivo; no en builds Mock ni en simulador.

## Automatización por ticket

Desde el chat: «Ejecutá W02 desde develop y prepará el PR». Cada ticket produce una rama, un PR y evidencia de checks. GitHub ejecuta automáticamente Repository checks e iOS; cada push corrige/revalida el mismo PR. Descargar la rama, recorrer la app y comunicar resultado. Si hay observaciones, corregir el mismo PR; después de aprobación explícita, integrar a develop y recién entonces comenzar el siguiente ticket dependiente.

No se ejecuta un merge automático. Para exigir los checks, configurar el ruleset de develop con `repository-checks` e `ios-build-and-test` después de la primera ejecución exitosa. Un único mantenedor usa su recorrido y la evidencia del PR como revisión manual.

## Validación de esta entrega

La validación local de estructura del proyecto, schemes, plist, shell y diff se realiza antes de publicar. El entorno de ejecución del agente tiene restricciones de CoreSimulator y evaluación de manifiestos Swift; por eso se añade CI en un runner macOS con Xcode 26.2 explícito. El resultado de CI y su enlace se registran en el PR; no confundir compilación de Sandbox con integración verificada.

Referencia de toolchain: https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md
