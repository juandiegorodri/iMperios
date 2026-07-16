# iOS.md — App de iPad y multijugador en tiempo real

Documentación de la app iOS de iMperios y de la arquitectura multijugador P2P.
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
├── iMperios.xcodeproj/
│   └── project.pbxproj          Proyecto Xcode (target único de app iPad)
└── iMperios/
    ├── iMperiosApp.swift        Entrada SwiftUI; arranca el relé y muestra el juego
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

1. En un Mac con **Xcode 15+**: abrir `ios/iMperios.xcodeproj`.
2. En *Signing & Capabilities*, elegir tu **Team** (firma automática).
3. Elegir un iPad (real o simulador) y **Run**.
4. La primera vez que se cree/una una partida, iOS pedirá permiso de **Red
   local** (el texto está en `Info.plist`).

> Nota honesta: este proyecto se generó y estructuró a mano desde un entorno
> Linux (aquí no hay Xcode para compilarlo). Sigue el formato estándar de
> Xcode 14/15 y los tres archivos Swift usan solo APIs públicas estables
> (SwiftUI, WebKit, Network). Si Xcode objetara algo del `.pbxproj`, basta
> crear un proyecto vacío "App (SwiftUI)" llamado iMperios y arrastrar los 3
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

### Transporte (Fase 7): dos implementaciones detrás de una interfaz común

Desde la Fase 7, el protocolo de arriba **no sabe ni le importa** cómo viajan
los bytes: toda la mensajería pasa por `net.sendRaw(str)` (enviar; su
implementación cambia según el transporte activo) y `net.onRaw(str)` (recibir;
una sola función común a los dos transportes). Hay dos implementaciones:

| Transporte | Cómo se conecta | Quién lo corre | Funciona desde `https://` |
|---|---|---|---|
| **A. Red local** (`ws://`, puerto 8765) | `netConnect`/`netHostStart`/`netJoinStart` | `RelayServer.swift` en iPad (Network.framework) o `node server.js` en escritorio — tubería tonta que empareja 2 conexiones y reenvía texto de una a otra | No (contenido mixto) |
| **B. Online** (WebRTC DataChannel) | `netOnlineHostStart`/`netOnlineJoinStart`, señalizado con **PeerJS** (`https://unpkg.com/peerjs@1/dist/peerjs.min.js`, cargado bajo demanda solo al pulsar el botón) | El broker público de PeerJS solo para el handshake inicial; después los datos van directo entre los dos navegadores (P2P real) | Sí |

El anfitrión LAN se conecta a `ws://127.0.0.1:8765` (su propio relé); el
cliente a `ws://<IP-del-anfitrión>:8765`. En la app, `GameWebView` inyecta
`window.__NATIVE_IP` para que el menú muestre la IP a compartir.

Para el transporte Online, el anfitrión crea un `Peer` con id
`imperios7-<código>` (código de 6 caracteres, `genRoomCode`/`peerIdFor`) y lo
muestra en pantalla; el invitado escribe el código y `peer.connect(...)` abre
el `DataChannel` (`wireOnlineConn` cablea ambos lados a `sendRaw`/`onRaw`).

### Protocolo (JSON sobre el transporte activo)

| Mensaje | Dirección | Contenido |
|---|---|---|
| `hello` | ambos → relé/peer | `{role:'host'\|'client'}`; si NO hay partida en curso, el anfitrión la arranca; si ya la hay (reconexión), reenvía `init` en vez de reiniciar |
| `init` | anfitrión → cliente | configuración del mapa, `terrain`, `bridge` y la primera instantánea (siempre completa) |
| `snap` | anfitrión → cliente (~7/s) | instantánea **completa**: entidades serializadas (bandos invertidos) + recursos/era/tecnologías/estadísticas de ambos lados |
| `snapd` | anfitrión → cliente (~7/s, Fase 7) | instantánea **delta**: solo entidades cuya serialización cambió desde el último mensaje (`upd`) + ids eliminados (`rem`) — se alterna con `snap` (completa cada ~1s) para ahorrar bytes; el cliente fusiona ambos tipos sobre el mismo array de entidades |
| `cmd` | cliente → anfitrión | `{c:'move'\|'gather'\|'attack'\|'buildjob'\|'stop'\|'train'\|'cancel'\|'age'\|'upg'\|'econ'\|'rally'\|'place'\|'wall'\|'amove'\|'lineupg'\|'garrison'\|'expel'\|'market'\|'gate', …}` |
| `end` | anfitrión → cliente | `{win:bool}` desde la perspectiva del cliente |

### Dónde vive en el código (`index.html`)

- Bloque `MULTIJUGADOR P2P`: `net`, transporte A (`netConnect/netHostStart/
  netJoinStart`), transporte B (`loadPeerJs/netOnlineHostStart/
  netOnlineJoinStart/wireOnlineConn/netOnlineConnLost/clientTryReconnect`),
  serialización (`serEntity/deserEntity/makeSnap/makeSnapDelta/applySnap`),
  interpolación de cliente (`interpClientPositions`), mensajería
  (`netOnMessage`, `netSendInit`, `clientStartFromInit`, `clientEnd`) y el
  aplicador de comandos del anfitrión (`hostHandleCmd`, `hostPlace`, `hostWall`).
