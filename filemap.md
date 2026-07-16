# filemap.md — Mapa de archivos

Estructura del repositorio. Actualizar cuando se añadan archivos o secciones de
código nuevas (ver normas en `CLAUDE.md`).

## Archivos del repositorio

| Archivo | Propósito |
|---|---|
| `index.html` | **El juego completo**: HTML + CSS + JavaScript embebido. Es el único archivo necesario para jugar. |
| `DESIGN.md` | Documento de diseño (GDD) detallado del juego. |
| `CLAUDE.md` | Guía del proyecto, flujo de trabajo, normas y listado de funcionalidades. |
| `filemap.md` | Este archivo: mapa de archivos y estructura del código. |
| `progress.md` | Bitácora cronológica de avance. |
| `README.md` | Cómo jugar, controles y cómo desplegar. |
| `assets/ART.md` | Manual de línea gráfica y lista de sprites/animaciones. |
| `assets/sprites/*.png` | Sprites finales del juego (unidades, edificios, recursos). |
| `assets/atlas.png` / `atlas.json` | Atlas de sprites (Fase 8): 30 de los 34 PNG de `assets/sprites/` empaquetados y PRE-ESCALADOS en una sola textura + su mapa de recortes, para menos peticiones y menos reescalado por cuadro. Generado por un script Node de la sesión (`build_atlas.cjs`, no forma parte del repo, igual criterio que `arena.cjs` de la Fase 5); regenerar si cambian los PNG de origen. Ver `assets/ART.md`. |
| `assets/_raw/*.webp` | Hojas fuente generadas con Ideogram (para re-recortar). |
| `vercel.json` | Config de despliegue estático en Vercel (caché de sprites y del atlas, headers). |
| `.vercelignore` | Excluye del deploy web `ios/`, `server.js`, `assets/_raw/` y los `.md`. |
| `manifest.webmanifest` | Web App Manifest (PWA: nombre, iconos, pantalla completa). |
| `assets/icon-180.png` / `icon-512.png` | Iconos de la app (apple-touch-icon / manifest). |
| `iOS.md` | App de iPad y arquitectura del multijugador P2P. |
| `PLAN.md` | Plan maestro por fases (revisión, principios y hoja de ruta ejecutable). |
| `server.js` | Relé WebSocket (Node, sin dependencias) para multijugador LAN en escritorio (transporte A, Fase 7). |
| `ios/MiniAoE.xcodeproj/` | Proyecto Xcode (app iPad, target único). |
| `ios/MiniAoE/*.swift` | `MiniAoEApp` (entrada), `GameWebView` (WKWebView), `RelayServer` (relé WS + IP local). |
| `ios/MiniAoE/Info.plist` | Permisos de red local, orientaciones de iPad, ATS. |

## Estructura interna de `index.html`

El archivo se organiza en estas secciones (en orden de aparición):

### `<head>` / `<style>`
- Estilos de la UI: barra superior (`#topbar`), panel de acciones (`#actions`),
  botones flotantes (`#util`: inactivos / centrar / pausa), overlays de inicio y
  fin, avisos (`#hint`), botones (`.btn`).

### `<body>` (marcado)
- `#game` (canvas), `#topbar` (recursos), `#util` (botones inactivos/centrar/
  pausa), `#hint`, `#actions` (panel inferior), `#startScreen`, `#endScreen`.

### `<script>` — lógica del juego
1. **Configuración / definiciones de datos**: constantes del mundo (`WORLD`,
   `POP_MAX`, `BONUS`, `AGGRO`, `MAX_AGE`), `STRONG_VS` (cuadrilátero por
   categoría), `UNIT` (unidades con `cat`; incluye 3 héroes con `hero:true`),
   `BLD` (edificios: Casa, Castillo, Torre con `atk`, y de producción —Granja,
   Mina de Oro, Mina de Piedra, Bosquero— con `produces`/`plants`; murallas con
   `wall:true` —`wall`, `wall_tower`— y la Puerta `gate` con `wall:true,
   gate:true`, Fase 4; Fase 5: `siegeworkshop` —Taller de Asedio, entrena
   Catapulta, req. Cuartel + Era Feudal— y `market` —Mercado, req. Era de las
   Herramientas—), `UNIT_LINES`/`GARRISON_MAX`/`MARKET_QTY` y demás constantes
   de la Fase 5 (ver 4.5), `AGES`, `ECON`, `UPG`, `RES`, presets (`RES_PRESETS`,
   `SPEED_PRESETS`, `MAPS`) y `gameConfig`.
