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
| `assets/_raw/*.webp` | Hojas fuente generadas con Ideogram (para re-recortar). |
| `vercel.json` | Config de despliegue estático en Vercel (caché de sprites, headers). |
| `.vercelignore` | Excluye del deploy web `ios/`, `server.js`, `assets/_raw/` y los `.md`. |
| `manifest.webmanifest` | Web App Manifest (PWA: nombre, iconos, pantalla completa). |
| `assets/icon-180.png` / `icon-512.png` | Iconos de la app (apple-touch-icon / manifest). |
| `iOS.md` | App de iPad y arquitectura del multijugador P2P. |
| `PLAN.md` | Plan maestro por fases (revisión, principios y hoja de ruta ejecutable). |
| `server.js` | Relé WebSocket (Node, sin dependencias) para multijugador en escritorio. |
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
   gate:true`, Fase 4), `AGES`, `ECON`, `UPG`, `RES`, presets (`RES_PRESETS`,
   `SPEED_PRESETS`, `MAPS`) y `gameConfig`.
2. **Estado global**: `cam`, `entities`, `selection`, `player`, `enemy`
   (con `mods.resMult` y `stats`), `gameSpeed`, `mapTheme`, `terrain`, `bridge`,
   flags (`running`, `paused`, `gameOver`, `difficulty`).
2.5. **Sprites gráficos**: `SPRITE_FILES`, `sprites`, `loadSprites`, `spr`,
   `drawSprite` (PNG escalado con respaldo de emoji), `drawShadow`,
   `setUnitTransform`/`resetTransform` (transform local barato para la
   animación de unidades, sin `save/restore`), y patrones de textura
   `getPattern`/`fillPattern` (suelo/agua/roca). Selección animada
   (`drawSelBox`/`drawSelRing`) y efectos `pings`. Murallas: `WALL_SP`,
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
   y tiene su propio comando `gate` (Fase 4).
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
4. **Creación de entidades**: `makeUnit`, `makeBuilding`, `makeResource`.
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
   (cálculo puro), `applyDamage` (aplica hp, `hurtT`, `hitBy` y `alertFlags` al
   impactar), `damage` (golpe cuerpo a cuerpo instantáneo), `fireProjectile`/
   `updateProjectiles` (proyectiles reales — arqueros, héroe arco, torres,
   torres de muralla, castillo — el daño se aplica al llegar, no al disparar).
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
10. **Render**: `render` (culling `onScreen` + filtro de niebla `fogRenderOk`,
    y `drawFogOverlay` al final de la escena — ver 2.55.5), `drawTerrain`
    (río/puente/riscos), `drawGround`, `drawCorpses` (cadáveres: fade + caída,
    también filtrados por niebla), `onScreen`, `drawResource`/`drawBuilding`
    (con `drawDamageFx`: humo/fuego por hp) /`drawUnit` (animación procedural
    — bamboleo, lunge, volteo — y flash `hurtT`; dibujan **sprite** con anillo
    de bando y sombra, respaldo de emoji; el lunge también cubre el estado
    `amove` — Fase 3), `drawProjectiles` (flechas en vuelo, también
    filtradas por niebla), `drawHpBar`, `roundRect`. `drawBuilding` dibuja el
    rally con línea punteada + bandera 🚩 + icono del recurso si es
    encadenado (Fase 3); la Puerta (Fase 4) usa el sprite `obj_gate` (no
    `bld_wall_h/v`) y siempre dibuja un candado 🔒/🔒→🔓 sobre ella según
    `e.closed` (no solo al seleccionarla).
11. **Entrada táctil**: objeto `input` (incluye `panVelX`/`panVelY`/`lastPanT`
    para la inercia de cámara, Fase 3), manejadores
    `pointerdown/move/up/cancel`, `wheel`, teclado; `pickAt`, `handleTap`
    (primero consume `orderMode==='amove'` pendiente — ver `amoveOrder` — y
    también acepta fijar el rally sobre un recurso/edificio de producción; la
    orden de mover unidades propias delega en `applyGroupMove` — Fase 4),
    `handleDoubleTap` (unidades del mismo tipo visibles; Fase 3: también
    edificios del mismo tipo), `finishBoxSelect`, `selectedUnits`,
    `selectedBuilding`; colocación (`placementValid`, `tryPlaceBuilding`).
12. **UI: panel de acciones**: `btnEl`, `clearActions` (limpia botones y filas de
    cola), `updateActionPanel` (multiplicador de producción, fila de cola
    cancelable, chips de filtro por tipo en selecciones mixtas — Fase 3 —,
    estado abierta/cerrada de una Puerta seleccionada — Fase 4 — y botón
    Deseleccionar), `buildingButtons` (incluye avance de era, tecnologías
    económicas, construcción de Casa/Castillo y, para una Puerta, el botón
    "🔒 Cerrar puerta"/"🔓 Abrir puerta" que alterna `b.closed` — Fase 4, ≥44px,
    envía comando `gate` si es cliente MP), `deselectAll`. Botón "⚔️→
    Ataque-mover" (Fase 3, con militares seleccionados) fija `orderMode='amove'`;
    botón "🪖 Todo el ejército" (`#btnArmy`) selecciona todos los militares
    vivos propios.
13. **Barra superior y utilidades de UI**: `updateTopbar` (contador de inactivos
    y tasa de producción por recurso), `idleVillagers`, `selectNextIdle`,
    `showHint`, `endGame` y `renderSummary` (tabla del resumen final).
14. **Menú principal y arranque**: `MAP_DESC`, `refreshMenu` y listeners de las
    opciones del menú; botón Empezar; **prueba gráfica** (`openGfxTest` + botón);
    listeners de fin/centrar (doble toque → `lastAlert`, Fase 3)/pausa/inactivos/
    ejército (`#btnArmy`)/grupos de control (`#btnGrp1-3`); bloqueo de gestos
    del navegador; refresco periódico del panel; `loadSprites()` + `resize()` +
    `requestAnimationFrame(loop)`.
