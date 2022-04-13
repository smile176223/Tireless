//
//  VideoRecord.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import ReplayKit
import Photos

class VideoRecord {
    private let recorder = RPScreenRecorder.shared()
    
    private var countTime = 0
    
    var getVideoRecordUrl: ((URL) -> Void)?
    
    func startRecording(completion: @escaping (() -> Void)) {
        guard recorder.isAvailable else {
            return
        }
        recorder.startRecording { error in
            completion()
            self.countDownTimer()
            guard error == nil else {
                return
            }
        }
    }
    
    func stopRecording(success: @escaping ((URL) -> Void), failure: @escaping (() -> Void)) {
        guard recorder.isRecording else {
            failure()
            return
        }
        let url = getDirectory()
        recorder.stopRecording(withOutput: url) { [weak self] err in
            if err != nil {
                print("fail to save")
            }
            self?.saveToPhotos(tempURL: url)
            DispatchQueue.main.async {
                success(url)
            }
        }
    }
    
    private func getDirectory() -> URL {
        var tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let stringDate = formatter.string(from: Date())
        tempPath.appendPathComponent(String.localizedStringWithFormat("output-%@.mp4", stringDate))
        return tempPath
    }
    
    private func saveToPhotos(tempURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
        } completionHandler: { success, error in
            if success == true {
                print("Saved video to photos")
            } else {
                print("Error video to Photos \(String(describing: error))")
            }
        }
    }
    
    func userTapBack() {
        if recorder.isRecording == true {
            recorder.stopRecording()
        }
    }
    
    func countDownTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            self?.countTime += 1
            if self?.countTime == 10 {
                self?.stopRecording(success: { url in
                    self?.getVideoRecordUrl?(url)
                }, failure: {
                    print("not recording")
                })
                timer.invalidate()
            }
        })
    }
}
