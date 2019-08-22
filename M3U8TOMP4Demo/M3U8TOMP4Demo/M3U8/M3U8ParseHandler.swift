//
//  M3U8ParseHandler.swift
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/15.
//  Copyright © 2019 Beryter. All rights reserved.
//

import Foundation

protocol M3U8ParseHandlerProtocol {
    /// 解析完成
    func parseFinish(parser:M3U8ParseHandler, M3U8: M3U8Model?, error: Error?)
}

class M3U8ParseHandler {
    /// 链接地址
    let m3u8URL: String
    /// 代理
    var delegate: M3U8ParseHandlerProtocol?
    
    init(_ url: String) {
        m3u8URL = url
    }
    
    lazy var tsURLPrefix: String = {
        let range = self.m3u8URL.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil)!
        let pre = self.m3u8URL[self.m3u8URL.startIndex...range.lowerBound]
        return String(describing: pre)
    }()
    
    func start() {
        self.parse()
    }
    
    private func parse() {
        
        guard m3u8URL.hasPrefix("http://") || m3u8URL.hasPrefix("https://") else {
            if let delegate = self.delegate {
                delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 1, message: "链接错误"))
            }
            return
        }
        
        guard m3u8URL.hasSuffix(".m3u8") else {
            if let delegate = self.delegate {
                delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 1, message: "链接错误"))
            }
            return
        }
        
        guard let resURL = URL(string: m3u8URL) else {
            if let delegate = self.delegate {
                delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 1, message: "链接错误"))
            }
            return
        }
        
        let m3u8Str = try? String(contentsOf: resURL, encoding: .utf8)
        
        guard let resultStr = m3u8Str else {
            if let delegate = self.delegate {
                delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 2, message: "M3U8信息错误"))
            }
            return
        }
        let headStr = "#EXTINF:"
        // 解析TS文件
        var extinfRange = resultStr.range(of: headStr)
        if extinfRange == nil {
            if let delegate = self.delegate {
                delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 2, message: "M3U8信息缺少TS文件信息"))
            }
            return
        }
        var handlerStr = resultStr
        var index = 0
        var items = [M3U8TSModel]()
        
        while extinfRange != nil {
            let commaIndex = handlerStr.firstIndex(of: ",")
            guard let ci = commaIndex else {
                if let delegate = self.delegate {
                    delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 2, message: "M3U8信息缺少TS文件信息"))
                }
                return
            }
            let durationStr = String(describing: handlerStr[extinfRange!.upperBound ..< ci])
            let duration = Double(durationStr)
            let tsRange = handlerStr.range(of: ".ts")
            if tsRange == nil {
                if let delegate = self.delegate {
                    delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 2, message: "M3U8信息缺少TS文件信息"))
                }
                return
            }
            let start = handlerStr.index(after: ci)
            var tsName = String(describing: handlerStr[start ..< tsRange!.lowerBound])
            let lineRange = tsName.range(of: "\n")
            if lineRange != nil {
                tsName = String(describing: tsName[lineRange!.upperBound...])
            }
            tsName = tsName.replacingOccurrences(of: "\t", with: "")
            tsName = tsName.replacingOccurrences(of: "\n", with: "")
            
            let tsFileName = tsName + ".ts"
            let tsURL = self.tsURLPrefix + tsFileName
            
            let model = M3U8TSModel()
            model.durationStr = durationStr
            model.name = tsName
            
            model.url = tsURL
            model.duration = duration
            model.index = index
            items.append(model)
            
            handlerStr = String(describing: handlerStr[tsRange!.upperBound...])
            index += 1
            extinfRange = handlerStr.range(of: headStr)
        }
        if items.isEmpty {
            if let delegate = self.delegate {
                delegate.parseFinish(parser: self, M3U8: nil, error: M3U8ParseError(code: 2, message: "M3U8信息缺少TS文件信息"))
            }
            return
        }
        //解析完毕了所有的TS片段
        if let delegate = self.delegate {
            let model = M3U8Model()
            model.url = m3u8URL
            model.dataStr = resultStr
            model.items = items
            delegate.parseFinish(parser: self, M3U8: model, error: nil)
        }
    }
}
