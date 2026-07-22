# Manual de línea gráfica — iMperios

Guía para que **todos** los sprites del juego mantengan el mismo estilo y se
entiendan de un vistazo. Las imágenes se generan con Ideogram siguiendo estas
reglas y se guardan en `assets/sprites/`.

> **✅ Pivote de dirección de arte completado (FASE 9, 2026-07-21/22)**: el
> set activo en `assets/sprites/` YA ES el estilo v2 — vista cenital
> ESTRICTA (90°) con estética de **ficha de juego de mesa tipo sticker**
> (contorno grueso, colores planos vivos, arte NEUTRO de bando — el motor
> pinta encima un borde blanco + uno de color de bando). Generado con
> Gemini (no Ideogram) siguiendo la especificación completa en
> **[`board/board_sprites.json`](board/board_sprites.json)** (7 hojas:
> unidades, tiers de mejora, edificios económicos, edificios militares,
> murallas, recursos/props, texturas de piso — cada celda con su prompt
> exacto), recortado y con el fondo quitado por un script de la sesión, y
> reempaquetado en `assets/atlas.png`/`atlas.json`. El resto de esta sección
> (§1-4) describe el estilo **v1** (pixel-art 8-bit, ya REEMPLAZADO por
> completo) — se conserva sin reescribir como referencia histórica y por si
> hiciera falta reconstruir algún sprite suelto con ese criterio antiguo.
> Detalle completo del pipeline de recorte/integración en `progress.md`
> (entrada 2026-07-22).

---

## 1. Estilo visual (la "línea gráfica")

- **Técnica**: *pixel art* estilo **8/16-bit** (retro, bordes nítidos, sin
  degradados suaves; sombreado por bloques de color).
- **Cámara**: **vista cenital de alto ángulo** (mirando desde arriba con una
  ligera inclinación ~70°) para que cada objeto se lea bien desde el aire.
- **Lectura clara**: un objeto **centrado** por sprite, silueta reconocible que
  ocupa ~70-80% del encuadre, con **contorno oscuro** de 1 px para destacar
  sobre el terreno.
- **Fondo**: se genera sobre **fondo plano** (magenta `#FF00FF` o blanco) y luego
  se le quita el fondo → **PNG transparente**.
- **Sombra**: una **elipse de sombra** suave bajo el objeto (integrada o añadida
  en el juego) para anclar la unidad/edificio al suelo.
- **Sin texto, sin marcos, sin firmas, sin números** dentro del sprite.
- **Neutral de bando**: las unidades se dibujan en colores neutros; el bando
  (azul jugador / rojo IA) se indica con el **anillo de color** que el motor ya
  dibuja bajo cada unidad. No "pintar" la unidad de azul/rojo.

### Paleta base (medieval terrosa)
- Verdes hierba: `#4f8a3f` `#3f7d3f` `#2e5e2a`
- Marrones/madera: `#8a5a2b` `#6b4423` `#caa46a`
- Piedra/gris: `#9aa3b2` `#6b7280` `#3a3f47`
- Oro: `#e6c34a` `#c9a227`
- Acento rojo (techos/banderas): `#c0455a`
- Piel/tela: `#e8b98a` `#d9d2c5`

### Tamaños
- Generación: cuadrícula a **2048×2048** (celdas de 512×512) o sprites sueltos a
  **1024×1024**. Siempre alta resolución; el juego **reescala** al tamaño final.
- Tamaños en juego (aprox.): unidades **26-30 px**, recursos **28-34 px**,
  edificios **40-74 px** (Centro Urbano y Castillo los más grandes).

---

## 2. Pipeline de producción (cómo se hacen)

1. **Generar** con Ideogram. Para varios objetos: pedir una **cuadrícula**
   (p. ej. 2×2 o 4×3) de objetos separados, mismo estilo, fondo plano. Para
   piezas sueltas: un objeto centrado.
2. **Descargar** la imagen (URL de Ideogram) a `assets/_raw/`.
3. **Recortar** por celdas de la cuadrícula y **auto-ajustar** a la caja del
   contenido (bounding box de píxeles no-fondo) con Playmáwright + Canvas.
4. **Quitar fondo** (transparencia) — `remove_background` o chroma-key del color
   plano.
5. **Reescalar/optimizar** y guardar en `assets/sprites/<nombre>.png`.
6. **Verificar** (ver sección 4) y, si no cumple, **regenerar**.
7. **Integrar**: registrar el nombre en `SPRITES` dentro de `index.html`. El
   motor lo dibuja con `drawSprite(...)` y, si falta, usa el emoji de respaldo.

### Prompt base (sufijo de estilo, se añade a cada objeto)
> "top-down high-angle **8-bit pixel art** game sprite, single object centered,
> bold readable silhouette, 1px dark outline, flat **#FF00FF magenta**
> background, no text, no shadow border, medieval RTS, earthy palette"

---

## 3. Lista de elementos (assets) y animaciones

