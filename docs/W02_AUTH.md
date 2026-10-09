# W02 — autenticación (primer PR)

Estado: implementación parcial, pendiente de build/tests iOS y validación Sandbox. W02 no está cerrado.

## Contratos corregidos

- `signUp` devuelve `SignUpResult`: usuario autenticado únicamente cuando Supabase devuelve sesión; si requiere confirmar correo, muestra instrucciones y limpia las contraseñas sin consultar/crear perfiles.
- Login por correo y Google, registro y consulta del usuario conservan el rol del perfil existente. La selección de rol sólo se usa al crear un perfil nuevo.
- Si el perfil aparece entre lectura e inserción, el upsert ignora duplicados y vuelve a leer la fila persistida, sin sobrescribirla.
- AuthViewModel ejecuta sus cambios en MainActor y evita registros simultáneos.

## Verificación en esta computadora (09/10/2026)

- `git diff --check`: pasó.
- Parse de los siete archivos Swift modificados/agregados con `swiftc -frontend -parse`: pasó. No equivale a compilar o ejecutar tests.
- Package.resolved permanece intacto.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer Scripts/ci-ios.sh`: dos intentos bloqueados por el entorno del agente. Primero no pudo escribir diagnósticos en caché de SwiftPM. Tras habilitar esas carpetas, falló con `sandbox-exec: sandbox_apply: Operation not permitted`. CoreSimulator también rechazó la conexión. No hay resultados de build ni tests aprobados.
- Se agregan tres tests de presentación y tres del adaptador Supabase con URLProtocol local: registro sin sesión, con sesión, error y conservación de rol. No se usan credenciales ni servicios externos. Ejecución pendiente.

## Recorrido local pendiente

1. Abrir el proyecto en Xcode, elegir Monederito-Mock y ejecutar Product → Test (Cmd-U). Revisar AuthRegistrationTests, SupabaseRegistrationTests y EnvironmentTests.
2. Ejecutar `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer Scripts/ci-ios.sh` desde una terminal local para los tests y builds Release/Sandbox.
3. En Mock, registrar una cuenta: debe entrar con el usuario retornado por el repositorio.
4. Con configuración Sandbox, probar registro con Confirm email activado: permanece en registro, muestra el correo y no entra a la app. Confirmar el correo y volver al login manualmente.
5. Con Confirm email desactivado, una cuenta nueva entra únicamente después de recuperar el perfil.
6. Con una cuenta beneficiary existente, iniciar por email y por Google aunque la UI elija benefactor: el perfil debe conservar beneficiary. Verificar la fila antes/después en Sandbox.

## Siguientes partes de W02

Restauración real de Supabase al relanzar, expiración/refresh y errores, recuperación completa (solicitud, callback y contraseña nueva), logout y eliminación de login ficticio por biometría. El callback de confirmación automática tampoco se implementa en este primer PR. Google real y el caso concurrente de creación requieren validación Sandbox. No iniciar W03 hasta integrar W02 completo.
