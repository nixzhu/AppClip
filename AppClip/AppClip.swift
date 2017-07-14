//
//  AppClip.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import UIKit

public struct AppClip {

    private static var server: HTTPServer?

    public static func create(title: String, icon: UIImage, urlScheme: String) {
        let port: in_port_t = 8532
        if server == nil {
            let _server = HTTPServer()
            do {
                try _server.start(port: port)
                server = _server
            } catch {
                print(error)
            }
        }
        server?.titles[urlScheme] = title
        server?.icons[urlScheme] = UIImagePNGRepresentation(icon)?.base64EncodedString()
        DispatchQueue.main.async {
            UIApplication.shared.openURL(URL(string: "http://localhost:\(port)/\(urlScheme)")!)
        }
    }
}
