//
//  HTTPRequest.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

class HTTPRequest {

    var method: String = ""
    var path: String = ""
    var queryParams: [(String, String)] = []

    init() {
    }
}

extension HTTPRequest: CustomStringConvertible {

    var description: String {
        var lines: [String] = []
        lines.append("method: \(method)")
        lines.append("path: \(path)")
        lines.append("queryParams: \(queryParams)")
        return lines.joined(separator: ", ")
    }
}
