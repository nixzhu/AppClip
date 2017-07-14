//
//  Socket.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

class Socket {

    let socketFileDescriptor: Int32

    init(socketFileDescriptor: Int32) {
        self.socketFileDescriptor = socketFileDescriptor
    }

    deinit {
        close()
    }

    private var shutdown = false
    func close() {
        if shutdown {
            return
        }
        shutdown = true
        Socket.close(self.socketFileDescriptor)
    }

    fileprivate class func close(_ socket: Int32) {
        _ = Darwin.close(socket)
        print("close socket: \(socket)")
    }

    fileprivate class func setNoSigPipe(_ socket: Int32) {
        var no_sig_pipe: Int32 = 1
        setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
    }
}

extension Socket {

    enum Error: Swift.Error {
        case socketCreationFailed
        case socketSettingReUseAddrFailed
        case bindFailed
        case listenFailed
        case acceptFailed
        case recvFailed
        case writeFailed
    }
}

extension Socket {

    class func tcpSocketForListen(address: String? = nil, port: in_port_t, maxPendingConnection: Int32 = SOMAXCONN) throws -> Socket {
        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            throw Error.socketCreationFailed
        }
        print("create socket: \(socketFileDescriptor)")

        var value: Int32 = 1
        if setsockopt(socketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size)) == -1 {
            Socket.close(socketFileDescriptor)
            throw Error.socketSettingReUseAddrFailed
        }
        Socket.setNoSigPipe(socketFileDescriptor)
        print("set socket opt")

        var addr = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin_family: UInt8(AF_INET),
            sin_port: port.bigEndian,
            sin_addr: in_addr(s_addr: in_addr_t(0)),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        if let address = address {
            if address.withCString({ cstring in inet_pton(AF_INET, cstring, &addr.sin_addr) }) != 1 {
                fatalError("\(address) is not converted.")
            }
        }
        let bindResult = withUnsafePointer(to: &addr) {
            bind(socketFileDescriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in>.size))
        }
        if bindResult == -1 {
            Socket.close(socketFileDescriptor)
            throw Error.bindFailed
        }
        print("bind addr: \(addr.sin_addr)")

        if listen(socketFileDescriptor, maxPendingConnection) == -1 {
            Socket.close(socketFileDescriptor)
            throw Error.listenFailed
        }
        print("listen")

        return Socket(socketFileDescriptor: socketFileDescriptor)
    }

    func acceptClientSocket() throws -> Socket {
        var addr = sockaddr()
        var len: socklen_t = 0
        let clientSocket = accept(socketFileDescriptor, &addr, &len)
        if clientSocket == -1 {
            throw Error.acceptFailed
        }
        Socket.setNoSigPipe(clientSocket)
        return Socket(socketFileDescriptor: clientSocket)
    }

    func read() throws -> UInt8 {
        var buffer = [UInt8](repeating: 0, count: 1)
        let next = recv(self.socketFileDescriptor as Int32, &buffer, Int(buffer.count), 0)
        if next <= 0 {
            throw Error.recvFailed
        }
        return buffer[0]
    }

    private static let CR = UInt8(13)
    private static let NL = UInt8(10)

    func readLine() throws -> String {
        var characters: String = ""
        var n: UInt8 = 0
        repeat {
            n = try self.read()
            if n > Socket.CR { characters.append(Character(UnicodeScalar(n))) }
        } while n != Socket.NL
        return characters
    }
}

extension Socket {

    func writeUTF8(_ string: String) throws {
        try writeUInt8(ArraySlice(string.utf8))
    }

    private func writeUInt8(_ data: ArraySlice<UInt8>) throws {
        try data.withUnsafeBufferPointer {
            try writeBuffer($0.baseAddress!, length: data.count)
        }
    }

    private func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent = 0
        while sent < length {
            let s = write(self.socketFileDescriptor, pointer + sent, Int(length - sent))
            if s <= 0 {
                throw Error.writeFailed
            }
            sent += s
        }
    }
}
