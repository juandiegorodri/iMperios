//  MiniAoEApp.swift
//  Punto de entrada de la app. Arranca el relé WebSocket local (para poder ser
//  anfitrión de partidas multijugador) y muestra el juego a pantalla completa.

import SwiftUI

@main
struct MiniAoEApp: App {
    init() {
        // El relé corre siempre: es barato y así "Crear partida" funciona al instante.
        RelayServer.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            GameWebView()
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
        }
    }
}
