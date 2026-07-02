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
