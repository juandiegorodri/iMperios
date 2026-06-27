# Mini-AoE — Documento de Diseño (GDD)

Versión web ultra básica de Age of Empires, pensada para jugarse con **pantalla
táctil desde el navegador del iPad** (Safari) sin instalar nada, sin servidor y
sin proceso de compilación. Todo vive en un único archivo `index.html`
(Canvas 2D + JavaScript puro).

Este documento es la descripción larga y detallada del juego. El archivo
`index.html` es la implementación jugable de lo aquí descrito.

---

## 0. Principios de diseño

1. **Cero fricción**: se abre como una página web. Un solo archivo. Funciona
   offline una vez cargado.
2. **Táctil primero**: todos los objetivos de toque miden ≥ 44 px. Nada depende
   de clic derecho, teclado o paso del ratón por encima (hover).
3. **Ultra básico pero completo**: economía, construcción, ejército, combate con
   contraunidades, mejoras, IA enemiga y condición de victoria. Lo justo para
   que sea *un juego de verdad*, no una maqueta.
4. **Legible en pantalla pequeña**: vista cenital (desde arriba), sprites
   simples (emoji/figuras), UI en los bordes para no tapar el campo de juego.

---

## 1. Interfaz y control táctil

### 1.1 Cámara
- **Paneo**: arrastrar con **dos dedos** mueve el mapa. Se usan dos dedos para
  no confundir el movimiento de cámara con las órdenes a las unidades.
- **Zoom**: pellizco (pinch) con dos dedos.
- **Botón "Centrar"**: vuelve la cámara a tu Centro Urbano.
- En escritorio (para pruebas): rueda del ratón = zoom; flechas = paneo.

### 1.2 Selección
- **Toque simple** sobre una unidad propia → la selecciona (reemplaza la
  selección anterior).
- **Arrastre con un dedo** sobre el terreno → dibuja una **caja de selección**
  que selecciona todas las unidades militares propias dentro del recuadro.
- **Doble toque** sobre una unidad → selecciona **todas las unidades del mismo
  tipo** visibles en pantalla (todos los arqueros, todos los aldeanos…).
- **Toque en vacío** → deselecciona.

### 1.3 Órdenes contextuales (acción según lo que tocas)
Con una o varias unidades seleccionadas, un **toque simple** se interpreta así:
- Tocas **terreno libre** → las unidades se mueven allí.
- Tocas un **recurso** (árbol, arbusto, veta) → los **aldeanos** van a
  recolectarlo.
- Tocas una **unidad o edificio enemigo** → las unidades **militares** van a
  atacarlo.
- Tocas un **edificio propio en construcción** → los aldeanos van a construirlo.

### 1.4 Panel de acciones (parte inferior)
Botones grandes (≥ 44 px) que **cambian según lo seleccionado**:
- **Aldeano** → menú de construcción (Cuartel, Galería, Establo, Herrería) +
  "Detener".
- **Centro Urbano** → "Crear Aldeano" y (si estás en la Edad de las
  Herramientas) "Avanzar de Era".
- **Cuartel** → "Milicia", "Piquetero".
- **Galería de Tiro** → "Arquero".
- **Establo** → "Caballo".
- **Herrería** → las cuatro mejoras globales (requieren Edad de las
  Herramientas).
- **Militar** → "Detener".

Cada botón muestra su **coste** y se **deshabilita** si no hay recursos, si falta
el prerrequisito o si se alcanzó el límite de población.

### 1.5 Barra superior
Marcador siempre visible: 🍖 Comida · 🪵 Madera · 🪙 Oro · 🪨 Piedra ·
👥 Población (actual / máxima) · Era actual.

### 1.6 Punto de reunión (rally point)
Con un edificio de producción seleccionado, un toque en el terreno fija el
**punto de reunión**: las unidades nuevas aparecen y caminan hasta ahí.

---

## 2. Economía y recursos

Cuatro recursos, cada uno con su fuente y su uso:

| Recurso | Fuente | Se usa para |
|---|---|---|
| 🍖 **Comida** | Arbustos de bayas | Aldeanos, Milicia, Piqueteros, Caballos; mejoras |
| 🪵 **Madera** | Árboles | Todos los edificios; Arqueros; mejoras |
| 🪙 **Oro** | Vetas amarillas | Caballos, Arqueros; avance de Era; mejoras |
| 🪨 **Piedra** | Vetas grises | Avance de Era; mejoras defensivas (futuro: torres) |

**Mecánica simplificada de recolección**: en cuanto el aldeano completa un
ciclo de recolección, el recurso se suma **directamente al marcador global**.
No hay que caminar de vuelta al Centro Urbano a depositar. Esto elimina
microgestión y código, manteniendo el espíritu "ultra básico".

**Nodos de recurso**: cada fuente tiene una cantidad finita. Cuando se agota,
desaparece y el aldeano busca automáticamente la fuente más cercana del mismo
tipo (o queda inactivo si no hay).

**Estados visuales del aldeano**: Quieto (idle), Caminando y Recolectando
(animación simple de "golpe"). Sin animaciones fluidas: basta con que cambie el
dibujo.

---

## 3. El Cuadrilátero de Combate (contraunidades)

Combate tipo "piedra, papel o tijera" de **4 vías**. Cada unidad tiene un **daño
base** y un **multiplicador de bonificación ×2** contra su objetivo ideal.

