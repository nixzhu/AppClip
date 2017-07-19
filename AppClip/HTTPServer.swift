//
//  HTTPServer.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

class HTTPServer {

    var titles: [String: String] = [:]
    var icons: [String: String] = [:]
    var toturialImages: [String: String] = [:]

    init() {
    }

    private var socket: Socket?

    func start(address: String? = nil, port: in_port_t) throws {
        socket = try Socket.tcpSocketForListen(address: address, port: port)
        print("accepting...")
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            guard let socket = strongSelf.socket else { return }
            while let clientSocket = try? socket.acceptClientSocket() {
                print("cliend socket: \(clientSocket.socketFileDescriptor)")
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.handleConnection(clientSocket)
                }
            }
        }
    }

    private func handleConnection(_ socket: Socket) {
        print("handle connection")
        do {
            let request = try HTTPRequestParser.readHTTPRequest(fromSocket: socket)
            print("request: \(request)")
            switch request.path {
            case "/test":
                var htmlLines: [String] = []
                htmlLines.append("<html>")
                htmlLines.append("<head>")
                htmlLines.append("<title>Success</title>")
                htmlLines.append("</head>")
                htmlLines.append("<body>")
                htmlLines.append("<h1>Server is working!</h1>")
                htmlLines.append("<p>\(Date())</p>")
                htmlLines.append("</body>")
                htmlLines.append("</html>")
                let htmlString = htmlLines.joined()
                let response = HTTPResponse.ok(htmlString: htmlString)
                try respond(socket, with: response)
            default:
                let location = locationOfURLScheme(String(request.path.characters.dropFirst()))
                let response = HTTPResponse.movedPermanently(location: location, htmlString: "<html></html>")
                try respond(socket, with: response)
            }
        } catch {
            print(error)
        }
        socket.close()
    }

    private func locationOfURLScheme(_ urlScheme: String) -> String {
        var lines: [String] = []
        lines.append("data:text/html;")
        lines.append("charset=UTF-8,")
        lines.append("<html>")
        lines.append("<head>")
        titles[urlScheme].flatMap {
            lines.append("<title>\($0)</title>")
        }
        icons[urlScheme].flatMap {
            lines.append("<link rel='apple-touch-icon' href='data:image/png;base64,\($0)'/>")
        }
        lines.append("<style type='text/css'>")
        lines.append("html { height: 100%; box-sizing: border-box; }")
        lines.append("*, *:before, *:after { box-sizing: inherit; }")
        lines.append("body { position: relative; margin: 0; padding-bottom: 6rem; min-height: 100%; }")
        lines.append(".main { margin: 0 auto; padding-top: 24px; padding: 1rem; }")
        lines.append(".footer { position: absolute; right: 0; bottom: 0; left: 0; padding: 1rem; }")
        lines.append(".app_clip { float: right; color: #E2E2E2; font-size: x-small; }")
        lines.append("a { color: #D0D0D0; }")
        lines.append("</style>")
        lines.append("<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'/>")
        lines.append("<meta name='apple-mobile-web-app-capable' content='yes'/>")
        lines.append("<script>if (window.navigator.standalone) { window.location.href='\(urlScheme)'; }</script>")
        lines.append("</head>")
        lines.append("<body>")
        lines.append("<div class='main'>")
        titles[urlScheme].flatMap {
            lines.append("<h1>\($0)</h1>")
        }
        toturialImages[urlScheme].flatMap {
            lines.append("<img src='data:image/jpeg;base64,\($0)'/>")
        }
        lines.append("<ol>")
        lines.append("<li>Tap Action</li>")
        lines.append("<li>Add to Home Screen</li>")
        lines.append("</ol>")
        lines.append("<div class='footer'>")
        lines.append("<p class='app_clip'>Powered by <a href='https://github.com/nixzhu/AppClip'>AppClip</a>.</p>")
        lines.append("</div>")
        lines.append("</div>")
        lines.append("</body>")
        lines.append("</html>")
        return lines.joined()
    }

    private func respond(_ socket: Socket, with response: HTTPResponse) throws {
        var lines: [String] = []
        switch response {
        case .ok:
            lines.append("HTTP/1.1 200 OK")
            lines.append("Connecttion: close")
        case let .movedPermanently(location, _):
            lines.append("HTTP/1.1 301 Moved Permanently")
            lines.append("Location: \(location)")
        }
        let htmlString = response.htmlString
        lines.append("Content-Type: text/html")
        lines.append("Content-Length: \(htmlString.characters.count)")
        lines.append("")
        lines.append(htmlString)
        let string = lines.joined(separator: "\r\n")
        try socket.writeUTF8(string)
    }
}
