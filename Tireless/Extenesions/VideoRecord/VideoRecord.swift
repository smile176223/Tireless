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
    
    func startRecording(completion: @escaping (() -> Void)) {
        guard recorder.isAvailable else {
            return
        }
        recorder.startRecording { error in
            guard error == nil else {
                return
            }
        }
        completion()
    }
    
    func stopRecording(_ viewcontroller: UIViewController, completion: @escaping (() -> Void)) {
        guard recorder.isRecording else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        let url = getDirectory()
        if #available(iOS 14.0, *) {
            recorder.stopRecording(withOutput: url) { [weak self] err in
                if err != nil {
                    print("fail to save")
                }
                self?.saveToPhotos(tempURL: url)
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            recorder.stopRecording { [weak self] (preview, _) in
                guard let preview = preview else {
                    return
                }
                let alert = UIAlertController(title: "計畫目標達成!",
                                              message: "Nice!",
                                              preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "放棄重做!", style: .destructive,
                                                 handler: { [weak self] (_: UIAlertAction) in
                    self?.recorder.discardRecording(handler: {
                        DispatchQueue.main.async {
                            completion()
                        }
                    })
                })

                let editAction = UIAlertAction(title: "完成儲存!", style: .default,
                                               handler: { (_: UIAlertAction) -> Void in
                    preview.previewControllerDelegate = viewcontroller as? RPPreviewViewControllerDelegate
                    preview.modalPresentationStyle = .overFullScreen
                    viewcontroller.present(preview, animated: true, completion: nil)
                })
                alert.addAction(editAction)
                alert.addAction(deleteAction)
                viewcontroller.present(alert, animated: true, completion: nil)
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
    
    func videoIsRecording() -> Bool {
        return recorder.isRecording
    }
    
    func discardVideo() {
        recorder.stopRecording()
    }
    
}
