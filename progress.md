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
