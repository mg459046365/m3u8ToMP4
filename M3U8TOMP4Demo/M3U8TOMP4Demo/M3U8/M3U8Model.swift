//
//  M3U8Model.swift
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/15.
//  Copyright © 2019 Beryter. All rights reserved.
//

import Foundation

class M3U8Model {
    var items:[M3U8TSModel]?
    var dataStr: String?
    var url: String?
    
    lazy var name: String = {
        let range = self.url!.range(of: "/", options: .backwards, range: nil, locale: nil)!
        let m3u8Range = self.url!.range(of: ".m3u8", options: .backwards, range: nil, locale: nil)
        let tmp = self.url![range.upperBound..<m3u8Range!.lowerBound]
        return String(describing: tmp)
    }()
    
}
