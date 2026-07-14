# progress.md — Bitácora de avance

Registro cronológico del desarrollo. Solo se **agrega** al final; no se borra el
historial. Ver normas en `CLAUDE.md`.

---

## 2026-06-27 — PR #1: juego base jugable
- Creado `index.html`: motor Canvas 2D + JS puro, táctil para iPad.
- Economía con 4 recursos (comida, madera, oro, piedra) y recolección directa.
- Unidades: Aldeano, Milicia, Piquetero, Arquero, Caballo.
- Edificios base (5): Centro Urbano, Cuartel, Galería de Tiro, Establo, Herrería.
- Cuadrilátero de combate ×2 (Arquero → Milicia → Piquetero → Caballo → Arquero).
- Entrenamiento por cola, construcción por aldeanos, mejoras de Herrería (4),
  avance de Era.
- IA enemiga con 3 dificultades; condición de victoria/derrota.
- Controles: selección por toque/caja/doble toque, órdenes contextuales, cámara
  con 2 dedos + zoom, pausa, pantallas de inicio/fin.
- Documentación inicial: `DESIGN.md`, `README.md`.
- Verificado en Chromium headless (sin errores) + captura de pantalla.

## 2026-06-27 — PR #2: calidad de vida + torres
- **Localizador de aldeanos inactivos**: botón con contador en vivo; cicla y
  centra la cámara; insignia 💤 sobre los inactivos en el mapa.
- **Símbolo de recurso** sobre los aldeanos que recolectan (🍒/🌳/💰/🪨).
- **Botón Deseleccionar** en el panel de acciones (unidades y edificios).
- **Torres defensivas** (🗼): construibles por aldeanos (madera + piedra),
  auto-disparo a enemigos en rango, radio visible al seleccionar; la IA las
  construye en Normal/Difícil.
- Verificado en Chromium headless (sin errores) + captura de pantalla.

## 2026-06-27 — PR #3: producción por cantidad de edificios + documentación
- **Producción acelerada**: cuantos más edificios del mismo tipo productor tenga
  un bando, más rápido entrena ese tipo de unidades (×1, ×1.5, ×2, …). Se
  muestra el multiplicador en el panel del edificio. Funciones `countBuildings`
  y `prodSpeed`.
- Creados los documentos de proceso: **`CLAUDE.md`** (contexto + normas + listado
  de funcionalidades), **`filemap.md`** (mapa de archivos y estructura del
  código) y **`progress.md`** (esta bitácora).
- Normas añadidas: cada funcionalidad nueva debe actualizar `CLAUDE.md`,
  `filemap.md` (si cambia la estructura) y `progress.md`.
- Verificado en Chromium headless (`prodSpeed` correcto, sin errores).

## 2026-06-27 — PR #3 (continuación): nivel de producción + arreglo de IA
- **Tasa de recolección en la barra superior**: junto a cada recurso se muestra
  la producción actual (p. ej. «+1.4/s»), sumando la tasa de los aldeanos que
  recolectan ese recurso; se resalta en verde cuando hay producción activa.
  Implementado en `updateTopbar`.
- **Arreglo de IA (bug)**: la IA dejaba el cuartel a medio construir y dejaba de
  producir porque desviaba al aldeano constructor para hacer la torre. Ahora
  `buildIfNeeded` solo toma aldeanos que no estén construyendo y la IA no inicia
  un edificio nuevo mientras haya otro en construcción (construcción secuencial).
- Documentación actualizada (`CLAUDE.md`, `filemap.md`, `progress.md`).
- Verificado en Chromium headless: tasas correctas (+0.7/s, +1.4/s); la IA
  termina el cuartel, entrena unidades y construye en orden; sin errores.

## 2026-06-27 — PR #4: menú, mapas, población, edades, tecnologías y cola
- **Menú principal** con opciones de partida: mapa, recursos iniciales, velocidad,
  inteligencia de la IA y posición del jugador.
