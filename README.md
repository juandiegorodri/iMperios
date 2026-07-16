# Mini-AoE ⚔️

Versión **ultra básica de Age of Empires** para jugar con pantalla táctil
directamente desde el navegador del iPad (Safari). La lógica vive en un único
**`index.html`** (Canvas 2D + JavaScript puro, sin dependencias ni compilación);
los **gráficos** son sprites pixel-art en `assets/sprites/` (con respaldo de
emoji si faltan, así el juego nunca se rompe).

## Cómo jugar

Sírvelo como sitio estático y ábrelo en Safari. Opciones:
- **Vercel** (recomendado): conecta el repo; es un sitio **estático sin build**
  (ver `vercel.json`). Sirve `index.html` en la raíz. Al fusionar en `main` se
  despliega solo. Incluye manifest e icono para **«Añadir a pantalla de inicio»**.
- **GitHub Pages**: Settings → Pages → rama `main` → `/ (root)`.

> ⚠️ El **multijugador por red local** (pestaña «📶 Red local (IP)») usa
> WebSocket `ws://` y por seguridad del navegador **no funciona desde una web
> `https://`** (Vercel/Pages). Úsalo desde la **app de iPad** (`ios/`) o
> abriendo el juego por `http`/`localhost` (`node server.js`). Para jugar
> desde `https://` (p. ej. el propio despliegue de Vercel) sin estar en la
> misma red, usa la pestaña **«🌐 Online (código)»** (WebRTC): un jugador crea
> una sala y comparte el código de 6 caracteres, el otro lo introduce y
> conecta. El modo un jugador funciona perfecto en la web sin nada de esto.

En el **menú principal** eliges: mapa (Llanura / Río / Selva Negra / Riscos),
recursos iniciales, velocidad, inteligencia de la IA y tu posición. También hay
una pantalla **«🎨 Prueba gráfica»** que lista todos los sprites.

### Controles táctiles
- **Toque simple** en una unidad → la selecciona.
- **Toque simple** con unidades seleccionadas: terreno → mover · recurso o
  edificio de producción → recolectar (aldeanos) · enemigo → atacar · cimientos
  propios → construir · edificio propio dañado → reparar.
- **Arrastre con un dedo** → caja de selección. **Doble toque** → todas las
  unidades de ese tipo en pantalla.
- **Dos dedos** → mover cámara (paneo) y pellizcar para zoom.
- Botón **👷** localiza aldeanos inactivos; **⌂** centra en tu base; **⏸** pausa.

### Objetivo
Recolecta 🍖 comida, 🪵 madera, 💰 oro y 🪨 piedra; crea aldeanos y ejército;
avanza de Era, investiga mejoras y tecnologías; y **destruye el Centro Urbano
enemigo** antes de que destruyan el tuyo.

### Cuadrilátero de combate (×2 de daño)
Arquero → Milicia → Piquetero → Caballo → Arquero (cada uno fuerte contra el
siguiente). Los héroes del Castillo heredan la categoría de su tipo.

### Multijugador (dos pestañas en el menú)
- **🌐 Online (código)**: un jugador pulsa **«Crear sala»** y comparte el
  código de 6 caracteres que aparece en pantalla; el otro pulsa **«Unirse con
  código»**, lo escribe y conecta. Usa WebRTC (señalizado con PeerJS, cargado
  solo al pulsar el botón) — funciona **desde `https://`**, sin estar en la
  misma red ni usar la app de iPad. Si la conexión se cae en plena partida,
  reintenta con el mismo código hasta 60s antes de rendirse.
- **📶 Red local (IP)**: uno pulsa **«Crear partida (anfitrión)»** y el otro
  **«Unirse a una partida»** con la IP del anfitrión. En iPad, la app de
  `ios/` incluye el servidor; en escritorio, corre `node server.js` en la
  máquina del anfitrión. Solo funciona por `http`/`localhost` (ver aviso
  arriba).

Detalles del protocolo (host autoritativo, snapshots, comandos) y ambos
transportes: **[`iOS.md`](iOS.md)**.

## Funcionalidades

El listado completo y siempre actualizado está en **[`CLAUDE.md`](CLAUDE.md)**.
En resumen: 4 edades, ~12 edificios (incl. Casa, Castillo, granjas/minas con
capacidad finita, Torre), héroes, **murallas** con torres de arqueros, IA con
tres doctrinas, mapas temáticos (río con puente, riscos), resumen de partida,
**multijugador P2P** (LAN por WebSocket y Online por WebRTC/código de sala),
app iOS para iPad, y gráficos pixel-art con vista cenital.

## Documentación

- **[`DESIGN.md`](DESIGN.md)** — documento de diseño (GDD).
- **[`PLAN.md`](PLAN.md)** — plan maestro por fases (hoja de ruta ejecutable).
- **[`iOS.md`](iOS.md)** — app de iPad (Xcode) y arquitectura multijugador.
- **[`CLAUDE.md`](CLAUDE.md)** — guía del proyecto, normas y listado de
  funcionalidades.
- **[`filemap.md`](filemap.md)** — mapa de archivos y estructura del código.
- **[`progress.md`](progress.md)** — bitácora de avance.
- **[`assets/ART.md`](assets/ART.md)** — línea gráfica y lista de sprites.

## Tecnología

Canvas 2D + JavaScript puro (sin dependencias). Sprites generados con Ideogram
según `assets/ART.md`. Pensado para poder migrarse a Phaser.js / Pixi.js si se
quiere ampliar.