2. **Estado global**: `cam`, `entities`, `selection`, `player`, `enemy`
   (con `mods.resMult` y `stats`), `gameSpeed`, `mapTheme`, `terrain`, `bridge`,
   flags (`running`, `paused`, `gameOver`, `difficulty`).
2.5. **Sprites gráficos** (Fase 8: atlas + pre-escalado + carga perezosa,
   sustituye el `loadSprites()` eager de fases anteriores): `SPRITE_FILES`
   (lista de los 34 nombres válidos), `SPRITE_SET` (el mismo conjunto, para
   comprobar en O(1) si un nombre tiene PNG real antes de pedirlo — evita
   404 para edificios sin sprite aún, como `bld_market`/`bld_siegeworkshop`
   de la Fase 5, que usan emoji), `sprites`/`ensureLooseSprite`/`spr` (PNG
   sueltos de `assets/sprites/`, carga PEREZOSA: solo se piden por red si el
   atlas falla o no tiene ese sprite), `atlasImg`/`atlasFrames`/`atlasReady`/
   `atlasFailed`/`loadAtlas` (carga `assets/atlas.png`+`assets/atlas.json` —
   un atlas con cada sprite ya PRE-ESCALADO a su tamaño máximo real de uso
   en juego, ver `assets/ART.md`; bajo `file:` se salta el intento de red a
   propósito, ver comentario en el propio `loadAtlas`, porque Chromium
   bloquea `fetch()` local por CORS y lo registra como `console.error`
   aunque el fallo se capture bien), `drawSprite` (atlas primero con recorte
   por coordenadas → PNG suelto perezoso → `false`, y el llamador pinta el
   emoji de respaldo), `drawShadow`,
   `setUnitTransform`/`resetTransform` (transform local barato para la
   animación de unidades, sin `save/restore`), y patrones de textura
   `getPattern`/`fillPattern` (suelo/agua/roca; las 4 texturas `tile_*` se
   quedan FUERA del atlas a propósito, ver `assets/ART.md`). Selección
   animada (`drawSelBox`/`drawSelRing`) y efectos `pings` (con pool, ver
   9.5). Murallas: `WALL_SP`,
   `WALL_TOWER_EVERY`, `wallSegmentType(pts,i)` (Fase 4: decide si el tramo `i`
   es muro/torre/**Puerta** — el tramo central de una línea de ≥3 tramos),
   `wallTap`/`wallPoints`, colisión `blockedByWall`/`wallBlocksSide`
   (`frameWalls`, ver 8.5). La reparación vive en la rama `build` del bucle de
   unidades.
2.55. **Sonido (WebAudio sintetizado)**: `audioCtx`/`masterGain`/`ambientNode`,
   `ensureAudio` (creado/reanudado en el primer gesto táctil, requisito de
   Safari), `setSoundOn` (persistido en `localStorage`), `playTone`/`playNoise`
   (osciladores/ruido crudos), `startAmbient` (loop de viento), `playSfx`
   (espada, flecha, talar, picar, construir, unidad lista, edificio destruido,
   alerta, victoria/derrota) y `sfxAllowed` (throttle por nombre de efecto).
2.55.5. **Niebla de guerra, minimapa y alertas** (Fase 2): constantes
   `FOG_CELL`/`FOG_COLS`/`FOG_ROWS`/`VISION_UNIT`/`VISION_BLD`, estado
   (`fogExplored`/`fogVisible` como `Uint8Array` de la rejilla, `fogCanvas`
   offscreen de baja resolución). Funciones: `fogIndex`/`fogVisibleAt`/
   `fogExploredAt` (consulta), `markVision`/`recomputeFog` (recálculo cada
   ~150ms desde `loop`, también en el cliente MP), `redrawFogCanvas` (pinta la
   textura de niebla), `drawFogOverlay` (la pega sobre el canvas principal con
   suavizado bilineal), `fogRenderOk` (filtro por entidad, usado en `render`,
   `drawProjectiles`, `drawCorpses` y `pickAt`) y `resetFog` (reinicio por
   partida). Alertas: `alertZoneKey`/`triggerAttackAlert` (throttle 8s por
   zona de 200px, pulso rojo + botón `#btnAlert`), `showAlertButton`/
   `hideAlertButton`; se dispara desde `applyDamage` (host/SP) y desde
   `applySnap` (cliente MP, comparando hp entre instantáneas). Minimapa:
   canvas `#minimap` + botón `#btnMiniToggle` (colapsar), `buildMinimapTerrain`
   (terreno cacheado 1 vez por mapa), `drawMinimap` (redibujado a ~4.5Hz:
   terreno + niebla + puntos por bando + pulsos de alerta + rectángulo de
   cámara), `minimapPointerToCam`/`minimapToWorld` (tocar/arrastrar mueve la
   cámara) y `positionMinimap` (se recoloca sobre el panel de acciones, cuyo
   alto varía). Puramente de render/cliente: no cambia el protocolo
   multijugador ni la lógica de la IA (que sigue "viendo" todo internamente).
2.6. **Multijugador P2P** (bloque `MULTIJUGADOR P2P`): estado `net`, conexión
   (`netConnect`/`netHostStart`/`netJoinStart`), serialización con bandos
   invertidos (`serEntity`/`deserEntity`/`serProjectile`/`makeSnap`/
   `applySnap` — este último también reconstruye efectos visuales del cliente:
   flash de daño, cadáveres y SFX de "unidad lista"/"edificio destruido"/
   "alerta" comparando instantáneas consecutivas), mensajería
   (`netOnMessage`/`netSendInit`/`clientStartFromInit`/`clientEnd`) y comandos
   del cliente aplicados por el anfitrión (`hostHandleCmd`/`hostPlace`/
   `hostWall`). Guardas de cliente en la economía, órdenes y colocación.
   Ver `iOS.md` para el protocolo completo. El comando `amove` (Fase 3) sigue
   el mismo patrón que `move`; los comandos `move`/`amove` calculan el A* y la
   formación **en el host** vía `applyGroupMove` (Fase 4, ver 8.5). El estado
   abierto/cerrado de una Puerta viaja como `o.cl` en `serEntity`/`deserEntity`
   y tiene su propio comando `gate` (Fase 4). Fase 5: el tier de línea de
   mejora investigado viaja gratis en `side.upg` (sin cambios en el protocolo,
   ver 4.5); el conteo de guarnición de un edificio viaja como `o.gr` y si una
   unidad está guarnecida como `o.gi` (ambos en `serEntity`/`deserEntity`); el
   proyectil de catapulta lleva `o.k:'siege'` en `serProjectile`; comandos
   nuevos en `hostHandleCmd`: `lineupg`, `garrison`, `expel`, `market`.
   **Fase 7 — transporte abstraído + WebRTC + robustez** (el protocolo de
   arriba NO cambió): `net.sendRaw(str)`/`net.onRaw(str)` son la única
   interfaz entre el protocolo y el transporte. Transporte A (LAN, sin
   cambios): `netConnect`/`netHostStart`/`netJoinStart` cablean el WebSocket a
   `net.sendRaw`/`net.onRaw`. Transporte B (Online/WebRTC): `loadPeerJs`
   (inyecta `<script>` de PeerJS bajo demanda desde CDN),
   `netOnlineHostStart`/`netOnlineJoinStart` (código de sala de 6 caracteres,
   `genRoomCode`/`peerIdFor`), `wireOnlineConn` (cablea el DataChannel a
   `net.sendRaw`/`net.onRaw`), `netOnlineConnLost`/`clientTryReconnect`
   (reconexión ~60s con el mismo código, sin reiniciar la partida). UI: pestañas
   `#mpTabOnline`/`#mpTabLan` (clase propia `.mp-tab`, no `.opt-b`, para no
   heredar el resaltado genérico del menú), `#onlineCodeBox`/`#onlineCodeText`/
   `#btnCopyCode`. Deltas: `makeSnapDelta` (solo entidades cuya serialización
   cambió + ids eliminados) alterna con `makeSnap` completo cada ~1s
   (`net.fullT`, `net.deltaEnabled`); `applySnap` fusiona ambos tipos de
   mensaje (`snap`/`snapd`) sobre el mismo array `entities`. Interpolación:
   `net.ipPrev`/`net.ipCur` (posiciones de unidades antes/después de cada
   instantánea) + `interpClientPositions()` (lerp por fotograma, llamada desde
   `loop` solo en el cliente) — puramente de render, no toca simulación ni
   guardado.
2.7. **Grupos de control tácticos** (Fase 3, LOCALES del cliente — no viajan
   por red): `controlGroups` (3 arrays de ids), `saveControlGroup`/
   `cleanControlGroup`/`selectControlGroup` y `updateGroupBadge`; listeners
   `pointerdown`/`pointerup` de los botones `#btnGrp1-3` (mantener pulsado
   0.5s = guardar, toque = seleccionar, doble toque = seleccionar+centrar).
   Se reinician en `startGame`/`clientStartFromInit` y se limpian de muertos
   en `removeEntity`.
3. **Utilidades**: `dist`, `clamp`, `find`, `radiusOf`, recursos/coste
   (`canAfford`, `pay`, `costStr`, `popCount`, `popCap`), `hasBuilding`,
   `countBuildings`, `prodSpeed` (bono de producción por nº de edificios).
4. **Creación de entidades**: `makeUnit` (aplica el hp del tier de línea de
   mejora vigente del bando, Fase 5, vía `lineTierMult`), `makeBuilding`
   (inicializa `garrison:[]` en los edificios de `GARRISON_MAX`, Fase 5),
   `makeResource`.
4.5. **Líneas de mejora, asedio, guarnición y mercado** (Fase 5): `UNIT_LINES`
   (tiers por categoría con coste/`reqAge`), `LINE_TIER_MULT` (×1.35 por
   tier), `lineTierCount`/`lineTierMult` (consulta dinámica, usada por
   `unitAtk` y por el chevron en `drawUnit`), `nextLineTier`/`buyLineTier`
   (compra: sube hp de las unidades vivas de la categoría al instante, el atq
   se deriva solo; tier guardado en `side.upg`, gratis en `serSide`).
   `GARRISON_MAX`/`canGarrison`/`garrisonUnits`/`expelGarrison` (guarnición de
   torres/castillo/Centro Urbano; unidades guarnecidas llevan `e.garrisonedIn`
   y se saltan en `update`, `nearestEnemy`, `pickAt`, `separate` y el filtro de
   `render`). `MARKET_QTY`/`MARKET_SELL_GOLD`/`MARKET_BUY_GOLD`/`marketTrade`
   (Mercado). `SIEGE_BLD_MULT` (daño de área ×4 de la catapulta contra
   edificios/murallas, en `computeDamage`).
5. **Inicialización y mapas**: `startGame` (usa `gameConfig`, reinicia `stats`),
   `spawnResourceCluster`, `generateMap` (recursos/terreno por tema; río vertical
   con puente), `onObstacle` (bloqueo de construcción) y `blocksUnit` (bloqueo de
   paso: río salvo puente, y riscos).
6. **Cámara**: `viewW/viewH`, `centerOn`, `clampCam`, conversiones
   `worldToScreen` / `screenToWorld`, `resize`. **Inercia del paneo** (Fase 3):
   `cam.vx`/`cam.vy` (velocidad, medida con EMA en `pointermove` durante el
   gesto de 2 dedos) y `updateCameraInertia` (llamada desde `loop`): decae
   ~0.9/cuadro tras soltar los dedos y aplica un **clamp elástico** (atracción
   exponencial sin overshoot) si la inercia saca la cámara del mundo — el
   paneo en vivo sigue usando el clamp duro de siempre.
7. **Economía / entrenamiento**: `queueUnit`, `countQueued`, `tryAdvanceAge`
   (multi-era), `buyUpgrade`, `buyEcon`/`nextEcon` (tecnologías de recursos),
   `cancelQueued` (cancela y reembolsa), stats efectivas (`unitAtk`, `unitRange`,
   `unitArmor` por categoría, `gatherRate` por recurso), combate: `computeDamage`
   (cálculo puro; Fase 5: ×`SIEGE_BLD_MULT` el daño de la catapulta contra
   edificios/murallas, ×0.5 contra unidades), `applyDamage` (aplica hp,
   `hurtT`, `hitBy` y `alertFlags` al impactar), `damage` (golpe cuerpo a
   cuerpo instantáneo), `fireProjectile`/`updateProjectiles` (proyectiles
   reales — arqueros, héroe arco, torres, torres de muralla, castillo,
   catapultas — el daño se aplica al llegar, no al disparar; el proyectil
   `kind:'siege'` además hace daño de área reducido a otros edificios/
   murallas cercanos al punto de impacto, Fase 5).
8. **Lógica de unidades / IA**: `nearestEnemy`, `nearestResourceOfType`,
   `nearestGatherFor`/`nearestAnyResource` (incluyen edificios de producción),
   `srcRtype`, `autoAssignIdle` (aldeano inactivo busca trabajo), `separate`
   (empuje entre unidades cercanas; el resultado se descarta si cuela a
   alguien por el río/riscos **o por una muralla/puerta que le bloquee** —
   Fase 4, evita que el apiñamiento "filtre" unidades por las esquinas de
   murallas).
   **Ataque-mover** (Fase 3): `amoveOrder(units,x,y)` fija el estado `amove`
   (envía comando MP si es cliente, si no delega en `applyGroupMove` — Fase 4);
   la constante `AMOVE_RANGE` define el radio de auto-aggro continuo que usa
   el propio bucle de `update`.
8.5. **Pathfinding (A\*) y formaciones** (Fase 4, bloque `PATHFINDING (A*) Y
   FORMACIONES`): corre SOLO en host/partida local. `wallBlocksSide(w,side)`
   (¿bloquea este muro/puerta a este bando? — usada tanto por `blockedByWall`
   como por el grid/LOS del A*), `builtWalls()`, grid estático por bando
   (`pathGrids`, `buildPathGrid`, `getPathGrid`, `invalidatePathGrid` —
   reutiliza el tamaño de celda de la niebla, `FOG_CELL`/`FOG_COLS`/
   `FOG_ROWS`), `losClear` (línea de visión, evita el A* si no hace falta y
   suaviza el camino), `astarPath` (A* con min-heap propio, `heapPush`/
   `heapPop`, heurística octile, sin cortar esquinas), `smoothPath` (colapsa
   waypoints visibles), `computeGroupPath` (un camino por orden de grupo, cache
   compartido), `formationSlots`/`FORM_COLS`/`FORM_SP` (rejilla compacta
   alrededor del destino, cuerpo a cuerpo delante/arqueros detrás, asignación
   greedy) y `applyGroupMove(units,ownerSide,x,y,state)` (punto de entrada
   común para `move`/`amove`, usado por `handleTap`, `hostHandleCmd` y
   `amoveOrder`). `invalidatePathGrid` se llama al completar una
   muralla/puerta, al destruirla (`removeEntity`), al alternar una puerta y en
   `startGame`/`clientStartFromInit`.
9. **Bucle principal**: `loop` (además de simular, dispara `recomputeFog`
   cada ~150ms, `drawMinimap` cada ~220ms — ver 2.55.5 — y
   `updateCameraInertia` cada cuadro, también en el cliente MP), `update`
   (proyectiles; unidades con retaliación y auto-trabajo — la retaliación NO
   saca a una unidad en `amove` de su estado, solo le fija el objetivo, ver
   §2.7 más abajo —; **repath del A\*** (Fase 4): si una unidad en
   `move`/`amove` lleva >0.6s casi sin avanzar (`e.stuckT`), recalcula su
   camino desde donde está vía `computeGroupPath([e],...)`; estado `amove`:
   persigue/ataca enemigos en `AMOVE_RANGE` sin abandonar la marcha, retoma el
   destino al perder el objetivo; gather de nodos y edificios de producción
   con SFX de talar/picar, edificios con torres y bosqueros (`invalidatePathGrid`
   al completar la construcción de una muralla/puerta), muertes con conteo de
   bajas y creación de cadáveres visuales, fin de partida), `stepToward`
   (sigue los waypoints de `e.path`/`e.pathIdx` si los hay — Fase 4 — y al
   agotarlos, guiado por el puente y bloqueo de obstáculos/murallas como
   antes), `spawnTrained` (SFX "unidad lista"; rally encadenable — ver 2.7 —
   usa `nearestGatherFor` con el `rtype` del rally), `removeEntity` (limpia
   también `unitFace`, quita al muerto de `controlGroups` e invalida el grid
   de A* si era una muralla/puerta — Fase 4), `enemyAI` + `DOCTRINE` (3
   manuales) y `pickWaveTarget` (objetivo estratégico).
9.5. **Object pools y GC** (Fase 8, bloque junto a la declaración de
   `pings`/`projectiles`): `_projPool`/`allocProjectile`/`freeProjectile` y
   `_pingPool` reutilizan objetos "muertos" en vez de crear uno nuevo por
   cada disparo (`fireProjectile`) o ping (`addPing`) — en combates grandes
   son decenas por segundo. `updateProjectiles`/`drawPings` ya no usan
   `.splice()` (O(n), desplaza el array) sino un intercambio con el último
   elemento + `.pop()` (O(1); válido porque el orden entre proyectiles/pings
   no importa) y devuelven el objeto liberado al pool correspondiente.
   `update()` tampoco recalcula `frameWalls` con `entities.filter(...)` (un
   array nuevo cada cuadro) sino reutilizando el array (`length=0` + `push`).
   Puramente de render/simulación LOCAL: no cambia el protocolo MP (el
   cliente reconstruye su propio `projectiles` a partir del snapshot vía
   `.map()`, sin pool, en `applySnap`) ni el comportamiento observable
   (mismos proyectiles/pings, mismos campos).
10. **Render**: `render` (culling `onScreen` + filtro de niebla `fogRenderOk`,
    y `drawFogOverlay` al final de la escena — ver 2.55.5), `drawTerrain`
    (río/puente/riscos), `drawGround`, `drawCorpses` (cadáveres: fade + caída,
    también filtrados por niebla), `onScreen`, `drawResource`/`drawBuilding`
    (con `drawDamageFx`: humo/fuego por hp) /`drawUnit` (animación procedural
    — bamboleo, lunge, volteo — y flash `hurtT`; dibujan **sprite** con anillo
    de bando y sombra, respaldo de emoji; el lunge también cubre el estado
    `amove` — Fase 3; Fase 5: chevrons ▲ por tier de línea investigado sobre
    la unidad, y las unidades guarnecidas —`e.garrisonedIn`— se excluyen del
    listado a dibujar antes de llegar aquí), `drawProjectiles` (flechas/rocas
    en vuelo, también filtradas por niebla; Fase 5: el proyectil `kind:'siege'`
    de la catapulta se dibuja como roca con arco parabólico en vez de flecha),
    `drawHpBar`, `roundRect`. `drawBuilding` dibuja el
    rally con línea punteada + bandera 🚩 + icono del recurso si es
    encadenado (Fase 3); la Puerta (Fase 4) usa el sprite `obj_gate` (no
    `bld_wall_h/v`) y siempre dibuja un candado 🔒/🔒→🔓 sobre ella según
    `e.closed` (no solo al seleccionarla).
11. **Entrada táctil**: objeto `input` (incluye `panVelX`/`panVelY`/`lastPanT`
    para la inercia de cámara, Fase 3), manejadores
    `pointerdown/move/up/cancel`, `wheel`, teclado; `pickAt`, `handleTap`
    (primero consume `orderMode==='amove'` pendiente — ver `amoveOrder` — y
    también acepta fijar el rally sobre un recurso/edificio de producción; la
    orden de mover unidades propias delega en `applyGroupMove` — Fase 4; Fase
    5: tocar una torre/castillo/Centro Urbano propio con unidades
    guarnecibles seleccionadas —`canGarrison`— las mete dentro vía
    `garrisonUnits`, antes de la rama de "mover"), `handleDoubleTap` (unidades
    del mismo tipo visibles, excluye guarnecidas — Fase 5; Fase 3: también
    edificios del mismo tipo), `finishBoxSelect` (excluye guarnecidas — Fase
    5), `selectedUnits`, `selectedBuilding`; colocación (`placementValid`,
    `tryPlaceBuilding`).
12. **UI: panel de acciones**: `btnEl`, `clearActions` (limpia botones y filas de
    cola), `updateActionPanel` (multiplicador de producción, fila de cola
    cancelable, chips de filtro por tipo en selecciones mixtas — Fase 3 —,
    estado abierta/cerrada de una Puerta seleccionada — Fase 4 —, conteo de
    guarnición — Fase 5 — y botón Deseleccionar), `appendLineTierButtons`
    (Fase 5: botón de investigación del próximo tier de línea para las
    categorías entrenables en Cuartel/Galería/Establo), `buildingButtons`
    (incluye avance de era, tecnologías económicas, construcción de
    Casa/Castillo, entrenamiento de Catapulta en el Taller de Asedio, botones
    de compra/venta del Mercado, y para una Puerta, el botón "🔒 Cerrar
    puerta"/"🔓 Abrir puerta" que alterna `b.closed` — Fase 4, ≥44px, envía
    comando `gate` si es cliente MP; al final, para cualquier edificio con
    guarnición, info "🛡️ N/max" + botón "🚪 Expulsar" — Fase 5), `deselectAll`.
    Botón "⚔️→ Ataque-mover" (Fase 3, con militares seleccionados) fija
    `orderMode='amove'`; botón "🪖 Todo el ejército" (`#btnArmy`) selecciona
    todos los militares vivos propios (excluye guarnecidos — Fase 5).
13. **Barra superior y utilidades de UI**: `updateTopbar` (contador de inactivos
    y tasa de producción por recurso), `idleVillagers`, `selectNextIdle`,
    `showHint`, `endGame` y `renderSummary` (tabla del resumen final; Fase 6:
    también llama a `drawTimelineChart`).
14. **Menú principal y arranque**: `MAP_DESC`, `refreshMenu` y listeners de las
    opciones del menú; botón Empezar; **prueba gráfica** (`openGfxTest` + botón,
    usa `<img>` directos sobre los 34 nombres de `SPRITE_FILES`, no pasa por el
    atlas); listeners de fin/centrar (doble toque → `lastAlert`, Fase 3)/pausa/
    inactivos/ejército (`#btnArmy`)/grupos de control (`#btnGrp1-3`); bloqueo de
    gestos del navegador; refresco periódico del panel; listeners de
    guardado/ajustes/tutorial (Fase 6, ver 15-17). **Arranque + pantalla de
    carga** (Fase 8, bloque `Arranque + pantalla de carga`, overlay
    `#loadScreen` con barra `#loadBarFill`/`#loadPct`, z-index por encima del
    resto para que tape el menú hasta estar listo): `bootLoad` llama a
    `loadAtlas` — si el atlas carga, la barra salta casi al 100% de una vez
    (1 sola imagen+json); si falla, pide TODOS los PNG sueltos de golpe (en
    vez de perezosos) y sondea su progreso real cada 80ms hasta que estén
    todos listos — y `setLoadProgress`/`hideLoadScreen`; `LOAD_MAX_MS` (4s)
    es un tope de seguridad para que un fallo de red nunca deje al jugador
    atascado en la carga. El "audio" no ocupa tiempo real de carga (WebAudio
    sintetizado, sin archivos; el `AudioContext` de verdad solo arranca tras
    el primer toque, ver 2.55) — solo una fracción simbólica de la barra.
    Termina con `resize()` + `requestAnimationFrame(loop)`.
15. **Guardado local** (Fase 6, un solo jugador, bloque `GUARDADO LOCAL`
    justo después de `hostWall` — reutiliza `serEntity`/`deserEntity`/
    `serSide` del bloque MP de arriba): `SAVE_VERSION`/`SAVE_SLOT_KEY`/
    `AUTOSAVE_KEY`/`AUTOSAVE_INTERVAL_MS`, `fogToString`/`fogFromString`
    (empaqueta `fogExplored`, un `Uint8Array` de 0/1, como cadena de dígitos),
    `rebuildModsFromUpg` (reconstruye la caché `side.mods` a partir de los
    flags `side.upg` guardados, igual que hacen `buyUpgrade`/`buyEcon` al
    comprar), `buildSaveObject`/`applySaveObject` (serializa/restaura
    entidades **sin flip de bandos** vía `serEntity(e,false)`, más terreno/
    puente/config/edad/recursos/niebla explorada/grupos de control/línea de
    tiempo; la guarnición se guarda aparte con ids reales exactos —
    `save.garrisons` — porque el formato de `serEntity` para el snapshot MP
    solo lleva el conteo), `saveToSlot`/`loadFromSlot` (3 ranuras),
    `autosave`/`loadAutosave` (cada 2 min por `setInterval` fuera del bucle
    de render, y en `visibilitychange`), `refreshSaveUI` (rellena el botón
    "Continuar" del menú y las listas de ranuras del menú/panel `#saveScreen`
    abierto con el botón 💾 de `#util`). Todas las funciones empiezan con
    `if(inMP()) return`: deshabilitado por completo en multijugador (también
    se apaga explícitamente en `clientStartFromInit`).
16. **Ajustes** (Fase 6, sección `AJUSTES` justo antes del bloque de Sonido,
    porque el volumen se aplica ahí): `SETTINGS_KEY`, `loadSettings`/
    `saveSettings`/`applySettingsToUI` (persisten en `localStorage` como un
    único objeto: `sfxVol`/`ambVol`/`camSpeed`/`showFps`), `setAmbientVolumeLive`.
    `playTone`/`playNoise` multiplican su `vol` por `settings.sfxVol/100`;
    `startAmbient` usa `settings.ambVol/100`; `settings.camSpeed` multiplica
    el paneo táctil de 2 dedos (`pointermove`) y el paneo por flechas
    (`keydown`); `settings.showFps` activa `#fpsHud` (EMA de fps sobre el
    delta real, actualizada desde `loop`). Panel `#settingsScreen` (botón ⚙️
    en el menú y en `#util`) con sliders de volumen, botones Lenta/Normal/
    Rápida, botones Sí/No de fps y "🔄 Reiniciar tutorial" (`tutorialReset`).
17. **Tutorial guiado** (Fase 6, bloque `TUTORIAL GUIADO` antes de
    `// ---------- Actualización ----------`): `TUTORIAL_DONE_KEY`, estado
    `tutorial` (`active`/`step`/`baseline`/`flags`), `TUTORIAL_STEPS` (10
    pasos, cada uno con `msg`, `target()` —punto de mundo a resaltar, o
    null— y `check()` —condición real de avance, sondeada por `tutorialCheck`
    desde `loop` a ~3Hz—; `onEnter` opcional captura una línea base, p.ej.
    cuántos aldeanos hay ya). Helpers de consulta: `firstPlayerVillager`,
    `playerTown`, `nearestResourceToTown`, `playerGathering`,
    `countPlayerVillagers`, `fogExploredCount`. `tutorialShouldStart`/
    `tutorialArm` (se llama desde `startGame` y `applySaveObject`; una
    partida cargada a medias puede ya cumplir pasos, la máquina los salta
    sola), `tutorialEnterStep`/`tutorialCheck`/`tutorialFinish`/
    `tutorialSkip`/`tutorialReset`, `updateTutUI`/`hideTutBox` (panel
    `#tutBox`, con el botón "Saltar tutorial"), `drawTutorialTarget` (anillo
    pulsante en mundo, llamado desde `render`). El paso final ("Todo el
    ejército") se detecta con un flag puesto por el propio listener de
    `#btnArmy`, no por sondeo de estado. Deshabilitado por completo en
    multijugador.
18. **Línea de tiempo del resumen** (Fase 6.4, bloque `LÍNEA DE TIEMPO` junto
    al del tutorial): `gameTimeline`/`timelineT`/`TIMELINE_INTERVAL`/
    `TIMELINE_MAX_SAMPLES`, `totalRes`/`costTotal`/`militaryValue` (coste
    total invertido en tropas vivas de un bando), `sampleTimeline` (llamado
    desde `loop` cada 30s de juego, solo host/partida local — no en el
    cliente MP, que no simula), `drawTimelineChart` (dibuja `#tlChart` en
    `#endScreen`, llamado desde `renderSummary`).
19. **Corrección post-lanzamiento** (2026-07-16, tras juego real): `garrisonEnabled`
    y `peaceTimer` (globales fijados en `startGame` desde `gameConfig.garrison`/
    `gameConfig.peace`, nuevas opciones del menú principal); `nearestEnemy` y
    `applyDamage` respetan `peaceTimer` (sin combate durante la tregua); las dos
    ramas de guarnición (`handleTap` y el caso `'garrison'` de `hostHandleCmd`)
    exigen `garrisonEnabled`. `snapWallEndpoint` (usado por `wallTap`/`hostWall`)
    ajusta los extremos de una muralla al borde del mapa o a otra muralla
    cercana. `drawWallOrientedSprite` (junto a `drawSprite`) dibuja un sprite
    girado 90° — usado para que la Puerta se vea orientada según `e.dir`.
    `maybeShowQuickHelp`/`QUICKHELP_KEY` (overlay `#quickHelpScreen`, llamado
    desde `startGame`). El bucle de recolección (`update`) ya no reproduce SFX
    por cuadro y, al agotarse un edificio de producción, pasa a `build` sobre
    el mismo edificio en vez de buscar otro (retoma `gather` al recargarse).
