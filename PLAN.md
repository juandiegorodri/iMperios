# PLAN.md — Plan maestro: "que se sienta un RTS de verdad"

> **Objetivo del producto**: jugar iMperios desde el navegador del iPad,
> con controles táctiles de primera, y que la sensación sea la de un RTS real:
> vivo, legible, táctico y con ritmo.
>
> **Cómo usar este documento**: cada fase está escrita para que un modelo
> (Sonnet/Opus) la ejecute de principio a fin en una sesión. Ejecutar **una fase
> por PR**, en orden. Antes de empezar cualquier fase: leer `CLAUDE.md`
> (normas), `filemap.md` (dónde está cada cosa) y la sección «Reglas del
> ejecutor» de este documento.

---

## 1. Revisión del estado actual (2026-07)

**Métricas**: `index.html` ~2.370 líneas / 124 funciones; 34 sprites; ~4.5MB
de web desplegable; PWA + Vercel listos; multijugador LAN (WS) + app iOS.

### Lo que ya está fuerte
- Bucle RTS completo: economía (4 recursos, edificios de producción finitos,
  tecnologías), construcción, murallas con torres, 4 edades, héroes,
  cuadrilátero de contraunidades, reparación, población dinámica.
- IA con 3 doctrinas y objetivos estratégicos; 4 mapas temáticos (río con
  puente, riscos); resumen de partida.
- Táctil bien resuelto en lo básico: 1 dedo órdenes/caja, 2 dedos cámara,
  botones ≥44px, localizador de inactivos, cola editable.
- Gráficos pixel-art coherentes (manual en `assets/ART.md`) con fallback emoji.
- Multijugador anfitrión-autoritativo funcionando en LAN y app iOS montada.

### Las brechas que impiden que "se sienta un RTS real" (por impacto)
| # | Brecha | Síntoma para el jugador |
|---|--------|--------------------------|
| 1 | **Cero sonido y unidades estáticas** (se deslizan sin animación; sin proyectiles ni muertes) | "Parece una maqueta, no un juego" |
| 2 | **Sin niebla de guerra ni minimapa** | No hay exploración, ni tensión, ni mapa mental; te atacan y no te enteras |
| 3 | **Movimiento en línea recta** (`stepToward` solo esquiva deslizando) | Las unidades se atascan en edificios/murallas; los ejércitos llegan en fila india |
| 4 | **Sin mejoras de línea de unidad ni asedio** | Las edades casi no cambian tu ejército; las murallas son demasiado definitivas |
| 5 | **Control táctil sin atajos de RTS** (ni grupos de control, ni ataque-mover) | Microgestionar dos frentes a la vez es imposible |
| 6 | **Sin guardar/cargar ni ajustes** | Una interrupción = partida perdida |
| 7 | **Multijugador no funciona en la web https** (solo LAN/app) | No puedes retar a un amigo desde Vercel |
| 8 | Rendimiento sin presupuesto formal (atlas, GC, carga) | Riesgo de tirones en iPads viejos a medida que crece |

El plan ataca las brechas en ese orden: primero *sensación* (1-2), luego
*táctica* (3-4-5), luego *comodidad* (6), luego *alcance* (7-8).

---

## 2. Principios de diseño (no negociables entre fases)

1. **Todo objetivo táctil ≥ 44px**; nada depende de hover, clic derecho o teclado.
2. **La lógica vive en `index.html`** (sin build, sin frameworks); los assets en
   `assets/`. El juego debe seguir funcionando si falta un asset (fallback).
3. **60fps como meta en iPad**; cualquier sistema nuevo con coste por frame
   necesita presupuesto (medir antes/después con el patrón de `t22.cjs`).
4. **Cada acción del jugador produce feedback** en <100ms (visual y, tras la
   Fase 1, sonoro).
