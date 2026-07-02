//  RelayServer.swift
//  Servidor WebSocket local (puerto 8765) usando Network.framework.
//  Es el mismo papel que cumple `server.js` en escritorio: acepta exactamente
//  dos jugadores y reenvía cada mensaje de texto de uno al otro (tubería tonta;
//  toda la lógica del juego vive en el JavaScript del anfitrión).
//
//  El dispositivo ANFITRIÓN corre este servidor y su propio WKWebView se
//  conecta a ws://127.0.0.1:8765. El otro iPad se conecta a ws://<IP-anfitrión>:8765.

import Foundation
import Network

final class RelayServer {

    static let shared = RelayServer()
    static let port: UInt16 = 8765

    private var listener: NWListener?
    private var peers: [NWConnection] = []
    private let queue = DispatchQueue(label: "miniaoe.relay")

    func start() {
        guard listener == nil else { return }

        let params = NWParameters.tcp
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        params.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        do {
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: Self.port)!)
        } catch {
            print("[relé] no se pudo abrir el puerto \(Self.port): \(error)")
            return
        }

        listener?.newConnectionHandler = { [weak self] conn in self?.accept(conn) }
        listener?.start(queue: queue)
        print("[relé] escuchando en el puerto \(Self.port)")
    }

    private func accept(_ conn: NWConnection) {
        queue.async {
            guard self.peers.count < 2 else { conn.cancel(); return }
            self.peers.append(conn)
            conn.stateUpdateHandler = { [weak self] state in
                switch state {
                case .failed, .cancelled: self?.drop(conn)
                default: break
                }
            }
            self.receiveLoop(conn)
            conn.start(queue: self.queue)
            print("[relé] jugador conectado (\(self.peers.count)/2)")
        }
    }

    private func drop(_ conn: NWConnection) {
        guard peers.contains(where: { $0 === conn }) else { return }
        peers.removeAll { $0 === conn }
        // Cierra también al par restante: el juego mostrará "conexión perdida".
        for p in peers { p.cancel() }
        peers = []
        print("[relé] jugador desconectado; sala vacía")
    }

    private func receiveLoop(_ conn: NWConnection) {
        conn.receiveMessage { [weak self] data, _, _, error in
            guard let self else { return }
            if let data, error == nil {
                // Reenviar el mensaje de texto al otro jugador tal cual.
                let meta = NWProtocolWebSocket.Metadata(opcode: .text)
                let ctx = NWConnection.ContentContext(identifier: "text", metadata: [meta])
                for other in self.peers where other !== conn {
                    other.send(content: data, contentContext: ctx, completion: .idempotent)
                }
                self.receiveLoop(conn)
            } else {
                self.drop(conn)
                conn.cancel()
            }
        }
    }

    /// IP local (WiFi) del dispositivo, para mostrarla al crear una partida.
    static func localIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            guard (flags & (IFF_UP | IFF_RUNNING)) == (IFF_UP | IFF_RUNNING),
                  (flags & IFF_LOOPBACK) == 0,
                  ptr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }

            let name = String(cString: ptr.pointee.ifa_name)
            // en0 = WiFi en iPhone/iPad; acepta también bridges (hotspot).
            guard name == "en0" || name.hasPrefix("bridge") else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(ptr.pointee.ifa_addr, socklen_t(ptr.pointee.ifa_addr.pointee.sa_len),
                           &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 {
                address = String(cString: host)
                if name == "en0" { break }   // preferir la WiFi
            }
        }
        return address
    }
}
