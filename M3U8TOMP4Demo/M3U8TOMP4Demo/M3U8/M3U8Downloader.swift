//
//  M3U8Downloader.swift
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/15.
//  Copyright © 2019 Beryter. All rights reserved.
//

import Foundation
import Alamofire
import AVFoundation

class M3U8Downloader {
    let model: M3U8Model
    var successItems = [M3U8TSModel]()
    var failureItems = [M3U8TSModel]()
    
    let downloadGroup: DispatchGroup = {
        let group = DispatchGroup()
        return group
    }()
    
    init(_ mode: M3U8Model) {
        self.model = mode
    }
    
    func start() {
        prepare()
        downloadFiles()
    }
    
    private func prepare() {
        self.createDir()
    }
    
    
    private func downloadFiles() {
        guard let files = self.model.items else {
            return
        }
        
        files.forEach { (item) in
            self.downloadGroup.enter()
            let url = item.url!
            let destination = DownloadRequest.suggestedDownloadDestination()
            Alamofire.download(url, to: destination).response { [weak self] response in
                guard let self = self else { return }
                if response.response?.statusCode == 200, response.error == nil, let desURL = response.destinationURL {
                    //下载成功
                    do {
                        let tsPath = self.tsFilePath(model: item)
                        item.desPath = tsPath
                        try FileManager.default.copyItem(at: desURL, to: URL(fileURLWithPath: tsPath))
                        try FileManager.default.removeItem(at: desURL)
                        self.successItems.append(item)
                    } catch {
                        self.failureItems.append(item)
                    }
                }else{
                    self.failureItems.append(item)
                    if let desURL = response.destinationURL {
                        try? FileManager.default.removeItem(at: desURL)
                    }
                }
                print(response.request ?? "")
                print(response.response ?? "")
                print(response.temporaryURL ?? "")
                print(response.destinationURL ?? "")
                print(response.error ?? "")
                self.downloadGroup.leave()
            }
        }
        
        self.downloadGroup.notify(queue: DispatchQueue.global()) {
            //所有的视频都下载完毕
            if self.failureItems.isEmpty {
                self.ffmpegTSToMP4()
                return
            }
            print("有下载失败的文件")
        }
    }
    
    
    private func ffmpegTSToMP4() {
        var data = Data()
        for item in self.model.items! {
            let tmp = try? Data(contentsOf: URL(fileURLWithPath: item.desPath!), options: .dataReadingMapped)
            if tmp == nil {
                continue
            }
            data.append(tmp!)
        }
        
        do {
            try data.write(to: URL(fileURLWithPath: self.compTSPath))
        } catch {
            print("合成一个TS文件失败")
            return
        }
        print("开始转换\(Date().timeIntervalSince1970)")
        TS2MP4.convertTS(self.compTSPath, toMP4: self.mp4Path)
        print("转换完毕\(Date().timeIntervalSince1970)")
    }
    
    
    private func TSToMP4() {
        let item = self.model.items![0]
        let asset = AVURLAsset(url: URL(fileURLWithPath: item.desPath!))
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        guard compatiblePresets.contains(AVAssetExportPresetLowQuality) else {
            print("失败了")
            return
        }
        if !FileManager.default.fileExists(atPath: self.mp4Path) {
            FileManager.default.createFile(atPath: self.mp4Path, contents: nil, attributes: nil)
        }
        let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        session?.outputURL = URL(fileURLWithPath: self.mp4Path)
        session?.outputFileType = AVFileType.mp4
        session?.exportAsynchronously(completionHandler: {
            //这里非主线程
            var tmpString = "转换失败"
            if session?.status == AVAssetExportSession.Status.completed {
                tmpString = "输出成功"
            }else if session?.status == AVAssetExportSession.Status.failed {
                tmpString = "转换失败"
            }else if session?.status == AVAssetExportSession.Status.cancelled {
                tmpString = "任务取消"
            }else if session?.status == AVAssetExportSession.Status.exporting {
                tmpString = "转换ing"
            }else if session?.status == AVAssetExportSession.Status.waiting {
                tmpString = "等待ing"
            }else{
                tmpString = "未知错误"
            }
            print("转换结果=\(tmpString)")
        })
    }
    
    
    
    private func compositionVideo() {
        let composition = AVMutableComposition()
        let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionTrack!.preferredVolume = 1.0
        
        var success = true
        
        for item in self.model.items! {
            let videoAsset = AVURLAsset(url: URL(fileURLWithPath: item.desPath!))
            let trackArray = videoAsset.tracks(withMediaType: .video)
            if trackArray.isEmpty {
                print("错误1")
                success = false
                break
            }
            let track = trackArray[0]
            let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
            do {
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            } catch {
                print("错误1")
                success = false
                break
            }
        }
        if !success {
            print("转换失败了，退出")
            return
        }
        
        let exportSession = AVAssetExportSession(asset:composition, presetName: AVAssetExportPresetMediumQuality)
        guard let session = exportSession else {
            print("exportSession没有值")
            return
        }
        let temporaryFileName = self.mp4Path
        session.outputURL = URL(fileURLWithPath: temporaryFileName)
        session.outputFileType = AVFileType.mp4
        print("开始转换")
        session.exportAsynchronously(completionHandler: { () -> Void in
            //这里非主线程
            var tmpString = "转换失败"
            if session.status == AVAssetExportSession.Status.completed{
                tmpString = "输出成功"
            }else if session.status == AVAssetExportSession.Status.failed{
                tmpString = "转换失败"
            }else if session.status == AVAssetExportSession.Status.cancelled{
                tmpString = "任务取消"
            }else if session.status == AVAssetExportSession.Status.exporting{
                tmpString = "转换ing"
            }else if session.status == AVAssetExportSession.Status.waiting{
                tmpString = "等待ing"
            }else{
                tmpString = "未知错误"
            }
            print("转换结果=\(tmpString)")
        })
    }
    
    
    
    private func tsFilePath(model: M3U8TSModel) -> String {
        let url = self.desDir + "/" + model.name! + ".ts"
        return url
    }
    
    private func createDir() {
        if FileManager.default.fileExists(atPath: desDir) {
            print("移出了目录")
            try? FileManager.default.removeItem(atPath: desDir)
        }
        print("重新创建了目录")
        try? FileManager.default.createDirectory(atPath: desDir, withIntermediateDirectories: true, attributes: nil)
    }

    /// 文件根目录
    lazy var desDir: String = {
        let dir = NSHomeDirectory() + "/Documents" + "/" + model.name
        return dir
    }()
    
    lazy var compTSPath: String = {
        let path = self.desDir + "/" + model.name + "_result" + ".ts"
        return path
    }()
    
    lazy var mp4Path: String = {
        let path = self.desDir + "/" + model.name + ".mp4"
        return path
    }()
}