5. **Legibilidad ante todo**: unidades siempre distinguibles del terreno
   (aprendido en PR #7 con el terreno claro).
6. **No romper el multijugador**: todo estado nuevo que afecte simulación debe
   entrar en `serEntity/deserEntity/makeSnap` (bandos invertidos) y todo input
   nuevo del jugador debe tener su comando en `hostHandleCmd`.

## 3. Reglas del ejecutor (para Sonnet/Opus)

1. Lee `CLAUDE.md`, `filemap.md` y la fase que te toque de este `PLAN.md`.
2. Trabaja en la rama `claude/mini-aoe-browser-game-k5vf3r` sincronizada con
   `main`; **una fase = un PR** (borrador → revisar → fusionar).
3. **Prueba en Chromium headless** (Playwright: `require('/opt/node22/lib/node_modules/playwright')`,
   `executablePath:'/opt/pw-browsers/chromium'`): cero `pageerror`/`console.error`,
   ejercita la lógica nueva vía `page.evaluate`, captura pantalla a 1024×768@2x.
   Si tocas simulación/red: correr también el test multijugador (patrón `mp.cjs`:
   relé `node server.js` + 2 páginas).
4. Al terminar: actualizar `CLAUDE.md` (lista de funcionalidades), `progress.md`
   (bitácora), `filemap.md` (si cambia estructura), `assets/ART.md` (si hay
   sprites nuevos) y marcar la fase aquí en `PLAN.md` (⬜→✅).
5. Sprites nuevos: seguir el pipeline de `assets/ART.md` (Ideogram → hoja 2×2
   magenta → recorte/keying → verificación visual → `SPRITE_FILES`).
6. Si una decisión de diseño no está cubierta aquí, elegir la opción más simple
   que preserve los principios de la sección 2, y documentarla en `progress.md`.

---

## 4. FASES

### FASE 1 — «Está vivo»: animación, proyectiles y sonido ✅
**Por qué primero**: es el 80% de la sensación. Hoy las unidades se deslizan
mudas; con esto el mismo juego "se convierte" en un juego de verdad.

**Alcance**
1. **Animación de unidades sin nuevos assets** (procedural, barata):
   - Caminar: balanceo vertical (bob) de 2-3px + inclinación ±4° alternante en
     `drawUnit` cuando `state==='move'|'gather'(en camino)`, fase por `e.id`.
   - Atacar/recolectar: "lunge" hacia el objetivo (desplazamiento 4px hacia el
     target durante `e.anim>0`) + escala breve ya existente.
   - Volteo horizontal según dirección de movimiento (guardar `e.face=±1` al
     moverse; `ctx.scale(e.face,1)` alrededor del sprite).
2. **Proyectiles reales**: sistema `projectiles[]` (origen, destino, t, tipo).
   Arqueros/héroe arco/torres/castillo disparan una flecha visible (línea/sprite
   pequeño con rotación) que viaja ~300px/s; el daño se aplica al impactar
   (mover la llamada a `damage()` del atacante al impacto). En multijugador el
   host lo simula; enviar proyectiles en el snapshot (o recrearlos en cliente
   con `st==='attack'`, más simple: campo `shots` ligero en snap).
3. **Muertes y daño**: al morir, ghost del sprite con fade + caída 0.4s
   (sistema `corpses[]` solo visual, fuera de `entities`); flash blanco 80ms al
   recibir daño (`e.hurtT`); edificios <50% hp muestran humo (partículas simples),
   <25% fuego.
4. **Sonido (WebAudio, sin archivos)**: sintetizar SFX cortos (osciladores +
   ruido): golpe espada, flecha, talar, picar, construir (martillo), unidad
   lista, edificio destruido, alerta "te atacan", victoria/derrota, y un
   **loop ambiental** suave (viento/pájaros) a bajo volumen. Botón 🔊/🔇 en
   `#util` (persistir en `localStorage`). iOS: inicializar `AudioContext` en el
   primer toque (requisito de Safari).
5. **Micro-feedback táctil**: al dar una orden, mini-bandera/ping en el destino
   (ya hay `addPing`; añadir variante verde para órdenes de movimiento).

**Criterios de aceptación**
- Unidad caminando se ve caminar (bob+volteo); arquero dispara flecha visible
  que impacta; unidad muere con fade; edificio dañado humea.
- 8+ SFX distintos + ambiente; toggle persiste; sin autoplay antes del primer gesto.
- Headless: 0 errores; rendimiento por **presupuesto absoluto** — coste de
  `update()+render()` por cuadro muy por debajo de 16.7ms (meta 60fps) bajo
  estrés. (El % relativo vs. base es poco fiable en headless compartido, donde
  el scheduling del navegador domina el fps bruto; medir el coste real de CPU.)
- Multijugador: cliente ve proyectiles/muertes (snapshot o reconstrucción).

---

### FASE 2 — Niebla de guerra, minimapa y alertas ✅
**Por qué**: exploración y mapa mental = identidad RTS.

**Alcance**
1. **Niebla de 3 estados** en rejilla ~40px/celda (65×38): oculto (negro),
   explorado (oscurecido, edificios/terreno visibles, unidades no), visible.
   Visión por unidad/edificio (radio ~180/220px). Recalcular visible cada
   ~150ms en canvas offscreen de baja resolución escalado con la cámara
   (suavizado bilineal). El **cliente MP calcula su propia niebla** localmente
   (tiene las posiciones de sus unidades en el snap); el render de entidades
   enemigas se filtra por celda visible.
2. **Minimapa** (esquina inferior-derecha, ~160px, colapsable): terreno
   (una vez), niebla, puntos de unidades/edificios por bando, rectángulo de
   cámara. **Tocar/arrastrar = mover cámara**. Redibujar a 4-5Hz, no por frame.
3. **Alertas**: cuando algo tuyo recibe daño fuera de pantalla → SFX de alerta
   (Fase 1) + pulso rojo en el minimapa + botón "⚔️ ir al ataque" temporal en
   `#util` que centra la cámara. Throttle: 1 alerta/8s por zona.
4. La IA no hace trampa visualmente (puede seguir "sabiendo" internamente, pero
   documentarlo); el **jugador** solo ve lo revelado.

**Criterios**: mapa inicia negro salvo tu base; explorar revela; enemigos solo
visibles con visión; minimapa navega la cámara con el dedo; alerta funciona
(test: spawn enemigo pegando a un edificio fuera de cámara → botón aparece).
Presupuesto: niebla+minimapa <3ms/frame en el estrés.

---

### FASE 3 — Manos de RTS: grupos, ataque-mover y cámara pro ✅
**Por qué**: sin esto no puedes llevar dos frentes; es el techo de habilidad.

**Alcance**
1. **Grupos de control táctiles**: 3 ranuras (①②③) en `#util`. Con selección
   activa, mantener pulsada una ranura 0.5s = guardar; toque corto = seleccionar
   grupo; doble toque = seleccionar y centrar. Persisten ids (limpiar muertos).
2. **Ataque-mover** (botón ⚔️→ en el panel con militares seleccionados): las
   unidades avanzan al punto y atacan todo lo que encuentren (nuevo estado
   `amove` con `move`+auto-aggro continuo). Comando MP `amove`.
3. **Selección mejorada**: botón "🪖 Todo el ejército" (selecciona todos los
   militares vivos); en cajas mixtas, chips en `#selinfo` para filtrar por tipo
   con un toque; doble toque sobre edificio = todos los edificios del tipo.
4. **Cámara con inercia**: al soltar el paneo de 2 dedos, decaimiento ~0.9/frame;
   tope elástico en bordes. Botón ⌂ ya existe; añadir doble-toque ⌂ = ir a la
   última alerta.
5. **Rally visible y encadenable**: mantener el rally al tocar recurso = los
   nuevos aldeanos van directo a recolectar ese tipo (ya parcial en
   `spawnTrained`; completar con `rtype` correcto y mostrar bandera+línea).

**Criterios**: guardar/recuperar grupos con toques; a-move ataca por el camino
(test: fila de enemigos entre A y B → mueren al pasar); inercia sin "temblor";
todo con feedback (Fase 1). MP: `amove` y grupos funcionan en cliente.

---

### FASE 4 — Pathfinding y formaciones ✅
**Por qué**: es la brecha "invisible" más grande; los atascos rompen la magia.

**Alcance**
1. **A\* en rejilla gruesa** (celda 40px, 65×38): estático (edificios, río sin
   puente, riscos, murallas por bando) recalculado al construir/destruir.
   `stepToward` sigue waypoints del path suavizado (línea de visión: saltar
   waypoints visibles). Cache por destino compartido (un path por orden de
   grupo, offsets por unidad). Presupuesto: <2ms por orden de 30 unidades
   (A* es 65×38=2.470 celdas, trivial); repath si bloqueado >0.6s.
2. **Formaciones al mover en grupo**: destino en rejilla compacta (filas de
   ~6, separación 26px) alrededor del punto, asignando el slot más cercano a
   cada unidad (greedy). Militares cuerpo a cuerpo delante, arqueros detrás
   (orden por categoría).
3. **Puertas de muralla** (sprite `obj_gate` ya existe): al trazar una muralla,
   el tramo central es Puerta (nuevo `BLD.gate`): deja pasar unidades propias
   (colisión por bando en `blockedByWall` ya lo permite: hacer que la puerta no
   bloquee al dueño y sí al rival), HP menor que torre. Botón en panel de
   puerta: abrir/cerrar manual (cerrada bloquea a todos).
4. Separación (`separate`) consciente de murallas ya existe; revisar esquinas.

**Criterios**: una tropa rodea la base enemiga sin atascarse (test: destino
detrás de un anillo de murallas con puerta propia → entran por la puerta);
30 unidades llegan en formación (2-3 filas, no serpiente); sin caídas de fps.
MP: paths solo en host (cliente sigue snapshots, sin cambios).

---

### FASE 5 — Profundidad RTS: líneas de unidad, asedio, guarnición y mercado ✅
**Por qué**: que cada Era cambie tu ejército y las murallas tengan respuesta.

**Alcance**
1. **Líneas de mejora por Era** (investigables en el edificio productor):
   - Milicia→Espadachín (II)→Campeón (IV); Piquetero→Alabardero (III);
     Arquero→Arquero de Tiro Largo (III); Caballo→Caballero (III)→Paladín (IV).
   - Cada tier: +HP/+atk (~+35%), coste de investigación creciente, **tinte o
     insignia** visual (chevrons ▲▲ sobre la unidad; sprites nuevos opcionales).
     Aplica a unidades existentes y futuras del bando (guardar tier en `side.upg`;
     `unitAtk/maxHp` derivados). MP: tier viaja en `serSide`.
2. **Asedio — Catapulta** (Taller de Asedio 🏭, req. Era III + Cuartel):
   daño de área ×4 contra edificios/murallas, lentísima, débil cuerpo a cuerpo,
   proyectil parabólico (Fase 1). La IA Difícil construye 1-2 al asediar
   murallas (añadir a `DOCTRINE.hard`).
3. **Guarnición**: tocar torre/castillo propio con arqueros seleccionados =
   entran (max 4/8): +1 flecha por arquero, protegidos; botón "expulsar".
   Aldeanos pueden guarecerse en el Centro Urbano (no disparan, solo refugio).
4. **Mercado** 🏪 (Era II): intercambiar 100 de un recurso por 70 de oro y
   comprar 100 de recurso por 130 de oro (tasas fijas simples).
5. **Pasada de balance**: tabla en este PLAN de coste/DPS/HP revisada tras
   pruebas; objetivo: ninguna unidad domina >55% de enfrentamientos igualados
   fuera de su contra (script headless de arena 20v20 por matchup).

**Criterios**: investigar Espadachín actualiza stats+insignia de milicia viva;
catapulta derriba una muralla en ~8 tiros y pierde contra 2 caballos; guarnecer
duplica flechas de una torre; arena automatizada pasa los umbrales de balance.

**Resultado (2026-07-15, PR #14)**: implementado según el alcance. Tabla de
balance final de la arena 20v20 (25 combates/matchup, motor real vía
`update()`, ver `progress.md` para metodología y caveats sobre la
sensibilidad de un combate determinista sin kiting):

| Ataca \ Defiende | Arquero | Milicia | Piquetero | Caballo |
|---|---|---|---|---|
| **Arquero**   | — | **100%** (contra) | 56% (neutral) | 4% |
| **Milicia**   | 0% | — | **100%** (contra) | 44% (neutral) |
| **Piquetero** | 48% (neutral) | 0% | — | **100%** (contra) |
| **Caballo**   | **92-100%** (contra) | 36% (neutral) | 0% | — |

Stats ajustadas: `pike` hp55→60/atk5→6; `archer` hp35→55/atk5→5.4/cd1.5→1.2 y
penalización cuerpo a cuerpo 0.5→0.6; `cavalry` hp95→52/atk9→6.87. Los 4
contras del cuadrilátero dominan 92-100% (correcto); los 2 matchups neutrales
(Arquero-Piquetero, Milicia-Caballo) quedan ~50/50, dentro (o a 1 combate de
25 del límite) del tope del 55%. Sprites de catapulta/Taller de
Asedio/Mercado pendientes de generar (emoji de respaldo esta sesión, ver
`assets/ART.md`).

---

### FASE 6 — Partidas con memoria: guardar, ajustes y tutorial ✅
**Alcance**
1. **Guardar/cargar**: serializar partida completa (reutilizar
   `serEntity`+`serSide` sin flip + terrain/bridge/config/edad/fog explorada) a
   `localStorage` en 3 ranuras + **autoguardado** cada 2 min y al ocultar la
   pestaña (`visibilitychange`). Menú: "Continuar" si hay autoguardado.
   Solo un jugador (en MP, deshabilitado).
2. **Ajustes** (⚙️ en menú y en `#util`): volumen SFX/ambiente, velocidad de
   cámara, mostrar fps, reiniciar tutorial. Persisten en `localStorage`.
3. **Tutorial guiado** (primera partida): secuencia de 8-10 pasos con flecha
   señalando el objetivo real (recolecta 50 madera → construye casa → entrena
   milicia → mata al lobo/explora → …), avanza por eventos reales del juego.
   Saltable. Implementar como máquina de estados sobre hooks existentes.
4. **Fin de partida plus**: línea de tiempo simple (recursos/militar cada 30s,
   guardado durante la partida) dibujada en el resumen.

**Criterios**: guardar→recargar página→cargar = misma partida (test headless
compara entidades/recursos); tutorial completable y saltable; ajustes persisten.

**Resultado (2026-07-15, PR #15)**: implementado según el alcance. La única
sorpresa fue la guarnición: el formato de `serEntity` pensado para el
snapshot MP solo lleva el CONTEO de guarnecidos por edificio (al cliente le
basta, no simula), así que el guardado local necesitó una serialización
aparte con los ids reales (`save.garrisons`) para poder restaurar/expulsar
correctamente tras cargar — documentado como decisión de diseño en
`progress.md`. Ciclo guardar→recargar→cargar verificado con `localStorage`
real y `page.reload()` de verdad (no en memoria): 76 entidades, recursos,
Era, mapa y la posición exacta de un aldeano coinciden tras el ciclo
completo. Autoguardado de una partida de 194 entidades: 0.7ms y ~20KB.
Tutorial de 10 pasos verificado paso a paso simulando cada evento real
(gather, construir, entrenar, explorar, avanzar de Era, «Todo el ejército»);
saltable y no reaparece tras completarse/saltarse. Regresión de multijugador
(`server.js` + 2 páginas): 0 errores, y guardado/tutorial confirmados
inertes en MP. Detalle completo de las pruebas en `progress.md`.

---

### FASE 7 — Multijugador en la web (WebRTC) ✅
**Por qué**: jugar desde Vercel contra cualquiera, sin misma WiFi ni app.
**Estado**: el protocolo actual (host-autoritativo, `netOnMessage`,
`hostHandleCmd`, snapshots con flip) NO cambia; solo se añade **transporte**.

**Alcance**
1. **Abstraer transporte**: interfaz `net.sendRaw(str)` + `net.onRaw(str)`;
   implementación A = WebSocket LAN actual; B = **WebRTC DataChannel**.
2. **Señalización con PeerJS** (broker público en `wss://`, permitido desde
   https): cargar `https://unpkg.com/peerjs@1/dist/peerjs.min.js` **bajo
   demanda** (script dinámico al pulsar los botones online; mantener el juego
   sin dependencias en frío). Anfitrión: `new Peer()` → muestra **código de
   sala** de 6 caracteres (su peer id acortado/mapeado). Invitado: introduce el
   código → `peer.connect(id)` → DataChannel confiable/ordenado.
3. **UI**: sección multijugador con dos pestañas: «🌐 Online (código)» y
   «📶 Red local (IP)» (la actual). Mostrar el código grande + botón copiar.
4. **Robustez**: interpolación de posiciones en cliente (buffer de 2 snaps,
   lerp — quita los "saltitos" a 7Hz y mejora también LAN); compresión: enviar
   snapshot completo cada 1s y **deltas** (solo entidades cambiadas) entre
   medias; reconexión con el mismo código durante 60s (host guarda el último
   estado y reenvía `init`).
5. **Failovers claros**: si PeerJS no conecta (NAT duro), mensaje honesto con
   alternativa LAN/app. (TURN propio queda fuera de alcance.)

**Criterios**: dos pestañas headless juegan por WebRTC (PeerJS real) igual que
el test `mp.cjs`; movimiento del cliente fluido (lerp); deltas reducen >60% los
bytes/s medidos; LAN sigue funcionando.

**Resultado (2026-07-15/16, PR #16)**: LAN verificada sin regresión (2 páginas
headless, mismo protocolo). Lerp e interpolación verificados (73/73 muestras
distintas, monótonas, en 1.2s). Deltas verificados con cifras reales: ~79% de
reducción de bytes/s frente a snapshot completo siempre. El punto de WebRTC
real con PeerJS **no se pudo cerrar en headless**: el sandbox de este entorno
no da salida de red al proceso del navegador (ni con ni sin el proxy de
agente configurado explícitamente — `curl`/Node sí llegan a los mismos hosts
desde el shell, pero Chromium headless no), así que el script de PeerJS ni
siquiera termina de cargar (queda documentado con detalle en `progress.md`).
El código de la vía online está completo y su camino de fallo (mensaje
honesto, sin errores de consola, `net.mode` se limpia para poder reintentar)
quedó verificado; la conexión real queda pendiente de una red con internet de
verdad o del iPad.

---

### FASE 8 — Rendimiento, carga y calidad final ✅
**Alcance**
1. **Atlas de sprites**: empaquetar los PNG en 1-2 atlas (script Node con
   Playwright/canvas, guardar `atlas.png`+`atlas.json`); `drawSprite` lee del
   atlas (drawImage con recorte). Menos peticiones y memoria GPU; mantener
   fallback emoji.
2. **Pre-escalado**: al cargar, rasterizar cada sprite a su tamaño máximo de
   uso ×2 en offscreen canvas (evita reescalar 400px→40px cada frame).
3. **GC y allocs**: eliminar closures/arrays por frame en `update/render`
   calientes (revisar con heap snapshots); object pool para proyectiles/pings.
4. **Carga**: pantalla de carga con barra (sprites+audio), `<link rel=preload>`
   del atlas; meta descripción/og para compartir el link.
5. **Matriz QA final**: iPad Safari real (tocar TODO), iPhone (¿jugable?
   documentar), Chrome/Firefox escritorio, modo PWA instalado, rotación,
   multitarea (visibilitychange pausa en SP).
6. **Presupuesto**: estrés `t22` ≥55fps headless; partida 20 min sin fugas de
   memoria (heap estable ±10%).

**Criterios**: carga <2s en 4G simulado; fps estable; QA matrix documentada en
`progress.md` con resultados.

**Resultado (2026-07-16, PR #17)**: implementado según el alcance, con esto
el plan maestro **F1-F8 queda completo**. Atlas de 30/34 sprites
(`assets/atlas.png`+`.json`, 1024×2159, ~2.5MB) pre-escalados a su tamaño
máximo real de uso (fórmula por sprite en `assets/ART.md`), con fallback a
PNG suelto perezoso y luego emoji; verificado pixel-correcto (diferencia
media <3/255 en 6 sprites comparados atlas-vs-suelto). Object pool para
proyectiles y pings (retirada O(1) por intercambio con el último elemento en
vez de `.splice()`) y `frameWalls` reutilizando el array en vez de
`.filter()` cada cuadro. Pantalla de carga con barra de progreso + meta Open
Graph. Estrés headless: 285 entidades → `update()+render()` ≈1.4-1.5ms/cuadro
(presupuesto 16.7ms para 60fps, sobra ~91%); partida larga simulada (~20 min
de juego, 72.000 cuadros con combate continuo) con heap y arrays estables
(sin fugas). Regresión completa (un jugador + MP LAN) sin errores. Detalle
completo, matriz QA (verificado headless / pendiente de dispositivo real) y
el caveat de `file://`+CORS en `progress.md` (entrada 2026-07-16).

---

## 5. Orden, dependencias y cadencia

```
F1 Vida (anim+sonido)  ──►  F2 Niebla+minimapa  ──►  F3 Manos RTS
                                                          │
F5 Profundidad ◄── F4 Pathfinding+formaciones ◄───────────┘
      │
      ▼
F6 Guardar+tutorial ──► F7 MP web (WebRTC) ──► F8 Rendimiento final
```
- F1 y F2 son independientes entre sí (pueden invertirse), pero ambas antes que F3.
- F4 antes que F5 (la catapulta y las puertas necesitan paths decentes).
- F7 puede adelantarse si urge el online; solo depende del protocolo actual.
- Tras **cada** fase: fusionar a `main` (deploy Vercel automático) y probar en
  el iPad real del usuario antes de arrancar la siguiente.

## 6. Registro de fases
| Fase | Estado | PR | Notas |
|---|---|---|---|
| F1 Vida | ✅ | #10 | Animación procedural sin sprites nuevos, proyectiles reales con daño al impacto, cadáveres/flash/humo-fuego, 10 SFX sintetizados + ambiente, ping verde. Ver `progress.md` 2026-07-15. |
| F2 Niebla+minimapa | ✅ | #11 | Niebla de 3 estados (65×38 celdas, 40px), recálculo cada 150ms sobre offscreen de baja resolución escalado con suavizado bilineal; minimapa colapsable a ~4.5Hz con control táctil de cámara; alertas con throttle 8s/zona (pulso + botón ⚔️). Puramente render/cliente, protocolo MP intacto. Ver `progress.md` 2026-07-15. |
| F3 Manos RTS | ✅ | #12 | Grupos de control ①②③ (locales del cliente, limpian muertos); ataque-mover (estado `amove`, comando MP propio, auto-aggro continuo sin perder el destino); "Todo el ejército" + chips de filtro por tipo + doble toque en edificio; inercia de cámara con clamp elástico (sin temblor); rally encadenable sobre recurso con línea+bandera. Ver `progress.md` 2026-07-15. |
| F4 Pathfinding | ✅ | #13 | A* en rejilla gruesa (40px, cachada por bando, invalidada solo al construir/destruir muralla o alternar puerta), formaciones (filas de 6, melee delante/arqueros detrás, asignación greedy), Puerta 🚪 como tramo central de muralla, repath a los 0.6s atascado, separación consciente de murallas. MP: A* solo en el host. **Superado por la corrección post-lanzamiento del 2026-07-16** (2ª ronda): entonces una muralla normal NO bloqueaba a su propio dueño (solo al rival); ahora bloquea a TODOS, y solo una Puerta abierta deja pasar al dueño (con `frameOpenGates` dándole un pasillo real junto a la puerta). Ver `progress.md` 2026-07-15 y 2026-07-16 (2). |
| F5 Profundidad | ✅ | #14 | Líneas de mejora por Era (chevrons ▲, tier en `side.upg`, gratis en MP; insignia mejorada a óvalo+⭐ en la corrección post-lanzamiento); Catapulta + Taller de Asedio (daño de área ×4 vs edificios, proyectil parabólico; dibujo procedural en vez de emoji desde la 2ª ronda de correcciones); guarnición de torres/castillo/Centro Urbano (+1 flecha/arquero guarnecido; deshabilitada por defecto desde la corrección post-lanzamiento, opción de menú para activarla); Mercado (100 recurso ↔ 70/130 oro); pasada de balance con arena 20v20 headless (tabla arriba). Ver `progress.md` 2026-07-15 y 2026-07-16 (1 y 2). |
| F6 Memoria+tutorial | ✅ | #15 | Guardado local en 3 ranuras + autoguardado (2min/`visibilitychange`), reutiliza `serEntity`/`serSide` sin flip de bandos, guarnición reparada aparte con ids reales; ajustes (volumen SFX/ambiente, velocidad de cámara, fps, reiniciar tutorial) persistentes; tutorial de 10 pasos por sondeo de estado real (no temporizador), saltable, no se repite; línea de tiempo (recursos+valor militar cada 30s) en el resumen. Todo deshabilitado limpiamente en MP. Ver `progress.md` 2026-07-15. |
| F7 MP web | ✅ | #16 | Transporte abstraído (`net.sendRaw`/`net.onRaw`), transporte A=WS LAN sin cambios (regresión verificada) y B=WebRTC/PeerJS bajo demanda con código de sala de 6 caracteres; menú con pestañas Online/Red local; interpolación de posiciones en cliente (lerp por fotograma); snapshots con deltas (~79% menos bytes/s medido vs. completo); reconexión ~60s con el mismo código. PeerJS real no verificable en headless (sandbox sin egreso de red para el navegador) — código y fallback honesto verificados, conexión real pendiente de red/iPad. Ver `progress.md` 2026-07-15/16. |
| F8 Rendimiento | ✅ | #17 | Atlas de sprites pre-escalado (30/34, fallback PNG suelto perezoso→emoji), pool de proyectiles/pings (retirada O(1)), `frameWalls` sin `.filter()` por cuadro, pantalla de carga con barra + meta Open Graph. Estrés 285 entidades ≈1.4-1.5ms/cuadro; partida larga (~20min simulados) con heap estable; regresión SP+MP LAN sin errores. Plan **F1-F8 completo**. Ver `progress.md` 2026-07-16. |

## 7. Estado del plan: COMPLETO (F1-F8) + dos rondas de correcciones post-lanzamiento

El plan maestro de 8 fases se ejecutó por completo (PRs #10-#17, todas
fusionadas en `main`). Tras jugarlo de verdad, hubo **dos rondas más** de
correcciones (fuera del plan original, pero documentadas con el mismo rigor):

- **2026-07-16 (1) — PR #18**: 11 problemas de juego real — sonido de
  recolección continuo quitado; granjas/minas se recargan solas en vez de
  abandonarse; huecos en extremos de murallas cortas cerrados
  (`snapWallEndpoint`); puerta orientada según `e.dir`; insignia de tier
  legible (óvalo+⭐); catapulta con respaldo más visible; guarnición
  deshabilitada por defecto (antes ocurría por accidente al tocar el propio
  edificio); infografía rápida de controles al empezar cada partida; Centro
  Urbano con autodefensa; tiempo de tregua configurable; velocidad de
  partida ajustable en vivo desde Ajustes.
- **2026-07-16 (2) — PR #19**: 6 problemas más — **las murallas ahora
  bloquean también al dueño** (antes solo al rival; corrección de diseño
  importante, con su propio efecto colateral geométrico ya corregido — ver
  `frameOpenGates` en `progress.md`); torres de muralla gratis eliminadas
  (ahora se construyen explícitamente sobre un tramo, pagando su coste real);
  puerta con concordancia visual total con la muralla (mismo sprite + marca
  superior); catapulta y Taller de Asedio con dibujo procedural (sin sprites
  propios, Ideogram sigue sin estar disponible); sonido de construcción
  suavizado.

Detalle completo, cifras de cada prueba y metodología en `progress.md`
(entradas 2026-07-16). Listado de funcionalidades siempre actualizado en
`CLAUDE.md` §6.

**Pendientes conocidos y documentados con honestidad** (no bloquean el uso
normal del juego):
- Conexión WebRTC/PeerJS real de punta a punta (Fase 7): el código y el
  fallback están verificados, pero la señalización real no se pudo probar en
  el sandbox de desarrollo (sin salida de red para el navegador headless).
  Pendiente de probar con una conexión a internet real o desde el iPad.
- Matriz de QA en dispositivo físico (iPad/iPhone Safari real, PWA instalada,
  rotación, multitarea) — Fase 8: no verificable sin hardware real.
- Sprites propios de Catapulta, Taller de Asedio y Mercado (`unit_siege.png`,
  `bld_siegeworkshop.png`, `bld_market.png`): Ideogram requiere
  re-autenticación, no disponible en ninguna sesión hasta ahora. Mientras
  tanto usan un respaldo procedural/emoji (ver `assets/ART.md`).

Si se retoma el proyecto en una sesión nueva: leer `CLAUDE.md` (normas y
listado de funcionalidades), `filemap.md` (dónde está cada cosa en
`index.html`) y las últimas entradas de `progress.md` para el contexto
completo antes de tocar código.

### FASE 9 (nueva, fuera de la numeración F1-F8 original) — Vista de tablero

Iniciada y completada 2026-07-21/22 por pedido directo del usuario: pivote de
dirección de arte hacia una cámara **cenital estricta** (90°) con estética de
**ficha de juego de mesa tipo sticker**, sin cambiar la simulación (mismo RTS
en tiempo real, mismo mapa, misma niebla). Fase A (motor: rejilla de
colocación para edificios/unidades libres, fichas centradas con trim de
bando, rotación real al movimiento, refuerzo del efecto de interacción,
`hitBox` simplificado), Fase B (arte real de Gemini recortado, fondo
quitado, integrado con arte propio por tier de mejora de línea, atlas
regenerado) y **Fase C** (correcciones tras jugar de verdad con el arte
integrado: proporción edificio/unidad corregida con `BLD_VIS_SCALE`,
recorte arreglado de caballo/catapulta/arquero/piquetero, decisión de dejar
de rotar el sprite del personaje —solo rota el anillo/muesca de bando,
porque el arte generado no respeta un "mirar hacia arriba" consistente—,
rejilla de tablero permanente y murallas alineadas a ella, iconos de sprite
real en los botones de entrenamiento/construcción, y un segundo anillo de
color de bando reforzado sobre la ficha) **ya están fusionadas** — el juego
usa el set v2 completo, no quedan sprites pixel-art v1 en uso, y ya fue
verificado tras un playtest real. Detalle completo en `progress.md`
(entradas 2026-07-21 y 2026-07-22, incluida "FASE 9C: correcciones tras
jugar con el arte real integrado") y `CLAUDE.md` §6.
