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

    let testTSPath = Bundle.main.path(forResource: "100000002_record_result", ofType: "ts")
    let testMP4Path = NSHomeDirectory() + "/Documents" + "/" + "test" + ".mp4"
    let url = "http://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8"

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
    }

    @objc func testTS2MP4() {
        // 直接用测试文件，测试TS转mp4
        DispatchQueue.global().async {
            let error = TS2MP4.convertTS(self.testTSPath, toMP4: self.testMP4Path)
            if let _ = error {
                print("转换失败")
            } else {
                print("转换成功")
            }
        }
    }

    @objc func startDownload() {
        // 下载m3u8文件，并解析
        let m3u8ParseHandler = M3U8ParseHandler(url)
        m3u8ParseHandler.delegate = self
        m3u8ParseHandler.start()
    }
}
