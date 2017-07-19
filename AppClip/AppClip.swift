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

    public static func create(title: String, icon: UIImage, urlScheme: String, toturialImage: UIImage) {
        let port: in_port_t = 8532
        func openSafariToRequest(_ server: HTTPServer) {
            server.titles[urlScheme] = title
            server.icons[urlScheme] = UIImagePNGRepresentation(icon)?.base64EncodedString()
            server.toturialImages[urlScheme] = UIImageJPEGRepresentation(toturialImage, 0.75)?.base64EncodedString()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                guard let url = URL(string: "http://localhost:\(port)/\(urlScheme)") else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        if let server = server {
            openSafariToRequest(server)
        } else {
            let _server = HTTPServer()
            do {
                try _server.start(port: port)
                server = _server
                openSafariToRequest(_server)
            } catch {
                print(error)
            }
        }
    }
}
