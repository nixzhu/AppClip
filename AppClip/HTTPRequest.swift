//
//  HTTPRequest.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

struct HTTPRequest {

    let method: String
    let path: String
    let queryParams: [(String, String)]

    init(method: String, path: String, queryParams: [(String, String)]) {
        self.method = method
        self.path = path
        self.queryParams = queryParams
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
