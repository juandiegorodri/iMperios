//  GameWebView.swift
//  WKWebView que carga el juego (index.html + assets/ empaquetados en el bundle).
//  Tras cargar, inyecta window.__NATIVE_IP con la IP local del dispositivo para
//  que el menú multijugador pueda mostrarla al crear una partida.

import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .black
        // El juego gestiona sus propios gestos táctiles; el scroll nativo estorba.
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false

        if let indexURL = Bundle.main.url(forResource: "index", withExtension: "html") {
            let root = Bundle.main.resourceURL ?? indexURL.deletingLastPathComponent()
            webView.loadFileURL(indexURL, allowingReadAccessTo: root)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let ip = RelayServer.localIPAddress() ?? "IP no disponible"
            webView.evaluateJavaScript("window.__NATIVE_IP = '\(ip)';", completionHandler: nil)
        }
    }
}