- Integraciones: `loop()` (el cliente no llama a `update()`, pero sí llama a
  `interpClientPositions()` cada fotograma), `enemyAI()` (se desactiva en MP),
  `update()` (envío de instantáneas, alternando completa/delta), `endGame()`
  (aviso al cliente), guardas de cliente en `queueUnit/tryAdvanceAge/
  buyUpgrade/buyEcon/cancelQueued/handleTap/tryPlaceBuilding/wallTap/Detener`.
- Menú: pestañas «🌐 Online (código)» (`btnOnlineHost`, `btnOnlineJoin`,
  `onlineCodeInput`, `btnOnlineJoinGo`, `onlineCodeBox`, `btnCopyCode`) y
  «📶 Red local (IP)» (`btnHost`, `btnJoin`, `joinIp`, `btnJoinGo`), más
  `mpStatus` (compartido) y el interruptor de pestañas (`mpTabOnline`/
  `mpTabLan`, clase propia `.mp-tab`, no `.opt-b`).

### Probar el multijugador sin iPads

```bash
# Red local:
node server.js            # en una terminal (relé)
# abre index.html en DOS ventanas del navegador:
#  - ventana A: pestaña "Red local" → "Crear partida (anfitrión)"
#  - ventana B: pestaña "Red local" → "Unirse a una partida" → IP 127.0.0.1 → Conectar

# Online (necesita internet real; no verificado en el sandbox de desarrollo,
# ver PLAN.md §4 F7 y progress.md 2026-07-15/16):
# abre index.html en DOS ventanas/dispositivos:
#  - ventana A: pestaña "Online" → "Crear sala" → comparte el código
#  - ventana B: pestaña "Online" → "Unirse con código" → pega el código → Conectar
```
El transporte LAN está verificado de punta a punta con dos Chromium headless
(conexión, órdenes del cliente aplicadas en el anfitrión, instantáneas de
vuelta —completas y delta— y fin de partida sincronizado, sin errores de
consola), igual que la interpolación de posiciones y el ahorro de bytes de
los deltas (~79% medido). El transporte Online se verificó hasta donde el
sandbox de desarrollo lo permite (ver PLAN.md/progress.md): el camino de
fallo (script no carga, mensaje honesto, `net.mode` se limpia) funciona; la
señalización PeerJS real de punta a punta queda pendiente de una red con
internet de verdad o del iPad.

## 4. Decisiones y límites conocidos

- **Anfitrión autoritativo, no lockstep**: sencillo y robusto para 2 jugadores;
  el cliente ve el estado con ~150 ms de granularidad, pero desde la Fase 7
  se interpola entre instantáneas (`interpClientPositions`) para que el
  movimiento no se vea "a saltitos".
- **Sin seguridad**: el relé LAN acepta a los 2 primeros que lleguen (pensado
  para red local doméstica); el transporte Online usa el broker público de
  PeerJS solo para el handshake, sin autenticación (el "código de sala" es la
  única barrera — suficiente para jugar entre amigos, no pensado como
  mecanismo de seguridad real).
- La **pausa** está deshabilitada en multijugador; «Jugar de nuevo» recarga la
  página para reconectar limpio.
- La app iOS asume WiFi (`en0`) para detectar la IP; con hotspot usa `bridge*`.
- **Reconexión (Fase 7)**: con el transporte Online, si el `DataChannel` se
  cae en plena partida, el anfitrión mantiene su `Peer` abierto ~60s
  esperando que el mismo código vuelva a conectar (sin reiniciar la partida);
  el cliente reintenta automáticamente durante esa ventana. La reconexión de
  LAN sigue limitada por `server.js` (cierra ambas conexiones ante cualquier
  desconexión), sin cambios en esta fase.

## 5. Hoja de ruta sugerida (paso a paso)

1. Compilar en Xcode, probar en 2 iPads reales y ajustar lo que surja.
2. ~~Interpolación de posiciones en el cliente~~ — hecho en la Fase 7
   (`interpClientPositions`).
3. Descubrimiento automático del anfitrión con **Bonjour/NWBrowser** (sin
   escribir IPs) para la vía LAN.
4. ~~Reconexión de partida (guardar el último snap y re-entrar)~~ — hecho en
   la Fase 7 para el transporte Online (ventana de 60s con el mismo código);
   pendiente para LAN (necesitaría tocar `server.js`/`RelayServer.swift` para
   aceptar una conexión de reemplazo).
5. Verificar el transporte Online (WebRTC/PeerJS) con una conexión a internet
   real fuera del sandbox de desarrollo (o en el iPad) — no verificable en
   headless por restricciones de red del entorno, ver `progress.md`.
6. Icono de la app y pantalla de lanzamiento con la línea gráfica de
   `assets/ART.md`.
6. GameCenter/Multipeer como transporte alternativo si se quiere jugar sin WiFi.