- **Mapas temáticos**: Llanura, Río (bloquea construcción en el cauce), Selva
  Negra (madera abundante) y Riscos (bloques rocosos, abunda piedra/oro).
  Funciones `generateMap`, `onObstacle`, `drawTerrain` y color de fondo por mapa.
- **Población dinámica**: se inicia con 20; Centro Urbano +20, Casa +5,
  Castillo +50 (tope 200). `popCap` reemplaza la constante fija.
- **Edificios nuevos**: Casa 🏠 y Castillo 🏰 (defensa potente + población,
  requiere Era III).
- **Cuatro edades** (`AGES`): Inicial → Herramientas → Feudal → Imperial;
  `tryAdvanceAge` ahora es multi-era.
- **Tecnologías económicas por recurso** (`ECON`, `buyEcon`, `nextEcon`):
  Molino/Aserradero/Minería/Cantera y versiones avanzadas; aumentan la
  recolección de cada recurso (`mods.resMult`, `gatherRate` por recurso).
- **Velocidad de partida**: `gameSpeed` escala el `dt` del bucle.
- **Cola de edificio editable**: iconos de la cola; tocar uno cancela y reembolsa
  (`cancelQueued`). Arreglado `clearActions` para no duplicar la fila de cola.
- **IA mejorada**: avanza de era, construye casas al llegar al tope de población,
  levanta castillos (Difícil/Era III), recolección ponderada y entrena la unidad
  que puede pagar.
- Documentación actualizada (`CLAUDE.md`, `filemap.md`, `progress.md`).
- Verificado en Chromium headless: menú y opciones, casa (+5) y castillo (+50),
  avance de edades, tecnología de recurso (+30%), cancelación con reembolso,
  mapas con obstáculos que bloquean construcción; sin errores de consola.

## 2026-06-27 — PR #5: resumen, producción de recursos, héroes, IA y río con puente
- **Resumen de partida**: tabla comparativa (Tú vs IA) con era, unidades
  entrenadas/perdidas, enemigos eliminados, edificios construidos/perdidos y
  tecnologías (`renderSummary`, conteo en `stats`).
- **Edificios de producción**: Granja, Mina de Oro, Mina de Piedra (recolección
  renovable) y Bosquero (planta árboles). `nearestGatherFor`/`nearestAnyResource`,
  gather desde edificios en el bucle.
- **Héroes del Castillo**: Héroe Espada/Arco/Jinete (`UNIT` con `cat` y `hero`);
  cuadrilátero por categoría; aura ⭐ en el render.
- **Aldeanos combaten y se defienden**: orden de ataque para aldeanos y
  retaliación de toda unidad golpeada (`damage` marca `hitBy`; el bucle responde
  y el aldeano reanuda su recurso con `resumeGather`).
- **Río con puente**: río vertical que separa a los jugadores; `blocksUnit`
  impide cruzarlo salvo por el puente; `stepToward` guía a las unidades al
  puente. Los riscos también bloquean el paso.
- **Aldeanos inactivos buscan trabajo** (`autoAssignIdle`): terminan obras,
  siguen con su recurso o el más cercano; «Detener» fija `halt` para dejarlos
  quietos.
- **Tres manuales de IA** (`DOCTRINE` + `pickWaveTarget`): Fácil (ataca el Centro),
  Normal (objetivo más cercano, economía y torres) y Difícil (héroes y objetivos
  estratégicos: defensas → economía → Centro).
- Documentación actualizada (`CLAUDE.md`, `filemap.md`, `progress.md`).
- Verificado en Chromium headless: granja renovable, auto-trabajo, cruce por el
  puente (izq.→der.), retaliación de aldeano, resumen (7 filas), doctrinas y la
  IA construyendo/entrenando; sin errores. Corrección: el río pasaba a ser
  vertical para no partir las bases.

## 2026-06-27 — PR #6: gráficos con sprites (Ideogram)
- Creado **`assets/ART.md`**: línea gráfica (8-bit, vista cenital) + lista
  completa de sprites y animaciones.
