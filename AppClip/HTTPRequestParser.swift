//
//  HTTPRequestParser.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

struct HTTPRequestParser {

    enum Error: Swift.Error {
        case invalidStatusLine
    }

    private init() {
    }

    static func readHTTPRequest(fromSocket socket: Socket) throws -> HTTPRequest {
        let statusLine = try socket.readLine()
        let statusLineTokens = statusLine.components(separatedBy: " ")
        if statusLineTokens.count < 3 {
            throw Error.invalidStatusLine
        }
        let request = HTTPRequest()
        request.method = statusLineTokens[0]
        request.path = statusLineTokens[1]
        request.queryParams = extractQueryParams(request.path)
        return request
    }

    static private func extractQueryParams(_ url: String) -> [(String, String)] {
        guard let questionMark = url.characters.index(of: "?") else {
            return []
        }
        let queryStart = url.characters.index(after: questionMark)
        guard url.endIndex > queryStart else {
            return []
        }
        let query = String(url.characters[queryStart..<url.endIndex])
        return query.components(separatedBy: "&")
            .reduce([(String, String)]()) { (c, s) -> [(String, String)] in
                guard let nameEndIndex = s.characters.index(of: "=") else {
                    return c
                }
                guard let name = String(s.characters[s.startIndex..<nameEndIndex]).removingPercentEncoding else {
                    return c
                }
                let valueStartIndex = s.index(nameEndIndex, offsetBy: 1)
                guard valueStartIndex < s.endIndex else {
                    return c + [(name, "")]
                }
                guard let value = String(s.characters[valueStartIndex..<s.endIndex]).removingPercentEncoding else {
                    return c + [(name, "")]
                }
                return c + [(name, value)]
        }
    }
}
