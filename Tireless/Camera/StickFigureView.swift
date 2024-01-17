//
//  StickFigureView.swift
//  Tireless
//
//  Created by Liam on 2024/1/17.
//

import SwiftUI

struct Stick: Shape {
    var points: [CGPoint]
    var size: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }
        
        path.move(to: points[0])
        for point in points {
            path.addLine(to: point)
        }
        
        return path
            .applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
}

struct StickFigureView: View {
    
    var bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]?
    var size: CGSize
    
    var body: some View {
        let rightLegParts = [
            bodyParts?[.rightAnkle]?.location,
            bodyParts?[.rightKnee]?.location,
            bodyParts?[.rightHip]?.location
        ].compactMap { $0 }
        
        let leftLegParts = [
            bodyParts?[.leftAnkle]?.location,
            bodyParts?[.leftKnee]?.location,
            bodyParts?[.leftHip]?.location
        ].compactMap { $0 }
        
        let rightArmParts = [
            bodyParts?[.rightWrist]?.location,
            bodyParts?[.rightElbow]?.location,
            bodyParts?[.rightShoulder]?.location,
            bodyParts?[.neck]?.location
        ].compactMap { $0 }
        
        let leftArmParts = [
            bodyParts?[.leftWrist]?.location,
            bodyParts?[.leftElbow]?.location,
            bodyParts?[.leftShoulder]?.location,
            bodyParts?[.neck]?.location
        ].compactMap { $0 }
        
        let rootToNoseParts = [
            bodyParts?[.root]?.location,
            bodyParts?[.neck]?.location,
            bodyParts?[.nose]?.location
        ].compactMap { $0 }
        
        ZStack {
            Stick(points: rightLegParts, size: size)
                .stroke(lineWidth: 3.0)
                .fill(Color.green)
            Stick(points: leftLegParts, size: size)
                .stroke(lineWidth: 3.0)
                .fill(Color.green)
            Stick(points: rightArmParts, size: size)
                .stroke(lineWidth: 3.0)
                .fill(Color.green)
            Stick(points: leftArmParts, size: size)
                .stroke(lineWidth: 3.0)
                .fill(Color.green)
            Stick(points: rootToNoseParts, size: size)
                .stroke(lineWidth: 3.0)
                .fill(Color.green)
        }
    }
}
