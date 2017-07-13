//
//  HTTPServer.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

public class HTTPServer {

    var socket: Socket?

    public init() {
    }

    public func start(address: String? = nil, port: in_port_t = 8964) throws {
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
            try respond(socket)
        } catch {
            print(error)
        }
        socket.close()
    }

    private func respond(_ socket: Socket) throws {
        try socket.writeUTF8("HTTP/1.1 200 OK\r\n")
        try socket.writeUTF8("Connecttion: close\r\n")
        try socket.writeUTF8("Content-Type: text/html\r\n")
        let htmlString = "<html><head><title>Hello</title></head><body><h1>Hello</h1></body></html>"
        try socket.writeUTF8("Content-Length: \(htmlString.characters.count)\r\n")
        try socket.writeUTF8("\r\n")
        try socket.writeUTF8(htmlString)
    }
}
