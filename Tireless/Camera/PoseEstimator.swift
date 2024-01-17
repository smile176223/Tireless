//
//  PoseEstimator.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import AVFoundation
import Vision
import Combine

public class PoseEstimator: ObservableObject {
    
    enum DetectError: Error {
        case lowConfidence
        case sequenceError(Error)
    }
    
    @Published var bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]?
    @Published var detectError: DetectError?
    private let sequenceHandler = VNSequenceRequestHandler()
    private var cancellables = Set<AnyCancellable>()
    
    public func captureOutput(_ sampleBuffer: CMSampleBuffer) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectBodyPose)
        
        do {
            try sequenceHandler.perform([humanBodyRequest], on: sampleBuffer, orientation: .up)
        } catch {
            detectError = .sequenceError(error)
        }
    }
    
    private func detectBodyPose(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observations.forEach(processObservation)
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard var recognizedPoints = try? observation.recognizedPoints(.all) else { return }
        
        recognizedPoints.removeValue(forKey: .leftEar)
        recognizedPoints.removeValue(forKey: .rightEar)
        let pointsConfidence = recognizedPoints.allSatisfy { $0.value.confidence > 0 }
        
        if pointsConfidence {
            set(recognizedPoints)
        } else {
            set(DetectError.lowConfidence)
        }
    }
    
    private func set(_ bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    private func set(_ error: DetectError) {
        DispatchQueue.main.async {
            self.detectError = error
        }
    }
}
