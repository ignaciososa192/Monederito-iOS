# W02 — autenticación y sesión

## Cambios

El registro distingue usuario autenticado de confirmación de correo pendiente. Login por correo/Google y restauración conservan el rol guardado; la creación del perfil queda a cargo del trigger existente en auth.users. La app sólo lee perfiles al autenticar y no intenta crearlos por errores de lectura.

La app restaura Supabase al arrancar y volver a foreground. El SDK renueva tokens expirados; un refresh token inexistente/reutilizado elimina la sesión. Los errores de red/perfil se muestran, sin convertirlos silenciosamente en ausencia de sesión. El evento signedOut limpia usuario y rutas; una restauración tardía no puede deshacer logout.

Recuperación tiene solicitud de correo, callback PKCE, formulario de contraseña nueva y logout al finalizar/cancelar. Registro confirma por `monederito://auth/callback`; recuperación usa `monederito://auth/recovery` para diferenciar el flujo incluso con el SDK 2.43.1, que emite signedIn al intercambiar códigos PKCE. Se valida el enlace mediante el SDK antes de habilitar el formulario. Abrir el enlace en el mismo dispositivo que lo solicitó.

Los botones de logout de dashboard/settings eliminan tokens del SDK. Biometría sólo recupera una sesión existente, nunca crea una identidad Mock. Accesos DEBUG ficticios se muestran únicamente en Mock.

## Configuración Sandbox

`Config/Sandbox.local.xcconfig` y `GoogleService-Info.plist` permanecen locales e ignorados. El proyecto Supabase monederito fue restaurado con autorización del propietario y quedó ACTIVE_HEALTHY. Las tablas profiles/transactions/beneficiary_accounts/risk_alerts existen; el trigger on_auth_user_created crea el perfil. No se aplicaron cambios SQL ni migraciones.

En Supabase Authentication → URL Configuration, permitir exactamente:

- `monederito://auth/callback`
- `monederito://auth/recovery`

Esta allow-list remota debe verificarse antes de probar correos reales. El plist registra el scheme monederito y el callback Google existente. No usar service-role en la app.

## Validación

Los tests de la primera entrega (registro y roles) pasaron en el run 38006703485, y Release compiló; el job fue cancelado durante los builds adicionales. La corrección expires_at de las fixtures quedó validada.

Para esta ampliación: diff --check y parse Swift pasan. Scripts/ci-ios.sh fue intentado localmente y bloqueado por restricciones de caché SwiftPM/CoreSimulator del agente. CI del último commit y el recorrido Sandbox quedan pendientes hasta registrar su resultado.

Tests nuevos: restauración, logout y limpieza de rutas, error visible, restauración tardía tras logout, recuperación sin acceso a billetera, persistencia SDK con nuevo cliente, token expirado/refresh, logout persistido, solicitud/callback/actualización de contraseña con transporte HTTP local. Package.resolved permanece intacto.

## Recorrido local antes de cerrar W02

1. Monederito-Mock → Cmd-U. Verificar EnvironmentTests/AuthRegistrationTests/AuthSessionTests/SupabaseRegistrationTests.
2. Monederito-Sandbox → Cmd-R. Login por correo con usuario existente; matar/relanzar y confirmar que vuelve a la misma cuenta/rol.
3. Logout desde dashboard y settings; relanzar y verificar que permanece fuera. Simular error de red al restaurar: mostrar error y permitir reintento al volver a foreground.
4. Registrar con confirmación activada: instrucciones de correo, sin acceso a billetera; abrir el enlace en el mismo dispositivo. Sin confirmación: entrar con perfil recuperado.
5. Google con perfil existente de otro rol: no cambiar el rol; cancelar Google no autentica.
6. Solicitar recuperación; abrir enlace, guardar contraseña nueva y volver al login. Contraseña nueva funciona y vieja falla. Enlace inválido/expirado informa error; cancelar recuperación elimina sesión.
7. Expiración: validar refresh y sesión revocada. Biometría sin sesión no autentica. Accesos DEBUG no aparecen en Sandbox.

W02 se cierra tras CI verde y este recorrido real. Confirmación/email/Google requieren validación manual con la configuración remota. W03/W08 siguen fuera de alcance.
