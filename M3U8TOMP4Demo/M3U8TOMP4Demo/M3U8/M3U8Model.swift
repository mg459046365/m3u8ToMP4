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
//    "https://ks3-cn-beijing.ksyun.com/ivms-vms-dev/records/hls/biz/0505050505050001/1575374272000_1575374332000.m3u8?KSSAccessKeyId=AKLTti6U2QSES-q-QoqaVGBCeQ&Expires=1578045302&Signature=5Lho6a3pNjyqUjmlEjk+d6ziXmI="

    lazy var name: String = {
        var array = self.url!.components(separatedBy: ".m3u8")
        let tmp = array[0]
        array = tmp.components(separatedBy: "/")
        return array.last!
//        let range = self.url!.range(of: "/", options: .backwards, range: nil, locale: nil)!
//        let m3u8Range = self.url!.range(of: ".m3u8", options: .backwards, range: nil, locale: nil)
//        let tmp = self.url![range.upperBound..<m3u8Range!.lowerBound]
//        return String(describing: tmp)
    }()
    
}
