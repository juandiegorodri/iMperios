# Mini-AoE ⚔️

Versión **ultra básica de Age of Empires** para jugar con pantalla táctil
directamente desde el navegador del iPad (Safari). Un solo archivo, sin
instalación, sin servidor y sin proceso de compilación.

## Cómo jugar

Abre **`index.html`** en el navegador. En el iPad puedes:
1. Subir el archivo a cualquier hosting estático (o tu iCloud Drive / Files) y
   abrirlo en Safari, o
2. Usar GitHub Pages (Settings → Pages → rama → `/root`).

Elige dificultad (Fácil / Normal / Difícil) y empieza.

### Controles táctiles
- **Toque simple** en una unidad → la selecciona.
- **Toque simple** con unidades seleccionadas: terreno → mover · recurso →
  recolectar (aldeanos) · enemigo → atacar · cimientos propios → construir.
- **Arrastre con un dedo** → caja de selección (unidades militares).
- **Doble toque** en una unidad → selecciona todas las de su tipo en pantalla.
- **Dos dedos** → mover cámara (paneo) y pellizcar para zoom.
- Botón **⌂** centra en tu base; **⏸** pausa.

### Objetivo
Recolecta 🍖 comida, 🪵 madera, 💰 oro y 🪨 piedra; crea aldeanos y ejército;
avanza de Era e investiga mejoras en la Herrería; y **destruye el Centro Urbano
enemigo** antes de que destruyan el tuyo.

### Cuadrilátero de combate (×2 de daño)
Arquero → Milicia → Piquetero → Caballo → Arquero (cada uno fuerte contra el
siguiente).

## Diseño completo

Ver **[`DESIGN.md`](DESIGN.md)** para el documento de diseño detallado
(interfaz táctil, economía, edificios, árbol tecnológico, IA y bucle de juego).

## Tecnología

Canvas 2D + JavaScript puro (sin dependencias). Pensado para poder migrarse a
Phaser.js o Pixi.js si se quiere ampliar.
