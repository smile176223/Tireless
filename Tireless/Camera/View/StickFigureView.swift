//
//  StickFigureView.swift
//  Tireless
//
//  Created by Liam on 2024/1/17.
//

import SwiftUI

struct Stick: Shape {
    var points: [CGPoint]?
    var size: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let points = points, !points.isEmpty else { return path }
        
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
    
    var bodyGroup: [HumanBody.Group: [CGPoint]]?
    var size: CGSize
    
    var body: some View {
        ZStack {
            Stick(points: bodyGroup?[.leftLeg], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            Stick(points: bodyGroup?[.rightLeg], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            Stick(points: bodyGroup?[.leftArm], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            Stick(points: bodyGroup?[.rightArm], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            Stick(points: bodyGroup?[.rootToNose], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
        }
    }
}
