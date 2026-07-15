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
