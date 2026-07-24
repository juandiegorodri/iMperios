# CLAUDE.md — Guía del proyecto iMperios

Este archivo da contexto a Claude (y a cualquier desarrollador) sobre el
proyecto. **Léelo al empezar cualquier sesión** y respeta las normas de abajo.

---

## 1. Qué es el proyecto

**iMperios**: una versión *ultra básica* de un RTS clásico para jugarse con
**pantalla táctil desde el navegador del iPad** (Safari). Todo el juego vive en
un único archivo **`index.html`** (Canvas 2D + JavaScript puro, sin
dependencias, sin servidor, sin proceso de compilación).

- Diseño completo: ver **`DESIGN.md`**.
- Mapa de archivos y estructura del código: ver **`filemap.md`**.
- Bitácora de avance: ver **`progress.md`**.
- Línea gráfica y lista de sprites: ver **`assets/ART.md`**.
- App iOS y arquitectura multijugador: ver **`iOS.md`**.
- **Plan maestro por fases** (qué construir a continuación y cómo): ver
  **`PLAN.md`** — al ejecutar una fase, seguir sus «Reglas del ejecutor».

## 2. Stack y restricciones

- **Lógica en un solo archivo**: `index.html` (HTML + CSS + JS embebido). No
  añadir build tools, frameworks ni dependencias externas salvo que se acuerde.
