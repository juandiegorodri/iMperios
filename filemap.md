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
   Mina de Oro, Mina de Piedra, Bosquero— con `produces`/`plants`), `AGES`,
   `ECON`, `UPG`, `RES`, presets (`RES_PRESETS`, `SPEED_PRESETS`, `MAPS`) y
   `gameConfig`.
2. **Estado global**: `cam`, `entities`, `selection`, `player`, `enemy`
   (con `mods.resMult` y `stats`), `gameSpeed`, `mapTheme`, `terrain`, `bridge`,
   flags (`running`, `paused`, `gameOver`, `difficulty`).
2.5. **Sprites gráficos**: `SPRITE_FILES`, `sprites`, `loadSprites`, `spr`,
   `drawSprite` (PNG escalado con respaldo de emoji), `drawShadow`,
   `setUnitTransform`/`resetTransform` (transform local barato para la
   animación de unidades, sin `save/restore`), y patrones de textura
   `getPattern`/`fillPattern` (suelo/agua/roca). Selección animada
   (`drawSelBox`/`drawSelRing`) y efectos `pings`. Murallas: `WALL_SP`,
   `WALL_TOWER_EVERY`, `wallTap`/`wallPoints`, colisión `blockedByWall`
   (`frameWalls`). La reparación vive en la rama `build` del bucle de unidades.
2.55. **Sonido (WebAudio sintetizado)**: `audioCtx`/`masterGain`/`ambientNode`,
   `ensureAudio` (creado/reanudado en el primer gesto táctil, requisito de
   Safari), `setSoundOn` (persistido en `localStorage`), `playTone`/`playNoise`
   (osciladores/ruido crudos), `startAmbient` (loop de viento), `playSfx`
   (espada, flecha, talar, picar, construir, unidad lista, edificio destruido,
   alerta, victoria/derrota) y `sfxAllowed` (throttle por nombre de efecto).
2.6. **Multijugador P2P** (bloque `MULTIJUGADOR P2P`): estado `net`, conexión
   (`netConnect`/`netHostStart`/`netJoinStart`), serialización con bandos
   invertidos (`serEntity`/`deserEntity`/`serProjectile`/`makeSnap`/
   `applySnap` — este último también reconstruye efectos visuales del cliente:
   flash de daño, cadáveres y SFX de "unidad lista"/"edificio destruido"/
   "alerta" comparando instantáneas consecutivas), mensajería
   (`netOnMessage`/`netSendInit`/`clientStartFromInit`/`clientEnd`) y comandos
   del cliente aplicados por el anfitrión (`hostHandleCmd`/`hostPlace`/
   `hostWall`). Guardas de cliente en la economía, órdenes y colocación.
   Ver `iOS.md` para el protocolo completo.
3. **Utilidades**: `dist`, `clamp`, `find`, `radiusOf`, recursos/coste
   (`canAfford`, `pay`, `costStr`, `popCount`, `popCap`), `hasBuilding`,
   `countBuildings`, `prodSpeed` (bono de producción por nº de edificios).
4. **Creación de entidades**: `makeUnit`, `makeBuilding`, `makeResource`.
5. **Inicialización y mapas**: `startGame` (usa `gameConfig`, reinicia `stats`),
   `spawnResourceCluster`, `generateMap` (recursos/terreno por tema; río vertical
   con puente), `onObstacle` (bloqueo de construcción) y `blocksUnit` (bloqueo de
   paso: río salvo puente, y riscos).
6. **Cámara**: `viewW/viewH`, `centerOn`, `clampCam`, conversiones
   `worldToScreen` / `screenToWorld`, `resize`.
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
   `srcRtype`, `autoAssignIdle` (aldeano inactivo busca trabajo), `separate`.
9. **Bucle principal**: `loop`, `update` (proyectiles, unidades con
   retaliación y auto-trabajo, gather de nodos y edificios de producción con
   SFX de talar/picar, edificios con torres y bosqueros, muertes con conteo de
   bajas y creación de cadáveres visuales, fin de partida), `stepToward`
   (guiado por el puente y bloqueo de obstáculos), `spawnTrained` (SFX "unidad
   lista"), `removeEntity` (limpia también `unitFace`), `enemyAI` +
   `DOCTRINE` (3 manuales) y `pickWaveTarget` (objetivo estratégico).
10. **Render**: `render`, `drawTerrain` (río/puente/riscos), `drawGround`,
    `drawCorpses` (cadáveres: fade + caída), `onScreen`, `drawResource`/
    `drawBuilding` (con `drawDamageFx`: humo/fuego por hp) /`drawUnit`
    (animación procedural — bamboleo, lunge, volteo — y flash `hurtT`; dibujan
    **sprite** con anillo de bando y sombra, respaldo de emoji),
    `drawProjectiles` (flechas en vuelo), `drawHpBar`, `roundRect`.
11. **Entrada táctil**: objeto `input`, manejadores `pointerdown/move/up/cancel`,
    `wheel`, teclado; `pickAt`, `handleTap`, `handleDoubleTap`,
    `finishBoxSelect`, `selectedUnits`, `selectedBuilding`; colocación
    (`placementValid`, `tryPlaceBuilding`).
12. **UI: panel de acciones**: `btnEl`, `clearActions` (limpia botones y filas de
    cola), `updateActionPanel` (multiplicador de producción, fila de cola
    cancelable y botón Deseleccionar), `buildingButtons` (incluye avance de era,
    tecnologías económicas y construcción de Casa/Castillo), `deselectAll`.
13. **Barra superior y utilidades de UI**: `updateTopbar` (contador de inactivos
    y tasa de producción por recurso), `idleVillagers`, `selectNextIdle`,
    `showHint`, `endGame` y `renderSummary` (tabla del resumen final).
14. **Menú principal y arranque**: `MAP_DESC`, `refreshMenu` y listeners de las
    opciones del menú; botón Empezar; **prueba gráfica** (`openGfxTest` + botón);
    listeners de fin/centrar/pausa/inactivos; bloqueo de gestos del navegador;
    refresco periódico del panel; `loadSprites()` + `resize()` +
    `requestAnimationFrame(loop)`.
