//
//  PoseEstimator.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import AVFoundation
import Vision

public class PoseEstimator: ObservableObject {
    
    enum DetectError: Error {
        case lowConfidence
        case sequenceError(Error)
    }
    
    @Published var bodyGroup: [HumanBody.Group: [CGPoint]]?
    @Published var detectError: DetectError?
    @Published var count: Int = 0
    private let sequenceHandler = VNSequenceRequestHandler()
    private let squatEstimator = SquatEstimator()
    
    public init() {
        squatEstimator.$count
            .receive(on: RunLoop.main)
            .assign(to: &$count)
    }
    
    public func captureOutput(_ sampleBuffer: CMSampleBuffer) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectBodyPose)
        
        do {
            try sequenceHandler.perform([humanBodyRequest], on: sampleBuffer, orientation: .right)
        } catch {
            set(error: .sequenceError(error))
        }
    }
    
    private func detectBodyPose(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observations.forEach(processObservation)
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard observation.confidence > 0.5, var recognizedPoints = try? observation.recognizedPoints(.all) else { return }
        
        recognizedPoints.removeValue(forKey: .leftEar)
        recognizedPoints.removeValue(forKey: .rightEar)
        let pointsConfidence = recognizedPoints.allSatisfy { $0.value.confidence > 0 }
        
        if pointsConfidence {
            set(recognizedPoints)
            squatEstimator.perform(recognizedPoints)
        } else {
            set([:])
            set(error: DetectError.lowConfidence)
        }
    }
    
    private func set(_ points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        DispatchQueue.main.async {
            self.bodyGroup = HumanBody.pose(points)
        }
    }
    
    private func set(error: DetectError) {
        DispatchQueue.main.async {
            self.detectError = error
        }
    }
}

extension Dictionary where Key == VNHumanBodyPoseObservation.JointName, Value == VNRecognizedPoint {
    func locate(_ jointName: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
        guard let point = self[jointName], point.confidence > 0.5  else { return nil }
        
        return point.location
    }
}
