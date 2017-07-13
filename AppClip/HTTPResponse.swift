//
//  HTTPResponse.swift
//  AppClip
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import Foundation

enum HTTPResponse {
    case ok(htmlString: String)
    case movedPermanently(location: String, htmlString: String)

    var htmlString: String {
        switch self {
        case let .ok(htmlString): return htmlString
        case let .movedPermanently(_, htmlString): return htmlString
        }
    }
}