> Estado: ⬜ pendiente · 🟡 generado/sin verificar · ✅ integrado.
> «Anim» describe la animación objetivo (de momento se implementan estáticos +
> el rebote/escala que ya hace el motor; los fotogramas extra son fase 2).
>
> **Hecho (PR #6): las 8 unidades, los 12 edificios y los 4 recursos.**
> **Hecho (PR #7): terreno (pasto, agua, roca/tierra), montaña, muralla, torre de
> muralla y puerta.** Total 32 sprites integrados (✅). Hojas fuente en
> `assets/_raw/*.webp` y sprites finales en `assets/sprites/*.png`.

### Unidades (neutras; el bando lo da el anillo)
| Sprite | Archivo | Anim objetivo | Estado |
|---|---|---|---|
| Aldeano | `unit_villager.png` | idle, caminar (2f), recolectar (golpe) | ⬜ |
| Milicia | `unit_infantry.png` | idle, caminar, atacar (espada) | ⬜ |
| Piquetero | `unit_pike.png` | idle, caminar, atacar (pica) | ⬜ |
| Arquero | `unit_archer.png` | idle, caminar, disparar (arco) | ⬜ |
| Caballo | `unit_cavalry.png` | idle, galopar, embestir | ⬜ |
| Héroe Espada | `unit_hero_sword.png` | idle, atacar (aura ⭐) | ⬜ |
| Héroe Arco | `unit_hero_archer.png` | idle, disparar (aura ⭐) | ⬜ |
| Héroe Jinete | `unit_hero_cav.png` | idle, galopar (aura ⭐) | ⬜ |

### Edificios (vista cenital, tejado visible)
| Sprite | Archivo | Anim objetivo | Estado |
|---|---|---|---|
| Centro Urbano | `bld_town.png` | bandera ondeando, humo | ⬜ |
| Casa | `bld_house.png` | humo de chimenea | ⬜ |
| Cuartel | `bld_barracks.png` | estandarte | ⬜ |
| Galería de Tiro | `bld_range.png` | diana | ⬜ |
| Establo | `bld_stable.png` | — | ⬜ |
| Herrería | `bld_blacksmith.png` | chispas/yunque | ⬜ |
| Torre | `bld_tower.png` | destello al disparar | ⬜ |
| Castillo | `bld_castle.png` | banderas, destello | ⬜ |
| Granja | `bld_farm.png` | trigo meciéndose | ⬜ |
| Mina de Oro | `bld_goldmine.png` | brillo | ⬜ |
| Mina de Piedra | `bld_quarry.png` | — | ⬜ |
| Bosquero | `bld_lumbercamp.png` | — | ⬜ |

### Recursos (objetos del mundo)
| Sprite | Archivo | Anim objetivo | Estado |
|---|---|---|---|
| Arbusto de bayas (comida) | `res_food.png` | leve balanceo | ⬜ |
| Árbol (madera) | `res_wood.png` | leve balanceo | ⬜ |
| Veta de oro | `res_gold.png` | destello | ⬜ |
| Roca de piedra | `res_stone.png` | — | ⬜ |

### Terreno (texturas tileables) — opcional, fase 2
| Sprite | Archivo | Notas | Estado |
|---|---|---|---|
| Hierba (llanura) | `tile_grass.png` | tileable 256×256 | ⬜ |
| Suelo de bosque | `tile_forest.png` | tileable | ⬜ |
| Suelo rocoso (riscos) | `tile_rock.png` | tileable | ⬜ |
| Agua (río) | `tile_water.png` | tileable | ⬜ |
| Puente | `tile_bridge.png` | tablones | ⬜ |

### Efectos / UI — opcional, fase 2
| Sprite | Archivo | Notas | Estado |
|---|---|---|---|
| Flecha | `fx_arrow.png` | proyectil arquero/torre | ⬜ |
| Aura de héroe | `fx_hero_aura.png` | brillo dorado | ⬜ |
| Bandera de reunión | `fx_rally.png` | punto de rally | ⬜ |

### Pendientes de la Fase 5 (PR #14) — sin generar esta sesión
Ideogram no estaba disponible (requiere re-autenticación); las 3 entidades
nuevas de la Fase 5 usan el **respaldo de emoji** del motor y sus nombres
**NO** se registraron en `SPRITE_FILES` a propósito (para no generar
peticiones 404 que Chromium reporta como `console.error` y violan la regla
de "cero errores de consola" de `CLAUDE.md` §4). Cuando se generen, añadir el
nombre correspondiente a `SPRITE_FILES` en `index.html`:
| Sprite | Archivo (a crear) | Emoji de respaldo actual | Notas |
|---|---|---|---|
| Catapulta | `unit_siege.png` | 🎯 (respaldo procedural, ver abajo) | vista cenital, muy grande/pesada, ruedas de madera, brazo de lanzamiento visible |
| Taller de Asedio | `bld_siegeworkshop.png` | 🏭 (respaldo con silueta) | cobertizo abierto con vigas de madera, similar tamaño a Cuartel |
| Mercado | `bld_market.png` | 🏪 | toldo/puesto con mercancías apiladas, distinto de Casa/Granja |

**Respaldo mejorado sin sprite** (2026-07-16, tras feedback de juego real: el
emoji solo se veía pequeño y "sin gráfica"): mientras no exista `unit_siege.png`,
la Catapulta se dibuja con una forma **vectorial propia** (`drawCatapultIcon`
en `index.html`: ruedas, chasis de madera, brazo lanzador con contrapeso) en
vez de un emoji; el Taller de Asedio usa una silueta con tejado a dos aguas
(triángulo + cuerpo) con el emoji 🏭 dentro, en vez de un cuadro plano. Cuando
se generen los PNG reales, estos respaldos procedurales dejan de usarse solos
(el motor siempre prueba primero el sprite/atlas).

### Atlas de sprites (Fase 8, PR #17)
Para reducir peticiones de red y el coste de reescalar sprites cada cuadro, 30
de los 34 PNG de `assets/sprites/` (todos salvo las 4 texturas tileables
`tile_*`, que se quedan sueltas — ver más abajo) se empaquetan en
`assets/atlas.png` + `assets/atlas.json` mediante un script Node
(`build_atlas.cjs`, generado y ejecutado en la sesión, **no forma parte del
repo** — el mismo criterio que `arena.cjs` en la Fase 5). El script:
1. Lee las dimensiones nativas de cada PNG.
2. Calcula, a mano, la altura de destino MÁXIMA real con la que ese sprite se
   dibuja en juego (a partir de las fórmulas de `drawSprite(...)` en
   `index.html`: `size*escala*zoom_máx(1.6)*DPR(2)`, con un margen del 15%), y
   la clampa a la altura nativa (nunca sobre-escala más allá del detalle real
   de la fuente: si lo pedido es mayor que lo que hay, se copia tal cual).
3. Empaqueta cada sprite ya PRE-ESCALADO a ese tamaño en un único lienzo
   (empaquetado "shelf", 1024px de ancho) y guarda `atlas.png` (RGBA) +
   `atlas.json` (`{w,h,frames:{nombre:{x,y,w,h}}}`).

Resultado: atlas de 1024×2159 (~2.5MB) para 30 sprites, frente a ~3.7MB en 30
peticiones sueltas — menos peticiones Y sin tener que reescalar desde el PNG
nativo (hasta 462px) hasta los ~30-70px con que se ve una unidad/edificio en
pantalla. `drawSprite(...)` en `index.html` intenta el atlas primero
(`ctx.drawImage` con recorte por las coordenadas de `atlas.json`); si el atlas
no cargó (o le falta ese nombre) cae al PNG suelto de `assets/sprites/`
(carga perezosa, solo bajo demanda) y, si tampoco existe, al emoji de
respaldo de siempre. Verificado con comparación de píxeles (ver
`progress.md`): diferencia media <3/255 por canal frente al PNG suelto al
mismo tamaño de destino (el margen viene de que el atlas añade un paso de
reescalado extra, no de un recorte incorrecto).

Las 4 texturas `tile_grass/water/mountain/dirt` se quedan **fuera** del atlas
a propósito: se usan con `ctx.createPattern(img,...)` sobre la imagen
COMPLETA (repite el sprite entero como textura); meterlas en el atlas
obligaría a recortarlas primero a un canvas aparte para no repetir el atlas
entero como patrón, y con solo 4 archivos de 256×256 cacheados una vez
(`_patterns`) el ahorro sería nulo frente al riesgo de un patrón mal
recortado.

### Murallas y Puerta (PR #7 / Fase 4; actualizado en la corrección post-lanzamiento del 2026-07-16)
Sprites ya integrados fuera de la tabla anterior: `bld_wall.png`/
`bld_wall_h.png`/`bld_wall_v.png` (muro, con variantes horizontal/vertical
según `e.dir`), `bld_wall_tower.png` (Torre de Muralla) y `obj_mountain.png`
(montañas decorativas de los riscos). La **Puerta** (edificio `gate`) usaba
originalmente `obj_gate.png` (una puerta de madera grande, sin variantes h/v,
que desentonaba con el resto de la muralla de piedra). Tras feedback de juego
real se cambió a dibujarse con el **mismo sprite que un tramo de muralla
normal** (`bld_wall_h`/`bld_wall_v` según `e.dir`, concordancia visual total)
más una pequeña marca oscura en la parte de arriba (dibujada por código, no
un sprite nuevo) para diferenciarla, además del candado 🔒 (cerrada) / 🔓
(abierta) en emoji, siempre visible —no solo al seleccionarla— para que se
note su estado de un vistazo. `obj_gate.png` queda sin uso en el motor
(se conserva en `assets/sprites/` por si se retoma en el futuro).

---

## 4. Criterios de verificación (el "loop")

Cada sprite debe cumplir, antes de integrarse:
1. **Se entiende**: al describir la imagen (Ideogram `describe_image` o revisión
   visual) se reconoce **qué objeto es** sin pistas.
2. **Vista correcta**: cenital de alto ángulo (no de perfil puro ni 3D realista).
3. **Estilo**: pixel art 8-bit con contorno; coherente con el resto.
4. **Fondo limpio**: transparente, sin restos del color plano ni halos.
5. **Encuadre**: objeto centrado, sin recortes en los bordes.

Si alguno falla, se **regenera** ajustando el prompt y se vuelve a verificar.
