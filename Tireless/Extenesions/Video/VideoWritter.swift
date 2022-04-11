//
//  VideoWritter.swift
//  Tireless
//
//  Created by Hao on 2022/4/10.
//

import Foundation
import AVFoundation

class VideoWriter {
    
    var avAssetWriter: AVAssetWriter
    
    var avAssetWriterInput: AVAssetWriterInput
    
    var url: URL
    
    init(withVideoType type: AVVideoCodecType) {
        if #available(iOS 11.0, *) {
            avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video,
                                                    outputSettings: [AVVideoCodecKey: type,
                                                                    AVVideoHeightKey: 480,
                                                                     AVVideoWidthKey: 640])
        } else {
            avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video,
                                                    outputSettings: [AVVideoCodecKey: AVVideoCodecH264,
                                                                    AVVideoHeightKey: 480,
                                                                     AVVideoWidthKey: 640])
        }
        avAssetWriterInput.expectsMediaDataInRealTime = true
        avAssetWriterInput.transform = CGAffineTransform(rotationAngle: .pi / 2)
        do {
            let directory = try VideoWriter.directoryForNewVideo()
            if type == AVVideoCodecType.hevc {
                url = directory.appendingPathComponent(UUID.init().uuidString.appending(".hevc"))
            } else {
                url = directory.appendingPathComponent(UUID.init().uuidString.appending(".mp4"))
            }
            avAssetWriter = try AVAssetWriter(url: url, fileType: AVFileType.mp4)
            avAssetWriter.add(avAssetWriterInput)
            avAssetWriter.movieFragmentInterval = CMTime.invalid
        } catch {
            fatalError("Could not initialize avAssetWriter \(error)")
        }
    }
    
    func write(sampleBuffer buffer: CMSampleBuffer) {
        if avAssetWriter.status == AVAssetWriter.Status.unknown {
            avAssetWriter.startWriting()
            avAssetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
        }
        if avAssetWriterInput.isReadyForMoreMediaData {
            avAssetWriterInput.append(buffer)
        }
    }
    
    func stopWriting(completionHandler handler: @escaping (AVAssetWriter.Status) -> Void) {
        avAssetWriter.finishWriting {
            handler(self.avAssetWriter.status)
        }
    }
    
    static func directoryForNewVideo() throws -> URL {
        let videoDir = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask).first?.appendingPathComponent("videos")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateDir = videoDir?.appendingPathComponent(formatter.string(from: Date()))
        try FileManager.default.createDirectory(atPath: (dateDir?.path)!,
                                                withIntermediateDirectories: true, attributes: nil)
        return dateDir!
    }
}
