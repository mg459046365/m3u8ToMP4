//
//  ViewController.swift
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/15.
//  Copyright © 2019 Beryter. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController, M3U8ParseHandlerProtocol {
    var dw: M3U8Downloader?
    func parseFinish(parser: M3U8ParseHandler, M3U8: M3U8Model?, error: Error?) {
        guard let model = M3U8 else {
            print("文件出错")
            return
        }
        // 下载
        let downloader = M3U8Downloader(model)
        dw = downloader
        dw?.start()
    }

    let testTSPath = Bundle.main.path(forResource: "1581232248000_1581232271000_result", ofType: "ts")
    let testMP4Path = NSHomeDirectory() + "/Documents" + "/" + "1581232248000_1581232271000" + ".mp4"
//    let url = "http://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8"
    let url = "https://ks3-cn-beijing.ksyun.com/ivms-vms-test/records/hls/biz/0505050505050112/1583683204756_1583684029458.m3u8?KSSAccessKeyId=AKLTti6U2QSES-q-QoqaVGBCeQ&Expires=1586328472&Signature=r4oWWIIue+TnrlKDXrrPWKgeoTw="

//    let url = "https://scpub-oss1.antelopecloud.cn/records/m3u8_info2/1566871533_1566871564.m3u8?access_token=540410181_3356491776_1598269035_3f2016cdb608714b606a99234929037c&head=1"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: view.frame.midX - 150, y: 200, width: 300, height: 40)
        btn.setTitle("下载M3U8并存储为MP4文件", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(startDownload), for: .touchUpInside)

        view.addSubview(btn)

        let btn1 = UIButton(type: .custom)
        btn1.frame = CGRect(x: view.frame.midX - 150, y: 280, width: 300, height: 40)
        btn1.setTitle("测试TS2MP4", for: .normal)
        btn1.setTitleColor(.red, for: .normal)
        btn1.layer.borderColor = UIColor.red.cgColor
        btn1.layer.borderWidth = 1
        btn1.layer.cornerRadius = 2
        btn1.layer.masksToBounds = true
        btn1.addTarget(self, action: #selector(testTS2MP4), for: .touchUpInside)
        view.addSubview(btn1)
        
        let btn2 = UIButton(type: .custom)
        btn2.frame = CGRect(x: view.frame.midX - 150, y: btn1.frame.maxY + 30, width: 300, height: 40)
        btn2.setTitle("测试TS2MP4另一个", for: .normal)
        btn2.setTitleColor(.red, for: .normal)
        btn2.layer.borderColor = UIColor.red.cgColor
        btn2.layer.borderWidth = 1
        btn2.layer.cornerRadius = 2
        btn2.layer.masksToBounds = true
        btn2.addTarget(self, action: #selector(testTS2MP4Other), for: .touchUpInside)
        view.addSubview(btn2)
    }
    
    @objc func testTS2MP4Other() {
        
        let ts = Bundle.main.path(forResource: "100000002_record_result", ofType: "ts")
        let MP4P = NSHomeDirectory() + "/Documents" + "/" + "100000002_record_result_pp" + ".mp4"
        
        // 直接用测试文件，测试TS转mp4
//        DispatchQueue.global().async {
            let error = TS2MP4.convertTS(ts, toMP4: MP4P)
            if let _ = error {
                print("转换失败")
            } else {
                print("转换成功")
            }
//        }
    }

    @objc func testTS2MP4() {
        // 直接用测试文件，测试TS转mp4
//        DispatchQueue.global().async {
            let error = TS2MP4.convertTS(self.testTSPath, toMP4: self.testMP4Path)
            if let _ = error {
                print("转换失败")
            } else {
                print("转换成功")
            }
//        }
    }

    @objc func startDownload() {
        // 下载m3u8文件，并解析
        let m3u8ParseHandler = M3U8ParseHandler(url)
        m3u8ParseHandler.delegate = self
        m3u8ParseHandler.start()
    }
}
