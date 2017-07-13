//
//  HTTPServer.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

class HTTPServer {

    init() {
    }

    var socket: Socket?

    func start(address: String? = nil, port: in_port_t) throws {
        socket = try Socket.tcpSocketForListen(address: address, port: port)

        print("accepting...")
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            guard let socket = strongSelf.socket else { return }
            while let clientSocket = try? socket.acceptClientSocket() {
                print("cliend socket: \(clientSocket.socketFileDescriptor)")
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.handleConnection(clientSocket)
                }
            }
        }
    }

    private func handleConnection(_ socket: Socket) {
        print("handle connection")
        let parser = HTTPRequestParser()
        do {
            let request = try parser.readHTTPRequest(socket)
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
                var htmlLines: [String] = []
                htmlLines.append("<html>")
                htmlLines.append("<head>")
                htmlLines.append("<title>Redirecting</title>")
                htmlLines.append("</head>")
                htmlLines.append("<body>")
                htmlLines.append("<h1>Redirecting...</h1>")
                htmlLines.append("</body>")
                htmlLines.append("</html>")
                let htmlString = htmlLines.joined()
                let location = locationOfURLScheme(String(request.path.characters.dropFirst()))
                let response = HTTPResponse.movedPermanently(location: location, htmlString: htmlString)
                try respond(socket, with: response)
            }
        } catch {
            print(error)
        }
        socket.close()
    }

    private func locationOfURLScheme(_ urlScheme: String) -> String {
        return "data:text/html;charset=UTF-8,<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'/><meta name='apple-mobile-web-app-capable' content='yes'/><script>if (window.navigator.standalone){window.location.href='\(urlScheme)';}</script></head><body><h1>AppClip</h1><p>\(Date())</p></body></html>"
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