- Generadas con Ideogram 6 hojas de sprites (recursos, militares, aldeano+héroes
  y 3 de edificios), descargadas, **recortadas por cuadrícula**, con **fondo
  magenta quitado** (familia magenta) y auto-ajustadas → 24 PNG en
  `assets/sprites/`. Hojas fuente en `assets/_raw/`.
- **Loop de verificación**: revisión visual en rejilla; se regeneró la hoja de
  economía (había salido en fondo blanco/pictórico) para unificar el estilo.
- Integración en el motor: `loadSprites`, `spr`, `drawSprite`, `drawShadow`;
  `drawResource/drawBuilding/drawUnit` ahora dibujan sprite con anillo de bando
  y sombra, con **respaldo de emoji**. Barras de vida e insignias reubicadas.
- Pantalla **«Prueba gráfica»** en el menú (`openGfxTest`): muestra los 24
  sprites y marca los que no cargan (verificado 24/24, 0 fallidos, sin errores).
- Documentación actualizada (`CLAUDE.md`, `filemap.md`, `progress.md`,
  `assets/ART.md`).

## 2026-06-27 — PR #7: terreno, selección, reparar, murallas, arquero c.a.c.
- **Sprites de terreno** (Ideogram): pasto/agua/roca/tierra (tiles) + montaña,
  muralla, torre de muralla y puerta. Suelo con textura por `createPattern`
  (`getPattern`/`fillPattern`); río con agua y riscos con roca + `obj_mountain`.
  32 sprites en total.
- **Selección mejorada**: se quitó el anillo bajo los edificios (parecía sombra);
  ahora hay sombra neutra + bandera de bando, corchetes/anillo dorado animado
  (`drawSelBox`/`drawSelRing`) y efecto de selección/deselección (`pings`).
- **Reparar edificios**: tocar un edificio propio dañado con aldeanos lo repara
  gastando parte del coste (rama de `build` ampliada a construir/reparar).
- **Murallas**: herramienta de dos toques (`wallTap`/`wallPoints`), coste en
  piedra por tramo, **Torres de Muralla** cada N que disparan (arqueros
  protegidos), y colisión que bloquea a unidades rivales (`frameWalls`/
  `blockedByWall`).
- **Arquero c.a.c.**: daño a la mitad si el enemigo lo alcanza de cerca.
- Verificado en Chromium headless: 32/32 sprites, murallas (vertical/horizontal),
  reparación (hp 360→393), penalización del arquero (10→5), sin errores.

## 2026-06-27 — PR #7 (cont.): producción finita, tasa desde edificios, terreno claro, murallas H/V
- **Nivel de producción**: ahora cuenta a los aldeanos que recolectan de
  edificios de producción (antes salía 0/s). Corregido en `updateTopbar`.
- **Capacidad finita (500)**: granja/mina de oro/mina de piedra tienen `reserve`
  de 500; al agotarse se marcan «agotada» y hay que **recargarlas reparando**
  (cuesta el coste de construcción). `bldHasReserve`, gather decrementa reserva,
  rama de `build` añade la recarga; el panel muestra la reserva.
- **Terreno más claro**: se regeneraron los tiles (pasto/agua/roca/tierra) en
  tonos claros para que las unidades contrasten y se distingan mejor.
- **Murallas horizontal y vertical**: sprites `bld_wall_h`/`bld_wall_v` elegidos
  según la orientación de la línea (`b.dir`). 34 sprites en total.
- Verificado: tasa desde granja (+0.7/s), recarga 0→500 gastando 60 de madera,
  murallas en ambas orientaciones, sin errores.

## 2026-07-02 — PR #8: multijugador P2P en tiempo real + app iOS
- **Multijugador P2P**: anfitrión autoritativo (simula todo, IA desactivada) y
  cliente que renderiza instantáneas (~7/s) y envía comandos; bandos invertidos
  en el cable para reutilizar toda la UI sin refactor. Menú «📶 Multijugador»
  (crear partida / unirse por IP). Protocolo y detalles en `iOS.md`.
- **Relé WebSocket** (puerto 8765): `server.js` en Node (sin dependencias, con
  handshake y framing RFC 6455 a mano) para escritorio/pruebas.
- **App iOS (iPad)** en `ios/`: proyecto Xcode con WKWebView que empaqueta
  `index.html` + `assets/` por referencia, `RelayServer.swift`
  (Network.framework) como relé nativo del anfitrión, IP local inyectada como
  `window.__NATIVE_IP`, permisos de red local en `Info.plist`.
- **Sombras de edificios eliminadas** (desentonaban con los sprites).
- Documentación: nuevo **`iOS.md`**; actualizados `CLAUDE.md`, `filemap.md`,
  `README.md`.
- Verificado de punta a punta con el relé Node y dos Chromium headless:
  conexión (74 entidades en ambos), entrenar desde el cliente (cola y recursos
  del anfitrión + reflejo en la instantánea), orden de recolección vía UI real,
  victoria/derrota sincronizada; sin errores de consola en ninguno de los dos
  lados. Regresión de un jugador OK. El proyecto Xcode no se pudo compilar aquí
  (entorno Linux); estructura estándar documentada en `iOS.md`.

## 2026-07-02 — PR #9: optimización, pulido iOS y despliegue en Vercel
- **Rendimiento**: índice `id→entidad` O(1) (`_byId`/`rebuildIndex`/`find`) y
  **culling** de entidades fuera de pantalla en `render` (antes ordenaba y
  dibujaba todas). Estrés con ~122 entidades: sin errores, fluido.
- **iOS/PWA**: `manifest.webmanifest`, `apple-touch-icon`/favicon (icono del
  castillo generado), `theme-color`, meta de app web; inputs a 16px (sin
  auto-zoom), `-webkit-touch-callout`/tap-highlight off, panel de acciones con
  scroll (`max-height`/`pan-y`), listeners de `orientationchange`/`visualViewport`.
- **Vercel**: `vercel.json` (sitio estático, caché de sprites) y `.vercelignore`
  (excluye `ios/`, `server.js`, `assets/_raw/`, `.md`). Deploy de `main` sin build.
- **Guarda de contenido mixto**: el multijugador `ws://` avisa que no funciona
  desde `https://` (Vercel); sí en la app iOS (file://) o por http/localhost.
- **Sombras de edificios**: confirmadas eliminadas.
- Verificado en Chromium (viewport iPad): un jugador y multijugador sin errores
  de consola; captura a 1024×768.

## 2026-07-06 — PLAN.md: revisión integral y hoja de ruta por fases
- Revisión de dirección de juego del proyecto completo (~2.370 líneas, 124
  funciones, 34 sprites): fortalezas y las 8 brechas que impiden que "se sienta
  AoE", priorizadas por impacto.
- Nuevo **`PLAN.md`**: principios de diseño no negociables, «Reglas del
  ejecutor» para que Sonnet/Opus desarrollen cada fase de forma autónoma
  (una fase = un PR, con pruebas headless y actualización de docs), y 8 fases
  detalladas con alcance, anclas al código y criterios de aceptación:
  F1 animación+proyectiles+sonido · F2 niebla de guerra+minimapa+alertas ·
  F3 grupos de control+ataque-mover+cámara · F4 pathfinding A*+formaciones+
  puertas · F5 líneas de mejora+catapulta+guarnición+mercado+balance ·
  F6 guardar/cargar+ajustes+tutorial · F7 multijugador web (WebRTC/PeerJS,
  retomando el transporte abstraído) · F8 atlas+rendimiento+QA final.
- Enlazado desde `CLAUDE.md`, `README.md` y `filemap.md`.
- El trabajo de WebRTC iniciado en la sesión anterior queda formalizado como
  Fase 7 (el protocolo host-autoritativo actual no cambia; solo el transporte).