- **Gráficos (desde PR #6)**: sprites PNG en `assets/sprites/` cargados en
  tiempo de ejecución. Si un sprite falta, el motor usa un **emoji de respaldo**,
  así el juego sigue funcionando aunque falten los assets. Generación/estilo de
  los sprites: ver `assets/ART.md`.
- **Táctil primero**: objetivos de toque ≥ 44 px; 1 dedo = órdenes/caja de
  selección, 2 dedos = paneo + zoom. Debe funcionar también con ratón/rueda en
  escritorio (para pruebas).
- **Render**: vista cenital; sprites pixel-art (`assets/sprites/`) con respaldo
  de emoji. Escalado por `devicePixelRatio` para nitidez Retina.
- **Idioma**: la UI y los comentarios del código están en **español**.

## 3. Flujo de trabajo (git / despliegue)

- Rama de desarrollo: **`claude/mini-aoe-browser-game-k5vf3r`**. No empujar a
  otra rama sin permiso explícito.
- Cada tanda de cambios: commit claro → push → **PR en borrador** hacia `main`.
- `main` es la rama que sirve **GitHub Pages**:
  `https://juandiegorodri.github.io/iMperios/`. Al fusionar a `main`, la
  web se actualiza sola. El repositorio se renombró de `Ageofempires` a
  `iMperios` el 2026-07-18 (GitHub redirige automáticamente el nombre
  antiguo, tanto en la API como en clones/remotos git existentes).
- Tras fusionar una PR con *squash*, **sincroniza la rama con `main`**
  (`git fetch origin main` + `git reset --hard origin/main`) antes de la
  siguiente tanda, para que el próximo PR tenga un diff limpio.

## 4. Verificación

Antes de dar por terminada una funcionalidad, **probar en Chromium headless**
(Playwright ya está disponible en el entorno):
- Cargar `index.html`, iniciar partida y comprobar que **no hay errores de
  consola** (`pageerror` / `console.error`).
- Ejercitar la nueva lógica vía `page.evaluate(...)` accediendo a las funciones
  y al estado global (`entities`, `player`, etc.).
- Cuando aplique, capturar una **captura de pantalla** para revisar el aspecto.

Ejecutar con: `node test.cjs` usando
`require('/opt/node22/lib/node_modules/playwright')` y
`executablePath: '/opt/pw-browsers/chromium'`.

### 4.1 Proceso estándar para una tanda con varias correcciones/funcionalidades

> Aplica **siempre** que una tanda de trabajo incluya más de un cambio (lo
> habitual: el usuario pide una lista de correcciones/funcionalidades en un
> solo mensaje). No hace falta que el usuario lo pida cada vez — es el
> proceso por defecto del proyecto.

1. **Implementar TODO en una sola pasada**: escribir el código de cada
   corrección/funcionalidad de la tanda antes de verificar nada, y hacer un
   chequeo de sintaxis del `index.html` completo (`node --check` sobre el
   contenido del `<script>`) apenas termine de escribirse el código.
2. **Despachar un subagente (herramienta `Agent`) para probar la tanda**: no
   basta con las pruebas Playwright propias hechas al vuelo mientras se
   escribe el código — al terminar de implementar TODO, lanzar un agente
   (`subagent_type` general-purpose está bien) con un prompt que liste,
   funcionalidad por funcionalidad, qué se implementó y qué debe verificar de
   cada una (con capturas/`page.evaluate` sobre el estado real del juego,
   igual que en la sección 4 de arriba), y que reporte cuáles pasan y cuáles
   fallan con evidencia concreta (no solo "funciona"/"no funciona").
3. **Corregir lo que el agente reporte como fallido** y, si el ajuste es no
   trivial, repetir el paso 2 (otro agente, o el mismo si sigue disponible)
   sobre lo corregido antes de continuar.
4. **Solo cuando todo esté verificado como correcto**: actualizar la
   documentación obligatoria (sección 5 de abajo) y recién ahí commit → push
   → PR en borrador → (si el usuario pidió subir a `main`) marcar el PR listo
   y fusionar → sincronizar la rama con `main` (sección 3). Nunca fusionar a
   `main` con verificaciones pendientes o fallidas.

---

## 5. NORMAS DE DOCUMENTACIÓN (obligatorias)

> **Cada vez que se cree o modifique una funcionalidad, hay que actualizar la
> documentación en el mismo cambio (mismo commit/PR).**

### 5.1 `CLAUDE.md` (este archivo) — listado de funcionalidades
Mantener actualizada la sección **«6. Listado de funcionalidades»** con TODAS
las funcionalidades del juego. Al añadir una nueva, agrégala a la lista con una
línea descriptiva. Al cambiar uno comportamiento existente, edítalo.

### 5.2 `filemap.md` — mapa de archivos
Describe cada archivo del repositorio y, para `index.html`, las secciones
principales del código (definiciones de datos, estado, lógica, render, entrada,
UI). Al añadir una sección/sistema nuevo de código, **actualiza `filemap.md`**.

### 5.3 `progress.md` — bitácora de avance
Registro cronológico. Por cada tanda de trabajo añade una entrada **al final**
con: fecha, número de PR (si aplica), y lista de cambios. No borres el
historial; solo se agrega.

### 5.4 `assets/ART.md` — línea gráfica y sprites
Si se añaden o cambian **sprites**, seguir el estilo de `assets/ART.md` y
actualizar su lista de elementos/estado. Sprites finales en `assets/sprites/`,
hojas fuente en `assets/_raw/`. Mantener el **respaldo de emoji** en el motor.

> Regla rápida: **funcionalidad nueva ⇒ actualizar `CLAUDE.md` (lista) +
> `filemap.md` (si hubo cambios de estructura) + `progress.md` (siempre)**; si
> toca gráficos, también `assets/ART.md`.

---

## 6. Listado de funcionalidades

### Núcleo del juego
- **Motor**: Canvas 2D + JS puro en un solo `index.html`, optimizado para táctil
  de iPad; escalado Retina; bloqueo de gestos del navegador.
- **Cámara**: paneo con dos dedos, zoom por pinch; rueda y flechas en
  escritorio; botón «Centrar» (⌂) sobre la base propia.
- **Selección**: toque simple (unidad/edificio), arrastre de un dedo = caja de
  selección (prioriza militares), doble toque = todas las unidades del mismo
  tipo visibles, toque en vacío = deseleccionar.
- **Órdenes contextuales**: con unidades seleccionadas, tocar terreno = mover,
  recurso = recolectar (aldeanos), enemigo = atacar (militares), cimientos
  propios = construir.
- **Recursos (4)**: comida 🍖, madera 🪵, oro 💰, piedra 🪨. Nodos finitos; la
  recolección se suma directa al marcador (sin viaje de retorno). Al agotarse un
  nodo, el aldeano busca el siguiente del mismo tipo.
- **Unidades**: Aldeano, Milicia, Piquetero, Arquero, Caballo y 3 Héroes
  (Espada/Arco/Jinete, del Castillo). Los aldeanos también pueden atacar.
- **Edificios (12)**: Centro Urbano, Casa, Cuartel, Galería de Tiro, Establo,
  Herrería, Torre, Castillo, Granja, Mina de Oro, Mina de Piedra y Bosquero.
  Prerrequisitos: Galería y Establo requieren Cuartel; el Castillo requiere
  Edad Feudal (Era III).
- **Cuadrilátero de combate (×2)**: por categoría, Arquero → Milicia →
  Piquetero → Caballo → Arquero (cada uno fuerte contra el siguiente). Los
  héroes heredan la categoría de su tipo base.
- **Entrenamiento por cola**: cada edificio productor tiene cola con coste y
  tiempo; punto de reunión (rally) configurable tocando el terreno.
- **Construcción**: el jugador coloca cimientos (silueta que sigue el dedo) y
  los aldeanos los construyen con barra de progreso.
- **Mejoras de Herrería (4)**: Flechas de Punta de Hierro, Forja de Espadas,
  Escudos de Madera, Hachas Afiladas. Requieren Edad de las Herramientas.
- **Avance de Era**: cuatro edades (ver «Funcionalidades añadidas»); cada avance
  cuesta recursos y desbloquea contenido.
- **IA enemiga**: 3 dificultades (Fácil/Normal/Difícil); recolecta, construye,
  avanza de era, entrena ejército variado y lanza oleadas de ataque.
- **Población**: límite dinámico según edificios (ver «Población dinámica»),
  mostrado en la barra superior.
- **Auto-defensa y retaliación**: las unidades militares inactivas atacan
  enemigos cercanos, y CUALQUIER unidad golpeada (incluidos aldeanos) responde
  al atacante; el aldeano vuelve a su recurso al terminar.
- **Victoria/Derrota**: gana quien destruye el Centro Urbano rival.
- **UI/UX**: barra superior de recursos, panel inferior de acciones contextual,
  avisos (hints), pausa (⏸), pantallas de inicio y de fin.

### Funcionalidades añadidas
- **Localizador de aldeanos inactivos** (PR #2): botón 👷 arriba a la derecha con
  contador en vivo; al tocarlo selecciona y centra la cámara en el siguiente
  aldeano sin tarea (rota entre ellos). En el mapa los inactivos muestran 💤.
- **Símbolo de recurso al recolectar** (PR #2): cada aldeano que recolecta
  muestra una insignia con el icono del recurso (🍒/🌳/💰/🪨).
- **Botón Deseleccionar** (PR #2): en el panel de acciones, para unidades y
  edificios; limpia la selección.
- **Torres defensivas** (PR #2): edificio Torre 🗼 construible por aldeanos
  (madera + piedra); dispara automáticamente a enemigos en rango (muestra su
  radio al seleccionarla). La IA construye torres en Normal/Difícil.
- **Producción acelerada por cantidad de edificios** (PR #3): cuantos más
  edificios del mismo tipo productor tenga un bando, más rápido entrena ese tipo
  de unidades. Multiplicador = 1 + 0.5 × (nº de edificios − 1); 1 = ×1, 2 = ×1.5,
  3 = ×2, … Se muestra en el panel del edificio.
- **Nivel de producción por recurso** (PR #3): junto a cada recurso de la barra
  superior se muestra la tasa actual de recolección (p. ej. «+1.4/s»), calculada
  según los aldeanos que están recolectando ese recurso. Se resalta en verde
  cuando hay producción activa.
- **Menú principal con opciones** (PR #4): antes de jugar se configura la
  partida: mapa, recursos iniciales (Bajo/Estándar/Alto), velocidad
  (Lenta/Normal/Rápida), inteligencia de la IA (Fácil/Normal/Difícil) y posición
  del jugador (Izquierda/Derecha/Aleatoria).
- **Mapas con temática** (PR #4): Llanura, Río (río central que bloquea
  construcción), Selva Negra (madera abundante por todo el mapa) y Riscos
  (bloques rocosos que bloquean construcción; abunda piedra y oro).
- **Población dinámica** (PR #4): se empieza con 20 de población. El Centro
  Urbano aporta 20, cada Casa 🏠 +5 y el Castillo 🏰 +50 (tope absoluto 200).
- **Edificios nuevos** (PR #4): Casa 🏠 (sube población) y Castillo 🏰 (sube +50
  población, defensa potente con auto-disparo; requiere Edad Feudal).
- **Cuatro edades** (PR #4): Inicial → Edad de las Herramientas → Edad Feudal →
  Edad Imperial. Cada avance cuesta más recursos y desbloquea contenido
  (mejoras de Herrería en Era II, Castillo en Era III, tecnologías económicas de
  nivel 2 en Era IV).
- **Tecnologías económicas por recurso** (PR #4): en el Centro Urbano se
  investigan tecnologías que aumentan la recolección de cada recurso (Molino,
  Aserradero, Minería de Oro, Cantera y sus versiones avanzadas). Cada tier suma
  un % a la tasa de ese recurso.
- **Velocidad de partida** (PR #4): multiplicador global del ritmo del juego
  (Lenta ×0.7, Normal ×1, Rápida ×1.6).
- **Cola de edificio editable** (PR #4): al seleccionar un edificio se ve su cola
  de unidades como iconos; tocar uno lo cancela y reembolsa su coste.
- **IA mejorada** (PR #4): el enemigo avanza de era, construye casas al acercarse
  al tope de población, levanta castillos (en Difícil/Era III), reparte sus
  aldeanos de forma ponderada y entrena la unidad que puede pagar.
- **Resumen de partida** (PR #5): al terminar se muestra una tabla comparativa
  (Tú vs IA) con era alcanzada, unidades entrenadas, enemigos eliminados,
  unidades perdidas, edificios construidos/perdidos y tecnologías; resalta en
  verde quién gana cada métrica.
- **Edificios de producción de recursos** (PR #5): Granja 🌾 (comida), Mina de
  Oro ⛏️ (oro) y Mina de Piedra 🪨 (piedra) de las que los aldeanos recolectan
  de forma renovable; Bosquero 🌲 que planta árboles cercanos (madera renovable).
- **Héroes del Castillo** (PR #5): unidades especiales más fuertes — Héroe Espada
  🦸, Héroe Arco 🏹 y Héroe Jinete 🐎 — entrenadas en el Castillo; siguen el
  cuadrilátero según su categoría y muestran un aura dorada con ⭐.
- **Aldeanos combaten y se defienden** (PR #5): pueden recibir orden de atacar y
  responden solos cuando los atacan (retaliación), volviendo a su recurso
  después.
- **Río con puente** (PR #5): el río es vertical y separa a los jugadores;
  bloquea construcción y paso, salvo por un puente central por donde cruzan las
  unidades (guiado automático hacia el puente). Los riscos también bloquean paso.
- **Aldeanos inactivos buscan trabajo** (PR #5): un aldeano sin tarea va a
  terminar construcciones pendientes; si no hay, sigue con su recurso o el más
  cercano. El botón «Detener» los deja quietos a propósito.
- **Tres manuales de IA** (PR #5): doctrinas por dificultad. Fácil: economía
  mínima y siempre ataca el Centro Urbano. Normal: granjas/minas y torres,
  ataca el objetivo más cercano y se defiende. Difícil: economía completa,
  castillo y héroes, y objetivos estratégicos (primero neutraliza torres/castillo,
  luego arrasa la economía —aldeanos y producción— y por último el Centro).
- **Gráficos con sprites** (PR #6): sprites pixel-art (vista cenital, estilo
  8-bit) para las 8 unidades, los 12 edificios y los 4 recursos, generados con
  Ideogram según `assets/ART.md` y cargados desde `assets/sprites/`. El motor
  los dibuja con sombra; si falta un sprite, usa el emoji. Incluye una pantalla
  **«Prueba gráfica»** en el menú que lista todos los sprites y marca los que no
  cargan.
- **Sprites de terreno y selección mejorada** (PR #7): texturas de suelo (pasto/
  tierra), agua del río y roca de los riscos (con montañas decorativas); el
  anillo bajo los edificios se sustituyó por sombra + bandera de bando; la
  selección usa corchetes/anillo dorado animado y hay efecto de
  selección/deselección (pings).
- **Reparar edificios** (PR #7): un aldeano puede reparar un edificio propio
  dañado tocándolo; gasta parte de los recursos del coste de construcción.
- **Murallas** (PR #7): herramienta de dos toques (inicio y fin) que coloca una
  línea de tramos de muralla (piedra), con **Torres de Muralla** cada N tramos
  que disparan solas (arqueros protegidos). Las murallas bloquean el paso de las
  unidades rivales.
- **Arquero en cuerpo a cuerpo** (PR #7): a distancia pega completo, pero si el
  enemigo lo alcanza de cerca su daño baja a la mitad (no es especialista del
  combate cercano).
- **Capacidad finita de edificios de producción** (PR #7): Granja, Mina de Oro y
  Mina de Piedra dan **500 unidades** y luego se **agotan**; hay que recargarlas
  reparándolas (cuesta el coste de construcción). El nivel de producción de la
  barra superior cuenta también a quienes recolectan de estos edificios.
- **Terreno claro y murallas H/V** (PR #7): texturas de suelo en tonos claros
  para que las unidades contrasten; sprites de muralla horizontal y vertical
  según la orientación.
- **Multijugador en tiempo real P2P** (PR #8): un jugador crea la partida
  (anfitrión = servidor autoritativo, sin IA) y el otro se une con su IP.
  Relé WebSocket en el puerto 8765 (`server.js` en escritorio,
  `RelayServer.swift` en la app iOS). El cliente renderiza instantáneas (~7/s)
  y envía comandos; los bandos viajan invertidos para reutilizar toda la UI.
  Detalles en `iOS.md`.
- **App iOS para iPad** (PR #8): proyecto Xcode en `ios/` (WKWebView + relé
  nativo + IP local inyectada). Ver `iOS.md`.
- **Sin sombras bajo edificios** (PR #8): se eliminaron porque desentonaban con
  los sprites.
- **Optimización y pulido iOS/Vercel** (PR #9): índice id→entidad O(1) (`find`),
  culling de entidades fuera de pantalla en el render, meta/PWA para iPad
  (manifest, apple-touch-icon, theme-color, sin auto-zoom en inputs, panel de
  acciones con scroll), config de despliegue estático en Vercel (`vercel.json`,
  `.vercelignore`) y aviso claro de que el multijugador `ws://` no funciona desde
  `https://`.
- **PLAN.md: hoja de ruta por fases** (2026-07-06): plan maestro con principios
  de diseño, reglas del ejecutor y 8 fases (F1 vida → F8 rendimiento) para que
  el juego "se sienta un RTS real"; cada fase se ejecuta en su propio PR.
- **FASE 1 — Está vivo: animación, proyectiles y sonido** (PR #10): ver
  `PLAN.md` §4 F1. Cambios:
  - **Animación procedural de unidades** (sin sprites nuevos): bamboleo vertical
    y ligera inclinación al caminar, "lunge" (desplazamiento hacia el objetivo)
    al atacar/recolectar/construir, y volteo horizontal (`e.face`) según la
    dirección de movimiento real. Se calcula en `drawUnit` a partir del
    desplazamiento cuadro a cuadro (funciona igual en host y en el cliente MP,
    donde las entidades se recrean en cada instantánea). Por rendimiento, el
    transform se aplica con `ctx.setTransform` (no `save/restore`, mucho más
    barato con muchas unidades en pantalla).
  - **Proyectiles reales** (`projectiles[]`): arqueros, héroe de arco, torres,
    torres de muralla y castillo disparan una flecha visible que viaja
    (~300px/s) y aplica el daño **al impactar** (`computeDamage`/`applyDamage`,
    ya no al disparar). En multijugador viajan en el snapshot (`shots`) y el
    cliente solo los interpola (no simula daño).
  - **Muertes y daño visuales**: cadáveres (`corpses[]`, fuera de `entities`)
    con fade + caída de 0.4s al morir una unidad; flash blanco (`e.hurtT`) al
    recibir daño; edificios con <50% hp echan humo y <25% también fuego
    (`drawDamageFx`, derivado del hp actual, ya sincronizado por snapshot). El
    cliente MP reconstruye cadáveres y flashes comparando instantáneas
    consecutivas (sin simular).
  - **Sonido sintetizado con WebAudio** (sin archivos de audio): espada,
    flecha, talar, picar, construir, unidad lista, edificio destruido, alerta
    de ataque y victoria/derrota, más un loop ambiental de viento a bajo
    volumen. Botón 🔊/🔇 en `#util` (persistido en `localStorage`); el
    `AudioContext` se crea/reanuda en el primer toque del usuario (requisito de
    Safari/iOS, nada suena antes de eso).
  - **Micro-feedback**: ping verde (`addPing(...,'#7ddd7d')`) en el destino de
    una orden de movimiento, además del ping dorado ya existente de selección.
- **FASE 2 — Niebla de guerra, minimapa y alertas** (PR #11): ver `PLAN.md`
  §4 F2. Cambios:
  - **Niebla de guerra de 3 estados** (oculto/explorado/visible) sobre una
    rejilla de 40px/celda (65×38 celdas, cubre todo `WORLD`): oculto = negro
    opaco, explorado = oscurecido (terreno/edificios visibles, unidades no),
    visible = sin oscurecer. Visión de 180px por unidad y 220px por edificio
    propio construido. Se recalcula cada ~150ms (`recomputeFog`, no cada
    cuadro) sobre un array `Uint8Array` de la rejilla, y se pinta con una sola
    llamada `drawImage` escalando una textura de baja resolución (`fogCanvas`,
    1 celda = 1 píxel) con suavizado bilineal, así los bordes de la visión
    salen redondeados sin coste por celda en cada cuadro. Es **puramente de
    render/cliente**: no toca `entities` ni el protocolo multijugador
    (`serEntity`/`makeSnap` sin cambios) — cada cliente (host o jugador
    remoto) calcula su propia niebla a partir de sus propias entidades
    (`owner==='player'`, ya con los bandos intercambiados en MP). La IA
    enemiga sigue "viendo" el tablero completo como siempre (no se le oculta
    nada a propósito en su lógica); solo cambia lo que el JUGADOR ve dibujado
    y lo que puede tocar (`pickAt` también respeta la niebla).
  - **Minimapa** (esquina inferior-derecha, colapsable con un botón ≥44px):
    terreno cacheado una vez por partida, niebla (reutiliza la misma textura
    del mapa principal), puntos de unidades/edificios por bando (filtrados por
    niebla) y el rectángulo de la cámara. Tocar o arrastrar sobre el minimapa
    mueve la cámara (`centerOn`). Se redibuja a ~4.5Hz (`drawMinimap`), no cada
    cuadro.
  - **Alertas de ataque**: cuando algo del jugador recibe daño (host/partida
    local vía `applyDamage`, o el cliente MP comparando hp entre instantáneas
    en `applySnap`, que no simula daño pero sí lo detecta), con throttle de
    8s por zona de 200px (`triggerAttackAlert`). Si el punto atacado está
    fuera de cámara: pulso rojo que se desvanece en el minimapa y aparece el
    botón temporal "⚔️ ir al ataque" en `#util` (se oculta solo a los 10s o al
    tocarlo, y centra la cámara en la última zona atacada). El SFX de alerta
    (Fase 1) suena aparte, sin este throttle por zona.
- **FASE 3 — Manos de RTS: grupos, ataque-mover y cámara pro** (PR #12): ver
  `PLAN.md` §4 F3. Cambios:
  - **Grupos de control tácticos** (①②③ en `#util`, ≥44px, con contador en
    vivo): con selección activa, mantener pulsado 0.5s guarda el grupo; toque
    corto lo selecciona; doble toque lo selecciona y centra la cámara en su
    centro. Los ids se limpian de unidades muertas al instante. Son
    **locales del cliente** (no viajan por red; en multijugador cada jugador
    guarda los suyos).
  - **Ataque-mover** (botón "⚔️→ Ataque-mover" en el panel con militares
    seleccionados): las unidades avanzan hacia el punto tocado y persiguen y
    atacan automáticamente cualquier enemigo que encuentren en el camino
    (nuevo estado `amove`), retomando la marcha al perder el objetivo. Tiene
    su propio comando de red (`amove`), simétrico a `move`.
  - **Selección mejorada**: botón "🪖 Todo el ejército" en `#util` (selecciona
    todos los militares vivos propios, sin aldeanos ni edificios). En
    selecciones mixtas aparecen chips por tipo en el panel que reducen la
    selección con un toque. Doble toque sobre un edificio propio selecciona
    todos los edificios de ese tipo (antes solo existía para unidades).
  - **Cámara con inercia**: al soltar el paneo de 2 dedos, la cámara sigue
    deslizándose y decae suavemente (~0.9/cuadro) hasta pararse, con un tope
    elástico en los bordes del mapa (sin "temblor" ni rebote) si la inercia la
    saca del mundo. Doble toque en el botón ⌂ centra la cámara en la última
    zona atacada (Fase 2) en vez de la base propia.
  - **Rally encadenable**: fijar el punto de reunión de un edificio sobre un
    recurso (o un edificio de producción propio) hace que los aldeanos
    entrenados a partir de entonces vayan directos a recolectarlo; se ve una
    línea punteada + bandera 🚩 + icono del recurso desde el edificio hasta el
    punto de reunión al seleccionarlo.
- **FASE 4 — Pathfinding y formaciones** (PR #13): ver `PLAN.md` §4 F4.
  Cambios:
  - **A\* en rejilla gruesa** (reaprovecha el tamaño de celda de la niebla:
    40px, 65×38): grid de obstáculos estáticos (río sin puente, riscos,
    murallas/puertas) cacheado **por bando** (`pathGrids.player/enemy`) y
    recalculado solo al construir/destruir una muralla o alternar una puerta
    (`invalidatePathGrid`), nunca por cuadro. Antes de llamar al A* se
    comprueba línea de visión directa (`losClear`); si ya está despejada (caso
    común en terreno abierto) no hace falta calcular nada. El camino se
    suaviza saltando waypoints intermedios visibles (`smoothPath`).
    `stepToward` sigue los waypoints (`e.path`/`e.pathIdx`) y, al agotarlos,
    sigue yendo directo al destino real como siempre. Si una unidad lleva
    >0.6s sin avanzar (`e.stuckT`), se recalcula su camino desde donde está.
    Corre **solo en el host/partida local** (`applyGroupMove`, llamado desde
    `handleTap`, `hostHandleCmd` y `amoveOrder`); el cliente MP nunca ejecuta
    `update()` y por tanto tampoco A*, solo sigue las posiciones del snapshot.
  - **Cache de camino compartido por orden de grupo**: una orden de mover
    varias unidades calcula **un solo** A* desde el centroide del grupo
    (`computeGroupPath`) y todas comparten el mismo array de waypoints (cada
    una con su propio `pathIdx`); el destino final de cada unidad es su slot
    de formación individual.
  - **Formaciones**: al mover ≥2 unidades, se reparten en una rejilla
    compacta alrededor del punto de destino (filas de 6, separación 26px,
    `formationSlots`), asignando a cada unidad el slot libre más cercano
    (greedy); las filas más próximas al destino se reservan para cuerpo a
    cuerpo/aldeanos y las de atrás para arqueros, así el ejército llega en
    varias filas con los arqueros protegidos detrás en vez de en fila india.
  - **Puertas de muralla** (edificio `gate` 🚪, sprite `obj_gate`): al trazar
    una muralla de ≥3 tramos con la herramienta de dos toques, el tramo
    **central** es una Puerta en vez de muro/torre. Igual que una muralla
    normal, deja pasar SIEMPRE a las unidades propias y bloquea SIEMPRE a las
    rivales; a diferencia de una muralla normal, tiene un botón en su panel
    ("🔒 Cerrar puerta" / "🔓 Abrir puerta", ≥44px) para cerrarla
    manualmente, y entonces bloquea a TODOS, incluido el dueño (única forma
    de sellar un paso también para las propias unidades en este juego, ya
    que las murallas normales nunca bloquearon a su dueño, de antes de esta
    fase). Un candado 🔒/🔓 se dibuja siempre sobre la puerta para ver su
    estado de un vistazo. HP menor que la Torre de Muralla. El estado
    (`closed`) viaja en el snapshot y tiene su propio comando de red
    (`gate`).
  - **Esquinas de murallas sin atascos**: la separación entre unidades
    (`separate`) ya no puede empujar a nadie dentro de una muralla/puerta que
    le bloquee (antes solo se protegía contra el río/riscos); esto evitaba
    que el apiñamiento en las esquinas "colara" unidades a través del muro.
- **FASE 5 — Profundidad RTS: líneas de unidad, asedio, guarnición y mercado**
  (PR #14): ver `PLAN.md` §4 F5. Cambios:
  - **Líneas de mejora por Era** (`UNIT_LINES`, investigables en el edificio de
    entrenamiento — Cuartel/Galería/Establo): Milicia → Espadachín (Era II) →
    Campeón (Era IV); Piquetero → Alabardero (Era III); Arquero → Arquero de
    Tiro Largo (Era III); Caballo → Caballero (Era III) → Paladín (Era IV).
    Cada tier sube ~+35% hp/atq (compuesto) de TODAS las unidades vivas y
    futuras de esa categoría del bando (`lineTierCount`/`lineTierMult`,
    `buyLineTier` aplica el hp a las unidades vivas al instante; el atq se
    deriva dinámicamente en `unitAtk`); los héroes no la reciben. Insignia
    visual: chevrons ▲/▲▲ dibujados sobre la unidad en `drawUnit` (sin sprites
    nuevos). El tier investigado se guarda como flag en `side.upg` (mismo
    mecanismo que `UPG`/`ECON`), así que viaja gratis por `serSide` en
    multijugador; el hp/maxHp de las unidades ya mejoradas viaja por la
    serialización normal de entidades.
  - **Asedio — Catapulta** 🎯 (unidad `siege`, entrenada en el nuevo edificio
    **Taller de Asedio** 🏭 `BLD.siegeworkshop`, requiere Cuartel + Edad
    Feudal): muy lenta (velocidad 22), hp bajo, daño de área ×4 contra
    edificios/murallas (`SIEGE_BLD_MULT` en `computeDamage`) y solo mitad de
    daño contra unidades — pierde en cuerpo a cuerpo y 1 contra 2 caballos.
    Proyectil parabólico (`fireProjectile(...,'siege')`, arco visual en
    `drawProjectiles`, ~170px/s) que además hace daño de área reducido a
    otros edificios/murallas cercanos al impactar (`updateProjectiles`). La IA
    Difícil (`DOCTRINE.hard.siege`) construye un Taller y hasta 2 catapultas
    cuando el jugador tiene murallas en pie.
  - **Guarnición**: tocar una Torre/Torre de Muralla/Castillo propio (máx.
    4/4/8) con arqueros seleccionados los mete dentro (`garrisonUnits`): +1
    flecha por arquero guarnecido en cada volea del edificio, y quedan
    protegidos (no se pueden atacar ni seleccionar mientras estén dentro,
    `e.garrisonedIn`). El Centro Urbano (máx. 10) acepta aldeanos como
    refugio (no disparan). Botón "🚪 Expulsar" en el panel del edificio los
    devuelve fuera; si el edificio es destruido, las unidades salen ilesas.
    El estado viaja en MP: el conteo de guarnecidos por edificio (`o.gr` en
    `serEntity`) y el flag de unidad guarnecida (`o.gi`), así el cliente ve el
    número correcto y no dibuja/puede tocar esas unidades sin simular nada.
  - **Mercado** 🏪 (nuevo edificio `BLD.market`, Era de las Herramientas):
    vende 100 de comida/madera/piedra por 70 de oro, o compra 100 de esos
    recursos por 130 de oro (`marketTrade`, tasas fijas). Botones en el panel
    del Mercado; respeta los recursos disponibles.
  - **Pasada de balance**: arena headless 20v20 (`arena.cjs` en el scratchpad
    de la sesión) reutilizando el motor real (`update()`) por cada matchup del
    cuadrilátero. Se detectó que, en combate masivo forzado (sin kiting
    manual), Caballo vencía a su propio contra (Piquetero) y Arquero perdía
    contra su presa (Milicia) por pura ventaja de stats — se ajustaron
    `UNIT.pike`, `UNIT.archer` y `UNIT.cavalry` (hp/atq) para que los 4
    contras del cuadrilátero dominen claramente (~92-100%) y los 2 matchups
    neutrales (Arquero-Piquetero, Milicia-Caballo) queden por debajo del 55%
    de dominancia. Detalle y tabla resultante en `PLAN.md` §4 F5 y §6.
- **FASE 6 — Partidas con memoria: guardar, ajustes y tutorial** (PR #15): ver
  `PLAN.md` §4 F6. Cambios:
  - **Guardar/cargar** (un solo jugador): partida completa serializada a
    `localStorage` en **3 ranuras** (`imperios_save_1/2/3`) + **autoguardado**
    (`imperios_autosave`) cada 2 minutos (`setInterval`, fuera del bucle de
    render) y al ocultar la pestaña (`visibilitychange`). Reutiliza
    `serEntity`/`serSide` del bloque multijugador pero **sin el flip de
    bandos** (`serEntity(e, false)`: el guardado local es de un único
    jugador, no hay a quién voltearle el bando — a diferencia del snapshot de
    red). Incluye terreno/puente, `gameConfig`, edad/recursos/tecnologías,
    niebla YA EXPLORADA (`fogExplored` empaquetada como cadena de dígitos),
    grupos de control y la línea de tiempo (ver más abajo). La guarnición
    (torres/castillo/Centro Urbano) se guarda aparte con los ids reales
    exactos (`save.garrisons`), porque el formato de `serEntity` pensado para
    el snapshot MP solo lleva el CONTEO, no sirve para restaurar de verdad
    quién estaba dentro de qué edificio. En el menú aparece "▶ Continuar
    (autoguardado)" si hay uno disponible, y una lista de las 3 ranuras con
    su fecha/mapa/era. **Deshabilitado por completo en multijugador**
    (`if(inMP()) return` en cada función de guardar/cargar/autoguardar); el
    botón 💾 en `#util` no abre el panel en MP. Medido: partida de ~194
    entidades → autoguardado en <1ms y ~20KB (muy por debajo del límite
    típico de ~5MB de `localStorage`).
  - **Ajustes** ⚙️ (botón en el menú y en `#util`, panel `#settingsScreen`,
    persisten en `localStorage` como `imperios_settings`): volumen de SFX y de
    ambiente por separado (sliders 0-100 aplicados en `playTone`/`playNoise`/
    `startAmbient`, independientes del interruptor 🔊/🔇 de silencio general
    de la Fase 1), velocidad de cámara (Lenta/Normal/Rápida, multiplica el
    paneo táctil de 2 dedos y el paneo por flechas de teclado), mostrar fps
    (contador `#fpsHud`, EMA sobre el delta real sin escalar por velocidad de
    partida) y "🔄 Reiniciar tutorial" (borra el flag de completado/saltado y
    lo rearma si hay una partida en curso).
  - **Tutorial guiado** (primera partida de un jugador, `#tutBox` con anillo
    pulsante `drawTutorialTarget` sobre el objetivo en el mundo cuando
    aplica): máquina de estados de **10 pasos** (seleccionar aldeano →
    recolectar madera → recolectar comida → construir Casa → entrenar
    aldeano → explorar una zona oscura → construir Cuartel → entrenar
    Milicia → avanzar de Era → «Todo el ejército»), cada uno con un
    `check()` que consulta el estado REAL del juego (selección, entidades,
    niebla explorada, era…) por sondeo (~3/s desde `loop`, no por
    temporizador fijo): si el jugador ya cumplió la condición de un paso —p.
    ej. al cargar una partida guardada a medias— la máquina lo salta sola sin
    bloquear. Botón "Saltar tutorial" siempre visible. Recuerda en
    `localStorage` (`imperios_tutorial_done`) que ya se completó o se saltó,
    para no repetirlo. Deshabilitado por completo en multijugador.
  - **Línea de tiempo del resumen**: durante la partida se muestrean cada 30s
    (de juego, afectados por la velocidad de partida) los recursos totales y
    el "valor militar" (coste total invertido en tropas vivas) de cada bando
    en `gameTimeline` (solo host/partida local, no en el cliente MP, que no
    simula); se dibuja en `renderSummary` sobre un `<canvas id="tlChart">`
    del resumen final: 2 líneas sólidas (recursos tú/rival) y 2 discontinuas
    (valor militar tú/rival), o un aviso si la partida fue muy corta.
- **FASE 7 — Multijugador en la web (WebRTC)** (PR #16): ver `PLAN.md` §4 F7.
  El protocolo host-autoritativo (snapshots con flip de bandos, comandos del
  cliente) NO cambió; solo se añadió una capa de transporte y robustez.
  - **Transporte abstraído**: interfaz única `net.sendRaw(str)` (según el
    transporte activo)/`net.onRaw(str)` (común a ambos). Transporte A = el
    WebSocket LAN de siempre (`server.js`/`RelayServer.swift`, puerto 8765),
    sin cambios de comportamiento. Transporte B = **WebRTC DataChannel**
    señalizado con **PeerJS**, cargado bajo demanda desde
    `https://unpkg.com/peerjs@1/dist/peerjs.min.js` (`loadPeerJs()`) solo al
    pulsar un botón "Online" — en frío el juego sigue sin dependencias
    (verificado: 0 peticiones de red no-`file://` al cargar en SP).
  - **Multijugador Online con código de sala**: el anfitrión pulsa "Crear
    sala" (`netOnlineHostStart`) y PeerJS le asigna un id (`imperios7-XXXXXX`);
    se muestra un código de 6 caracteres grande + botón "📋 Copiar código". El
    invitado escribe el código (`netOnlineJoinStart`) y `peer.connect(...)`
    abre un DataChannel fiable/ordenado. Funciona desde `https:` (a diferencia
    del WebSocket LAN, bloqueado como contenido mixto), así que es la vía para
    jugar online desde el despliegue de Vercel sin estar en la misma red.
  - **UI de menú con dos pestañas** («🌐 Online (código)» / «📶 Red local
    (IP)», clase propia `.mp-tab`/`.mp-tab.active` para no depender del
    resaltado genérico `.opt-b.sel` del menú, que marcaría ambas pestañas a
    la vez al no tener `data-val`); la pestaña Red local mantiene tal cual el
    flujo de IP existente.
  - **Interpolación de posiciones en el cliente**: cada instantánea guarda la
    posición previa y la nueva de cada unidad (`net.ipPrev`/`net.ipCur` +
    marcas de tiempo); `interpClientPositions()` (llamada cada fotograma desde
    `loop`) hace un lerp entre ambas según el tiempo transcurrido, quitando
    los "saltitos" a ~7Hz. Puramente de render: no toca la simulación (el
    cliente no simula) ni el guardado.
  - **Deltas de snapshot**: el anfitrión alterna un snapshot **completo** cada
    ~1s (`net.fullT`) con **deltas** el resto del tiempo (solo entidades cuya
    forma serializada cambió desde el último mensaje, más los ids eliminados,
    `makeSnapDelta`); reduce bytes/s sin cambiar qué información viaja.
    Medido en una partida real de 2 jugadores: **~79% menos bytes/s** con
    deltas que forzando siempre completo (`net.deltaEnabled=false`).
  - **Reconexión con el mismo código** (~60s): si el DataChannel online se
    cae en plena partida, el anfitrión mantiene su `Peer` abierto y, al
    recibir una nueva conexión con el mismo código mientras la partida sigue
    en curso, reenvía el estado completo (`netSendInit`, que reinicia también
    la base de deltas) en vez de reiniciar la partida; el cliente reintenta
    conectar solo hasta agotar la ventana de 60s. Aplica también, de forma
    más simple, al `hello` de LAN (si ya hay partida en curso no se reinicia).
  - **Límite conocido y verificado con honestidad**: en el entorno headless de
    desarrollo (sandbox sin egreso de red real para el proceso del
    navegador), PeerJS no logra completar la señalización real (el script
    se inyecta pero no llega a cargar / el broker no responde); el fallo se
    maneja con un mensaje honesto y sin errores de consola. Pendiente de
    verificar con una conexión a internet real (o en el iPad). Ver
    `progress.md` (entrada 2026-07-15/16) para el detalle completo de qué se
    pudo y qué no se pudo probar.
- **FASE 8 — Rendimiento, carga y calidad final** (PR #17): ver `PLAN.md` §4
  F8. Con esto el plan maestro queda **completo** (F1-F8).
  - **Atlas de sprites**: 30 de los 34 PNG de `assets/sprites/` empaquetados
    en `assets/atlas.png`+`assets/atlas.json`, cada uno YA PRE-ESCALADO a su
    tamaño máximo real de uso en juego (×2 para Retina, clampado a no
    sobre-escalar más allá de la resolución nativa). `drawSprite(...)` prueba
    el atlas primero (recorte por coordenadas); si falla o le falta el
    sprite, cae al PNG suelto de siempre (ahora de carga PEREZOSA: solo se
    pide por red si hace falta) y, si tampoco existe, al emoji de respaldo
    (sin cambios). Las 4 texturas tileables (`tile_*`, usadas con
    `createPattern`) se quedan fuera del atlas a propósito. Ver
    `assets/ART.md` para el detalle del empaquetado y la verificación de
    píxeles (diferencia media <3/255 frente al PNG suelto al mismo tamaño).
  - **GC y allocs**: pool de objetos para proyectiles y pings
    (`_projPool`/`_pingPool`, evita crear un objeto nuevo por cada disparo o
    ping) con retirada O(1) por intercambio con el último elemento (en vez
    de `.splice()`); `update()` ya no recalcula `frameWalls` con
    `entities.filter(...)` cada cuadro sino reutilizando el array. Sin
    cambios de comportamiento observable ni en el protocolo MP.
  - **Pantalla de carga**: overlay `#loadScreen` con barra de progreso sobre
    los assets gráficos (atlas o, si falla, los PNG sueltos de respaldo);
    tope de 4s para nunca dejar al jugador atascado. `<link rel=preload>`
    del atlas y meta Open Graph/Twitter Card para compartir el enlace.
  - **Verificación headless**: carga por HTTP real (equivalente a
    producción https) con el atlas activo y 0 errores; comparación de
    píxeles atlas-vs-PNG-suelto en 6 sprites; fallback verificado ocultando
    el atlas; estrés de 285 entidades (`update()+render()` ≈1.4-1.5ms/cuadro,
    muy por debajo de los 16.7ms de 60fps); partida larga simulada (~20 min
    de juego, 72.000 cuadros) con heap y arrays estables; regresión completa
    de un jugador (construir, era, línea de mejora, guarnición, catapulta,
    mercado, niebla, guardar→recargar→cargar) y de multijugador LAN (0
    errores, el cliente ve exactamente 1 base propia + 1 rival). Bajo
    `file://` el atlas se salta el intento de red a propósito (Chromium
    bloquea `fetch()` local por CORS y lo registraría como error de consola
    aunque el fallo se capture bien) y cae limpio al PNG suelto: mismo
    camino de respaldo, cero errores. Matriz QA completa (qué se verificó
    headless / qué queda pendiente de dispositivo real) en `progress.md`
    (entrada 2026-07-16).
- **Corrección post-lanzamiento tras juego real** (2026-07-16): con las 8 fases
  ya fusionadas, se jugó una partida real y se corrigieron 11 problemas
  concretos reportados por el jugador:
  - **Sonido de recolección quitado**: `chop`/`mine` sonaban cada ~420ms de
    forma global mientras CUALQUIER aldeano recolectaba (un throttle por
    nombre de SFX, no por unidad), percibido como un pitido rítmico continuo
    durante toda la partida. Se quitaron esas llamadas del bucle de gather.
  - **Granjas/minas se renuevan solas**: al agotarse la reserva de un
    edificio de producción, el aldeano ANTES abandonaba la fuente para
    buscar otra; ahora se queda a recargarla (pasa a `build` sobre el mismo
    edificio) y, al llegar a 500, **retoma la recolección de esa misma
    fuente** en vez de quedar `idle` (antes se plantaba sin trabajar).
  - **Murallas cortas ya no dejan huecos en los extremos**: se comprobó por
    prueba que una muralla CERRADA (anillo completo) ya era 100%
    infranqueable; el problema real eran los extremos abiertos de murallas
    cortas, fáciles de rodear. `snapWallEndpoint` ajusta cada extremo al
    borde del mapa o a una muralla ya construida si cae muy cerca (~46px),
    cerrando el hueco accidental por imprecisión al trazarla.
  - **Puerta orientada según la muralla**: `obj_gate.png` solo tenía una
    orientación de arte (pensada para muralla horizontal) y se veía
    perpendicular/sin sentido en una muralla vertical. Nueva
    `drawWallOrientedSprite` gira el sprite existente 90° cuando `e.dir==='v'`
    (sin arte nuevo), manteniendo el mismo grosor que un tramo de muralla.
  - **Insignia de nivel/tier mejorada**: los chevrons ▲ de la línea de mejora
    (Fase 5) eran texto plano de 9px sin fondo, casi invisibles en combate.
    Ahora es un óvalo oscuro con borde (mismo lenguaje visual que las demás
    insignias) con 1-2 ⭐ según el tier investigado, claramente legible.
  - **Catapulta con respaldo más visible**: seguía sin sprite propio esta
    sesión (Ideogram no disponible), pero su emoji de respaldo se veía
    pequeño y se perdía en el terreno ("parecía sin gráfica"). Ahora dibuja
    una plataforma de madera detrás y el emoji más grande, como una máquina
    de asedio pesada. El Taller de Asedio ya usaba correctamente su respaldo
    (rect + emoji), verificado por prueba.
  - **Guarnición deshabilitada por defecto**: tocar el Centro Urbano/Castillo/
    Torre con unidades seleccionadas las guarnecía SIN querer (no había
    ninguna confirmación). Nueva opción de menú «🛡️ Guarnición» (Deshabilitada
    por defecto / Habilitada); con la opción desactivada, tocar el edificio
    simplemente lo selecciona, como cualquier otro edificio propio.
  - **Infografía rápida de controles**: overlay `#quickHelpScreen` con los
    controles básicos (selección/deselección, caja, doble toque, cámara de 2
    dedos, órdenes contextuales), mostrada al empezar CADA partida (a
    diferencia del tutorial de 10 pasos de la Fase 6, que solo corre una vez)
    salvo que el jugador marque «no volver a mostrar» (persistido en
    `localStorage`).
  - **El Centro Urbano se defiende solo**: antes no tenía `atk`/`range`/`cd`
    y no podía hacer nada ante un ataque directo. Ahora dispara igual que una
    Torre (auto-fuego a enemigos en rango).
  - **Tiempo de tregua configurable**: nueva opción de menú «🕊️ Tiempo de
    tregua» (sin tregua / 1 / 2 / 5 min). Mientras dura, ninguna unidad/IA
    inicia combate (`nearestEnemy` no devuelve blancos) y, si el jugador
    fuerza un ataque manual igualmente, no hace daño real (`applyDamage` lo
    bloquea entre bandos distintos). Cuenta atrás visible en la barra
    superior.
  - **Velocidad de partida ajustable en vivo**: nuevo control en Ajustes ⚙️
    para cambiar `gameSpeed` durante la partida (un jugador; oculto en MP,
    donde la simulación es del host).
  - Verificado headless: regresión de combate/proyectiles, niebla/MP LAN
    (bandos correctos), cruce del puente, y una partida real simulada de 300s
    con IA Difícil y tregua (sin errores, sin fugas). Detalle completo,
    incluidas las cifras de cada prueba, en `progress.md` (entrada
    2026-07-16, sección de correcciones post-lanzamiento).
- **Segunda ronda de correcciones tras juego real** (2026-07-16): 6 problemas
  más reportados tras probar la primera ronda:
  - **Las murallas ahora bloquean también al DUEÑO**: antes una muralla
    normal nunca bloqueaba a su propio bando (solo al rival) — comportamiento
    de diseño de la Fase 4, mal percibido en juego real como "las murallas no
    sirven de nada". Ahora una muralla normal bloquea a TODOS; solo una
    Puerta abierta deja pasar al dueño. Al hacerlo, el hueco de una Puerta se
    volvía geométricamente demasiado angosto para cruzarlo (los dos tramos
    vecinos, a solo `WALL_SP`≈28px, también bloqueaban al dueño) — corregido
    con `frameOpenGates`: los tramos normales vecinos a una Puerta ABIERTA del
    mismo dueño dejan de bloquearlo a ÉL (pasillo real de paso), sin dar esa
    cortesía al rival, que solo puede cruzar por el hueco exacto de la
    Puerta. Excepción añadida en `blockedByWall` para que un aldeano pueda
    acercarse a reparar/recargar su propia muralla aunque ahora bloquee.
  - **Torres de Muralla gratis eliminadas**: antes salía una Torre de Muralla
    GRATIS cada 6 tramos al trazar una línea (mismo coste que un tramo normal
    pero con ataque, más barata que una Torre real) — una trampa de recursos.
    Ahora la Torre de Muralla se construye EXPLÍCITAMENTE sobre un tramo de
    muralla normal ya en pie (botón "🏯 Construir Torre de Muralla", paga su
    coste real, `upgradeWallToTower`), convirtiendo la entidad en el sitio.
  - **Puerta con concordancia visual real**: ahora usa el MISMO sprite que un
    tramo de muralla normal (piedra, orientado según `e.dir`) con solo una
    pequeña marca oscura arriba para diferenciarla (más el candado 🔒/🔓 ya
    existente), en vez de una puerta de madera grande que desentonaba.
  - **Catapulta y Taller de Asedio con dibujo procedural**: sin sprites
    propios (Ideogram no disponible tampoco esta sesión), ahora se dibujan
    con formas vectoriales reconocibles en vez de solo un emoji — la
    Catapulta con ruedas+chasis+brazo lanzador (`drawCatapultIcon`), el
    Taller con una silueta de tejado a dos aguas.
  - **Sonido de construcción suavizado**: onda triangular y menos volumen en
    vez de una onda cuadrada fuerte, para que el "clic" de construir sea
    discreto en partidas largas.
  - Verificado headless: regresión completa de Fase 4 (A*/formaciones/
    puertas/rodeo de extremos), combate/proyectiles, MP LAN, puente del río,
    y partida real de 300s con IA Difícil, sin errores. Detalle en
    `progress.md` (entrada 2026-07-16, segunda ronda).
- **Corrección de selección, rally y deselección** (2026-07-18): tres ajustes
  de usabilidad tras jugar una partida real. El área táctil de unidades/
  edificios (`hitBox`) ahora sigue la geometría real del sprite (anclado por
  abajo, crece hacia arriba) en vez de un círculo centrado en la base —
  tocar la cabeza de un aldeano o el tejado de un edificio ya lo selecciona,
  no solo cerca de los pies. El punto de reunión (rally) solo se puede fijar
  en edificios que ENTRENAN unidades (`TRAIN_BLD`: Centro Urbano, Cuartel,
  Galería de Tiro, Establo, Taller de Asedio, Castillo); Granja/Minas/
  Herrería/etc. ya no lo aceptan. Tocar la pantalla con 2 dedos SIN mover
  (ni paneo ni pinch) y soltar rápido deselecciona todo — gesto táctil
  habitual en iPad, además del botón "✕ Deseleccionar" del panel (que se
  mantiene para ratón/escritorio).
- **FASE 9 — Vista de tablero: fichas tipo sticker** (2026-07-21/22):
  pivote de dirección de arte hacia un RTS con cámara **cenital estricta**
  (90°, sin perspectiva) y estética de **juego de mesa** (fichas planas tipo
  sticker/cartón sobre un tablero de pasto, estilo Carcassonne), pensado para
  jugarse con el iPad plano sobre una mesa. La SIMULACIÓN no cambia (sigue
  siendo el mismo RTS en tiempo real, mapa igual de grande, niebla de guerra
  igual); es un cambio de la capa gráfica y de colocación. Primera tanda
  (motor + fichas de respaldo, sin arte nuevo todavía):
  - **Edificios en rejilla, unidades libres**: al construir, el CENTRO del
    edificio se ajusta (`snapToGrid`) a la misma rejilla de 40px que ya usan
    niebla/pathfinding/minimapa (`FOG_CELL`); las unidades siguen moviéndose
    libremente por el mapa (incluida diagonal, sin restricción de rejilla) —
    solo cambia dónde se asienta un edificio nuevo, no el movimiento en
    tiempo real. El fantasma de colocación muestra la casilla ya encajada más
    una rejilla sutil alrededor, para que "se vea tablero" antes de confirmar.
  - **Fichas centradas y planas** (`drawBuilding`/`drawUnit`): se abandonó el
    anclaje "por los pies + estirado ×1.7" (simulaba un edificio visto en
    ¾) por un anclaje CENTRADO en `e.x,e.y`, con sombra recta (sin achatar)
    en vez de la elipse que simulaba perspectiva — igual en `drawShadow`
    (recursos), `drawSelRing`/`drawPings` (ya no se achatan).
  - **Trim de bando en vez de bandera**: cada edificio dibuja un borde blanco
    + un borde interior del color de bando (azul jugador / rojo rival)
    directamente sobre su marco — el MISMO arte sirve para ambos jugadores;
    lo que distingue de quién es un Castillo o una Casa son esas líneas, no
    un sprite o color distinto por bando. Las unidades llevan el mismo
    lenguaje: anillo blanco + anillo de color de bando alrededor de la ficha.
  - **Rotación real hacia el movimiento**: las unidades ya no solo voltean
    izquierda/derecha (`e.face`, que se conserva SOLO para la caída de los
    cadáveres) — rotan de verdad hacia el rumbo real de desplazamiento
    (ángulo suavizado cuadro a cuadro desde el delta de posición, igual en
    host y cliente MP porque se deriva de `e.x/e.y`, que siempre viajan en el
    snapshot). Una pequeña muesca triangular de color de bando en el borde
    del token marca el rumbo con claridad incluso con el arte de respaldo
    (emoji) de hoy.
  - **Refuerzo del efecto de interacción**: además del "lunge" ya existente
    (el atacante/recolector se desplaza hacia su objetivo) y el flash blanco
    al recibir daño, ahora quien recibe el golpe también sufre un breve
    "bonk" de escala (`hurtPunch`, ~110ms) — dos fichas que interactúan
    (atacar, recolectar, construir) se notan claramente en movimiento.
  - **Hitboxes simplificados** (`hitBox`): al estar ahora centradas, la zona
    de toque de una unidad es un cuadrado simétrico alrededor de su centro
    (antes era una caja asimétrica que reproducía el anclaje "por los pies")
    y la de un edificio es exactamente su huella cuadrada — selección más
    predecible y fácil de acertar en pantalla táctil.
  - **`assets/board/board_sprites.json`**: especificación completa (estilo
    global + 5 hojas/parrillas: unidades, edificios económicos, edificios
    militares, recursos/props, texturas de piso) con el prompt exacto de
    cada celda para generar el arte definitivo con IA (Gemini) — arte NEUTRO
    sin color de bando horneado (lo pinta el motor) y toda pieza mirando
    hacia el borde superior de su celda (el motor la rota en tiempo real).
    Cuando llegue ese arte se sustituyen los sprites actuales sin tocar la
    lógica de juego. Detalle del pipeline de recorte/import en `progress.md`.
  - Verificado headless: 0 errores de consola, movimiento diagonal libre
    confirmado, snap de colocación a múltiplos de 40px confirmado, rotación
    hacia un rumbo diagonal confirmada por cálculo, selección exacta en
    centro y borde de ficha confirmada, y regresión completa (pathfinding/
    formaciones/puertas, flip de bandos MP, cruce de puente, 300s con IA
    Difícil) sin errores.
  - **FASE 9B — Integración del arte real** (2026-07-22): el usuario generó
    con Gemini las 7 hojas completas de `assets/board/board_sprites.json` (34
    de 42 celdas útiles, tras corregir el mapeo de la parrilla de unidades y
    añadir la hoja de murallas que faltaba) y las subió como un `.zip`.
    Reemplazan por completo el set pixel-art v1 (unidades, los 12 edificios,
    4 recursos, `obj_mountain`, muralla horizontal/vertical/Torre de Muralla y
    las 4 texturas de piso) — la Puerta no necesitó imagen propia, hereda el
    sprite de muralla ya existente en el motor.
    - **Recorte automático** (script Python de la sesión, no forma parte del
      repo): cada hoja se recorta celda por celda y se le quita el fondo
      blanco por flood-fill (deja intactos los blancos internos, como brillos
      de armadura). Dos hojas necesitaron manejo especial en vez de división
      pareja: la de unidades (los personajes NO están centrados uniformemente
      —el piquetero, p. ej., tiene su cuerpo corrido hacia la celda vecina
      para dejarle sitio a la lanza larga— así que se detectan los huecos de
      tinta reales entre personajes por fila) y la de edificios económicos
      (el Centro Urbano y el Castillo ocupan una columna ENTERA de dos celdas
      de alto cada uno, no una celda 3×4 pareja —Gemini reorganizó la
      rejilla para darles protagonismo—, así que sus 10 celdas reales se
      recortaron con coordenadas verificadas a mano).
    - **Arte por TIER de línea de mejora** (pedido explícito del usuario:
      "arte es más pro, con este tipo de unidades nos lo podemos permitir"):
      además del set base (Fase 5 ya tenía Milicia/Piquetero/Arquero/Caballo/
      Héroes), ahora Espadachín, Campeón, Alabardero, Arquero de Tiro Largo,
      Caballero y Paladín tienen su PROPIA ficha (antes: mismo sprite base +
      insignia de estrellas encima). Nueva convención de nombre de archivo
      `unit_<categoría>_t<tier>` (p. ej. `unit_infantry_t1`); `drawUnit`
      intenta primero el sprite del tier investigado (`lineTierCount`, nunca
      para héroes) y si no existe cae al de tipo base — nunca dispara una
      petición de red nueva porque los nombres de tier ya están pre-
      registrados en `SPRITE_FILES`. La insignia de estrellas se mantiene
      encima igualmente (refuerzo visual, no redundante: el arte cambia la
      apariencia, la insignia sigue marcando el número exacto de tier).
    - **Atlas regenerado por completo** (`assets/atlas.png`+`atlas.json`,
      script Python de la sesión, empaquetado tipo estantería/shelf, cada
      sprite pre-escalado a ≤240px de lado mayor): imprescindible, porque
      `drawSprite` prioriza el atlas sobre el PNG suelto — sin regenerarlo,
      el juego habría seguido mostrando el arte viejo aunque se
      reemplazaran los PNG de `assets/sprites/`. Antes: 30 sprites, 2.59MB.
      Ahora: 38 sprites (suma el arte de tier, mercado, taller de asedio y
      catapulta que antes no tenían PNG), 2.4MB.
    - `bld_market`, `bld_siegeworkshop` y `unit_siege` pasan a tener sprite
      real (antes usaban emoji/dibujo procedural de respaldo, que se
      mantiene como red de seguridad si el PNG llegara a fallar).
    - Verificado headless sirviendo por HTTP real (no `file://`, para que el
      atlas cargue de verdad como en producción): atlas cargado con sus 38
      sprites, 0 errores de consola, compra de un tier de mejora en vivo
      confirmada visualmente (la Milicia cambia al sprite de Espadachín al
      investigarlo), murallas+puerta+3 héroes renderizados juntos sin
      errores, y regresión de 300s con IA Difícil sin errores.
  - **FASE 9C — Correcciones tras jugar con el arte real** (2026-07-22):
    lista concreta de problemas de juego real corregidos:
    - **Recorte roto de caballo/catapulta/arquero**: causa raíz encontrada —
      el detector de huecos exigía `cols-1` huecos para una fila de 4
      columnas nominales que solo tenía 3 personajes reales (4ª celda vacía
      a propósito), así que SIEMPRE caía a una división pareja rota para esa
      fila, cortando la cabeza/cola del caballo y filtrando un fragmento
      suyo dentro del recorte de la catapulta. Recortados de nuevo a mano
      con coordenadas verificadas por muestreo de píxeles.
    - **Piquetero recentrado**: su cuerpo ocupaba solo ~20% del ancho del
      recorte (la lanza larga dominaba el resto), así que el centro de la
      ficha caía sobre el asta vacía, "flotando" lejos del personaje.
      Recortado de nuevo centrado en el cuerpo real (detectado por perfil de
      densidad de tinta), con un tramo corto de lanza a cada lado.
    - **Las unidades ya NO rotan el cuerpo completo con el movimiento**: el
      arte generado no respeta de forma consistente "mirar hacia arriba"
      (cada pieza mira para un lado distinto), así que rotar el dibujo
      completo garantizaba que varias se vieran "yendo hacia atrás/de
      lado" sin importar que la fórmula de rotación en sí fuera correcta
      (se re-verificó matemáticamente). Ahora solo rotan el anillo y la
      muesca de dirección (formas simples, neutras a la rotación); el
      sprite/emoji se dibuja siempre en pie.
    - **`BLD_VIS_SCALE=1.9`**: los edificios no-muralla ahora se ven ~2.5-5×
      más grandes que una unidad (antes casi el mismo tamaño, por haber
      perdido sin querer el estirado ×1.7 de antes de la Fase 9 al pasar a
      fichas centradas). Unidades también reducidas (`sz` 22→16, `uH`
      40→30). Mismo multiplicador usado en render, `hitBox` y fantasma de
      colocación para que el área de toque coincida con lo que se ve.
    - **Rejilla de tablero SIEMPRE visible** (`drawBoardGrid`, no solo al
      colocar un edificio) + texturas de piso más chicas (`worldTile`
      300→80, más repetición) — refuerza el efecto "tablero de mesa".
    - **Murallas alineadas a la rejilla**: `snapWallEndpoint` encaja un
      extremo nuevo (sin muralla/borde de mapa cerca) a la intersección de
      rejilla más próxima.
    - **Anillo de bando reforzado por código** (no arte duplicado por bando,
      más caro de generar/mantener): un segundo anillo, más grueso, se
      dibuja ENCIMA del sprite, así nunca queda tapado por el arte del
      personaje.
    - **Iconos reales en botones de entrenamiento/construcción** (`btnEl`
      acepta un `iconSprite` opcional): Aldeano en el Centro Urbano, toda la
      lista de construcción de edificios, unidades entrenables, héroes del
      Castillo y la fila de cola — ya no usan el emoji.
    - Atlas regenerado otra vez con los 4 sprites corregidos.
    - Verificado con capturas reales en cada paso (no solo aserciones de
      código): sprites re-recortados completos, escena general con la
      nueva jerarquía de tamaños y la rejilla visible, panel con el icono
      real del Aldeano, muralla vertical perfectamente alineada (`punto %
      FOG_CELL === 0`), acercamiento a 4 unidades con anillos azul/rojo
      claramente distinguibles, y regresión de 300s con IA Difícil — 0
      errores de consola en todos los pasos.
  - **FASE 9D — Correcciones tras una segunda partida real** (2026-07-22):
    - **El cuerpo de la ficha AHORA SÍ rota hacia el rumbo real** (pedido
      explícito: "en este momento las direcciones solo se ven hacia un
      sentido"). `UNIT[type].faceOffset` (y `TIER_FACE_OFFSET` para el arte
      propio por tier, Fase 9B) calibra a mano el "sentido" real en el que
      quedó dibujado cada PNG (la mayoría NO respetó la convención "mirar
      hacia arriba" del prompt original — algunos miran hacia un lado, otro
      hacia arriba, sin patrón consistente entre sí ni entre tiers de la
      misma unidad); sumado al ángulo de movimiento real (`drawAngle`) en
      `drawUnit`, la ficha gira alineada con su rumbo en vez de "ir hacia
      atrás". Verificado moviendo cada tipo en las 4 direcciones cardinales
      y comparando capturas contra el sprite sin rotar.
    - **Quitados los anillos/bordes azul-rojo de bando** sobre unidades y el
      trim blanco+color sobre edificios (pedido explícito: "destruye
      completamente la gráfica"). El arte queda tal cual, sin decoración de
      bando añadida por código; la distinción jugador/rival quedará a cargo
      del arte propio por equipo que el usuario va a generar aparte (carpetas
      separadas azul/rojo, pendiente de integrar en una tanda futura).
    - **Sonido de construcción ya no se repite mientras se construye**: el
      "toc" cada ~380ms durante TODA la obra (edificio o mejora) era muy
      invasivo ("no permite jugar correctamente"). Se quitó `playSfx('build')`
      del bucle de construir; ahora solo suena una vez, al TERMINAR
      (`playSfx('built')`, nuevo case en `playSfx`), igual que ya pasaba con
      `'ready'` al terminar de entrenar una unidad. Detectado también en el
      cliente MP comparando `stats.built` entre instantáneas (mismo patrón
      que `stats.trained`/`'ready'`).
    - **Torre de Muralla: coste y tiempo reales** (antes costaba solo 20
      piedra y se convertía al instante — con una muralla de 5 tramos salían
      5 Torres casi gratis y sin esperar, ventaja excesiva). `BLD.wall_tower`
      ahora cuesta y tarda exactamente lo mismo que `BLD.tower`
      (madera+piedra, 18s). `upgradeWallToTower` ya no cambia el `btype` al
      pagar: arranca una cuenta regresiva (`e.upT`/`e.upTotal`, decrementada
      en `update()` junto al resto de edificios) durante la cual el tramo
      sigue siendo una muralla NORMAL (bloquea/colisiona igual, sin
      disparar); recién al llegar a 0 se convierte y empieza a disparar.
      Barra de progreso propia en `drawBuilding` mientras dura, y el botón
      del panel se deshabilita mostrando el tiempo restante. Estado
      serializado en el snapshot MP (`o.up`/`o.ut`) para que el cliente vea
      el mismo progreso.
    - **Murallas alineadas a la rejilla de edificios y solo horizontal/
      vertical**: antes una muralla trazada con una ligera diagonal se veía
      "muy mal" (el arte de muralla solo tiene orientación horizontal o
      vertical) y la separación entre tramos (`WALL_SP=28`) no coincidía con
      la rejilla de 40px (`FOG_CELL`) que ya usan los edificios. `WALL_SP`
      ahora es igual a `FOG_CELL`, y una nueva `wallLineEndpoints(a,b)`
      (usada por `wallTap`, `hostWall` —el camino de muralla en
      multijugador— y la vista previa de colocación) encaja ambos extremos a
      la rejilla (`snapWallEndpoint`, sin cambios) y además fuerza la línea a
      ser estrictamente horizontal o vertical, quedándose con el eje de
      mayor recorrido. Lo que se ve al arrastrar la herramienta de dos
      toques ya es exactamente lo que va a quedar construido.
    - Verificado headless: `wallLineEndpoints` con una entrada en diagonal
      produce una línea recta encajada a la rejilla; mejora de Torre de
      Muralla paga el coste real y tarda 18s en convertirse (probado
      avanzando la simulación); rotación de cada tipo de unidad comparada
      visualmente en las 4 direcciones cardinales; trazado de una muralla en
      diagonal con la herramienta real (`wallTap`) confirmado recto y en
      rejilla; regresión de ~90s de juego simulado con IA Difícil — 0
      errores de consola.
  - **FASE 9E — Aldeanos (y Héroe Espada) caminaban de espaldas** (2026-07-22):
    reporte de juego real tras la Fase 9D: "algunas unidades no tienen un
    sentido correcto al moverse, no todos, algunos si se ven correctos, los
    aldeanos van al revés". Investigado con capturas Playwright (zoom ×5.5
    sobre una unidad moviéndose en las 4 direcciones cardinales) en vez de
    solo revisar el código:
    - **Causa raíz**: `UNIT.villager` y `UNIT.hero_sword` se habían quedado
      con `faceOffset:0` (valor por defecto sin calibrar de verdad) mientras
      el resto de unidades ya tenían un valor propio calibrado en la Fase 9D.
      Son los dos únicos sprites dibujados "de frente" (cara/visor mirando a
      cámara, herramienta o capa colgando hacia abajo) y ese parecido
      engañó la calibración anterior a asumir "mirando hacia arriba" cuando
      el arte en realidad mira hacia ABAJO — un desfase de 180°.
    - `villager`: `faceOffset` 0 → `Math.PI`. Verificado: el pico ahora
      queda por delante al moverse (mismo patrón "la herramienta lidera" que
      Milicia/Piquetero); moviéndose hacia abajo se ve el sprite sin rotar,
      coherente con que el arte ya nace mirando hacia abajo.
    - `hero_sword`: `Math.PI` (misma lógica que el aldeano, por tener
      también cara/capa visible) se probó primero pero dejaba la espada por
      DETRÁS del movimiento — seguía mal, porque su composición real
      (escudo a un lado, espada al otro) es la misma que la Milicia base,
      no la del aldeano. Recalibrado a `-Math.PI/2` (el mismo valor que
      Milicia); verificado que la espada ya lidera el movimiento.
    - Se revisaron también las 6 fichas de línea de mejora (Espadachín,
      Campeón, Alabardero, Caballero, Paladín, Arquero de Tiro Largo)
      moviéndose a la derecha: las 6 ya mostraban su arma/cabeza de caballo
      por delante del movimiento, sin necesitar cambios.
    - **Lección**: `faceOffset` no se puede derivar solo de "¿hacia dónde
      mira la cara?" — para sprites con arma/herramienta asimétrica clara
      (Milicia, Piquetero, Arquero, Caballo y sus tiers, y también Héroe
      Espada pese a tener cara visible) esa arma es la señal fiable; para
      el aldeano, que no tiene ese par simétrico, hay que calibrar aparte.
    - Verificado headless: capturas en zoom alto de las 4 direcciones
      cardinales para Aldeano y Héroe Espada, más las 6 fichas de tier
      restantes moviéndose a la derecha; regresión de ~300s con IA Difícil
      — 0 errores de consola.
- **FASE 10 — Rediseño del menú principal** (2026-07-22): pedido explícito
  ("el menú de ahora parece una pantalla de debug, necesitamos uno típico de
  videojuego, como los de Age of Empires o Mario Kart"). El menú pasó de ser
  un único formulario largo con todas las opciones a la vez, a una pantalla
  de título con navegación por pasos: primero se elige el TIPO de partida,
  luego sus características.
  - **4 paneles dentro del mismo `#startScreen`** (`showMenuPanel(name)`):
    `title` (pantalla de título con banner del Castillo de fondo y 4-5
    botones grandes — ▶ Continuar si hay autoguardado, ⚔️ Jugar destacado,
    🌐 Multijugador, 💾 Partidas guardadas, ⚙️ Ajustes, más un enlace
    pequeño "🎨 Prueba gráfica" al pie), `setup` (las 7 características de
    la partida contra la IA: mapa/recursos/velocidad/IA/posición/tregua/
    guarnición, antes mezcladas con todo lo demás), `mp` (multijugador,
    pestañas Online/Red local) y `load` (las 3 ranuras de guardado manual).
    Los 4 viven dentro del overlay `#startScreen` de siempre —cero cambios
    en los ~10 sitios del código que ya lo ocultan/muestran al empezar o
    terminar una partida—, solo se alterna cuál panel está visible; al
    volver al menú tras jugar se fuerza el panel `title`.
  - **Fichas de opción más grandes y claras** (`.opt-b`): icono emoji arriba
    + etiqueta abajo (antes solo texto) y una marca ✓ dorada al estar
    seleccionada (antes solo un cambio sutil de borde). Mismo mecanismo de
    clic de siempre (`data-val`/`data-opt`), sin cambios de lógica.
  - **Botones grandes tipo videojuego** (`.bigMenuBtn`, nueva clase): icono +
    título + subtítulo, con una sombra inferior que se hunde al tocarlo y
    variantes de color para "Jugar" (borde dorado) y "Continuar" (borde
    verde).
  - Verificado headless: navegación completa entre los 4 paneles y vuelta;
    selección de opciones (mapa/dificultad) confirmada en `gameConfig` antes
    de empezar; Ajustes y Prueba gráfica siguen accesibles desde el nuevo
    título; ciclo completo jugar → victoria → «Jugar de nuevo» vuelve
    exactamente al panel `title`; capturas en móvil estrecho y ancho tipo
    iPad revisadas visualmente; 0 errores de consola.
- **Cuatro correcciones/mejoras tras jugar una partida real** (2026-07-22):
  - **Aldeanos ya NO quedan atrapados construyendo murallas** (bug que
    rompía la partida — se perdía el aldeano para siempre). Causa raíz en
    dos partes, reproducida con un repro headless real (línea de 16 tramos
    + un aldeano por tramo, simulación completa): 1) `blockedByWall` solo
    eximía al aldeano del tramo EXACTO que construía; en una línea, el
    tramo del medio puede quedar sandwich entre dos vecinos YA construidos
    cuyo radio de bloqueo se solapa justo donde tiene que pararse a
    trabajar — ahora exime de TODAS las murallas propias mientras
    construye/repara/recarga cualquier tramo. 2) Un aldeano que ya había
    terminado podía quedar atrapado un instante DESPUÉS, cuando OTRO tramo
    vecino (de otro aldeano) termina justo al lado suyo — nueva
    `unstickUnitsNearWall(w)`, llamada cada vez que un tramo cambia su
    geometría de bloqueo (termina de construirse o sube a Torre de
    Muralla), revisa a TODAS las unidades propias cercanas y las empuja
    (`escapeWallIfStuck`) justo fuera del radio del muro más cercano que
    las bloquea.
  - **Nueva opción "🗑️ Demoler"** en el panel de CUALQUIER edificio propio
    ya construido (sin reembolso), excepto el Centro Urbano (nunca — no se
    puede reconstruir, sería una autoderrota irreversible). Al demoler se
    pone `hp=0` y se deja que el camino de "muerte" de siempre procese el
    resto (sonido, stats, guarnición, rejilla de A*). De paso, los cimientos
    SIN terminar ahora muestran **"✕ Cancelar cimientos"** (reembolso
    completo). Ambas con su comando de red para multijugador.
  - **Niebla de guerra ya no se descuadra con mucho zoom out**: en un
    viewport más ancho/alto que el propio mundo a zoom mínimo (frecuente en
    pantallas anchas/iPad apaisado), el rectángulo que `drawFogOverlay` le
    pedía a la textura de niebla superaba sus dimensiones reales —
    `drawImage` dejaba sin pintar la porción sobrante, mostrando terreno
    crudo sin niebla. Corregido recortando el rectángulo fuente a los
    límites reales de la textura (destino recortado en la misma
    proporción, sin estirar) y rellenando la franja sobrante de negro
    sólido en vez de dejarla sin pintar.
  - **Pantalla de título más épica**: banner más grande y prominente con el
    sprite del Castillo, degradado oscuro para legibilidad, dos héroes
    reales del juego (Espada y Arco) flanqueando el título con ligera
    inclinación, título con relleno degradado dorado y resplandor
    pulsante, divisor decorativo, y un marco doble color oro en toda la
    tarjeta.
  - Verificado headless: 16 tramos de muralla construidos por 16 aldeanos
    sin ninguno atrapado (7 corridas repetidas, `blockedByWall===false`
    siempre); demoler una Casa la elimina e incrementa `stats.lostB`, el
    Centro Urbano no muestra el botón; niebla corregida con capturas
    antes/después en ambas esquinas del mapa; título revisado en móvil y
    escritorio ancho; regresión de ~300s con IA Difícil sin errores de
    consola.
- **Efectos visuales: humo/fuego más intenso y huellas en el suelo**
  (2026-07-22): pedido explícito de más efectos visuales.
  - **Humo/fuego escala de forma continua** con el % de vida perdido (antes
    2 escalones fijos y muy sutiles): más columnas de humo, más oscuras y
    rápidas cuanto peor está el edificio (desde <70% hp), fuego más grande
    desde <35%, y chispas ascendentes cerca del colapso para reforzar la
    sensación de urgencia pedida explícitamente.
  - **Huellas en el suelo** (`footprints[]`, mismo patrón de pool que
    `corpses`/`pings`): cada unidad a pie deja una marca cada 15px
    recorridos, que se desvanece en 5.5s con un aro claro alrededor para
    contrastar con la textura del césped. Tope de seguridad de 500 huellas
    vivas para batallas masivas (medido: ~12.75ms/cuadro sin tope con 120
    unidades marchando sin parar → ~3.5ms/cuadro con el tope).
  - Verificado headless: rastro de huellas visible tras una unidad en
    movimiento, desvanecimiento real confirmado esperando su tiempo de vida
    real (no simulado); comparación de intensidad de humo/fuego en 3
    edificios a 65%/30%/8% de vida; regresión de ~300s con IA Difícil sin
    errores de consola.
- **Más efectos visuales: chispas, polvo, destello dorado y sacudida de
  cámara** (2026-07-22): a pedido explícito ("implementa todos" sobre 5
  sugerencias). Todos puramente decorativos (pool + purga por edad, mismo
  patrón que huellas/cadáveres/pings), funcionan igual en host y cliente MP.
  - **Chispas de recolección** (`sparks[]`): 2-3 partículas de color según
    el recurso saltan del punto de contacto al recolectar madera/piedra/
    oro/comida, con throttle por unidad.
  - **Chispazo de impacto cuerpo a cuerpo**: mismo array, variante más
    intensa (`rtype:'impact'`) solo para golpes instantáneos (no arquero/
    catapulta, que ya muestran un proyectil).
  - **Polvo bajo la caballería** (`dust[]`): nube que se disipa rápido tras
    el Caballo/Héroe Jinete al galopar.
  - **Destello dorado al avanzar de Era o completar una mejora** (`bursts[]`,
    `triggerAchievementBurst`): anillo dorado + destellos sobre el Centro
    Urbano; detectado también en el cliente MP por diff de `age`/`upg`.
  - **Sacudida de cámara** al caer un Centro Urbano o Castillo (cualquier
    bando): `triggerShake` decae en tiempo real; se aplica en `render()`
    como un `ctx.translate` temporal que nunca toca `cam.x`/`cam.y` de
    verdad, así que no afecta al mapeo pantalla↔mundo de los toques.
  - Verificado headless: cada efecto confirmado con capturas/mediciones
    dedicadas (chispas frescas antes de apagarse, destello con anillo+
    orbitales, sacudida con diferencia de píxeles real entre cuadros);
    regresión de ~300s con IA Difícil sin errores de consola.
- **Correcciones tras juego real: tamaño/orientación por tier, huellas y
  muralla-trampa** (2026-07-24): 4 problemas reportados jugando con el arte
  por tier de la Fase 9B.
  - **Escala inconsistente al mejorar de tier**: `unit_pike_t1.png`
    (Alabardero) y `unit_cavalry_t1`/`unit_cavalry_t2.png`
    (Caballero/Paladín) tenían canvases mucho más grandes que el personaje
    real (asta larga, o el caballo dibujado en el eje vertical en vez de
    horizontal como el resto del set) — `drawSprite` escala el canvas
    COMPLETO a una altura fija, así que el personaje quedaba diminuto frente
    a sus hermanos. Recortados (`pike_t1`, y `infantry_t2`/Campeón, caso más
    leve) o rotados 90° (`cavalry_t1`/`cavalry_t2`, en el eje equivocado) y
    reempaquetado `assets/atlas.png`/`atlas.json` (obligatorio: el atlas
    tiene prioridad sobre el PNG suelto en `drawSprite`).
  - **Orientación de movimiento corregida** (`faceOffset`/
    `TIER_FACE_OFFSET`, recalibrados probando las 4 direcciones cardinales):
    Catapulta (iba al revés), Campeón, Alabardero (arma en diagonal ~45°,
    fuera del barrido habitual de 90°), Héroe Espada y Héroe Arco (se
    movían de lado).
  - **La Catapulta ya deja huellas**: se quitó su exclusión explícita
    (pensada para "tiene ruedas, no pies", percibida como bug real en juego).
  - **Aldeanos atrapados en murallas al construirlas (persistía)**: la
    protección existente (`unstickUnitsNearWall`) solo actuaba en el
    instante en que un tramo TERMINABA de construirse; un aldeano podía
    quedar encajado después por simple apiñamiento (`separate()`) sin que
    ningún muro cambiara de estado. Ahora el chequeo por unidad de CADA
    cuadro llama a `escapeWallIfStuck` en cuanto detecta que su posición de
    reposo (antes de separar) ya está bloqueada por una muralla propia —red
    de seguridad continua y no solo por evento. Verificado con 16 tramos de
    muralla y 16 aldeanos construyendo a la vez: 0 atrapados.
  - Verificado headless: 4 unidades de tier a tamaño consistente (captura
    comparativa), las 7 unidades corregidas revisadas en las 4 direcciones
    cardinales, huellas confirmadas tras la Catapulta, y el repro de
    murallas (16 tramos/16 aldeanos) sin ningún `blockedByWall===true`;
    regresión adicional sin errores de consola.
- **Tanda grande de mejoras pedidas tras jugar: automatización, selección,
  mapa, partida/menú y tutorial accesible** (2026-07-24):
  - **Aldeanos iniciales repartidos**: los 3 aldeanos del jugador arrancan
    recolectando comida/madera/oro (uno cada uno) en vez de quedar idle.
  - **Radio de búsqueda de recurso limitado** (`IDLE_GATHER_RADIUS`, 5
    casillas/200px): un aldeano que agota su recurso ya no viaja lejos a
    buscar el siguiente (podía terminar cerca de la base rival); si no hay
    nada cerca, se queda quieto en vez de alejarse.
  - **Doble toque de selección rápida solo para ejército**: ya no aplica a
    aldeanos ni edificios (cae a un toque normal en esos casos).
  - **Haz de luz vertical sobre lo seleccionado**: además del anillo/
    corchetes, un cono de luz translúcido sube desde cada unidad/edificio
    seleccionado para verlo claro en medio del combate.
  - **Selector de tamaño de mapa** (Pequeño/Grande ×1.5/Enorme ×2, menú de
    configuración): `WORLD` y las rejillas de niebla/A* se reconstruyen al
    tamaño elegido; el generador de mapas escala sus clusters de recursos y
    añade más al área extra. Se sincroniza al cliente MP y se guarda/
    restaura en las partidas guardadas.
  - **Barra de puntaje en vivo** (esquina inferior derecha, sobre el
    minimapa): nombres de los dos bandos + una puntuación que se actualiza
    durante toda la partida (recursos, ejército vivo, era, bajas, producción).
  - **Alias del jugador + nombres graciosos para la IA**: input en el menú
    principal (máx. 16 caracteres, saneado sin símbolos ni HTML — protegido
    contra inyección), persistido. La IA usa un nombre al azar (BarbaRosa,
    JuanaLaCuerda, GuillermoElComelón…) en cada partida de un jugador; en MP
    viaja el alias real de cada humano.
  - **El anfitrión de una sala MP elige las opciones de la partida**: "Crear
    sala"/"Crear partida" ya no aloja directo — lleva primero al panel de
    configuración (mapa/tamaño/recursos/velocidad/tregua/etc.) y solo abre
    la sala al pulsar "Empezar partida" con esas opciones ya elegidas.
  - **Chat multijugador** (botón 💬, solo visible en MP): mensajes de texto
    simples entre los dos jugadores sobre el transporte de red ya existente;
    el texto se escapa al pintarse.
  - **Vida de edificios ×2**: todos los edificios de `BLD` duplicaron su hp
    (estaba siendo muy fácil destruirlos).
  - **Botón "🎬 Ver tutorial"** en el menú principal: presentación PASIVA de
    10 frames con icono animado y frase corta, navegable, sin depender de
    una partida en curso — para entender los controles antes de jugar (a
    diferencia del tutorial guiado de 10 pasos de la Fase 6, que exige jugar
    de verdad).
  - Verificado headless: reparto inicial de aldeanos por recurso, aldeano
    lejos de cualquier fuente se queda idle, doble toque en aldeano cae a
    selección simple, `render()` sin errores con la nueva capa de selección,
    alias saneado al vuelo, vista previa del tutorial navega y cierra bien,
    mapa Enorme confirmado en `WORLD`/niebla, flujo de "Crear sala" no aloja
    hasta confirmar opciones, mensaje de chat simulado recibido, vida de
    edificios doblada confirmada, regresión de aldeanos-en-murallas y
    partida simulada con IA Difícil — todo sin errores de consola.
- **Corrección de tamaño real al evolucionar, selección más sobria, Centro
  Urbano/Castillo imponentes y tutorial simulado** (2026-07-24):
  - **Se quitó el sistema de estrellas de nivel** sobre las unidades: el
    arte por tier ya se distingue solo, no hacía falta la insignia aparte.
  - **Arreglado el encogimiento real al evolucionar** (Caballero/Paladín,
    Alabardero): `drawSprite` forzaba siempre la misma altura y dejaba el
    ancho libre según el aspecto de cada sprite; ahora acepta una caja
    "contain" (alto y ancho máximos) usada por todas las unidades, así el
    ancho queda acotado sin importar cuán distinto sea el aspecto del arte
    de cada tier.
  - **Haz de selección de unidades más tenue**: mucha menos opacidad y sin
    blending "lighter" (ya no se quema a blanco).
  - **Edificios: titileo del cuadrado en vez del haz de luz**: los
    edificios seleccionados parpadean su propio recuadro en vez de llevar
    el cono de luz de las unidades.
  - **Centro Urbano y Castillo a 4×4 casillas**: huella visual exacta de
    160×160px, bastante más imponentes que el resto de edificios.
  - **Tutorial: simulación tipo "grabación de pantalla"**: la vista previa
    pasiva (botón 🎬 Ver tutorial) pasó de iconos con animación CSS a 10
    mini-animaciones reales en un `<canvas>` propio con las gráficas reales
    del juego y un círculo blanco que imita el dedo tocando la pantalla,
    para: seleccionar unidad, llevarla a hacer una acción, deseleccionar,
    crear unidad, subir de Era, atacar unidad, moverse por el mapa, mejorar
    unidad, atacar edificio y construir torre/muralla defensiva.
  - Verificado headless: los 10 pasos del tutorial recorridos sin errores;
    unidades de tier a tamaño consistente (captura); Centro Urbano a
    160×160px exactos con corchetes+titileo y sin estrellas; regresión de
    aldeanos-en-murallas y partida simulada con IA Difícil sin errores.
- **Gráficas del Centro Urbano por Era y correcciones al tutorial simulado**
  (2026-07-24): el usuario subió las 3 gráficas por Era como `.zip`.
  - El Centro Urbano cambia de gráfica según la Era del bando dueño
    (`townSpriteName`): Era Inicial usa el sprite de siempre, Eras II-IV
    tienen ficha propia (recortadas/con transparencia real, optimizadas).
  - **Tutorial corregido**: deseleccionar ya no simula un toque en el mapa
    (eso mueve a la unidad de verdad) sino el gesto real de 2 dedos sin
    mover; subir de Era y mejorar unidad ahora muestran el panel de
    acciones apareciendo y un segundo toque sobre su botón real, con texto
    más descriptivo; el paso de subir de Era muestra el Centro Urbano
    cambiando de gráfica con el mismo arte del juego. Se agregaron 2 pasos
    nuevos (doble toque = mismo tipo, arrastre = caja de selección), 12 en
    total.
  - Verificado headless: los 12 pasos recorridos sin errores, capturas de
    cada gesto nuevo/corregido, `townSpriteName` confirmado por Era, y
    regresión completa sin errores de consola.
- **Icono de oro plateado, caballería demasiado chica y Centro Urbano 1.5×
  más grande** (2026-07-24):
  - **Icono de oro**: `🪙` (se veía plateado en iPad) reemplazado por `💰`
    en toda la interfaz — consistente con `RES.gold.emoji`.
  - **Caballería más grande**: nueva `UNIT_BOX_W` calibra el ancho de la
    caja "contain" por sprite (Caballo/Caballero/Paladín/Héroe Jinete) para
    preservar un área de token parecida en vez de forzarlos todos al mismo
    ancho — se veían "muy chiquitos" con la caja genérica.
  - **Centro Urbano 1.5× más grande**: de 4×4 a 6×6 casillas del tablero
    (240px de huella visual); el Castillo queda igual. Ajustado el offset
    de los aldeanos iniciales y del cluster de recursos de cada base para
    que no queden dentro de la huella nueva.
  - Verificado headless: tamaño exacto del Centro Urbano, aldeanos fuera de
    su huella, caballería a tamaño comparable con el resto de unidades
    (captura), y regresión completa sin errores de consola.
- **Caballo/Caballero: tamaño con largo mínimo garantizado y dirección
  corregida** (2026-07-24):
  - La familia caballería (Caballo/Caballero/Paladín/Héroe Jinete) ahora
    fija un LARGO objetivo de 2.2 casillas del tablero (en vez de acotar
    el ancho por sprite), calculado a partir del aspecto real de cada
    imagen — notablemente más grandes que el intento anterior.
  - El Caballo (unidad base) se movía al revés: su PNG mira hacia la
    derecha, no hacia la izquierda como se había asumido; `faceOffset`
    corregido y verificado en las 4 direcciones. El Caballero ya estaba
    bien calibrado (su arte sí mira a la izquierda) y no se tocó.
  - Verificado headless: largo exacto (88px) confirmado para ambos, las 4
    direcciones del Caballo con la cabeza liderando, el Caballero con su
    tier real aplicado moviéndose bien, y regresión completa sin errores.
