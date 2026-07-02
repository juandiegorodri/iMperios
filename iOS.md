# iOS.md — App de iPad y multijugador en tiempo real

Documentación de la app iOS de Mini-AoE y de la arquitectura multijugador P2P.
Léelo junto a `CLAUDE.md` (normas del proyecto) y `filemap.md` (mapa de código).

---

## 1. Qué se construyó

1. **App iOS nativa para iPad** (`ios/`): un contenedor `WKWebView` que empaqueta
   el juego web tal cual (`index.html` + `assets/`) y añade lo que la web no
   puede hacer sola: un **servidor WebSocket local** para ser anfitrión de
   partidas y la **IP local** del dispositivo para mostrarla en el menú.
2. **Multijugador en tiempo real P2P** (en `index.html`, funciona también en
   escritorio con `server.js`): un jugador **crea la partida (anfitrión =
   servidor)** y el otro **se conecta a su IP**. Sin servidores externos.
3. Ajuste visual: se **eliminaron las sombras bajo los edificios**.

## 2. Estructura del proyecto iOS

```
ios/
├── MiniAoE.xcodeproj/
│   └── project.pbxproj          Proyecto Xcode (target único de app iPad)
└── MiniAoE/
    ├── MiniAoEApp.swift         Entrada SwiftUI; arranca el relé y muestra el juego
    ├── GameWebView.swift        WKWebView que carga index.html del bundle e
    │                            inyecta window.__NATIVE_IP tras cargar
    ├── RelayServer.swift        Servidor WebSocket (puerto 8765) con
    │                            Network.framework + utilidad de IP local
    └── Info.plist               Permisos de red local, orientaciones iPad, ATS
```

Los recursos web **no están duplicados**: el proyecto referencia `../index.html`
y `../assets` (carpeta azul) desde la raíz del repositorio. Al compilar, Xcode
los copia al bundle, así la app siempre empaqueta la última versión del juego.

### Cómo abrir y correr

1. En un Mac con **Xcode 15+**: abrir `ios/MiniAoE.xcodeproj`.
2. En *Signing & Capabilities*, elegir tu **Team** (firma automática).
3. Elegir un iPad (real o simulador) y **Run**.
4. La primera vez que se cree/una una partida, iOS pedirá permiso de **Red
   local** (el texto está en `Info.plist`).

> Nota honesta: este proyecto se generó y estructuró a mano desde un entorno
> Linux (aquí no hay Xcode para compilarlo). Sigue el formato estándar de
> Xcode 14/15 y los tres archivos Swift usan solo APIs públicas estables
> (SwiftUI, WebKit, Network). Si Xcode objetara algo del `.pbxproj`, basta
> crear un proyecto vacío "App (SwiftUI)" llamado MiniAoE y arrastrar los 3
> `.swift`, el `Info.plist` y las referencias a `../index.html` y `../assets`
> — son 2 minutos; todo el valor está en los fuentes.

## 3. Arquitectura del multijugador

### Modelo: anfitrión autoritativo

- El **anfitrión** ejecuta la simulación completa (la misma `update()` del modo
  un jugador, con la IA desactivada) y envía **instantáneas de estado** (~7/s).
- El **cliente no simula**: renderiza la última instantánea y envía **comandos**
  (mover, recolectar, atacar, construir, entrenar, investigar, muralla, rally…).
- **Truco de perspectiva**: el anfitrión envía el estado con los bandos
  intercambiados (`player`↔`enemy`). Así el cliente "se ve" siempre como
  `player` y **toda la UI existente funciona sin refactorizar**. Los comandos
  del cliente se aplican en el anfitrión sobre el lado `enemy`, validando
  propiedad de cada entidad.

### Transporte: relé WebSocket en el puerto 8765

Tubería tonta que empareja exactamente 2 conexiones y reenvía los mensajes de
texto de una a la otra. Dos implementaciones equivalentes:

