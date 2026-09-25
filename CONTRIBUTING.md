# Desarrollo y versiones

## Gitflow liviano para un desarrollador

- `master`: línea de releases verificadas. Su snapshot inicial es histórico y todavía no certifica una release.
- `develop`: integración del siguiente incremento.
- `feature/<objetivo>`, `fix/<problema>`, `chore/<tarea>`: nacen de develop, PR de vuelta a develop y se eliminan tras integrar.
- `release/0.x.0`: nace de develop al congelar alcance. Solo estabilización, versión y notas; PR a master y sincronización posterior hacia develop.
- `hotfix/<problema>`: nace de master después de una release; vuelve a master y develop.

Para features usar squash merge. Para release y sincronización entre ramas permanentes usar merge commit, preservando la relación del historial. No reescribir ramas permanentes ni mover tags publicados.

Ejemplo del trabajo diario:

```sh
git fetch origin
git switch develop
git pull --ff-only origin develop
git switch -c fix/auth-session-restoration
# editar, verificar, commit y push de esta rama; abrir PR contra develop
```

Las integraciones existentes no se separan retroactivamente del historial. Abrir ramas temporales cuando se comience su ticket:

1. `chore/reproducible-ios-build`: configuración y CI iOS.
2. `fix/supabase-auth-session`: sesión, rol y contratos de datos.
3. `chore/firebase-environments`: arranque mock autónomo, configuración y Crashlytics.
4. `feat/wallet-navigation`: navegación individual y retiro del control familiar.
5. `feat/wallet-ledger`: dinero, saldo y operaciones atómicas sandbox.
6. `feat/wallet-transfers`: destinatario, confirmación, recibo e historial.
7. `feat/analytics-wallet-events`: instrumentación del flujo terminado y privacidad.

No mantener ramas Supabase/Firebase/Analytics permanentes: todos los cambios verificados deben converger en develop.

## Migración desde main

Se crearon master y develop desde `c1b2c60490c5c8843290af58744756a84c150c66`. Este PR apunta a develop. Main se conserva y sigue siendo default durante la transición.

Pendiente de configuración en GitHub: cambiar default a develop para los PR cotidianos; proteger master y develop mediante rulesets; exigir PR y el check `repository-checks`; prohibir force push y eliminación. Agregar el check de build y tests cuando exista y esté verde. No exigir aprobación de un tercero mientras haya un único mantenedor (el autor no puede aprobar su propio PR). Autoevaluar el diff y dejar evidencia de validación en el cuerpo del PR.

Una vez verificado que todas las referencias, clones y automatizaciones migraron, retirar main en una tarea explícita. No conservar tres líneas activas.

## Versionado

Se adopta `MAJOR.MINOR.PATCH` como convención de releases de la app; el contrato incluye comportamiento y persistencia, no solo una API pública.

- Objetivo inicial: **0.1.0**, primera baseline ejecutable y verificable. Hay más trabajo que un esqueleto 0.0.1, pero eso no acredita 1.0.0.
- Mientras se prepara: etiqueta eventual `v0.1.0-alpha.1` solo sobre un commit compilado y documentado.
- `0.2.0`: identidad y navegación individual completas.
- `0.3.0`: saldo y transferencia sandbox persistida de punta a punta.
- `0.4.0`: resto de operaciones sandbox y trazabilidad.
- `1.0.0`: contrato sandbox estable, todos los P0 cerrados, pruebas y recorrido completo en dispositivo/TestFlight. No representa una billetera que mueva dinero real.
- Parches `0.x.1`: correcciones compatibles dentro de ese incremento.

`MARKETING_VERSION = 0.1.0` expresa el objetivo, no una publicación. `CURRENT_PROJECT_VERSION` es un número de build creciente para cada distribución. El sufijo alpha/beta pertenece al tag Git, no a MARKETING_VERSION.

Crear un tag anotado `vX.Y.Z` sobre el commit exacto de master validado y publicar notas con alcance, limitaciones, build y evidencia. No crear tags automáticos por cada merge ni etiquetar este baseline como estable antes de compilarlo.

## Definition of Done

Un PR explica problema y resultado; contiene un solo objetivo; declara cambios de contrato y migración; verifica escenarios de éxito/error/reintento relevantes; incluye pruebas del dominio cuando corresponda. Para UI, evidencia de navegación, accesibilidad y estados vacío/carga/error. No dar éxito antes de persistir una operación.

El workflow inicial comprueba higiene y formatos del repositorio. **No compila ni prueba la app**. La integración CI iOS es un P0 independiente que necesita scheme compartido, configuración mock autónoma y un runner con SDK compatible.

Referencias: https://semver.org/ y https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches
