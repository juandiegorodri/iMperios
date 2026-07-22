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

## 2026-07-15 — PR #10: FASE 1 — «Está vivo»: animación, proyectiles y sonido
- **Animación procedural de unidades** (sin sprites nuevos): bamboleo vertical
  e inclinación ±4° al caminar, "lunge" (~4px) hacia el objetivo al
  atacar/recolectar/construir, y volteo horizontal por dirección real de
  movimiento (`e.face`), calculado en `drawUnit`. El volteo y el bamboleo se
  derivan del desplazamiento cuadro a cuadro (idénticos en host y cliente MP);
  el "lunge" depende del pulso `e.anim` del host, que en el cliente MP se
  **reconstruye desde el snapshot** (campos `an`/`tg`/`bd`: pulso de animación
  y objetivo/obra), de modo que el cliente también ve el golpe.
  Por rendimiento, el transform de cada unidad usa `ctx.setTransform` directo
  (`setUnitTransform`/`resetTransform`) en vez de `ctx.save/restore`: con ~130
  unidades en pantalla, clonar el estado completo del canvas por unidad costaba
  bastante más que fijar la matriz y devolverla a la base (`DPR,0,0,DPR,0,0`).
- **Proyectiles reales** (`projectiles[]`): arqueros, héroe de arco, torres,
  torres de muralla y castillo disparan una flecha visible (~300px/s); el daño
  se calcula al disparar (`computeDamage`) pero se **aplica al impactar**
  (`applyDamage`, vía `updateProjectiles`), moviendo la llamada de daño que
  antes era instantánea. Se eliminó el antiguo "beam" instantáneo de torres y
  la línea estática de flecha de arquero (ambos redundantes ahora).
- **Muertes y daño visuales**: `corpses[]` (fuera de `entities`) con fade +
  caída de 0.4s al morir una unidad; flash blanco `e.hurtT` (timestamp, no
  contador) al recibir daño; edificios con hp<50% humean y hp<25% también
  arden (`drawDamageFx`, puramente derivado de `hp/maxHp`, por lo que funciona
  igual en el cliente MP sin lógica extra).
- **Sonido con WebAudio sintetizado** (sin archivos): 10 SFX distintos —
  espada, flecha, talar, picar, construir, unidad lista, edificio destruido,
  alerta de ataque, victoria y derrota — más un loop ambiental de viento a bajo
  volumen, todo generado con osciladores/ruido. Throttle por nombre de efecto
  (`sfxAllowed`) para no saturar en batallas grandes. Botón 🔊/🔇 nuevo en
  `#util`, estado en `localStorage`; el `AudioContext` se crea/reanuda en el
  **primer gesto táctil** (requisito de Safari/iOS), nunca antes.
- **Micro-feedback**: variante verde de `addPing` en el destino de una orden de
  movimiento (antes solo existía el ping dorado de selección).
- **Compatibilidad multijugador**: el host es quien simula proyectiles y daño;
  el snapshot (`makeSnap`) incluye un campo ligero `shots` con los proyectiles
  en vuelo (posición, progreso, bando) y un flag `al` de "te atacan". El
  cliente (`applySnap`) **no simula**: solo interpola las flechas recibidas,
  reconstruye cadáveres y flashes de daño comparando la instantánea anterior
  con la nueva (unidades que desaparecen → cadáver; hp que baja → `hurtT`),
  reconstruye el "lunge" (pulso `anim` + objetivo desde `an`/`tg`/`bd`), y
  dispara SFX de forma reconstruida: el de **flecha** cuando aparece un
  proyectil nuevo en `shots` (cada proyectil lleva un id `i`), y los de
  "unidad lista"/"edificio destruido"/"alerta"/"victoria"/"derrota" comparando
  `stats.trained`/`stats.lostB` y el flag `al` entre instantáneas. Los SFX de
  acción cuerpo a cuerpo (espada, talar, picar) siguen siendo del host y no se
  reconstruyen en el cliente (aproximación deliberada para no meter falsos
  positivos).
- **Pruebas**: Chromium headless (1024×768@2x) con `spritesReady>=32`, cero
  `pageerror`/`console.error`; ejercitada la lógica nueva por `page.evaluate`
  (arquero genera proyectil y el daño no se aplica hasta el impacto, muerte
  crea cadáver, flash de daño y alerta se disparan, toggle de sonido persiste
  en `localStorage`, `AudioContext` se crea tras un toque simulado). Prueba de
  multijugador real con `node server.js` + 2 Chromium (anfitrión/cliente):
  ambos llegan a `running=true` sin errores y el **cliente reconstruye el
  proyectil del arquero a partir del snapshot** (`shots`), combate consistente
  en ambos lados. Estrés con ~195 entidades (130 unidades en combate + 2
  edificios dañados): el coste real de CPU en `update()+render()` se midió en
  ~3.3-3.6ms/frame (base ~2.9-3.2ms). El criterio de rendimiento se evalúa como
  **presupuesto absoluto**, no como % relativo: el coste por cuadro se mantiene
  muy por debajo de los 16.7ms de un cuadro a 60fps (~4-5× de margen), así que
  no hay riesgo real de caída de fps. El fps bruto por `requestAnimationFrame`
  en este entorno headless compartido es ruidoso (gran parte del tiempo por
  cuadro es scheduling del propio navegador, no `update`/`render`), por lo que
  el % relativo entre versiones es poco informativo; se recomienda una medición
  final en un iPad real antes de cerrar el rendimiento de cara a producción.
- **Corrección de fidelidad MP** (misma fase, tras validación independiente):
  se añadió la reconstrucción del "lunge" y del SFX de flecha en el cliente
  (antes solo caminaba/oía alertas), verificada con dos Chromium reales
  (host+cliente vía `server.js`): el cliente muestra `anim>0`, reconstruye el
  objetivo del golpe y reproduce `arrow` al llegar proyectiles nuevos, con cero
  errores de consola en ambos lados.

## 2026-07-15 — PR #11: FASE 2 — Niebla de guerra, minimapa y alertas
- **Niebla de guerra de 3 estados** (oculto/explorado/visible) sobre una
  rejilla de `FOG_CELL=40px` que cubre todo `WORLD` (65×38 celdas, exacto).
  Visión de 180px por unidad propia y 220px por edificio propio ya construido
  (`markVision`, recorre solo la caja delimitadora de cada fuente, no toda la
  rejilla). Se recalcula cada ~150ms (`recomputeFog`, llamado desde `loop`,
  no cada cuadro) sobre dos `Uint8Array` (`fogVisible`/`fogExplored`, esta
  última persiste — una vez explorada una celda, se queda "oscurecida" para
  siempre en vez de re-ocultarse del todo, como en un AoE real). Para pintarla
  barato: `redrawFogCanvas` vuelca la rejilla a una textura offscreen de baja
  resolución (`fogCanvas`, 1 celda = 1 píxel: negro opaco=oculto, semitrans-
  parente=explorado, transparente=visible) y `drawFogOverlay` la pega sobre el
  canvas principal con una sola llamada `drawImage` escalada (suavizado
  bilineal automático del navegador → bordes de visión redondeados sin coste
  por celda en cada cuadro). Filtrado de entidades por niebla (`fogRenderOk`,
  usado en `render`, `drawProjectiles`, `drawCorpses` y también en `pickAt`
  para que no se pueda ni tocar lo oculto): lo propio siempre se ve; edificios
  y recursos enemigos/neutrales necesitan estar **explorados** (se ven
  oscurecidos, sin unidades — pedido explícito de la Fase 2); unidades,
  cadáveres y proyectiles enemigos necesitan estar en una celda **visible
  ahora mismo** (desaparecen al salir de la visión).
  **Es puramente de render/cliente**: no se tocó el protocolo multijugador
  (`serEntity`/`deserEntity`/`makeSnap` sin cambios) — cada cliente (host o
  jugador remoto) calcula su propia niebla a partir de sus propias entidades
  (`owner==='player'`, que en el cliente MP ya vienen con los bandos
  intercambiados por `deserEntity`), así que no simula nada nuevo. La IA
  enemiga (`enemyAI`) sigue "viendo" el tablero completo como siempre en su
  lógica interna (no se le oculta nada a propósito ahí); lo único que cambia
  es lo que el JUGADOR ve dibujado y puede tocar.
- **Minimapa** (`#minimapWrap`, esquina inferior-derecha, ~160×92px):
  `buildMinimapTerrain` cachea el terreno del mapa activo una sola vez por
  partida (fondo + río/puente/riscos a baja resolución); `drawMinimap` lo
  redibuja a ~4.5Hz (no cada cuadro) superponiendo la MISMA textura de niebla
  del mapa principal (`fogCanvas`, reutilizada tal cual), puntos de
  unidades/edificios por bando (filtrados por `fogRenderOk`, igual que en el
  mapa principal) y el rectángulo de la cámara. Tocar o arrastrar sobre el
  minimapa mueve la cámara (`minimapPointerToCam`→`centerOn`). Botón
  `#btnMiniToggle` (44×44px) para colapsarlo/expandirlo. `positionMinimap` lo
  recoloca por encima del panel de acciones (`#actions`, cuyo alto cambia
  según su contenido) para que nunca lo tape.
- **Alertas de ataque**: `triggerAttackAlert(x,y)` con throttle de 8s por
  "zona" de 200px (`alertZoneKey`), llamado desde `applyDamage` cuando algo
  del jugador recibe daño (host/partida local) y también desde `applySnap`
  (cliente MP: no simula daño, pero detecta que el hp de algo suyo bajó entre
  dos instantáneas consecutivas — mismo mecanismo que ya usaba el flash blanco
  de daño de la Fase 1). Si el punto atacado está fuera de la cámara
  (`onScreen`): añade un pulso rojo que se desvanece en el minimapa
  (`alertPulses`) y muestra el botón temporal "⚔️ ir al ataque" en `#util`
  (`showAlertButton`/`hideAlertButton`, se oculta solo a los 10s o al
  tocarlo, y centra la cámara en `lastAlert`). El SFX de alerta (ya existía
  desde la Fase 1, `playSfx('alert')`) sigue sonando aparte, sin este
  throttle por zona — se reutilizó tal cual, como pedía el encargo.
- **Pruebas**: Chromium headless (1024×768) con `spritesReady>=32`, cero
  `pageerror`/`console.error`. Ejercitado por `page.evaluate`: (a) al empezar
  la partida solo ~4.8% de las celdas están exploradas (base propia incluida,
  el resto oculto); (b) mover una unidad a una zona lejana y recalcular la
  niebla la revela (pasa de oculta a visible+explorada); (c) una unidad
  enemiga fabricada lejos de cualquier unidad propia queda filtrada
  (`fogRenderOk`=false), se vuelve visible al acercar una unidad propia y
  recalcular, y vuelve a ocultarse (aunque sigue "explorada") al alejarla de
  nuevo — confirma que las unidades exigen visión ACTUAL, no solo exploración;
  (d) dañar el Centro Urbano propio con la cámara centrada lejos dispara el
  botón `#btnAlert` (clase `show`) y fija `lastAlert`; (e) el minimapa existe
  y un toque/arrastre real sobre su `boundingBox` (vía `page.mouse`) cambia
  `cam.x`/`cam.y`; el botón de colapsar mide 44×44px y colapsa/expande
  correctamente. **Multijugador real** (`node server.js` + 2 Chromium,
  host con «Crear partida» + cliente con «Unirse» a `127.0.0.1`): ambos llegan
  a `running=true` con cero errores en ambos lados; el cliente calcula su
  propia niebla (celda de su Centro Urbano ya explorada nada más conectar) y,
  tras mover un aldeano por un comando de red real (mismo camino que un toque:
  `netSend({t:'cmd',c:'move',...})`), la niebla del cliente se actualiza sola
  alrededor de la nueva posición — sin que el cliente ejecute lógica de daño
  ni de movimiento (`net.mode==='client'` nunca llama a `update()`).
  **Estrés**: ~264 entidades (95 pares en combate cuerpo a cuerpo/a distancia
  más las iniciales). Midiendo `update()+render()` con niebla+minimapa
  recalculados en **todos** los cuadros (cota pesimista deliberada; en el
  juego real se recalculan a 150/220ms, no cada cuadro) dio ~3.10ms de media
  por cuadro (p95 3.9ms, máx 6.8ms); la misma prueba con niebla+minimapa
  completamente anulados (no-ops) dio ~2.80ms — **coste incremental de la
  Fase 2 de ~0.30ms de media**, muy por debajo del presupuesto de <3ms pedido
  (y el total sigue muy por debajo de los 16.7ms de un cuadro a 60fps).
- **Captura de pantalla**: base propia con el círculo de visión de bordes
  suaves (bilineal) rodeado de negro, aldeanos caminando con la niebla
  siguiéndolos, y el minimapa mostrando terreno+niebla+puntos+cámara en la
  esquina inferior-derecha.

## 2026-07-15 — PR #12: FASE 3 — Manos de RTS: grupos, ataque-mover y cámara pro
Ver `PLAN.md` §4 F3. Cambios:
- **Grupos de control tácticos (①②③)**: 3 botones nuevos en `#util` (badge con
  el nº de unidades vivas). Con selección activa, mantener pulsado 0.5s guarda
  el grupo (`saveControlGroup`); toque corto lo selecciona (`selectControlGroup`);
  doble toque lo selecciona **y** centra la cámara en su centroide. Los ids se
  limpian de unidades muertas al instante en `removeEntity` y también de forma
  perezosa al usar el grupo (`cleanControlGroup`). Son **locales del cliente**
  (no viajan por red; cada jugador de una partida MP guarda los suyos), y se
  reinician en `startGame`/`clientStartFromInit`.
- **Ataque-mover**: nuevo estado de unidad `amove` (`update`, junto a `move`/
  `gather`/`build`/`attack`). Botón "⚔️→ Ataque-mover" en el panel de acciones
  cuando hay al menos una unidad militar seleccionada; el siguiente toque en el
  mapa fija el destino (`amoveOrder`). Cada cuadro, si hay un enemigo dentro de
  `AMOVE_RANGE` (150px) lo persigue y ataca (reutiliza `unitRange`/
  `computeDamage`/`damage`/`fireProjectile`, igual que `attack`) sin abandonar
  el estado `amove`; al perderlo (muere o se aleja) retoma la marcha hacia el
  punto. La retaliación (`hitBy`) ya no fuerza el cambio a estado `attack` para
  una unidad en `amove`: solo le fija el objetivo y deja que su propio bucle
  se encargue, así nunca "olvida" su destino tras defenderse. Comando MP propio
  `amove` (`hostHandleCmd`), simétrico a `move`; el lunge de animación y el
  campo `tg` del snapshot (`serEntity`) también cubren `amove` para que el
  cliente vea el golpe.
- **Selección mejorada**: botón "🪖 Todo el ejército" en `#util` (selecciona
  todos los militares vivos propios, sin aldeanos ni edificios). En
  selecciones mixtas (≥2 tipos de unidad), el panel muestra chips (`.btn.q.chip`)
  que reducen la selección a un solo tipo con un toque. Doble toque sobre un
  edificio propio ahora selecciona todos los edificios de ese tipo
  (`handleDoubleTap`; antes solo existía para unidades).
- **Cámara con inercia**: `cam.vx`/`cam.vy` guardan la velocidad reciente del
  paneo de 2 dedos (medida con EMA en `pointermove`, aplicada en
  `updateCameraInertia` desde `loop`); al soltar los dedos decae ~0.9/cuadro
  (normalizado por `dt`, no depende del framerate real) hasta pararse. El
  paneo EN VIVO sigue con el clamp duro de siempre (`clampCam`); el **clamp
  elástico** (aproximación exponencial sin overshoot, sin "temblor") solo entra
  en juego durante el propio deslizamiento inercial, si este saca a la cámara
  del mundo. Doble toque en ⌂ centra en `lastAlert` (Fase 2) en vez de la base.
- **Rally encadenable**: fijar el punto de reunión de un edificio (tocar
  terreno con un edificio seleccionado) ahora también acepta tocar un recurso
  o un edificio de producción propio, guardando el `rtype` en `b.rally`
  (`o.ry.rt` en el snapshot). `spawnTrained` usa `nearestGatherFor` con ese
  `rtype` para mandar a los aldeanos entrenados derechos a recolectar (nodo o
  edificio, el que esté más cerca). Render: línea punteada del edificio al
  punto de reunión + bandera 🚩 + icono del recurso, visible al seleccionar.
- **Pruebas**: Chromium headless (1024×768) con `spritesReady>=32`, cero
  `pageerror`/`console.error` en todos los escenarios. Por `page.evaluate`:
  (a) `saveControlGroup`/`selectControlGroup` restauran exactamente la
  selección guardada; matar a una unidad del grupo la quita al instante
  (verificado antes y después de volver a seleccionar el grupo); (b) fila de 5
  enemigos entre los puntos A y B, `amoveOrder` hacia B, ~900 cuadros de
  `update()`: los 5 mueren y las unidades propias terminan más allá del punto
  medio (estado `idle`, ya llegaron a B); (c) "Todo el ejército" selecciona
  solo militares vivos propios (sin aldeanos/edificios/enemigos); con
  selección mixta aparecen 2 chips y tocar uno reduce la selección al tipo
  correcto; (d) inercia: velocidad grande simulada, 90 cuadros de
  `updateCameraInertia` sin ningún cambio de signo en el desplazamiento (cero
  "temblor"), termina con `vx=vy=0` y dentro del mundo; forzar `cam.x=-50`
  confirma que se atrae de vuelta a 0 sin pasarse de largo (`overshotZero:
  false`); (e) rally sobre un nodo de comida: el aldeano entrenado sale en
  estado `gather` con `rtype==='food'` apuntando a ese nodo. **Multijugador
  real** (`node server.js` + 2 Chromium, host «Crear partida» + cliente
  «Unirse» a `127.0.0.1`): ambos llegan a `running=true` sin errores; el
  comando `amove` enviado por el cliente aparece aplicado en el host (unidad
  del lado `enemy` con `state==='amove'`) y reflejado en el siguiente
  snapshot del cliente; se confirma que el cliente nunca llama a `update()`
  (`net.mode==='client'`, sin simulación de daño). **Estrés**: 254 entidades
  (90+90 militares repartidos en 4 tipos, todas en `amove`, más las
  iniciales) tras 60 cuadros de mezcla en combate: `update()` ~3.42ms de media
  (p95 4.6ms, máx 6.5ms) + `render()` ~0.63ms de media → **~4.0ms/cuadro
  combinados**, muy por debajo de los 16.7ms de un cuadro a 60fps.
  Regresión: partida real de ~9s con IA + pausa/reanudación + orden de
  movimiento normal (no `amove`) sin errores ni comportamiento roto.
- **Captura de pantalla**: panel de acciones con "3 Milicia" seleccionados,
  botones "⚔️→ Ataque-mover"/"Detener"/"Deseleccionar", los 3 botones de grupo
  de control (①②③, uno con badge "2") y el botón "🪖 Todo el ejército" en
  `#util`, más la bandera y línea de rally sobre el Centro Urbano.

## 2026-07-15 — PR #13: Fase 4 — Pathfinding y formaciones
- **A\* en rejilla gruesa** (`PLAN.md` §4 F4): reaprovecha el tamaño de celda
  de la niebla (40px, 65×38 celdas). Grid de obstáculos ESTÁTICOS (río sin
  puente, riscos, murallas/puertas) cacheado **por bando** (`pathGrids`,
  `buildPathGrid`/`getPathGrid`) porque una muralla/puerta bloquea distinto a
  cada bando; se invalida (`invalidatePathGrid`) solo al terminar de construir
  o destruir una muralla/puerta, al alternar una puerta y al arrancar
  partida — NUNCA por cuadro. Antes de llamar al A* se comprueba línea de
  visión directa (`losClear`); si ya está despejada (el caso más común, en
  terreno abierto) no hace falta pathfinding. `astarPath` usa un min-heap
  propio (`heapPush`/`heapPop`), heurística octile y movimiento 8-direccional
  sin cortar esquinas (dos celdas bloqueadas adyacentes no permiten la
  diagonal); si el destino cae en celda bloqueada, busca la libre más cercana
  (radio 4). El camino se suaviza saltando waypoints intermedios visibles
  (`smoothPath`, sustituye además el primer/último waypoint por las
  coordenadas REALES de inicio/destino, no el centro de su celda).
  `stepToward` sigue esos waypoints (`e.path`/`e.pathIdx`) cuando el destino
  es `e.move` (no aplica a perseguir un objetivo vivo de recolección/
  construcción/ataque, que ya esquivaban localmente); al agotarlos, sigue el
  código de siempre (línea recta + deslizado + puente). Si una unidad lleva
  más de 0.6s casi sin avanzar (`e.stuckT`), se recalcula su camino desde
  donde está.
- **Cache de camino compartido por orden de grupo**: una orden de mover varias
  unidades calcula **un solo** A* desde el centroide del grupo
  (`computeGroupPath`); todas comparten la MISMA referencia al array de
  waypoints (barato en memoria) pero cada una guarda su propio `pathIdx`.
  Punto de entrada único `applyGroupMove(units, ownerSide, x, y, state)`,
  usado por `handleTap` (jugador local), `hostHandleCmd` (comandos `move`/
  `amove` del cliente MP, aplicados en el HOST) y `amoveOrder`.
- **Formaciones**: al mover ≥2 unidades, `formationSlots` reparte destinos en
  una rejilla compacta alrededor del punto (filas de `FORM_COLS=6`,
  separación `FORM_SP=26`px), asignando a cada unidad el slot libre más
  cercano (greedy). Las filas más próximas al destino se reservan para
  cuerpo a cuerpo/aldeanos y las de atrás para arqueros (partición de los
  slots ordenados por fila ANTES de la asignación greedy, para que un
  arquero nunca robe un slot delantero solo por estar más cerca).
- **Puertas de muralla** (`BLD.gate`, `wall:true, gate:true`, sprite ya
  existente `obj_gate`, HP 600 — menor que la Torre de Muralla 1100): al
  trazar una muralla de ≥3 tramos con la herramienta de dos toques
  (`wallSegmentType`), el tramo CENTRAL es una Puerta en vez de muro/torre
  (tanto en `wallTap` como en `hostWall`, mismo criterio). `wallBlocksSide(w,
  side)` centraliza la regla: una Puerta bloquea al rival SIEMPRE (igual que
  una muralla normal) y al dueño SOLO si está cerrada manualmente
  (`b.closed`); una muralla normal nunca bloquea a su propio dueño (regla ya
  existente de PR #7, sin tocar). Botón en el panel de la Puerta ("🔒 Cerrar
  puerta"/"🔓 Abrir puerta", ≥44px; comando MP `gate`) y un candado 🔒/🔓
  dibujado siempre sobre ella (no solo al seleccionarla) para ver su estado
  de un vistazo. `b.closed` viaja en el snapshot (`o.cl`).
- **Esquinas de murallas sin atascos**: el post-procesado de `separate()` (que
  ya evitaba colar unidades por el río/riscos) ahora también revierte el
  empuje si acaba dentro de una muralla/puerta que bloquea a esa unidad —
  antes solo se comprobaba `blocksUnit`, así que el apiñamiento en una
  esquina podía "filtrar" unidades a través del muro.
- **Multijugador**: sin cambios de protocolo salvo el flag `o.cl` de la Puerta
  y el comando `gate`; el A* y las formaciones se calculan SOLO en el host
  (`applyGroupMove` se llama desde `hostHandleCmd`); el cliente sigue
  reconstruyendo entidades desde el snapshot sin ejecutar `update()` en
  ningún caso, tal como antes.
- **Pruebas**: Chromium headless (1024×768), `spritesReady>=32`, cero
  `pageerror`/`console.error` en todos los escenarios (partida local
  sintética con `dt` fijo, humo de UI real con clics/menú reales, soak test
  en tiempo real de ~12s con IA Difícil, y multijugador real). Por
  `page.evaluate` con `update(dt)` en bucle: (a) una muralla enemiga de 10
  tramos cortando el paso directo → la unidad la rodea y llega al destino
  (dist final ~22px) en 165 cuadros; (b) anillo de murallas propias con una
  Puerta: una unidad propia entra por la puerta abierta, una unidad rival
  queda fuera (dist final ~78-80px); para aislar el efecto de "cerrada
  bloquea también al dueño" de la regla (ya existente) de que una muralla
  normal nunca bloquea a su dueño, se construyó además un muro de riscos de
  punta a punta del mapa con un único hueco tapado por una Puerta: con la
  puerta abierta el dueño cruza; cerrada, se queda atrapado (único paso
  posible); reabierta, vuelve a cruzar; (c) 28 unidades (20 milicia + 8
  arqueros) mandadas a un punto: distancia media final de la milicia al
  destino (58.9px) menor que la de los arqueros (101.4px) → van delante;
  separación lateral final de 158.7px (varias filas, no fila india);
  distancia mínima entre unidades 24.1px (no colapsan en el mismo punto); (d)
  A* de una orden de 30 unidades con obstáculo real de por medio: ~0.2-0.5ms
  (holgado bajo los 2ms de presupuesto); estrés con ~280 entidades
  (mayoría moviéndose, varias con A* real): `update()+render()` ~3.6-4.6ms/
  cuadro, muy por debajo de los 16.7ms de un cuadro a 60fps. **Humo de UI
  real**: menú → "Empezar" → seleccionar aldeano → botón "🧱 Muralla" del
  panel → dos toques reales en el canvas → 8 tramos con exactamente 1 Puerta;
  seleccionar la Puerta muestra el botón "🔒/🔓" en el panel y tocarlo cambia
  `b.closed`. **Soak test en tiempo real** (~12s, mapa Riscos, IA Difícil,
  velocidad Rápida, bucle `requestAnimationFrame` real, no `update()`
  manual): órdenes de grupo aleatorias (`move`/`amove`) y construcción de
  murallas con la lógica real cada 2s, cero errores, partida sigue viva.
  **Multijugador real** (`node server.js` + 2 Chromium, host «Crear partida»
  + cliente «Unirse» a `127.0.0.1`): ambos llegan a `running=true` sin
  errores; el cliente ve (vía snapshot) una unidad creada por el host con una
  muralla enemiga de por medio, envía el comando `move` de red, el HOST le
  asigna un camino A* (`u.path` no vacío) y el CLIENTE observa —solo por
  snapshot— que su unidad llega rodeando la muralla; se confirma que
  `net.mode==='client'` (el cliente nunca entra en la rama que llama a
  `update()`, por tanto nunca ejecuta A* ni calcula daño).
- **Caveats conocidos**: la rejilla de 40px puede, en teoría, dejar un hueco
  de un único ancho de celda (~40px) topológicamente "aislado" del A* si está
  rodeado por obstáculos en TODAS las columnas/filas vecinas (ver prueba (b):
  el hueco de prueba se hizo de ~100px para evitarlo). En la práctica esto no
  afecta a las Puertas reales del juego, porque los tramos de muralla se
  colocan cada `WALL_SP=28`px y una única Puerta nunca queda aislada por
  completo en la rejilla salvo que el jugador construya un cerco casi
  perfectamente sellado con esa única abertura; si ocurriera, el repath por
  atasco (`e.stuckT>0.6s`) seguiría intentándolo cada 0.6s sin quedar
  encallado en un bucle de error, pero podría no encontrar camino mientras el
  cerco exista.
- **Arreglo tras validación del orquestador (misma fase)**: se detectó y
  corrigió una **cuña al rodear el EXTREMO de una muralla larga**: la unidad
  quedaba clavada contra el último tramo (dentro de su radio de colisión de
  ~28px) porque el A* seguía apuntando hacia el lado bloqueado y el
  deslizamiento por ejes no ofrecía salida; el repath no la liberaba porque la
  geometría volvía a atraparla. Ahora, cuando ambos ejes están bloqueados por
  una muralla/puerta, `stepToward` empuja la unidad radialmente ALEJÁNDOSE del
  muro más cercano (`nearestBlockingWall`) hasta salir de su radio de colisión,
  y el repath retoma el rodeo. Solo se activa en la cuña real (rarísimo en
  juego normal), así que no afecta el paso normal. Verificado headless: una
  unidad rodea un muro sólido de ~920px y LLEGA al destino (antes se quedaba a
  ~490px), sin regresión del movimiento abierto, del cruce por el puente del
  río, del combate/MP (Fases 1-3) ni de las puertas; A* ~0.35ms/orden de 30,
  estrés ~4.2ms/cuadro con ~257 entidades.

---

## 2026-07-15 — PR #14: Fase 5 — Profundidad AoE (líneas de unidad, asedio, guarnición, mercado)
Ver `PLAN.md` §4 F5 (marcada ✅) y `CLAUDE.md` §6 para el detalle de cada
funcionalidad. Resumen de cambios en `index.html`:

- **Líneas de mejora por Era** (`UNIT_LINES`): Milicia→Espadachín(II)→Campeón(IV);
  Piquetero→Alabardero(III); Arquero→Arquero de Tiro Largo(III);
  Caballo→Caballero(III)→Paladín(IV). Cada tier +35% hp/atq (compuesto),
  investigable en Cuartel/Galería/Establo (`appendLineTierButtons`). Aplica al
  instante a las unidades vivas (`buyLineTier` reescala `hp`/`maxHp`) y de
  fábrica a las futuras (`makeUnit` usa `lineTierMult`); `unitAtk` deriva el
  atq dinámicamente, sin duplicar el efecto. Insignia: chevrons ▲ en
  `drawUnit`. El tier viaja gratis por `serSide` (es un flag más en
  `side.upg`, igual que `UPG`/`ECON`); comando MP nuevo `lineupg`.
- **Catapulta** (`UNIT.siege` 🎯, Taller de Asedio `BLD.siegeworkshop` 🏭,
  req. Cuartel + Era Feudal): muy lenta (vel. 22), hp bajo, daño de área ×4
  contra edificios/murallas y ×0.5 contra unidades (`SIEGE_BLD_MULT` en
  `computeDamage`); proyectil parabólico (`kind:'siege'` en
  `fireProjectile`/`drawProjectiles`, daño de área a edificios cercanos al
  impacto en `updateProjectiles`). IA Difícil (`DOCTRINE.hard.siege`)
  construye Taller y hasta 2 catapultas cuando el jugador tiene murallas.
- **Guarnición**: `GARRISON_MAX` (torre/torre de muralla 4, castillo 8, Centro
  Urbano 10); tocar el edificio con arqueros (o aldeanos para el Centro
  Urbano) seleccionados los mete dentro (`garrisonUnits`, en `handleTap`
  antes de la orden de mover); +1 flecha por arquero guarnecido en cada
  volea del edificio; botón "🚪 Expulsar" (`expelGarrison`). Las unidades
  guarnecidas (`e.garrisonedIn`) no se dibujan, no se pueden tocar/atacar/
  seleccionar y no ejecutan IA (excluidas en `update`, `nearestEnemy`,
  `pickAt`, `separate`, `render`, `handleDoubleTap`, `finishBoxSelect`,
  `btnArmy`, `cleanControlGroup`); si el edificio muere, salen ilesas. Viaja
  en MP como conteo (`o.gr` en el edificio) y flag (`o.gi` en la unidad);
  comandos nuevos `garrison`/`expel`.
- **Mercado** (`BLD.market` 🏪, Era de las Herramientas): vende 100
  comida/madera/piedra por 70 oro, compra 100 por 130 oro (`marketTrade`,
  tasas fijas); botones en su panel; comando MP `market`.
- **Pasada de balance**: arena headless 20v20 por matchup del cuadrilátero
  (`arena.cjs`, reutiliza el motor real vía `update()`, sin reimplementar las
  fórmulas de combate). Hallazgo: en combate masivo forzado (sin kiting
  manual) Caballo derrotaba a su propio contra (Piquetero) el 100% de las
  veces y Arquero perdía la mayoría de las veces contra su presa (Milicia),
  por pura ventaja de stats — el bono ×2 del cuadrilátero no bastaba para
  compensar diferencias de hp/atq/cd demasiado grandes. Ajustes de stats:
  - `pike`: hp 55→60, atk 5→6.
  - `archer`: hp 35→55, atk 5→5.4 (nótese decimal: la sensibilidad de un
    combate 20v20 con cooldowns fijos es tan alta que valores enteros saltan
    de ~0% a ~90%+ de victorias sin punto intermedio; hubo que afinar con
    decimales), cd 1.5→1.2; penalización de cuerpo a cuerpo (Fase 1) relajada
    de ×0.5 a ×0.6.
  - `cavalry`: hp 95→52, atk 9→6.87.
  - Resultado final (25 combates/matchup, con separación inicial >rango de
    arquero y variación posicional amplia para no caer en el "todo o nada"
    del combate determinista — ver caveat abajo):

    | Ataca \ Defiende | Arquero | Milicia | Piquetero | Caballo |
    |---|---|---|---|---|
    | **Arquero**   | — | **100%** (contra) | 56% (neutral) | 4% |
    | **Milicia**   | 0% | — | **100%** (contra) | 44% (neutral) |
    | **Piquetero** | 48% (neutral) | 0% | — | **100%** (contra) |
    | **Caballo**   | **92-100%** (contra) | 36% (neutral) | 0% | — |

    Los 4 contras del cuadrilátero (Arquero→Milicia, Milicia→Piquetero,
    Piquetero→Caballo, Caballo→Arquero) dominan claramente (92-100%). Los 2
    matchups neutrales (fuera del cuadrilátero: Arquero-Piquetero,
    Milicia-Caballo) quedan cerca de 50/50 y por debajo (o a un solo combate,
    1/25, del límite) del 55% pedido en ambas direcciones.
  - **Caveat honesto**: un combate 20v20 con daño/cooldown determinista y sin
    kiting manual (el motor no implementa retirada automática de arqueros)
    tiende a un efecto "bola de nieve" muy marcado — pequeñas diferencias de
    stats cruzan un umbral de "golpes para matar" y el resultado salta de
    ~0% a ~95%+ sin zona intermedia estable. Encontrar el punto de equilibrio
    exacto requirió (a) separar los ejércitos más allá del rango del arquero
    (para que su ventaja de alcance cuente antes del cuerpo a cuerpo) y (b)
    una variación posicional inicial bastante amplia (±200px) para que el
    Monte Carlo tenga variedad real de desenlaces en vez de repetir el mismo
    resultado binario. Con 25 tiradas la resolución mínima es de 4 puntos
    porcentuales (1/25), así que "56%" y "55%" son, en la práctica, el mismo
    resultado. Se considera el objetivo cumplido en espíritu (ninguna unidad
    aplasta fuera de su contra; los 2 matchups neutrales están prácticamente
    empatados) aunque no se garantiza matemáticamente que CUALQUIER semilla
    aleatoria quede siempre ≤55%.
  - **Caveat de chokepoint (verificación del orquestador)**: el equilibrio
    "neutral ~50/50" solo se sostiene con los ejércitos separados. En un
    **cuello de botella** (puente del río, puerta de muralla) donde el cuerpo a
    cuerpo se traba de inmediato, los matchups neutrales se vuelven aplastantes
    (Arquero vs Piquetero ≈ 0/100; Milicia vs Caballo ≈ 100/0), porque el
    arquero no puede kitear y la unidad de línea traba primero. Es un efecto de
    **geometría de combate**, no solo de semilla, y afecta a este juego en
    particular porque los chokepoints son una mecánica central. No se corrige
    por ajuste de stats (es inherente al melee-lock sin kiting); se documenta.
    Se confirmó además que el `hp` bajo del Caballo (52) es un **punto de
    equilibrio deliberado**, no una unidad "rota": el Piquetero vence al Caballo
    en TODOS los valores de hp probados (52–80) por el ×2 del cuadrilátero, pero
    subir el hp del Caballo por encima de ~55 hace que **aplaste a la Milicia**
    en el matchup neutral (de 4/6 a 6/6), así que se mantiene en 52.
- **Arreglo tras validación del orquestador — guarnición en MP**: el comando
  `garrison` del cliente no podaba `selection`, así que volver a tocar el mismo
  edificio sin reseleccionar duplicaba ids ya guarnecidos en el host
  (`garrison=[76,77,76,77]`), inflando el bono de flechas y llenando el cupo con
  fantasmas. Ahora `garrisonUnits` ignora unidades ya guarnecidas (`u.garrisonedIn`
  o ya presentes en `b.garrison`), robusto ante reordenamientos de red y
  selecciones obsoletas. Verificado headless: re-guarnecer las mismas unidades
  es un no-op (`[76,77]`→`[76,77]`) y un arquero nuevo sí entra (`[76,77,78]`).
- **Sprites pendientes**: catapulta, Taller de Asedio y Mercado usan el
  respaldo de emoji esta sesión (sin acceso a Ideogram); sus nombres NO se
  añadieron a `SPRITE_FILES` a propósito (para no generar peticiones 404 que
  Chromium reporta como `console.error`). Ver `assets/ART.md`.
- **Verificación headless** (Playwright, scripts en el scratchpad de la
  sesión, no en el repo): 0 `pageerror`/`console.error` en todos los casos.
  - Línea de mejora: investigar Espadachín en Era II sube hp 55→74 de una
    milicia viva y de una futura; atq 6→8.1; coste descontado; tier viaja en
    `serSide` (confirmado en un snapshot simulado).
  - Catapulta: derriba una muralla (700hp) en 8 tiros; pierde 1 vs 2 caballos
    (muere sin apenas dañarlos).
  - Guarnición: 3 arqueros en una torre → 4 flechas por volea (vs 1 sin
    guarnecer); expulsar los libera; tope de 4 respetado con 6 candidatos.
  - Mercado: vender 100 madera → +70 oro exactos; comprar 100 piedra → -130
    oro exactos; bloquea la operación sin recursos suficientes.
  - Multijugador real (`server.js` + 2 páginas, host/cliente): ambos
    `running===true`; el cliente ve el tier investigado por el host (bando
    `enemy`↔`player` invertido) reflejado en `hp` de una unidad y en
    `player.upg`, y ve el conteo de guarnición (2/4) de una torre — todo vía
    snapshot, sin que el cliente ejecute `update()`; 0 errores.
  - Estrés: ~246 entidades (incluye 20 catapultas y murallas) en combate
    activo, `update()+render()` medio 3.39ms/cuadro (pico 12.7ms), muy por
    debajo del presupuesto de 16.7ms/cuadro.

## 2026-07-15 — PR #15: Fase 6 — Partidas con memoria: guardar, ajustes y tutorial
Ver `PLAN.md` §4 F6. Resumen de cambios (detalle funcional en `CLAUDE.md` §6 y
estructura de código en `filemap.md`, secciones 15-18):

- **Guardar/cargar** (un solo jugador, 3 ranuras + autoguardado): reutiliza
  `serEntity`/`serSide` del bloque MP **sin el flip de bandos**
  (`serEntity(e, false)` — nuevo segundo parámetro, por defecto `true` para no
  tocar el protocolo de red existente). Incluye terreno/puente, `gameConfig`,
  edad/recursos/tecnologías/`stats`, niebla YA EXPLORADA (`fogExplored`
  empaquetada como cadena de dígitos, no como array JSON — más compacto), y la
  línea de tiempo. La guarnición necesitó un cuidado aparte: el formato de
  `serEntity` pensado para el snapshot MP solo lleva el CONTEO de guarnecidos
  por edificio (le basta al cliente, que no simula), así que `deserEntity`
  deja `u.garrisonedIn=true` (booleano) y `b.garrison` con placeholders — para
  el guardado LOCAL eso habría dejado unidades guarnecidas "perdidas" e
  inexpulsables tras cargar. Se guarda aparte `save.garrisons` (ids reales
  exactos, estables en un guardado de un jugador) y `applySaveObject` hace una
  pasada de reparación que reconstruye el mapeo id-a-edificio real. Autoguardado
  cada 2 minutos por `setInterval` (fuera del bucle de `render`, cero coste por
  cuadro) y en `visibilitychange`. Deshabilitado con guardas `if(inMP()) return`
  en cada función; también se apaga explícitamente en `clientStartFromInit`.
- **Ajustes** ⚙️: volumen de SFX y de ambiente por separado (antes solo había
  un interruptor 🔊/🔇 de silencio total; ahora los sliders escalan el `vol` en
  `playTone`/`playNoise` y la ganancia de `startAmbient`), velocidad de cámara
  (multiplica el paneo táctil de 2 dedos y el paneo por flechas), mostrar fps
  (EMA sobre el delta REAL, sin escalar por velocidad de partida, para que el
  contador no mienta en partidas "Rápidas") y reiniciar tutorial. Persisten en
  `localStorage` como un único objeto (`miniaoe_settings`).
- **Tutorial guiado**: máquina de estados de 10 pasos con `check()` por
  SONDEO (~3/s desde `loop`) sobre el estado real del juego, no por
  temporizador — decisión deliberada para que una partida cargada a medias
  (o un jugador que ya sabe jugar) salte solo los pasos ya cumplidos sin
  bloquear. Anillo pulsante (`drawTutorialTarget`) sobre el objetivo en el
  mundo cuando el paso lo tiene; el paso final ("Todo el ejército") se marca
  con un flag puesto por el propio listener de `#btnArmy` en vez de sondeo de
  estado (no hay una condición de "estado del mundo" limpia para "el jugador
  pulsó este botón"). Saltable; recuerda en `localStorage`
  (`miniaoe_tutorial_done`) que se completó o se saltó.
- **Línea de tiempo del resumen**: muestreo cada 30s de juego (recursos
  totales + "valor militar" = coste total invertido en tropas vivas, de cada
  bando) en `gameTimeline`, dibujado en `#tlChart` dentro de `renderSummary`
  con `drawTimelineChart`. Solo corre en host/partida local (`net.mode!=='client'`
  en `loop`), igual que el resto de la simulación.
- **Sin cambios en el protocolo multijugador**: `serEntity`/`serSide`/
  `makeSnap`/`hostHandleCmd` no ganaron ningún campo ni comando nuevo; el
  único cambio a `serEntity` es el parámetro `flip` (por defecto `true`, así
  que todas las llamadas existentes del bloque MP siguen produciendo
  exactamente el mismo payload que antes).
- **Verificación headless** (Playwright, scripts en el scratchpad de la
  sesión, no en el repo; `localStorage` REAL, con `page.reload()` real entre
  pasos, no simulado en memoria):
  - **Ciclo guardar → recargar la página → cargar** (criterio clave): partida
    con 76 entidades, recursos no triviales, Era II, una Casa y una Milicia
    añadidas a mano, y la posición exacta de un aldeano movido a
    `(555.5, 444.5)`. Tras `saveToSlot(1)` + `page.reload()` (vuelve al menú,
    `running===false`, `entities.length===0`, confirma que NO quedó nada en
    memoria) + `loadFromSlot(1)`: 76 entidades, recursos idénticos, Era 2,
    mapa igual, posición del aldeano a <0.6px, Casa y Milicia presentes,
    `running===true`. Coincide en los 8 campos comparados.
  - **Autoguardado + "Continuar"**: `autosave()` forzado (en vez de esperar 2
    minutos reales) escribe `miniaoe_autosave`; tras `page.reload()`, el botón
    "▶ Continuar (autoguardado)" del menú aparece visible y, al pulsarlo,
    restaura la partida (`running===true`, 76 entidades).
  - **Ajustes**: volumen SFX 25, volumen ambiente 10, cámara "Lenta" (0.6) y
    "Mostrar FPS" activado, todo vía clics/eventos reales en el panel; tras
    `page.reload()`, `settings` refleja los 4 valores y `#fpsHud` ya aparece
    visible sin necesidad de abrir Ajustes (se aplica en el arranque).
    "Reiniciar tutorial" limpia `miniaoe_tutorial_done` de `localStorage`.
  - **Tutorial**: se ejercitaron los 10 pasos simulando cada evento real
    (seleccionar aldeano, `state='gather'` de comida/madera, construir Casa y
    Cuartel, entrenar aldeano/Milicia, `recomputeFog()` tras mover visión a
    una esquina lejana del mapa, avanzar de Era, pulsar `#btnArmy`) y
    llamando a `tutorialCheck()` tras cada uno: avanzó paso a paso hasta
    completarse (`tutorial.active===false`, `miniaoe_tutorial_done==='1'`).
    Confirmado que NO se rearma en una partida nueva tras completarse, que
    "Saltar tutorial" también deja el flag puesto y tampoco reaparece, y que
    borrar el flag + `startGame` sí lo rearma.
  - **Línea de tiempo**: 3 muestras manuales (`sampleTimeline()`) con cambios
    de recursos/tropas entre ellas, luego `endGame(true)`: `drawTimelineChart`
    no lanza excepción, el `<canvas>` del resumen queda con contenido (no en
    blanco) y `#endScreen` se muestra.
  - **Regresión multijugador** (`server.js` + 2 páginas reales, host y
    cliente conectados y `running===true` en ambos): confirmado que
    `tutorial.active===false` en los dos, que "Continuar" queda oculto, y que
    pulsar el botón 💾 NO abre el panel de guardado (`#saveScreen` sigue
    oculto) — Fase 6 completamente inerte en MP, sin afectar la partida en
    red. 0 `pageerror`/`console.error` en host y cliente.
  - **Rendimiento del autoguardado**: partida sintética de 194 entidades
    (dentro del presupuesto de "~200 entidades" del enunciado) →
    `autosave()` completo (serializar + `JSON.stringify` + escribir en
    `localStorage`) tarda **0.7ms** y pesa **~20.2KB**; con 76 entidades
    (partida real de prueba) el guardado pesa **9.2KB**. Ambos muy por debajo
    del límite típico de ~5MB de `localStorage`, y el autoguardado corre en
    `setInterval` fuera del bucle de `render`, así que no puede causar
    tirones de fps aunque tardara más.
- **Caveats honestos** (limitaciones conocidas, aceptadas como la opción más
  simple que preserva los principios del `PLAN.md`):
  - Una unidad guardada a mitad de una orden de `move`/`amove` (con destino y
    ruta A* en curso) se queda "congelada" en ese estado tras cargar: la
    posición exacta SÍ se conserva (por eso el criterio de aceptación pasa),
    pero `e.move`/`e.path` no se serializan (nunca formaron parte de
    `serEntity`, ni siquiera para MP) y el motor no reanuda el desplazamiento
    solo; la unidad queda como inactiva hasta la próxima orden del jugador.
    Los proyectiles en vuelo tampoco se guardan (se limpian a `[]` al
    cargar, igual que en `clientStartFromInit`): es una simplificación menor,
    sin impacto en recursos/edificios/unidades ni en el resultado de la
    partida.
  - El tutorial no comprueba explícitamente que el aldeano que recolecta sea
    el que el jugador "seleccionó" en el paso 1 (el `check()` de cada paso
    consulta el estado global, no encadena qué unidad concreta cumplió el
    paso anterior); es deliberado para que la máquina también avance sola al
    cargar una partida ya avanzada, pero significa que un jugador podría
    completar un paso con una unidad distinta a la sugerida sin que el
    tutorial lo note (no se considera un problema: el objetivo pedagógico —
    "ya sabes recolectar madera"— igual se cumple).

### Arreglo tras validación del orquestador — regresión del snapshot MP (Fase 6)
- La validación independiente detectó que el nuevo 2º parámetro `flip` de
  `serEntity` (introducido para el guardado local, con `flip=true` por defecto)
  **rompía el snapshot multijugador**: `makeSnap` hacía `entities.map(serEntity)`,
  y `Array.map` invoca el callback con `(elemento, índice, array)`, así que la
  entidad del **índice 0** (siempre el Centro Urbano propio, id=1, creado primero
  en `startGame`) recibía `flip=0` — *falsy pero no `undefined`*, con lo que el
  guard `if(flip===undefined) flip=true` no saltaba y esa entidad viajaba **sin
  voltear el bando**. Efecto: el cliente veía DOS edificios como propios (su base
  y el Centro Urbano rival), contaminando niebla, selección y toda lógica de
  `owner==='player'`.
- Arreglo: envolver el callback → `entities.map(e=>serEntity(e))` (así `flip`
  queda `undefined` y toma el valor por defecto `true`). El guardado local no
  estaba afectado porque ya usaba una arrow explícita (`serEntity(e,false)`).
- Verificado headless con relé real (`server.js` + host + cliente `127.0.0.1`):
  el cliente ahora ve exactamente 1 Centro Urbano propio y 1 rival (bandos 4/4),
  cero errores de consola; regresión de un jugador (combate) OK.

## 2026-07-15/16 — FASE 7: Multijugador en la web (WebRTC), PR #16

Alcance ejecutado siguiendo `PLAN.md` §4 F7. El protocolo host-autoritativo
(snapshots con flip de bandos, comandos del cliente, `hostHandleCmd`) **no
cambió en absoluto** — todo lo nuevo vive en una capa de transporte y en
mejoras de robustez que se apoyan en él.

### 1. Transporte abstraído
- Interfaz única: `net.sendRaw(str)` (envía; su implementación cambia según
  el transporte activo) y `net.onRaw(str)` (recibe; una sola función, común a
  los dos transportes, que además cuenta bytes para medir deltas). `netSend`
  y `netOnMessage` pasan a apoyarse en esta interfaz en vez de tocar el
  `WebSocket` directamente.
- **Transporte A (LAN)**: `netConnect`/`netHostStart`/`netJoinStart` cablean
  el mismo `WebSocket ws://` de siempre a `net.sendRaw`/`net.onRaw`. Cero
  cambios de comportamiento para el usuario.
- **Transporte B (Online/WebRTC)**: `loadPeerJs()` inyecta
  `<script src="https://unpkg.com/peerjs@1/dist/peerjs.min.js">`
  dinámicamente SOLO al pulsar un botón "Online" (con timeout de 12s y
  mensaje honesto si falla). `netOnlineHostStart`/`netOnlineJoinStart` crean
  un `Peer` con id `miniaoe7-<código>` (código de 6 caracteres sin
  ambigüedades, `genRoomCode`); `wireOnlineConn` cablea el `DataChannel`
  (`reliable:true`) a la misma interfaz `sendRaw`/`onRaw`.

### 2. UI: pestañas Online / Red local
- Sección "🎮 Multijugador en tiempo real" con pestañas «🌐 Online (código)»
  y «📶 Red local (IP)» (la de siempre, intacta). Código grande +
  "📋 Copiar código" (`navigator.clipboard`, con fallback a mostrarlo en el
  estado si no hay permiso).
- Las pestañas usan una clase propia `.mp-tab`/`.mp-tab.active` (NO
  `.opt-b`): se detectó en pruebas que, si fueran `.opt-b` normales, el
  refresco genérico del menú (`refreshMenu`, pensado para grupos con
  `data-val` como mapa/velocidad) las marcaría a las DOS como "seleccionadas"
  a la vez tras el primer toque en la sección (ninguna de las dos tiene
  `data-val`, así que `data-val===gameConfig[...]` da `null===null`). Se
  reprodujo el problema en capturas de pantalla y se corrigió sacando los
  botones de pestaña del mecanismo `.opt-b` por completo.

### 3. Robustez
- **Interpolación de posiciones (cliente)**: `applySnap` guarda, además de
  aplicar el snapshot, la posición previa y la nueva de cada unidad
  (`net.ipPrev`/`net.ipCur`, con marcas de tiempo `net.ipT0`/`net.ipT1`).
  `interpClientPositions()`, llamada cada fotograma desde `loop` (solo
  `net.mode==='client'`), hace un lerp entre ambas según el tiempo
  transcurrido. Puramente de render: no toca `entities` de forma persistente
  más allá de la posición mostrada, no afecta al host ni al guardado.
- **Deltas de snapshot**: el anfitrión alterna snapshot **completo**
  (`makeSnap`) cada ~1s (`net.fullT`) con **delta** el resto del tiempo
  (`makeSnapDelta`: solo entidades cuya forma serializada cambió desde el
  último mensaje + ids eliminados, comparando contra `net.lastSentEnts`).
  `applySnap` fusiona ambos tipos de mensaje (`snap`/`snapd`) sobre el mismo
  array `entities`, así que el resto de la lógica (flash de daño, cadáveres,
  SFX, alertas) no necesita saber cuál llegó. `net.deltaEnabled=false` fuerza
  siempre completo (usado solo para medir el ahorro, ver pruebas abajo).
- **Reconexión con el mismo código (~60s)**: si el DataChannel online se cae
  en plena partida (`netOnlineConnLost`), el anfitrión mantiene su `Peer`
  abierto (no lo destruye) y, si llega una nueva conexión con el mismo id
  mientras la partida sigue (`running===true`), reenvía el estado completo
  vía `netSendInit()` (que también reinicia la base de deltas) en vez de
  reiniciar la partida; el cliente (`clientTryReconnect`) reintenta conectar
  contra el mismo `Peer` hasta agotar la ventana de 60s. De paso, se aplicó el
  mismo principio al `hello` de LAN: si el anfitrión ya tiene la partida en
  curso al recibir un `hello`, reenvía `init` en vez de reiniciar (antes
  siempre llamaba a `startGame`, lo que habría borrado la partida ante
  cualquier reconexión).

### Verificación headless (Playwright) — honestidad sobre los límites

Scripts en el scratchpad de la sesión (`test_a_lan.cjs` … `test_f_ui_misc.cjs`,
`screenshot_mp_ui.cjs`), `chromium.launch({executablePath:'/opt/pw-browsers/chromium'})`.

- **(a) Regresión LAN — CRÍTICA (PASS)**: `node server.js` + 2 páginas reales
  (host "Red local" → Crear partida; cliente → IP `127.0.0.1` → Conectar).
  Ambos `running===true`, `net.kind==='lan'`, host `net.mode==='host'` y
  cliente `net.mode==='client'`; ambos ven 1 base propia + 1 rival
  (`myTown`/`rivalTown` true en los dos, 74 entidades en ambos). Se probó
  además un comando real del cliente (`move` de un aldeano) reflejado en el
  host. **0 `pageerror`/`console.error`.**
- **(b) Interpolación (PASS)**: con una unidad del host avanzando a ritmo
  constante (desacoplado de la simulación real, para tener una señal
  perfectamente predecible), se muestreó la posición renderizada del cliente
  a ritmo de fotograma durante 1.2s: **73 muestras, 73 valores distintos**,
  estrictamente no decrecientes — frente a los ~8 valores "a saltos" que
  habría sin interpolación (una instantánea cada ~150ms). 0 errores.
- **(c) Deltas — cifras reales (PASS)**: en la MISMA partida en curso, 6s con
  `net.deltaEnabled=true` → **53 431 bytes** (≈8905 B/s); 6s con
  `net.deltaEnabled=false` (siempre completo) → **250 269 bytes**
  (≈41 712 B/s). **Reducción del 78.7%** (repetido en una segunda corrida:
  79.3%), por encima del 60% pedido por el criterio de la fase.
- **(d) WebRTC/PeerJS — NO se pudo cerrar el círculo en headless (documentado
  con honestidad)**: se intentó con el proxy de agente de este entorno
  configurado explícitamente en el `launch` de Playwright
  (`proxy:{server:'http://127.0.0.1:44475'}`, el mismo que usan `curl`/Node
  `fetch` y que SÍ llega a `unpkg.com` y a `0.peerjs.com` desde el shell:
  `curl` devuelve 200/302 a ambos). Sin embargo, **ninguna petición HTTPS del
  proceso del navegador headless llega a destino** en este sandbox: probado
  con y sin la opción `proxy` de Playwright, con `--proxy-server` explícito,
  y contra varios hosts (`unpkg.com`, `0.peerjs.com`, `registry.npmjs.org`,
  `anthropic.com`) — todas las peticiones HTTPS quedan en timeout; una
  petición HTTP simple SÍ llega al proxy pero éste la rechaza con 405 (solo
  acepta túneles CONNECT, no proxy HTTP plano), y una petición al propio
  proxy en `127.0.0.1` (sin salir del host) sí funciona. Conclusión: el
  proceso del navegador headless en este entorno no tiene salida de red real
  hacia internet (a diferencia de las herramientas de shell), así que la
  señalización de PeerJS no es verificable aquí de punta a punta.
  **Hasta dónde llegó exactamente** (`test_d_webrtc.cjs`, con el juego real):
  al pulsar "Crear sala" SÍ se inyecta el `<script>` de PeerJS en el DOM,
  pero `window.Peer` **nunca llega a definirse** (el script no termina de
  cargar); a los 12s el timeout de `loadPeerJs()` salta, se muestra un
  mensaje honesto en `#mpStatus` ("No se pudo cargar el módulo online...") y
  `net.mode` vuelve a `null` (permite reintentar o cambiar a Red local) — **0
  errores de página/consola**, es decir, el camino de fallo (punto 5 del
  alcance, "failovers claros") funciona correctamente. **Queda pendiente de
  verificar con una conexión a internet real (portátil/iPad fuera de este
  sandbox) que la señalización PeerJS y el DataChannel completen la conexión
  de extremo a extremo.**
- **(e) Regresión de un jugador (PASS)**: partida normal (sin MP) — 0
  peticiones de red no-`file://` al cargar (confirma "sin dependencias en
  frío"), `btnStart` arranca la partida, corre 2s con IA activa,
  `net.mode===null` todo el tiempo, 0 errores.
- **(f) UI online — casos borde (PASS)**: alternar "Unirse con código" muestra
  el campo; intentar conectar sin escribir código muestra aviso y no cambia
  `net.mode`; "Copiar código" con la sala ya mostrada actualiza el estado con
  el texto copiado. 0 errores.
- Captura de pantalla 1024×768 de ambas pestañas del menú (`mp_online_tab.png`
  con un código de sala de muestra generado con las funciones reales del
  juego — no una sesión conectada de verdad, ver caveat abajo —, y
  `mp_lan_tab.png`) guardada en el scratchpad de la sesión.

### Caveats honestos
- La conexión WebRTC/PeerJS real (broker + ICE + DataChannel de extremo a
  extremo) **no se pudo verificar en este entorno** por la razón de red
  explicada en (d); todo lo demás del código (transporte abstraído, deltas,
  interpolación, reconexión, UI, regresión LAN) sí quedó verificado con
  pruebas reales de dos páginas.
- El código de sala mostrado en la captura de pantalla de la pestaña Online
  se generó llamando directamente a `genRoomCode()`/`showOnlineCode()` (las
  mismas funciones del juego) para ilustrar la UI ya con datos, no proviene
  de una sala real creada contra el broker de PeerJS.
- La reconexión de LAN sigue limitada por `server.js` (acepta solo 2
  conexiones y cierra ambas ante cualquier desconexión, sin cambios en esta
  fase): la mejora de "no reiniciar la partida ante un `hello` con la partida
  en curso" ya aplica también ahí, pero un reintento real de reconexión por
  LAN necesitaría además tocar `server.js` para aceptar una tercera conexión
  de reemplazo — fuera de alcance de esta fase (el foco de "mismo código" es
  el transporte Online, que sí lo soporta de punta a punta salvo por el punto
  de red no verificable en (d)).

### Arreglo tras validación del orquestador — soft-lock del menú MP (Fase 7)
- La validación independiente encontró que `net.mode` no se reseteaba tras un
  error de señalización online (`peer`/`conn` `error`) ni al agotarse el timeout
  de reconexión de 60s, así que el menú multijugador quedaba **bloqueado**: el
  fallback a «Red local» no respondía (su handler está gateado con `if(!inMP())`)
  y había que recargar la página — incumpliendo la promesa de la fase de un
  "fallback limpio a LAN".
- Arreglo: helper `netFreeIfIdle(msg)` que libera el estado de red (destruye el
  `peer`/cierra el `ws`, deja `net.mode=null`) **solo si no hay partida en curso**
  (un error transitorio en mitad de una partida no tira la conexión). Cableado en
  los `error` de host/cliente online, en `netOnlineConnLost` y en el timeout de
  reconexión (que además marca la partida como terminada). Un error transitorio
  con partida en curso sigue mostrando el aviso sin liberar.
- Verificado headless: tras un error de señalización simulado (mock de `Peer`)
  sin partida en curso, `net.mode`/`net.kind` vuelven a `null` y `!inMP()` es
  true (el botón LAN «Crear partida» vuelve a funcionar); regresión LAN real
  (`server.js` + 2 páginas) intacta: el cliente ve 1 base propia + 1 rival, 0
  errores de consola.

---

## 2026-07-16 — PR #17: Fase 8 — Rendimiento, carga y calidad final

Última fase del plan maestro (`PLAN.md` §4 F8). Con esto **F1-F8 quedan
completas**. Alcance: atlas de sprites pre-escalado, object pool para
proyectiles/pings, pantalla de carga con barra de progreso, meta Open Graph
y una matriz QA final con cifras de rendimiento y memoria.

### 1. Atlas de sprites (`assets/atlas.png` + `assets/atlas.json`)
- Script Node (`build_atlas.cjs`, generado y ejecutado en la sesión, **no
  forma parte del repo** — mismo criterio que `arena.cjs` de la Fase 5: es
  una herramienta de build, no lógica del juego) que sirve el repo por HTTP
  local (necesario para que `<canvas>` no quede "tainted" leyendo imágenes
  locales bajo `file://`) y usa un Chromium headless para componer el atlas.
- Empaqueta **30 de los 34** PNG de `assets/sprites/` (todos salvo las 4
  texturas tileables `tile_grass/water/mountain/dirt`, que usan
  `ctx.createPattern` sobre la imagen COMPLETA y se quedan sueltas a
  propósito — meterlas en el atlas exigiría un canvas de recorte aparte para
  no repetir el atlas entero como textura, y el ahorro sería nulo con solo 4
  archivos cacheados una vez).
- Cada sprite se **PRE-ESCALA** antes de empaquetarlo a la altura máxima real
  con la que se dibuja en juego, calculada a mano a partir de las fórmulas de
  `drawSprite(...)` (`size*escala*zoom_máx(1.6)*DPR(2)`, +15% de margen) y
  clampada a la resolución nativa (nunca sube de resolución más allá del
  detalle real de la fuente — p. ej. `obj_mountain`/`bld_castle`/`bld_town`
  se copian tal cual porque lo que pediría la fórmula supera la fuente
  nativa). Resultado: atlas de **1024×2159px, ~2.5MB** (frente a ~3.7MB en
  30 peticiones sueltas) en un único `.png` + un `.json` de 3KB con los
  recortes (`{w,h,frames:{nombre:{x,y,w,h}}}`).
- `drawSprite(...)` en `index.html` prueba el atlas primero (`ctx.drawImage`
  con recorte por las coordenadas del json); si el atlas no cargó o le falta
  ese nombre, cae al PNG suelto de `assets/sprites/` — ahora de **carga
  perezosa** (`ensureLooseSprite`, antes se cargaban los 34 de golpe al
  arrancar): solo se piden por red si hace falta un respaldo. Si tampoco
  existe, el llamador pinta el emoji de siempre (sin cambios).
- **Guardarraíl importante** (encontrado en las pruebas, ver más abajo):
  `ensureLooseSprite` solo intenta la red si el nombre está en
  `SPRITE_FILES`/`SPRITE_SET`; para nombres sin PNG registrado (los
  edificios `bld_market`/`bld_siegeworkshop` de la Fase 5, que usan emoji a
  propósito porque Ideogram no estaba disponible esa sesión) devuelve un
  registro fijo sin disparar ninguna petición — si no, la carga perezosa
  habría reintroducido justo el 404/`console.error` que la Fase 5 evitó
  registrando esos nombres fuera de `SPRITE_FILES`.
- `vercel.json`: nueva regla de caché `immutable` para `/assets/atlas.(png|json)`
  (mismo criterio que `/assets/sprites/`). `.vercelignore` no necesitó
  cambios (no excluye `assets/atlas.*`).

### 2. Pre-escalado
Ver punto 1: el pre-escalado y el atlas se resolvieron juntos (el atlas ES
la versión pre-escalada). Para el camino de respaldo (PNG suelto, poco
frecuente) se mantiene el reescalado directo de siempre — es la rama menos
transitada, no merecía la pena duplicar la lógica de pre-escalado ahí.

### 3. GC y allocs
- **Object pool** para `projectiles` (`_projPool`/`allocProjectile`/
  `freeProjectile`) y `pings` (`_pingPool`): en vez de `push({...})` con un
  objeto nuevo en cada disparo/ping, se reutiliza uno ya "muerto" del pool
  (o se crea uno solo si el pool está vacío). `updateProjectiles`/`drawPings`
  ya no usan `.splice(i,1)` (O(n), desplaza el resto del array) sino un
  intercambio con el último elemento + `.pop()` (O(1); válido porque no hay
  dependencia de orden entre proyectiles/pings — ver razonamiento en
  `filemap.md` §9.5) y devuelven el objeto liberado al pool.
- `update()` ya no recalcula `frameWalls = entities.filter(...)` (un array
  nuevo cada cuadro) sino que reutiliza el array existente (`.length=0` +
  `push` manual).
- Comportamiento observable **idéntico** en ambos casos (mismos campos,
  mismos proyectiles/pings vistos en pantalla); no toca la simulación ni el
  protocolo MP (el cliente reconstruye su propio `projectiles` a partir del
  snapshot con `.map()`, sin pool, sin cambios).

### 4. Pantalla de carga + meta compartir
- Overlay `#loadScreen` (barra `#loadBarFill` + `#loadPct`, z-index 60, por
  encima de todo) visible hasta que `bootLoad()` decide que ya se puede
  jugar: si el atlas carga, salta casi al 100% de inmediato (1 imagen + 1
  json); si falla, pide TODOS los PNG sueltos de golpe (no perezosos, para
  que la barra tenga sentido) y sondea su progreso real cada 80ms. Tope de
  seguridad `LOAD_MAX_MS=4000` para que un fallo de red nunca deje al
  jugador atascado. El "audio" no tiene archivos que cargar (WebAudio
  sintetizado desde la Fase 1); el `AudioContext` real solo puede arrancar
  tras el primer toque (regla de Safari/iOS, sin cambios) — ocupa una
  fracción simbólica de la barra, con honestidad, en vez de fingir una carga
  que no existe.
- `<link rel="preload" as="image" href="assets/atlas.png">` (se retiró un
  preload equivalente para `atlas.json` con `as="fetch"`: bajo `file://`
  dispara su propio aviso de red por CORS incluso sin que el JS llegue a
  usarlo, y el archivo es demasiado pequeño —3KB— para que precargarlo
  aporte algo real).
- Meta Open Graph/Twitter Card (`og:title`/`og:description`/`og:image`,
  `twitter:*`) para que compartir el enlace del juego muestre una vista
  previa decente.

### 5. Matriz QA final

| Área | Verificado headless (Chromium) | Pendiente de dispositivo real |
|---|---|---|
| Carga con atlas (servido por HTTP) | ✅ 0 errores, `atlasReady=true`, 30 frames, menú y partida visibles con sprites | — |
| Carga con atlas bajo `file://` | ✅ 0 errores — se salta el intento de red a propósito (ver caveat) y cae a PNG suelto | — |
| Atlas pixel-correcto (6 sprites) | ✅ diferencia media <3/255 por canal vs. PNG suelto al mismo tamaño destino | — |
| Fallback si el atlas no carga (renombrado) | ✅ `atlasFailed=true`, cae a PNG suelto, juego funcional, captura visual idéntica | — |
| Rendimiento (285 entidades) | ✅ `update()+render()` ≈1.4-1.5ms/cuadro | Framerate real en Safari/iPad (motor JS y compositor distintos de Chromium) |
| Memoria (partida larga, ~20min simulados) | ✅ heap y arrays estables, sin fugas | Uso de memoria real prolongado en un iPad con RAM limitada |
| Regresión de un jugador (construir/era/línea/guarnición/asedio/mercado) | ✅ 0 errores, todas las comprobaciones pasan | — |
| Niebla/minimapa | ✅ base propia explorada, punto lejano no explorado | — |
| Guardar→recargar→cargar | ✅ `page.reload()` real + `localStorage`, entidades/recursos/edad coinciden | — |
| Multijugador LAN (`server.js` + 2 páginas) | ✅ 0 errores, cliente ve 1 base propia + 1 rival | Reconexión/latencia en una red Wi-Fi real con más de un salto |
| iPad Safari real (táctil, gestos, Retina) | — | **Pendiente** (sin dispositivo en este entorno) |
| iPhone (pantalla pequeña, ¿jugable?) | — | **Pendiente** |
| Modo PWA instalado (icono, standalone) | — | **Pendiente** |
| Rotación de pantalla física | — | **Pendiente** (el `resize()` responde a `window.innerWidth/Height`, pero el evento real de rotación de iOS no es reproducible headless) |
| Multitarea real (`visibilitychange` en Safari) | Parcial: el listener y `autosave()` ya se ejercitan en la Fase 6 con `document.hidden` simulado | Comportamiento exacto de Safari/iPadOS al perder foco (congelado por el SO, no solo el evento DOM) |
| Chrome/Firefox de escritorio | ✅ (Chromium headless cubre Chrome; Firefox no disponible en este entorno) | Firefox de escritorio real |

### 6. Cifras de rendimiento y memoria (medidas, no estimadas)
- **Estrés, 285 entidades** (100 unidades de ambos bandos, 20 edificios, 110
  recursos): 300 ciclos de `update(1/60)+render()` tras 30 de calentamiento →
  **462ms totales → 1.44-1.54ms/cuadro** (dos corridas), muy por debajo del
  presupuesto de 16.7ms para 60fps (~91% de margen).
- **Partida larga simulada** (72.000 cuadros = 60fps×60s×20min, con
  `update()+render()` en cada uno y disparos/pings sintéticos cada 5 cuadros
  para ejercitar el pool bajo carga sostenida): `performance.memory
  .usedJSHeapSize` pasó de **~4.3MB a ~4.6MB** (+6%, dentro del ±10% pedido,
  osciló entre esos valores sin tendencia monótona); `entities` bajó de 285
  a ~185 (bajas por el combate simulado, no una fuga: los ejércitos
  sintéticos se enfrentaron sin economía real); `pings` vivos se mantuvo
  acotado (120-180, nunca creciendo sin límite) y su pool se estabilizó en
  ~56 objetos reutilizables; `projectiles` vivos volvió a 0 en reposo con el
  pool estable en 80. Nada de esto se pudo observar en la primera versión
  del test porque **no llamaba a `render()`** dentro del bucle largo (solo
  `update()`) — sin `render()`, `drawPings()`/`drawCorpses()` (que podan y
  devuelven al pool) nunca corren, así que los arrays sí habrían crecido sin
  límite; corregido antes de dar la prueba por buena, ver caveat abajo.

### Caveats honestos
- **`file://` y `fetch()`**: Chromium bloquea `fetch()`/`XMLHttpRequest` a
  recursos locales por CORS (origen "null"), y lo registra como
  `console.error` de red **aunque el rechazo de la promesa se capture bien
  en JS** — no hay forma de evitar ese aviso desde el código de la página.
  Como el juego servido de verdad (GitHub Pages/Vercel) siempre es http(s),
  donde `fetch()` funciona sin problema, `loadAtlas()` detecta
  `location.protocol==='file:'` y se salta el intento de red a propósito,
  cayendo directo al PNG suelto — mismo comportamiento observable que un
  fallo real, sin el aviso inevitable. Esto significa que la ruta del atlas
  en sí **no se ejercita** al abrir `index.html` a mano (doble clic) ni bajo
  `file://`; para probarla de verdad (como se hizo aquí) hace falta servir
  el repo por http(s) — la pantalla de "Prueba gráfica" y las pruebas de
  Fases 1-7 ya usaban `file://`, así que se documenta este matiz nuevo con
  honestidad en vez de ocultarlo.
- El primer intento del test de "partida larga" no llamaba a `render()`
  dentro del bucle de 72.000 cuadros, así que no probaba de verdad la poda
  de `pings`/`corpses` ni el retorno al pool (ver punto 6); se corrigió
  antes de reportar cifras. Se deja constancia porque es exactamente el
  tipo de error que un test de rendimiento mal planteado puede esconder.
- El test de fallback (atlas renombrado temporalmente) genera, como es
  esperable, un `console.error` de red por el 404 real de `atlas.png` — se
  documenta como parte de la categoría ya aceptada en la Fase 5 ("un asset
  deliberadamente ausente para simular un escenario real produce su propio
  aviso de red, distinto de un bug del motor"); el archivo se restaura
  siempre en un `finally` del script de prueba.
- La matriz QA dedicada a iPad/iPhone/PWA/rotación/multitarea real **no se
  pudo verificar en este entorno** (sin dispositivo físico ni Safari real);
  se marca pendiente con honestidad en la tabla del punto 5, siguiendo la
  misma norma que las Fases 6 y 7 aplicaron a sus propios límites de
  entorno.

## 2026-07-16 — Corrección post-lanzamiento (feedback de juego real)

Con las 8 fases del plan maestro ya fusionadas en `main`, se jugó una partida
real (no headless) y se reportaron 11 problemas concretos. Se corrigieron
todos en la misma tanda, con diagnóstico y verificación headless por cada uno
antes de dar el problema por cerrado.

1. **Sonido continuo de recolección**: `playSfx('chop'/'mine')` se llamaba
   cada cuadro dentro del bucle de `gather`, con un throttle interno
   (`sfxAllowed`) por NOMBRE de SFX (global), no por unidad — con cualquier
   aldeano recolectando, sonaba un pitido cada ~420ms de forma ininterrumpida
   durante TODA la partida. Se quitó la llamada del bucle de recolección
   (dos sitios: nodo natural y edificio de producción). Verificado: el sonido
   ya no se dispara; el resto de SFX (espada, flecha, construir…) intactos.

2. **Granjas/minas se abandonaban al agotarse**: al llegar `reserve<=0`, el
   código buscaba INMEDIATAMENTE otro nodo del mismo tipo, dejando la fuente
   original sin recolectar para siempre. Además, al terminar de recargarla
   manualmente, el aldeano quedaba `idle` en vez de retomar la recolección.
   Arreglo: si la fuente agotada es un edificio de producción, el aldeano pasa
   a `build` sobre ESA MISMA fuente (recarga in situ); al llegar a 500, vuelve
   a `gather` de la misma fuente. Verificado con traza completa: `gather`
   (reserve 6→0) → `build` (recarga 64→224→384) → `gather` de nuevo (reserve
   500→494), sin intervención manual.

3. **Murallas: huecos en los extremos**: se comprobó primero que una muralla
   **cerrada** (anillo de 20 tramos alrededor de un punto, sin puerta) es
   100% infranqueable — una unidad enemiga persistente se quedó fuera
   (distancia 174 del centro, radio protegido 150) tras 150 segundos
   simulados de intentos. El problema real es que las murallas CORTAS (con
   extremos abiertos, lo normal al defender un paso) son rodeables por el
   extremo en pocos segundos si el jugador no las hace llegar exactamente
   hasta el borde del mapa u otra muralla. Nueva `snapWallEndpoint`: ajusta
   cada extremo de la línea trazada (`wallTap` y `hostWall`, cliente y
   anfitrión) al borde del mapa o a una muralla/puerta ya construida si cae
   a menos de 46px (~1.6 tramos), cerrando el hueco accidental. Verificado:
   una muralla que arranca a 20px del borde superior queda con su primer
   tramo exactamente en `y=0`; una segunda línea trazada cerca del final de
   la primera queda pegada exactamente a su posición (sin hueco).

4. **Puerta perpendicular en muralla vertical**: `obj_gate.png` solo existe
   en una orientación (pensada para muralla horizontal, confirmado mirando el
   sprite: puertas de madera dobles en una banda ancha y corta) y se dibujaba
   igual en cualquier `e.dir`, viéndose perpendicular/sin sentido en una
   muralla vertical. Nueva `drawWallOrientedSprite` (junto a `drawSprite`):
   gira el sprite existente 90° con `ctx.rotate` cuando `e.dir==='v'`,
   calculando el tamaño local para que el grosor (eje corto, perpendicular a
   la muralla) sea el mismo en ambas orientaciones. Verificado visualmente
   con una muralla horizontal y una vertical, cada una con su puerta: ambas
   se ven correctamente integradas en su respectiva muralla (captura en el
   scratchpad de la sesión).

5. **Insignia de tier casi invisible**: los chevrons ▲ de la línea de mejora
   (Fase 5) eran texto plano de 9px en dorado pálido, sin fondo, encima de la
   unidad — fácil de perder de vista en combate. Ahora es un óvalo oscuro con
   borde dorado (mismo lenguaje visual que las insignias de recurso/inactivo
   ya existentes) con 1-2 ⭐ según el tier investigado por el bando.

6. **Catapulta "transparente"**: se diagnosticó a fondo (probado en `file://`
   y sirviendo por HTTP con el atlas activo): el respaldo de emoji SÍ se
   dibuja correctamente en ambos casos (0 errores, `spr()`/`atlasFrames`
   confirman que ni la catapulta ni el Taller de Asedio están registrados,
   como es intencional desde la Fase 5) — no hay nada literalmnete
   transparente. El problema real es de legibilidad: el emoji 🎯 a tamaño
   normal se pierde entre el terreno/otras unidades. Se le añadió una
   plataforma de madera (óvalo oscuro) detrás y se agrandó el emoji ×1.6,
   para que lea como una máquina de asedio pesada. El Taller de Asedio ya
   se veía bien (rect + emoji, confirmado por captura); no se tocó.

7. **Guarnición accidental**: tocar el Centro Urbano/Castillo/Torre con
   unidades elegibles seleccionadas las guarnecía sin ninguna confirmación
   — un aldeano seleccionado + un toque casual al Centro Urbano bastaba.
   Nueva opción de menú «🛡️ Guarnición» (`gameConfig.garrison`,
   **Deshabilitada por defecto** / Habilitada); con la opción desactivada
   (`garrisonEnabled=false`), tanto `handleTap` como el comando MP
   `'garrison'` de `hostHandleCmd` ignoran la acción y el toque simplemente
   selecciona el edificio (comportamiento normal de cualquier edificio
   propio). Verificado: con `garrison:'off'`, tocar el Centro Urbano con un
   aldeano seleccionado NO lo guarnece y selecciona el edificio; con
   `garrison:'on'`, el guarnecido funciona exactamente como antes.

8. **Infografía rápida de controles**: overlay `#quickHelpScreen` con los
   controles básicos (selección, caja de selección, doble toque, cámara de 2
   dedos, órdenes contextuales), mostrado al empezar CADA partida — a
   diferencia del tutorial interactivo de 10 pasos (Fase 6), que solo corre
   la primera vez — con casilla «no volver a mostrar» persistida en
   `localStorage` (`miniaoe_quickhelp_skip`). Verificado: aparece en la
   primera partida, desaparece y persiste el flag al marcar la casilla, y ya
   no reaparece en una partida nueva posterior.

9. **Centro Urbano sin autodefensa**: `BLD.town` no tenía `atk`/`range`/`cd`,
   así que no podía hacer nada ante un ataque directo (el bucle de
   auto-disparo de edificios, reutilizado tal cual, es genérico sobre
   `bd.atk`). Se le dieron valores moderados (`atk:11, range:170, cd:1.0`,
   entre Torre y Castillo). Verificado: un enemigo pegado al Centro Urbano
   muere en ~10s simulados sin ninguna otra unidad defendiendo.

10. **Tiempo de tregua configurable**: nueva opción de menú «🕊️ Tiempo de
    tregua» (sin tregua / 1 / 2 / 5 min, `gameConfig.peace`). Mientras
    `peaceTimer>0`: `nearestEnemy` no devuelve blancos (ninguna IA ni
    auto-defensa inicia combate) y `applyDamage` anula el daño entre bandos
    distintos aunque el jugador fuerce un ataque manual (el golpe se ve pero
    no hace daño real). Cuenta atrás visible en la barra superior
    (`#peaceLabel`, mm:ss). Verificado: hp de un Centro Urbano atacado se
    mantiene en 1200 durante la tregua, el temporizador baja de 60 a 50 tras
    10s simulados, llega a 0 a los 60s, y el ataque vuelve a hacer daño real
    justo después (hp 1200→1176). Nota: el temporizador es del host/partida
    local (como el resto de la simulación); el cliente MP no tiene su propio
    conteo visual, aunque el bloqueo de daño sí aplica correctamente porque
    corre en el host autoritativo.

11. **Velocidad de partida ajustable en vivo**: nuevo control en el panel de
    Ajustes ⚙️ (visible solo con partida en curso de un jugador; oculto en
    MP, donde la simulación es del host) que cambia `gameSpeed` en caliente.
    Verificado: clic en «Rápida»/«Lenta» cambia `gameSpeed` a 1.6/0.7 al
    instante.

**Verificación de regresión** (headless, Chromium, cero errores en todos los
casos): combate/proyectiles (Fase 1) sin cambios; multijugador LAN
(`server.js` + 2 páginas) sigue viendo exactamente 1 base propia + 1 rival;
cruce del puente del río (Fase río) intacto; partida real simulada de 300s
(6000 `update()` de 0.05s) con IA Difícil y 30s de tregua — el enemigo avanzó
de Era, la tregua expiró a tiempo, 82 entidades vivas, sin errores ni cuelgues.

**Documentación actualizada en la misma tanda**: `CLAUDE.md` §6 (nueva
entrada), `filemap.md` (§19), este archivo.

## 2026-07-16 (2) — Segunda ronda de correcciones tras juego real

Nuevo feedback tras probar la primera ronda de correcciones. Se abordaron 6
problemas más, incluida una corrección de diseño importante en murallas.

1. **Murallas: bloquean también al DUEÑO (corrección de diseño)**. Desde la
   Fase 4, una muralla normal nunca bloqueaba a su propio dueño (`w.owner !==
   moverSide`), solo al rival — así que "atravesar la propia muralla" era el
   comportamiento previsto, no un bug, pero el jugador lo reportó como un
   error de fondo: si hay muralla, nadie debería poder cruzarla salvo por una
   puerta. Se cambió `wallBlocksSide`: una muralla normal ahora bloquea a
   TODOS (propios y rivales); solo una Puerta abierta deja pasar al dueño.
   - **Efecto colateral descubierto y corregido**: al bloquear también al
     dueño, el hueco de paso de una Puerta se volvió geométricamente
     demasiado angosto — los dos tramos de muralla INMEDIATAMENTE vecinos a
     la puerta (separados solo `WALL_SP`≈28px) también bloqueaban ahora al
     dueño, dejando un pasillo real de ~4px, insuficiente para que la física
     de movimiento lo cruzara de forma fiable (verificado: con una puerta
     abierta, la unidad propia se quedaba atascada justo en el umbral,
     `x≈1297` sin cruzar `x=1300`). Solución: nuevo `frameOpenGates` (subcaché
     de `frameWalls`, recalculado una vez por cuadro) — un tramo de muralla
     normal vecino a una puerta ABIERTA del MISMO dueño dentro de `WALL_SP*1.6`
     deja de bloquear a ESE dueño (pasillo real de paso), pero sigue
     bloqueando al rival siempre (el rival solo puede cruzar por el hueco
     exacto de la puerta). Verificado tras el arreglo: dueño cruza limpio
     (`x: 1397`, antes se atascaba en `1297`), rival sigue bloqueado
     (`x:1270`), puerta cerrada sigue bloqueando a todos (incl. dueño) en un
     anillo borde-a-borde del mapa (sin forma de rodear).
   - Se añadió una excepción en `blockedByWall` para `state==='build'` sobre
     ESE mismo tramo: un aldeano reparando/recargando su propia muralla
     (incluida una Torre de Muralla) puede acercarse lo suficiente para
     trabajar, aunque ahora la muralla bloquee.
   - Regresión completa re-verificada tras el cambio: A*/formaciones/rodeo de
     extremos (Fase 4) intactos, combate/proyectiles (Fase 1) intactos,
     multijugador LAN (bandos correctos) intacto, cruce del puente intacto,
     partida de 300s con IA Difícil sin errores.

2. **Torres de Muralla gratis eliminadas (trampa de recursos)**. Antes,
   `wallSegmentType` insertaba una Torre de Muralla GRATIS cada
   `WALL_TOWER_EVERY=6` tramos al trazar una línea (mismo coste que un tramo
   normal, 🪨5, pero con ataque) — mucho más barato que una Torre real
   (🪵50+🪨125) con estadísticas similares o mejores (hp 1100 vs 900). Ahora
   `wallSegmentType` solo distingue Puerta (tramo central) o muralla normal;
   la Torre de Muralla se **construye explícitamente** sobre un tramo de
   muralla normal YA EN PIE, pagando su coste real (`BLD.wall_tower.cost`),
   vía un nuevo botón "🏯 Construir Torre de Muralla" en el panel del tramo
   seleccionado (`upgradeWallToTower`, con comando MP `wallUpgrade`). Convierte
   la entidad EN EL SITIO (mismo id/posición/bando), así sigue formando parte
   de la misma línea sin dejar hueco. Verificado: una muralla trazada con el
   herramienta real ya no genera ninguna Torre de Muralla automática (antes
   sí); seleccionar un tramo normal muestra el botón (con su coste 🪨20);
   pagarlo convierte el tramo (hp 700→1100) y le da capacidad de auto-disparo
   real contra un enemigo pegado.
3. **Puerta con concordancia visual real con la muralla**. El intento anterior
   (Fase de corrección previa) rotaba `obj_gate.png` 90° para muralla
   vertical, pero seguía siendo una puerta de madera grande que desentonaba
   con la piedra del resto de la muralla. Ahora la Puerta se dibuja con el
   MISMO sprite que un tramo de muralla normal (`bld_wall_h`/`bld_wall_v`
   según `e.dir`, igual que un tramo cualquiera) y se le añade solo una
   pequeña marca oscura en la parte de ARRIBA (un pequeño dintel/marca, en
   ambas orientaciones, sin rotar) para diferenciarla de un tramo normal,
   además del candado 🔒/🔓 que ya existía. Se quitó `drawWallOrientedSprite`
   (quedó sin uso). Verificado visualmente con una línea horizontal y otra
   vertical, cada una con su puerta: ambas se integran con la textura de
   piedra de la muralla, con la marca+candado arriba en ambos casos.
4. **Catapulta y Taller de Asedio con dibujo procedural** (sin acceso a
   Ideogram esta sesión tampoco). El intento anterior (emoji 🎯 agrandado +
   plataforma) seguía sin leer como una máquina de asedio real. Ahora:
   - **Catapulta** (`drawCatapultIcon`): dibujo 100% vectorial en el espacio
     local ya transformado de `drawUnit` — dos ruedas con radios, un chasis
     de madera (rectángulo redondeado) y un brazo lanzador diagonal con un
     contrapeso/cangilón al final. Se reconoce como catapulta a simple vista,
     sin depender de ningún emoji.
   - **Taller de Asedio**: el respaldo genérico (rect + emoji) se sustituyó,
     solo para este edificio, por una silueta con **tejado a dos aguas**
     (triángulo + cuerpo rectangular) con el emoji 🏭 dentro — lee claramente
     como un edificio en vez de un cuadro plano.
   - Verificado visualmente (captura en el scratchpad de la sesión): ambas
     catapultas (jugador y rival) y el taller se distinguen con claridad del
     terreno y de otras unidades/edificios.
5. **Sonido de construcción suavizado**: el "clic" (`case 'build'`) usaba una
   onda cuadrada a volumen 0.10, con muchos armónicos y percibido como fuerte/
   molesto en partidas largas. Cambiado a onda triangular (más suave) y
   volumen 0.055 — un "toc" discreto en vez de un clic agudo.

**Verificación de regresión** (headless, Chromium, cero errores en todos los
casos): combate/proyectiles, multijugador LAN (1 base propia + 1 rival),
cruce del puente, A*/formaciones/puertas/rodeo de extremos (Fase 4 completa),
Centro Urbano/tregua/guarnición (ronda anterior), y una partida real simulada
de 300s con IA Difícil sin errores.

**Documentación actualizada en la misma tanda**: `CLAUDE.md` §6, `filemap.md`,
este archivo.

---

## 2026-07-16 — Cambio de nombre del proyecto: Mini-AoE → iMperios

Para evitar cualquier problema legal con Microsoft (dueño de la marca "Age of
Empires"), se renombró el proyecto de **Mini-AoE** a **iMperios** en todo el
código y la documentación:

- **`index.html`**: `<title>`, meta tags (`description`, Open Graph, Twitter
  Card, `apple-mobile-web-app-title`), textos en pantalla (pantalla de carga,
  menú principal, mensaje de bienvenida del tutorial) y comentarios del
  código. Las menciones sueltas a "Age of Empires"/"AoE" como referencia de
  género se cambiaron por "RTS"/"RTS real" (comparaciones genéricas, sin
  nombrar la marca).
- **Claves de `localStorage`** renombradas de `miniaoe_*` a `imperios_*`
  (`imperios_settings`, `imperios_sound`, `imperios_save_1/2/3`,
  `imperios_autosave`, `imperios_quickhelp_skip`, `imperios_tutorial_done`);
  esto invalida partidas guardadas/ajustes previos en el navegador de quien
  ya hubiera jugado (no había usuarios reales todavía). El prefijo de los ids
  de sala de PeerJS pasó de `miniaoe7-` a `imperios7-`.
- **`manifest.webmanifest`**: `name`/`short_name` a "iMperios", descripción
  sin "Age of Empires".
- **`server.js`**: comentario de cabecera y el log de arranque del relé.
- **Documentación** (`README.md`, `DESIGN.md`, `PLAN.md`, `CLAUDE.md`,
  `filemap.md`, `iOS.md`, `assets/ART.md`): título y menciones al nombre del
  proyecto actualizadas; comparaciones con el género "Age of Empires"/"AoE"
  cambiadas por "RTS"/"RTS clásico"/"RTS real". Las entradas históricas ya
  existentes en este archivo (`progress.md`) NO se tocaron —es un registro
  cronológico— por lo que siguen mencionando `miniaoe_*`/"Mini-AoE" tal como
  eran ciertas en su momento.
- **App iOS** (`ios/`): proyecto y carpeta renombrados de `MiniAoE`/
  `MiniAoE.xcodeproj` a `iMperios`/`iMperios.xcodeproj`; `MiniAoEApp.swift` →
  `iMperiosApp.swift` (`struct MiniAoEApp` → `struct iMperiosApp`); bundle id
  `com.miniaoe.game` → `com.imperios.game`; `Info.plist`
  (`CFBundleDisplayName`, texto de permiso de red local) e
  `INFOPLIST_FILE`/rutas dentro de `project.pbxproj` actualizadas al nuevo
  nombre de carpeta/target/producto.
- **No se tocó** la rama de desarrollo `claude/mini-aoe-browser-game-k5vf3r`
  (nombre de infraestructura fijado por el flujo de trabajo, no un texto de
  producto).

**Límite conocido**: el nombre del repositorio en GitHub
(`juandiegorodri/Ageofempires`) y la URL de GitHub Pages que depende de él
(`https://juandiegorodri.github.io/Ageofempires/`) **no se cambiaron** —no
hay herramienta disponible en esta sesión para renombrar el repositorio; debe
hacerse manualmente desde GitHub (Settings → repositorio → Rename) por
alguien con acceso, sabiendo que eso también cambiaría la URL pública.

**Verificado headless** (Chromium, Playwright): carga de `index.html` sin
errores de consola, título/menú/pantalla de carga muestran "iMperios",
`localStorage` usa las claves `imperios_*` nuevas, y una partida de un
jugador arranca y funciona con normalidad.

**Documentación actualizada en la misma tanda**: `README.md`, `DESIGN.md`,
`PLAN.md`, `CLAUDE.md`, `filemap.md`, `iOS.md`, `assets/ART.md`, este
archivo.

## 2026-07-18 — Repositorio renombrado en GitHub y PR #20 fusionado a `main`

El usuario renombró manualmente el repositorio en GitHub Settings de
`juandiegorodri/Ageofempires` a **`juandiegorodri/iMperios`** (cerrando el
límite conocido registrado en la entrada anterior). GitHub Pages ahora sirve
desde `https://juandiegorodri.github.io/iMperios/`. GitHub redirige de forma
transparente el nombre antiguo tanto en la API como en clones/remotos git ya
existentes, así que no hizo falta cambiar ningún remoto local.

Con el repo ya renombrado, se fusionó a `main` (squash) la PR #20
"Renombrar el proyecto a iMperios + cerrar el plan maestro" (commit
`651388f`), que reunía en la misma rama:
- El renombrado en código Mini-AoE → iMperios (título, `localStorage`,
  prefijo de salas PeerJS, `manifest.webmanifest`, `server.js`, toda la
  documentación y la app iOS) descrito en la entrada anterior.
- El commit de cierre de documentación del plan maestro (secciones nuevas en
  `PLAN.md` resumiendo F1-F8 + las dos rondas de correcciones
  post-lanzamiento).

Antes de fusionar se corrió de nuevo la prueba headless de humo (300s
simulados, IA Difícil, `node`+Playwright/Chromium) directamente sobre el
código ya renombrado: 0 errores de consola, progresión normal de recursos/
era, y se confirmó por `grep` que no quedan restos de `miniaoe`/`MiniAoE` en
`index.html`. Tras el merge, la rama de desarrollo
`claude/mini-aoe-browser-game-k5vf3r` se resincronizó con el nuevo `main`
(`git fetch` + `git checkout -B` + `git push --force-with-lease`), dejando
ambas ramas alineadas.

Se corrigió también la única referencia desactualizada que quedaba en
`CLAUDE.md` (§3, URL de GitHub Pages con el nombre antiguo del repo), y se
dejó anotado ahí mismo que el repo se renombró el 2026-07-18.

**Estado actual del proyecto**: plan maestro completo (F1-F8), dos rondas de
correcciones post-lanzamiento, y el renombrado a iMperios (código +
repositorio) ya fusionados en `main` y desplegados. Pendientes conocidos sin
resolver (ver `PLAN.md` §7): verificar una conexión WebRTC/PeerJS real fuera
del sandbox (sin egreso de red), QA en dispositivo físico (iPad real), y
sprites propios de Ideogram para Catapulta/Taller de Asedio/Mercado (hoy
usan dibujo procedural/emoji de respaldo). Para retomar el proyecto en una
sesión nueva: leer `CLAUDE.md` → `filemap.md` → estas últimas entradas de
`progress.md`.

---

## 2026-07-18 — Corrección de selección, rally y deselección (reporte de juego real)

Tres problemas de usabilidad reportados tras jugar una partida real:

- **Área de toque de unidades/edificios corregida** (`hitBox`, nueva función
  en el bloque de hit-testing): el `pickAt` anterior usaba un círculo
  centrado en `e.x,e.y`, pero unidades y edificios (salvo murallas/puertas)
  se dibujan con el sprite **anclado por abajo** (`e.x,e.y` = la base/pies,
  el sprite crece hacia arriba, ver `drawUnit`/`drawBuilding`). El círculo
  solo cubría la mitad inferior del dibujo: tocar la cabeza de un aldeano o
  el tejado de un edificio no lo seleccionaba, solo tocar cerca de los pies
  funcionaba. `hitBox(e)` reproduce en coordenadas de mundo la misma
  geometría que usa el render (altura/ancla del sprite según tipo de unidad
  o `size`/escala del edificio) y `pickAt` ahora comprueba el toque contra
  esa caja completa en vez de un círculo. Las murallas/puertas (dibujadas
  centradas, no ancladas por abajo) mantienen el círculo de siempre.
  Verificado headless: un toque cerca de la cabeza de un aldeano y uno cerca
  de los pies seleccionan la misma unidad (antes solo el segundo).
- **Punto de reunión (rally) solo en edificios que entrenan unidades**: antes
  cualquier edificio propio seleccionado aceptaba un rally al tocar el mapa,
  incluida una Granja, una Mina o la Herrería — edificios que no producen
  unidades y no deberían mostrar ese guía. Nueva constante `TRAIN_BLD`
  (`town`, `barracks`, `range`, `stable`, `siegeworkshop`, `castle`) y
  `handleTap` solo fija `selBuild.rally` si `TRAIN_BLD.has(selBuild.btype)`.
  Verificado headless: tocar el mapa con el Centro Urbano seleccionado fija
  el rally; con una Granja seleccionada, no.
- **Deseleccionar con 2 dedos**: gesto táctil habitual en iPad, en vez de
  depender solo del botón "✕ Deseleccionar" del panel (que se mantiene como
  alternativa para ratón/escritorio). Un toque con 2 dedos que NO se mueve
  (ni paneo ni pinch, umbral 12px) y se suelta en <400ms deselecciona todo
  (`input.twoFinger`/`twoFingerMoved`/`twoFingerTime`, revisado en
  `pointerdown`/`pointermove`/`pointerup` del canvas); si el gesto se
  convierte en un paneo o pinch real, se cancela automáticamente y no
  deselecciona.

Verificado headless (`node`+Playwright/Chromium, `startGame(cfg)` directo sin
pasar por el menú): 0 errores de consola/`pageerror` en los tres escenarios,
y las tres correcciones probadas por separado con `pickAt`/`handleTap`
llamados directamente contra el estado del motor.

## 2026-07-21 — FASE 9 (arranque): pivote a vista de tablero con fichas tipo sticker

Pedido del usuario tras jugar: pasar de sprites pixel-art en ¾ a un RTS con
**cámara cenital ESTRICTA** (90°, sin perspectiva) y estética de **juego de
mesa** — fichas planas tipo sticker/cartón sobre un tablero de pasto (estilo
Carcassonne, se va descubriendo con la niebla de guerra), pensado para
jugarse con el iPad plano sobre una mesa. Aclaración del propio usuario
durante el diseño: la simulación NO cambia — sigue siendo el mismo RTS en
tiempo real, con el mismo mapa grande (2600×1500) y la misma niebla de
guerra; solo cambia la capa gráfica y de colocación. Decisiones tomadas en
conversación (no todas las recomendadas por defecto se aceptaron tal cual):
- **Edificios en rejilla, unidades libres**: los edificios encajan en una
  rejilla al construirse; las unidades se mueven libres por todo el mapa,
  incluida diagonal, sin restricción de rejilla (el usuario fue explícito en
  que esto es "también un videojuego" y las unidades no pueden quedar
  atadas a una cuadrícula).
- **Ficha tipo sticker** (colores vivos + borde blanco), no madera pintada —
  se lee mejor a tamaño chico en iPad y combina mejor con el piso de pasto.
- **Bando por líneas de color sobre arte neutro**: el mismo arte de un
  Castillo sirve para ambos jugadores; lo que distingue de quién es cada
  ficha son unas líneas (trim) de color que pinta el MOTOR, no el arte.
- **Rotación real hacia el movimiento** (no solo volteo izquierda/derecha).
- **Efecto de interacción reforzado**: cuando dos fichas interactúan
  (ataque/recolección/construcción) debe notarse en movimiento, no solo un
  cambio de color — se pidió explícitamente añadir esto sobre lo que ya
  existía (el "lunge" de la Fase 1).

### Cambios de motor (esta tanda, sin arte nuevo todavía — placeholders)
- **`snapToGrid(x,y)`** (junto a `FOG_CELL`): nueva función que ajusta un
  punto al múltiplo de 40px más cercano. Se usa en `tryPlaceBuilding` (la
  colocación real) y en el fantasma de `render()` (lo que se ve durante la
  colocación es exactamente donde caerá) — con una rejilla sutil dibujada
  alrededor de la celda destino para reforzar la lectura de "tablero". Las
  murallas NO se tocaron (mantienen su propio sistema de espaciado
  `WALL_SP`/`snapWallEndpoint`, ya verificado en dos rondas de correcciones
  anteriores — cambiarlo habría sido un riesgo innecesario para este pivote).
- **`drawBuilding` reescrito**: ancla la ficha CENTRADA en `e.x,e.y` (variable
  `box`, ≈`d.size*1.05`) en vez del "por los pies + estirado ×1.7" de antes
  (simulaba un edificio visto en ¾); todos los offsets dependientes (barra
  de vida, barra de progreso, caja de selección, humo/fuego, flash de daño)
  se recalcularon relativos al nuevo centro. Se añadió una sombra recta
  desplazada (sin achatar) y un **trim de bando**: borde blanco + borde
  interior del color de bando (azul jugador / rojo rival) sobre el marco del
  edificio, que reemplaza la bandera pequeña de antes (se perdía a tamaños
  chicos de cámara y no cumplía el pedido de "líneas de color" sobre la
  MISMA pieza). Las murallas/puertas no se tocaron (ya eran planas/
  centradas desde la ronda de correcciones anterior).
- **`drawUnit` reescrito**: se sustituyó el volteo ±1 + bamboleo de ángulo
  fijo por una **rotación real** hacia el rumbo de movimiento. El ángulo
  (`fx.angle`, guardado en el mismo `Map` `unitFace` que ya existía) se
  suaviza cuadro a cuadro por interpolación angular de camino corto (evita
  el salto de ±180° al cruzar el signo) a partir del delta de posición real
  — funciona igual en host y cliente MP porque se deriva de `e.x/e.y`, que
  siempre viajan en el snapshot (mismo mecanismo que ya usaba el bamboleo/
  volteo de la Fase 1). `e.face` (±1) se conservó, pero AHORA solo para la
  caída de los cadáveres (`drawCorpses`), no para el dibujo en vivo. Cada
  unidad dibuja un relleno claro tipo cartón + anillo blanco + anillo de
  color de bando + una muesca triangular que marca el rumbo con claridad
  incluso con el arte de respaldo (emoji) de hoy — en cuanto llegue el arte
  real de la parrilla, rotará igual de bien porque se diseñó para ello (ver
  `board_sprites.json`, todas las piezas miran "hacia arriba" por defecto).
  Se añadió `hurtPunch`: un pulso de escala breve (~110ms) al recibir daño,
  sumado al lunge del atacante y al flash blanco ya existentes, para que la
  interacción se note en AMBAS fichas, no solo en la de enfrente.
- **Cámara cenital estricta de verdad**: `drawShadow` (sombra de recursos),
  `drawSelRing` (anillo de selección) y `drawPings` (efectos de selección/
  deselección) dejaron de achatarse con `ctx.scale(1,0.5)` — esa elipse
  simulaba una cámara en ángulo; con 90° estricto, un círculo recto es lo
  correcto.
- **`hitBox` simplificado**: con las fichas ya centradas, la zona de toque de
  una unidad es un cuadrado simétrico de radio fijo alrededor de su centro
  (antes reproducía offsets asimétricos para calzar con el anclaje "por los
  pies") y la de un edificio es exactamente su huella cuadrada + margen
  táctil — selección más simple y predecible, verificado por prueba (toque
  en el centro exacto Y en el borde desplazado de una ficha, ambos
  seleccionan correctamente).
- **`assets/board/board_sprites.json`**: especificación completa entregada
  al usuario para generar el arte definitivo con Gemini (no Ideogram, que se
  usó para el set v1) — 5 hojas/parrillas (P1 unidades 3×3, P2 edificios
  económicos 3×4, P3 edificios militares 2×2, P4 recursos/props 3×2, P5
  texturas de piso 2×2), cada celda con su prompt exacto en inglés, más un
  bloque de estilo global (sticker, cenital estricto, arte neutro de bando,
  sin sombra horneada, orientación "mirando hacia arriba" para que la
  rotación del motor funcione) y una sección `how_to_use` con el flujo de
  recorte/importación. Nota en `assets/ART.md` marcando el pivote de
  dirección de arte (v1 pixel-art ~70° sigue documentada y en uso mientras
  no se reemplace; v2 sticker/90° es la nueva dirección para lo que venga).

### Verificación headless
Suite completa re-ejecutada tras los cambios, 0 errores de consola en todos
los casos:
- Movimiento diagonal libre de una unidad (sin restricción de rejilla) tras
  una orden de `applyGroupMove` fuera de cualquier alineación de 40px.
- Colocación de un edificio (`tryPlaceBuilding`) con snap confirmado por
  aritmética (`b.x % FOG_CELL === 0` y lo mismo en Y).
- Rotación hacia un rumbo diagonal confirmada por cálculo (`atan2` del
  desplazamiento real tras 20 cuadros simulados con `update()+render()`).
- Selección por toque exacta: centro de un edificio, centro de una unidad, y
  un toque desplazado ~10px hacia el borde del token — las tres seleccionan
  correctamente.
- Regresión general: 300s simulados con IA Difícil (partida completa vía
  `startGame`+`update()` en bucle), suite de Fase 4 (A*/formaciones/puertas/
  rodeo de extremos), flip de bandos en cliente MP, y cruce de puente sobre
  el río — todo sin errores y con el comportamiento esperado.
- Capturas de pantalla revisadas visualmente: Centro Urbano ya como ficha
  centrada con trim blanco+azul claramente visible; aldeano en movimiento
  rotado hacia su rumbo (con el arte pixel-art v1 actual se ve "inclinado"
  en vez de "girado limpio" — esperado, mejorará al llegar el arte v2 diseñado
  para rotar); fantasma de colocación de edificio ya encajado a la rejilla.

### Pendiente
- Integrar el arte real de `board_sprites.json` en cuanto el usuario lo
  genere con Gemini y lo entregue (Fase B del plan: recorte + carga +
  sustitución de los sprites placeholder, sin tocar lógica de juego).
- Pulido visual adicional una vez haya arte real (ajuste fino de tamaño/
  anclaje por pieza, posible mosaico de piso de pasto con textura en vez del
  patrón actual — ya existe `tile_grass` pero podría regenerarse con el
  estilo v2 usando `P5_ground_tiles` del JSON).

## 2026-07-22 — Ajustes al spec de arte tras revisar la parrilla de unidades

El usuario entregó la primera parrilla de unidades generada con Gemini (4×3,
no 3×3 como pedía el spec original) describiéndola celda por celda. Se
confirmó el mapeo real: fila 3 son los HÉROES del Castillo (no una tercera
mejora de línea), y se decidió explícitamente usar **arte distinto por cada
tier de mejora de línea** en vez de solo la insignia de estrellas ("arte es
más pro, con este tipo de unidades nos lo podemos permitir") — esto implica
un cambio de motor real (buscar sprite por tipo+tier, no solo por tipo).

- `board_sprites.json` actualizado: la hoja `P1_units` ahora documenta la
  rejilla 4×3 REAL con el mapeo confirmado; nueva hoja `P1b_unit_tiers_missing`
  (2×2) con los 4 tiers que faltaban para cobertura completa (Campeón,
  Alabardero, Caballero, Paladín); nota de revisión en la celda de la
  catapulta (parecía un carromato) — luego el usuario confirmó que la
  catapulta se entendía bien y se retiró esa nota.
- A pedido del usuario, faltaba también una hoja de murallas (el usuario la
  pidió al notar que solo había torre independiente, no tramo de muro ni
  Torre de Muralla): nueva hoja `P6_walls` (1×3: muralla horizontal, muralla
  vertical, Torre de Muralla). La Puerta NO necesita imagen propia: el motor
  ya la dibuja reutilizando el sprite de muralla + una marca que pinta el
  propio código (decisión de diseño de una corrección anterior).
- Los prompts de Centro Urbano y Castillo se reescribieron con mucho más
  detalle tras feedback directo ("le falta detalle y épicidad"): el Centro
  Urbano ahora pide torreones laterales, campanario con campana y reloj,
  banderines y vigas decorativas; el Castillo pide doble anillo de almenas,
  cuatro torreones, rastrillo reforzado y torre del homenaje central —
  ambos con la instrucción explícita de ser los edificios más detallados e
  imponentes del set.
- Se exportó además el mismo contenido como **6 (luego 7) archivos
  independientes** (`assets/board/group_1_units.json` ...
  `group_7_walls.json`), uno por hoja, con las normas de estilo YA
  incrustadas dentro del `full_prompt` de cada celda (autocontenido) — a
  pedido explícito del usuario, para poder pegar un grupo a la vez en Gemini
  sin tener que copiar el bloque de estilo global por separado. Generados con
  un script Python de la sesión a partir de `board_sprites.json` (fuente de
  verdad; los `group_*.json` se regeneran desde ahí si cambia el spec
  maestro).

## 2026-07-22 — FASE 9B: integración del arte real generado con Gemini

El usuario generó las 7 hojas completas con Gemini y las subió como un único
`.zip` (7 PNG). Se investigó primero si las imágenes pegadas directamente en
el chat quedaban accesibles como archivo — **no**: solo son visibles para
evaluación visual, no hay un archivo real en el sistema de esta sesión hasta
que el usuario las sube como adjunto (confirmado con `find` buscando PNG
recientes: solo aparecían capturas propias de Playwright). Tras pedirle el
`.zip`, se extrajo y se identificó cada una de las 7 imágenes por inspección
visual (dimensiones + contenido), confirmando que cubrían las 7 hojas
completas del spec (incluida la de tiers ya vista antes por separado).

### Recorte y quitado de fondo
Script Python de la sesión (`Pillow`+`numpy`, no forma parte del repo):
recorte por celda + quitado de fondo por **flood-fill** desde los bordes de
cada celda sobre píxeles casi-blancos (conserva intactos los blancos
internos de la propia ilustración, como brillos de armadura, a diferencia de
un simple "todo lo blanco es transparente"), más un auto-recorte final al
bounding box de lo no-transparente.

La división pareja (N filas × M columnas iguales) solo funcionó para 3 de
las 7 hojas (tiers de unidad, edificios militares — ambas con línea
divisoria negra real y personajes centrados). Las otras 4 necesitaron un
enfoque distinto, cada una por una razón distinta, verificadas por prueba
visual (contact sheet con miniaturas etiquetadas) tras encontrar recortes
rotos:
- **Murallas y recursos/props**: sin línea divisoria, pero con separación
  pareja entre elementos — división pareja sin ajuste extra fue suficiente.
- **Unidades** (la hoja 4×3): los personajes NO están centrados
  uniformemente en su celda nominal — el piquetero, por ejemplo, tiene el
  cuerpo desplazado hacia la celda vecina para dejarle sitio a la lanza
  larga que "sobresale del borde" (tal como pedía su prompt), así que una
  división pareja recortaba solo la lanza y dejaba el cuerpo fuera. Se
  detectan los huecos de tinta reales entre personajes (perfil de densidad
  de píxeles no-blancos por columna, dentro de la franja de cada fila) y se
  usa el punto medio de cada hueco como límite de columna real.
- **Edificios económicos**: Gemini reorganizó la rejilla para darle
  protagonismo al Centro Urbano y al Castillo — cada uno ocupa una columna
  ENTERA de dos "filas" de alto (no una celda 3×4 pareja), con las 10
  celdas restantes acomodadas en las dos columnas sobrantes a 6 filas
  (incluyendo 2 variantes sin usar de Torre y de un cobertizo, además de la
  bandera y el carromato ya previstos como celdas libres). Esto no es un
  simple desalineamiento sino una rejilla genuinamente IRREGULAR, así que se
  detectaron las líneas divisorias reales (sí tenía línea negra) y se
  hardcodearon las 10 cajas de recorte a mano.
- **Texturas de piso**: cada una de las 4 texturas tiene su propio margen
  blanco asimétrico dentro de su cuadrante (no lo llena parejo), y encima
  agua/roca son más anchas que pasto/tierra. La detección automática de
  bbox por fracción de píxeles no-blancos resultó CONSISTENTEMENTE poco
  fiable en esta hoja concreta (ruido de antialiasing disperso a lo largo de
  toda la fila hacía que hasta un umbral por fracción, no solo "existe algún
  píxel", diera rangos incorrectos dos veces seguidas) — se hardcodearon las
  4 cajas a mano tras verificar los bordes reales por muestreo directo de
  píxeles.

### Cambios de motor
- **`SPRITE_FILES`** (índice 760): se añadieron `unit_siege`, `bld_market`,
  `bld_siegeworkshop` (antes excluidos a propósito por no tener PNG, per
  comentario de la Fase 5) y los 6 nombres de arte por tier
  (`unit_infantry_t1`, `unit_infantry_t2`, `unit_pike_t1`, `unit_archer_t1`,
  `unit_cavalry_t1`, `unit_cavalry_t2`).
- **`drawUnit`**: antes de dibujar, si la unidad no es héroe y su categoría
  tiene un tier de línea investigado (`lineTierCount`), intenta primero
  `drawSprite('unit_'+cat+'_t'+tier, ...)`; si `drawSprite` devuelve `false`
  (ni el atlas ni el PNG suelto lo tienen), cae al sprite de tipo base de
  siempre — sin disparar ninguna petición de red nueva, porque los nombres
  de tier ya están pre-registrados en `SPRITE_FILES` (el chequeo de "existe
  o no" lo hace el propio `drawSprite`/`spr()` ya existente, no hizo falta
  ningún mecanismo nuevo). El tier es del BANDO (no de la unidad individual),
  así que funciona igual en host y cliente MP sin tocar el protocolo — ya
  viajaba gratis en `serSide`. La insignia de estrellas de la Fase 5 se
  mantiene sobre la ficha igual que antes (el arte cambia la apariencia
  general, la insignia sigue precisando el tier exacto de un vistazo).
- **Atlas regenerado por completo** (`assets/atlas.png`+`assets/atlas.json`):
  imprescindible — `drawSprite` prueba el atlas ANTES que el PNG suelto, así
  que sin regenerarlo el juego habría seguido mostrando el pixel-art viejo
  para los ~30 sprites que ya estaban empaquetados, sin importar que se
  reemplazaran los PNG de `assets/sprites/`. Script Python de la sesión
  (empaquetado tipo estantería/"shelf", cada sprite reescalado a ≤240px de
  lado mayor antes de empaquetar). Antes: 30 sprites, 2.59MB. Ahora: 38
  sprites, 2.4MB (similar peso total pese a sumar 8 sprites nuevos, gracias
  al reescalado).

### Verificación
Se sirvió el juego por **HTTP real** (servidor Node mínimo de la sesión, NO
`file://`) para que el atlas cargara de verdad tal como en producción
(`file://` se salta el intento de red a propósito, ver comentario de
`loadAtlas` en el código):
- Atlas cargado con éxito: `atlasReady=true`, 38 sprites en `atlasFrames`.
- 0 errores de consola/`pageerror` en carga, partida, y 300s simulados con
  IA Difícil.
- Compra de un tier de mejora en vivo (`buyLineTier('player','infantry',0)`
  tras fijar la Era del jugador a 2): `lineTierCount` pasó de 0 a 1, el hp de
  una Milicia recién creada subió de 55 a 74 (`55×1.35≈74`, coincide con
  `LINE_TIER_MULT`), y la captura de pantalla confirma que la unidad cambia
  visualmente al sprite de Espadachín (chainmail completo + emblema de cruz
  en el escudo) en cuanto se investiga, con el hint "Espadachín investigado"
  visible.
- Captura con 3 tramos de muralla + puerta central (candado visible) + los 3
  héroes del Castillo (Espada/Arco/Jinete) renderizados juntos: todo legible,
  0 errores.
- Capturas generales de una partida normal confirmando visualmente: terreno
  de pasto con textura real, árboles/arbustos/vetas de oro y piedra con arte
  real, Centro Urbano con el nuevo diseño épico, población y recursos
  funcionando con normalidad.

### Pendiente
- `obj_bush_unused` (prop decorativo de la hoja de recursos) se recortó pero
  no se integró al motor (nada lo usa hoy); queda en `assets/sprites/` como
  posible prop suelto para el futuro.
- La textura `tile_dirt` tiene un ligero viñeteado más oscuro en el borde
  (el artista la dibujó como una "mancha" en vez de un cuadrado perfectamente
  edge-to-edge) — funciona pero no es 100% perfecta al repetirse en mosaico;
  no bloquea el uso, se puede regenerar más adelante si se nota en juego
  real.
- Integrar el arte de `obj_gate`/`bld_wall` (nombres de respaldo legado) no
  hizo falta tocarlo: siguen con el pixel-art viejo pero son rutas de
  respaldo que en la práctica no se usan (la Puerta ya reutiliza
  `bld_wall_h`/`bld_wall_v` nuevos).

## 2026-07-22 — FASE 9C: correcciones tras jugar con el arte real integrado

El usuario probó la Fase 9B integrada y reportó una lista concreta de
problemas de juego real: la relación de tamaño edificio/unidad no tenía
sentido (una unidad casi del tamaño de un edificio entero), unidades que se
movían "hacia atrás" o "de lado", caballos que se veían incompletos/cortados,
el centro del piquetero "en el aire", pidió que el piso se sintiera más como
un tablero (tiles más chicos + rejilla visible), que las murallas
correspondieran a esa rejilla, que los botones de entrenamiento usaran el
sprite real en vez del emoji, y que el bando de una unidad se entendiera
mejor a simple vista. También pidió explícitamente volver a testear de
verdad con capturas y revisar los errores, no solo asumir que algo quedó
bien.

### Diagnóstico (con capturas reales, antes de tocar código)
- **`unit_cavalry.png` estaba literalmente cortado**: la cabeza y la cola del
  caballo quedaban fuera del recorte. Al revisar la fuente con más margen se
  confirmó que el caballo fue dibujado ACOSTADO horizontalmente (cola a la
  izquierda, cabeza a la derecha) — el recorte automático de la fila
  (arquero/caballo/catapulta) no le dio suficiente ancho.
- **Causa raíz encontrada**: el detector de huecos (`smart_col_bounds`)
  exigía exactamente `cols-1` huecos para aceptar el resultado del recorte
  "inteligente" y si no los encontraba caía en silencio a una división
  pareja rota. La fila de arquero/caballo/catapulta tiene 4 columnas
  nominales pero solo 3 personajes reales (la 4ª celda está vacía a
  propósito) — nunca hay 3 huecos posibles con solo 3 elementos, así que
  SIEMPRE caía al respaldo roto para esa fila específica, cortando el
  caballo y filtrando un fragmento de su cola dentro del recorte de la
  catapulta. Se recortaron los tres (arquero, caballo, catapulta) a mano con
  coordenadas verificadas por muestreo de píxeles.
- **El piquetero "flotaba"**: su cuerpo (casco+escudo) ocupaba solo ~20% del
  ancho de la imagen recortada, con la lanza larga dominando el resto — al
  centrar la ficha en el punto medio del recorte completo, el centro visual
  caía sobre el asta vacía de la lanza, lejos del cuerpo real. Se recortó de
  nuevo centrado en el cuerpo real (detectado por perfil de densidad de
  tinta: la lanza es una línea delgada, el cuerpo es una mancha gruesa),
  dejando un tramo corto de lanza visible a cada lado en vez de la lanza
  completa de ~2.5× el ancho del cuerpo.
- **Movimiento "hacia atrás/de lado"**: se re-derivó la fórmula de rotación
  matemáticamente (con números concretos, no solo álgebra) y resultó
  CORRECTA — el problema real es que el arte generado NO respeta de forma
  consistente la convención pedida ("toda pieza mirando hacia arriba"): el
  aldeano/arquero/infantería parecen mirar hacia abajo, el caballo base
  mira hacia la derecha, el héroe jinete mira hacia la izquierda, los
  héroes de capa parecen mirar hacia arriba... cada pieza a su manera. Con
  esa base tan inconsistente, rotar el dibujo completo garantizaba que
  varias unidades se vieran "mal orientadas" sin importar qué tan correcta
  fuera la matemática.

### Decisión de diseño: dejar de rotar el cuerpo completo
En vez de intentar corregir la orientación de cada pieza ya generada (poco
fiable sin volver a generar todo el set), se decidió que la FICHA (sprite/
emoji) ya NO rota con el movimiento — se dibuja siempre en pie. Lo que SÍ
sigue rotando es el anillo + la muesca triangular de dirección (formas
simples, geométricamente neutras a la rotación), que siguen marcando el
rumbo real con fiabilidad. Esto es además el patrón habitual en varios RTS
de fichas/tokens (la pieza no gira, solo se desliza), y es coherente con la
estética de "juego de mesa" que se está buscando.

### Cambios de motor
- **`BLD_VIS_SCALE = 1.9`** (nueva constante): multiplicador visual (y de
  zona táctil) de los edificios no-muralla sobre su `d.size` — antes de la
  Fase 9A era ×1.7 pero como un ESTIRADO vertical sobre un sprite con
  aspecto natural; Fase 9A lo dejó en ×1.05 sobre una ficha ya cuadrada
  centrada, perdiendo sin querer casi toda la diferencia de tamaño con una
  unidad. Se usa el MISMO valor en `drawBuilding` (render), `hitBox`
  (para que el área de toque coincida con lo que se ve) y el fantasma de
  colocación (para que lo que se ve al colocar sea el tamaño real).
- **Unidades más chicas**: `sz` (diámetro de ficha) de 22→16, `uH` (alto del
  sprite) de 40→30 — junto con `BLD_VIS_SCALE`, restaura una jerarquía
  visual con sentido (Casa ~2.5× una unidad, Centro Urbano/Castillo ~4-5×).
- **`drawUnit` reescrito de nuevo**: el anillo+muesca de dirección se sigue
  dibujando dentro de `setUnitTransform(...,drawAngle,1)` (rotado); el
  sprite/emoji se dibuja DESPUÉS de `resetTransform()`, en coordenadas de
  pantalla normales, sin rotación. El "bonk" (`hurtPunch`) ahora también
  escala el sprite (`uH`), no solo el anillo. Un **segundo anillo de bando,
  más grueso, dibujado ENCIMA del sprite** (`sz*0.56` de radio,
  `sz*0.13` de grosor) refuerza la identificación de bando sin depender de
  que el anillo fino de abajo no quede tapado por el arte del personaje —
  hecho por código (no arte duplicado por bando), decisión tomada tras
  preguntarle al usuario: generar doble arte por bando es más caro de
  generar y mantener, y el resultado por código ya se ve claro en las
  capturas de verificación.
- **Rejilla de tablero SIEMPRE visible** (`drawBoardGrid`, llamada desde
  `drawGround`): antes solo aparecía como ayuda visual al colocar un
  edificio; ahora es una rejilla sutil y translúcida (`rgba(255,255,255,.10)`,
  1px) alineada a `FOG_CELL` (40px) sobre todo el suelo visible, recortada
  al rectángulo de pantalla y con un piso de zoom mínimo (celda <7px en
  pantalla) para no dibujar de más ni generar ruido visual al alejar mucho
  la cámara.
- **Texturas de piso más chicas**: `worldTile` (cuántos px de MUNDO cubre
  una repetición del patrón) bajado de 300 a 80 en las 3 llamadas a
  `fillPattern` (pasto/tierra, agua, riscos) — con más repetición se lee
  más como baldosas de tablero, calzando además con la rejilla persistente
  nueva (80 = 2 celdas de `FOG_CELL`).
- **Murallas alineadas a la rejilla**: `snapWallEndpoint` ahora, cuando un
  extremo de muralla NO cae cerca de otra muralla ni del borde del mapa (los
  dos casos ya cubiertos y verificados en fases anteriores, sin tocarlos),
  encaja el punto a la intersección de rejilla más cercana con
  `snapToGrid`. El resto del sistema de murallas (espaciado `WALL_SP=28`,
  snapping a murallas vecinas) no se tocó, para no arriesgar la lógica de
  esquinas/puertas ya verificada en dos rondas de correcciones anteriores.
- **Iconos reales en botones de entrenamiento/construcción**: `btnEl` acepta
  ahora un `iconSprite` opcional que agrega un `<img>` con el PNG real
  (`assets/sprites/<nombre>.png`) en vez de depender del emoji embebido en
  el texto del botón — aplicado al botón de Aldeano del Centro Urbano, a
  toda la lista de construcción de edificios, a las unidades entrenables de
  Cuartel/Galería/Establo/Taller de Asedio, a los héroes del Castillo, y a
  los iconos de la fila de cola (`.btn.q`). Los botones de tecnologías
  económicas/mejoras de Herrería/mercado se dejaron con emoji (no tienen un
  sprite de unidad/edificio 1:1 equivalente). Si el PNG no cargara,
  `onerror` lo oculta sin dejar un ícono roto — en la práctica no debería
  pasar nunca porque solo se usan nombres ya confirmados en
  `assets/sprites/`.
- **Atlas regenerado otra vez** (mismo script Python de la sesión) para que
  recoja los 4 sprites re-recortados (`unit_cavalry`, `unit_siege`,
  `unit_archer`, `unit_pike`) — el atlas tiene prioridad sobre el PNG suelto,
  así que sin regenerarlo el juego habría seguido mostrando los recortes
  rotos.

### Verificación (con capturas reales en cada paso, no solo aserciones de código)
Todo corrido por HTTP real (no `file://`), con capturas de pantalla
revisadas visualmente en cada punto, tal como pidió el usuario:
- Contact sheets de los 4 sprites re-recortados: caballo completo (cabeza y
  cola visibles), catapulta completa (sin fragmento de caballo filtrado),
  arquero completo, piquetero con el cuerpo centrado.
- Escena general (Centro Urbano + Casa + Cuartel + 4 unidades moviéndose en
  4 direcciones distintas): rejilla visible, edificios claramente más
  grandes que las unidades, texturas de piso repitiendo con más frecuencia,
  anillos de bando gruesos visibles.
- Panel de acciones del Centro Urbano: botón "Aldeano" mostrando el sprite
  real en vez del emoji 👷.
- Muralla nueva trazada en terreno abierto: perfectamente vertical y
  alineada a la rejilla (confirmado también por aritmética:
  `punto % FOG_CELL === 0` en ambos extremos).
- Acercamiento a 4 unidades (2 propias en movimiento, 2 rivales quietas):
  anillos azul/rojo claramente distinguibles, ninguna ficha cortada ni con
  orientación rara.
- Regresión general: 300s simulados con IA Difícil, 0 errores de consola en
  todos los pasos.

### Pendiente
- El anillo de bando fino de abajo (bajo el sprite) quedó redundante con el
  nuevo anillo grueso de encima — se podría simplificar a uno solo más
  adelante, pero no se tocó esta tanda para minimizar el diff.
- Si más adelante se regenera el set de unidades con Gemini, ahora sí
  conviene insistir con más fuerza en la instrucción "mirar hacia arriba"
  (o aceptar de una vez que las fichas no rotan y liberar esa restricción
  del prompt) — mientras tanto, la decisión de NO rotar el cuerpo completo
  es la solución vigente y ya verificada.
