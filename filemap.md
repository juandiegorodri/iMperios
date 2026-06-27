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
   `drawSprite` (PNG escalado con respaldo de emoji), `drawShadow`, y patrones de
   textura `getPattern`/`fillPattern` (suelo/agua/roca). Selección animada
   (`drawSelBox`/`drawSelRing`) y efectos `pings`. Murallas: `WALL_SP`,
   `WALL_TOWER_EVERY`, `wallTap`/`wallPoints`, colisión `blockedByWall`
   (`frameWalls`). La reparación vive en la rama `build` del bucle de unidades.
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
   `unitArmor` por categoría, `gatherRate` por recurso), combate (`damage`, marca
   `hitBy` para la retaliación).
8. **Lógica de unidades / IA**: `nearestEnemy`, `nearestResourceOfType`,
   `nearestGatherFor`/`nearestAnyResource` (incluyen edificios de producción),
   `srcRtype`, `autoAssignIdle` (aldeano inactivo busca trabajo), `separate`.
9. **Bucle principal**: `loop`, `update` (unidades con retaliación y auto-trabajo,
   gather de nodos y edificios de producción, edificios con torres y bosqueros,
   muertes con conteo de bajas, fin de partida), `stepToward` (guiado por el
   puente y bloqueo de obstáculos), `spawnTrained`, `removeEntity`, `enemyAI` +
   `DOCTRINE` (3 manuales) y `pickWaveTarget` (objetivo estratégico).
10. **Render**: `render`, `drawTerrain` (río/puente/riscos), `drawGround`,
    `onScreen`, `drawResource`/`drawBuilding`/`drawUnit` (dibujan **sprite** con
    anillo de bando y sombra; respaldo de emoji), `drawHpBar`, `roundRect`.
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
