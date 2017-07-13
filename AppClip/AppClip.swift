//
//  AppClip.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

public struct AppClip {

    private static var server: HTTPServer?

    public static func create() {
        let _server = HTTPServer()
        do {
            try _server.start()
            server = _server
        } catch {
            print(error)
        }
    }
}
