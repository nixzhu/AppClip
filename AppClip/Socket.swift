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

    class func close(_ socket: Int32) {
        _ = Darwin.close(socket)
    }

    class func setNoSigPipe(_ socket: Int32) {
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
    }

    class func tcpSocketForListen(address: String? = nil, port: in_port_t, maxPendingConnection: Int32 = SOMAXCONN) throws -> Socket {
        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            throw Error.socketCreationFailed
        }

        var value: Int32 = 1
        if setsockopt(socketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size)) == -1 {
            Socket.close(socketFileDescriptor)
            throw Error.socketSettingReUseAddrFailed
        }
        Socket.setNoSigPipe(socketFileDescriptor)

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

        if listen(socketFileDescriptor, maxPendingConnection) == -1 {
            Socket.close(socketFileDescriptor)
            throw Error.listenFailed
        }

        return Socket(socketFileDescriptor: socketFileDescriptor)
    }
}