Ciclo de fortalezas (cada una fuerte contra la siguiente):

```
   Arquero  ──fuerte→  Infantería/Milicia  ──fuerte→  Piquetero
      ↑                                                    │
      └──────────  Caballo  ←──fuerte──────────────────────┘
```

| Unidad | Fuerte contra (×2) | Débil contra | Coste |
|---|---|---|---|
| Infantería / Milicia | Piqueteros | Arqueros | Comida |
| Piquetero | Caballos | Infantería / Milicia | Comida + Madera |
| Caballo (caballería) | Arqueros | Piqueteros | Comida + Oro |
| Arquero | Infantería / Milicia | Caballos | Madera + Oro |

**Fórmula de daño**: `daño = ataque × (objetivo es su presa ideal ? 2 : 1) −
armadura_objetivo` (mínimo 1).

**Rangos**: la Infantería, los Piqueteros y los Caballos son cuerpo a cuerpo
(rango corto). Los Arqueros disparan a distancia.

**Auto-defensa**: una unidad militar inactiva detecta enemigos cercanos y los
ataca por su cuenta (radio de alerta). Así una base puede defenderse sola.

---

## 4. Edificios y árbol tecnológico

Solo **5 estructuras** para no saturar la pantalla del iPad.

### A. Centro Urbano (Town Center)
- Crea **Aldeanos**.
- **Avance de Era → Edad de las Herramientas** (cuesta Piedra + Oro): desbloquea
  las mejoras militares de la Herrería.
- Es el edificio cuya destrucción decide la partida.

### B. Cuartel / Barracas (Barracks)
- Entrena **Milicia** y **Piqueteros**.
- Cuesta Madera. Es el edificio militar base.

### C. Galería de Tiro con Arco (Archery Range)
- Entrena **Arqueros**.
- **Requiere** tener un Cuartel construido.

### D. Establo (Stable)
- Entrena **Caballos**.
- **Requiere** tener un Cuartel construido.

### E. Herrería (Blacksmith)
No produce unidades, solo **mejoras globales** (requieren Edad de las
Herramientas):
- **Flechas de Punta de Hierro**: +1 ataque y +1 rango a los Arqueros
  (Madera + Oro).
- **Forja de Espadas**: +1 ataque a Infantería y Caballos (Comida + Oro).
- **Escudos de Madera**: +1 armadura a **todas** las unidades (Madera + Piedra).
- **Hachas Afiladas**: los aldeanos recolectan **25 % más rápido**
  (Comida + Madera).

Cada mejora se compra una sola vez y se aplica a todas las unidades presentes y
futuras del jugador.

---

## 5. Construcción

1. Selecciona un aldeano y pulsa el edificio que quieres en el panel.
2. Entras en **modo colocación**: una silueta sigue tu dedo.
3. Toca el mapa para colocar los cimientos (si tienes recursos y el sitio es
   válido). El coste se descuenta al colocar.
4. El aldeano camina hasta los cimientos y los **construye** (barra de
   progreso). Cuantos más aldeanos asignes, más rápido. Al terminar, el edificio
   queda operativo.

---

## 6. Bucle de juego y condición de victoria

1. **Inicio**: 1 Centro Urbano, 3 Aldeanos y recursos iniciales (comida y madera
   para arrancar, algo de oro/piedra). Un enemigo controlado por la IA tiene una
   base equivalente en el extremo opuesto de un mapa estático de ~2 pantallas de
   ancho.
2. **Expansión**: creas aldeanos, los mandas a los recursos y levantas el
   Cuartel (y luego Galería / Establo / Herrería).
3. **Conflicto**: produces ejército combinando tipos para cubrir el cuadrilátero
   de combate y atacas la base rival, mientras te defiendes de sus oleadas.
4. **Victoria / Derrota**: gana quien **destruye primero el Centro Urbano del
   rival**. Si destruyen el tuyo, pierdes.

**Dificultad** (elegible al empezar): ajusta la velocidad de producción y la
agresividad de la IA (Fácil / Normal / Difícil).

**Población**: límite global (p. ej. 60) para mantener el rendimiento y obligar
a tomar decisiones; se muestra en la barra superior.

---

## 7. Notas técnicas de implementación

- **Motor**: Canvas 2D + JavaScript puro (sin dependencias) para garantizar que
  abra en cualquier iPad sin instalación. La estructura está pensada para poder
  migrarse a **Phaser.js** o **Pixi.js** si se quiere más adelante.
- **Gráficos**: vista cenital con sprites simples basados en emoji y figuras
  geométricas → cero archivos de imagen, nitidez perfecta en pantallas Retina.
- **Entrada**: eventos `touch` nativos de iOS (1 dedo = órdenes/caja, 2 dedos =
  paneo/zoom) más respaldo de ratón/rueda para probar en escritorio.
- **Render Retina**: el canvas escala con `devicePixelRatio` para verse nítido.
- **Sin scroll de página**: se desactiva el rebote/zoom del navegador para que
  los gestos sean solo del juego.

---

## 8. Ideas para más adelante (fuera del alcance ultra básico)

- Torres defensivas (uso adicional de la Piedra) y muros.
- Más edades con mejoras encadenadas.
- Casas y gestión real de población.
- Niebla de guerra y minimapa.
- Sonido y música.
- Guardado de partida en `localStorage`.
- Multijugador local por turnos en el mismo iPad.
