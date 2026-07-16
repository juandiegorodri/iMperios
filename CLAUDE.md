# CLAUDE.md — Guía del proyecto Mini-AoE

Este archivo da contexto a Claude (y a cualquier desarrollador) sobre el
proyecto. **Léelo al empezar cualquier sesión** y respeta las normas de abajo.

---

## 1. Qué es el proyecto

**Mini-AoE**: una versión *ultra básica* de Age of Empires para jugarse con
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
  `https://juandiegorodri.github.io/Ageofempires/`. Al fusionar a `main`, la
  web se actualiza sola.
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
  el juego "se sienta un AoE real"; cada fase se ejecuta en su propio PR.
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
- **FASE 5 — Profundidad AoE: líneas de unidad, asedio, guarnición y mercado**
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
    `localStorage` en **3 ranuras** (`miniaoe_save_1/2/3`) + **autoguardado**
    (`miniaoe_autosave`) cada 2 minutos (`setInterval`, fuera del bucle de
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
    persisten en `localStorage` como `miniaoe_settings`): volumen de SFX y de
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
    `localStorage` (`miniaoe_tutorial_done`) que ya se completó o se saltó,
    para no repetirlo. Deshabilitado por completo en multijugador.
  - **Línea de tiempo del resumen**: durante la partida se muestrean cada 30s
    (de juego, afectados por la velocidad de partida) los recursos totales y
    el "valor militar" (coste total invertido en tropas vivas) de cada bando
    en `gameTimeline` (solo host/partida local, no en el cliente MP, que no
    simula); se dibuja en `renderSummary` sobre un `<canvas id="tlChart">`
    del resumen final: 2 líneas sólidas (recursos tú/rival) y 2 discontinuas
    (valor militar tú/rival), o un aviso si la partida fue muy corta.