| Entorno | Relé | Quién lo corre |
|---|---|---|
| iPad (app) | `RelayServer.swift` (Network.framework) | El dispositivo **anfitrión**, siempre encendido |
| Escritorio/desarrollo | `server.js` (Node, cero dependencias) | El computador del anfitrión: `node server.js` |

El anfitrión se conecta a `ws://127.0.0.1:8765` (su propio relé); el cliente a
`ws://<IP-del-anfitrión>:8765`. En la app, `GameWebView` inyecta
`window.__NATIVE_IP` para que el menú muestre la IP a compartir.

### Protocolo (JSON sobre WebSocket)

| Mensaje | Dirección | Contenido |
|---|---|---|
| `hello` | ambos → relé | `{role:'host'\|'client'}`; al recibir el hello del cliente, el anfitrión arranca la partida |
| `init` | anfitrión → cliente | configuración del mapa, `terrain`, `bridge` y la primera instantánea |
| `snap` | anfitrión → cliente (~7/s) | entidades serializadas (bandos invertidos) + recursos/era/tecnologías/estadísticas de ambos lados |
| `cmd` | cliente → anfitrión | `{c:'move'\|'gather'\|'attack'\|'buildjob'\|'stop'\|'train'\|'cancel'\|'age'\|'upg'\|'econ'\|'rally'\|'place'\|'wall', …}` |
| `end` | anfitrión → cliente | `{win:bool}` desde la perspectiva del cliente |

### Dónde vive en el código (`index.html`)

- Bloque `MULTIJUGADOR P2P`: `net`, `netConnect/netHostStart/netJoinStart`,
  serialización (`serEntity/deserEntity/makeSnap/applySnap`), mensajería
  (`netOnMessage`, `netSendInit`, `clientStartFromInit`, `clientEnd`) y el
  aplicador de comandos del anfitrión (`hostHandleCmd`, `hostPlace`, `hostWall`).
- Integraciones: `loop()` (el cliente no llama a `update()`), `enemyAI()` (se
  desactiva en MP), `update()` (envío de instantáneas), `endGame()` (aviso al
  cliente), guardas de cliente en `queueUnit/tryAdvanceAge/buyUpgrade/buyEcon/
  cancelQueued/handleTap/tryPlaceBuilding/wallTap/Detener`.
- Menú: sección «📶 Multijugador» (`btnHost`, `btnJoin`, `joinIp`, `mpStatus`).

### Probar el multijugador sin iPads

```bash
node server.js            # en una terminal (relé)
# abre index.html en DOS ventanas del navegador:
#  - ventana A: "Crear partida (anfitrión)"
#  - ventana B: "Unirse a una partida" → IP 127.0.0.1 → Conectar
```
Está verificado de punta a punta con dos Chromium headless (conexión, órdenes
del cliente aplicadas en el anfitrión, instantáneas de vuelta y fin de partida
sincronizado, sin errores de consola).

## 4. Decisiones y límites conocidos

- **Anfitrión autoritativo, no lockstep**: sencillo y robusto para 2 jugadores
  en LAN; el cliente ve el estado con ~150 ms de granularidad (sin
  interpolación aún: los movimientos en el cliente avanzan "a saltitos").
- **Sin seguridad**: el relé acepta a los 2 primeros que lleguen; pensado para
  red local doméstica.
- La **pausa** está deshabilitada en multijugador; «Jugar de nuevo» recarga la
  página para reconectar limpio.
- La app iOS asume WiFi (`en0`) para detectar la IP; con hotspot usa `bridge*`.

## 5. Hoja de ruta sugerida (paso a paso)

1. Compilar en Xcode, probar en 2 iPads reales y ajustar lo que surja.
2. Interpolación de posiciones en el cliente (suavizar movimiento entre snaps).
3. Descubrimiento automático del anfitrión con **Bonjour/NWBrowser** (sin
   escribir IPs).
4. Reconexión de partida (guardar el último snap y re-entrar).
5. Icono de la app y pantalla de lanzamiento con la línea gráfica de
   `assets/ART.md`.
6. GameCenter/Multipeer como transporte alternativo si se quiere jugar sin WiFi.
