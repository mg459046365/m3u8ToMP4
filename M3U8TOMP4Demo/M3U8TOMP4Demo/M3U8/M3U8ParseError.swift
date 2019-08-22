//
//  M3U8ParseError.swift
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/15.
//  Copyright © 2019 Beryter. All rights reserved.
//

import Foundation

struct M3U8ParseError: Error {
    let code: Int
    let message: String?
    var localizedDescription: String {
        return message ?? ""
    }
}

