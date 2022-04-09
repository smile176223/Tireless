//
//  UIUtilities.swift
//  Tireless
//
//  Created by Hao on 2022/4/9.
//

import AVFoundation
import UIKit
import MLKit

public class UIUtilities {
    public static func imageOrientation(
        fromDevicePosition devicePosition: AVCaptureDevice.Position = .back
    ) -> UIImage.Orientation {
        var deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .faceDown || deviceOrientation == .faceUp
            || deviceOrientation
            == .unknown {
            deviceOrientation = currentUIOrientation()
        }
        switch deviceOrientation {
        case .portrait:
            return devicePosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return devicePosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return devicePosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return devicePosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            fatalError("error")
        }
    }
    private static func currentUIOrientation() -> UIDeviceOrientation {
        let deviceOrientation = { () -> UIDeviceOrientation in
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .portrait, .unknown:
                return .portrait
            case .faceUp:
                return . faceUp
            case .faceDown:
                return .faceDown
            @unknown default:
                fatalError("error")
            }
        }
        guard Thread.isMainThread else {
            var currentOrientation: UIDeviceOrientation = .portrait
            DispatchQueue.main.sync {
                currentOrientation = deviceOrientation()
            }
            return currentOrientation
        }
        return deviceOrientation()
    }
    public static func addCircle(
        atPoint point: CGPoint,
        to view: UIView,
        color: UIColor,
        radius: CGFloat
    ) {
        let divisor: CGFloat = 2.0
        let xCoord = point.x - radius / divisor
        let yCoord = point.y - radius / divisor
        let circleRect = CGRect(x: xCoord, y: yCoord, width: radius, height: radius)
        guard circleRect.isValid() else { return }
        let circleView = UIView(frame: circleRect)
        circleView.layer.cornerRadius = radius / divisor
        circleView.alpha = Constants.circleViewAlpha
        circleView.backgroundColor = color
        view.addSubview(circleView)
    }
    public static func addLineSegment(
        fromPoint: CGPoint, toPoint: CGPoint, inView: UIView, color: UIColor, width: CGFloat
    ) {
        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = color.cgColor
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.lineWidth = width
        let lineView = UIView()
        lineView.layer.addSublayer(lineLayer)
        inView.addSubview(lineView)
    }
    public static func addRectangle(_ rectangle: CGRect, to view: UIView, color: UIColor) {
        guard rectangle.isValid() else { return }
        let rectangleView = UIView(frame: rectangle)
        rectangleView.layer.cornerRadius = Constants.rectangleViewCornerRadius
        rectangleView.alpha = Constants.rectangleViewAlpha
        rectangleView.backgroundColor = color
        view.addSubview(rectangleView)
    }
    public static func addShape(withPoints points: [NSValue]?, to view: UIView, color: UIColor) {
        guard let points = points else { return }
        let path = UIBezierPath()
        for (index, value) in points.enumerated() {
            let point = value.cgPointValue
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            if index == points.count - 1 {
                path.close()
            }
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        let rect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        let shapeView = UIView(frame: rect)
        shapeView.alpha = Constants.shapeViewAlpha
        shapeView.layer.addSublayer(shapeLayer)
        view.addSubview(shapeView)
    }
    public static func createUIImage(
        from imageBuffer: CVImageBuffer,
        orientation: UIImage.Orientation
    ) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: Constants.originalScale, orientation: orientation)
    }
    public static func createPoseOverlayView(
        forPose pose: Pose, inViewWithBounds bounds: CGRect, lineWidth: CGFloat, dotRadius: CGFloat,
        positionTransformationClosure: (VisionPoint) -> CGPoint
    ) -> UIView {
        let overlayView = UIView(frame: bounds)
        let lowerBodyHeight: CGFloat =
            UIUtilities.distance(
                fromPoint: pose.landmark(ofType: PoseLandmarkType.leftAnkle).position,
                toPoint: pose.landmark(ofType: PoseLandmarkType.leftKnee).position)
            + UIUtilities.distance(
                fromPoint: pose.landmark(ofType: PoseLandmarkType.leftKnee).position,
                toPoint: pose.landmark(ofType: PoseLandmarkType.leftHip).position)
        let adjustmentRatio: CGFloat = 1.2
        let nearZExtent: CGFloat = -lowerBodyHeight * adjustmentRatio
        let farZExtent: CGFloat = lowerBodyHeight * adjustmentRatio
        let zColorRange: CGFloat = farZExtent - nearZExtent
        let nearZColor = UIColor.red
        let farZColor = UIColor.blue
        for (startLandmarkType, endLandmarkTypesArray) in UIUtilities.poseConnections() {
            let startLandmark = pose.landmark(ofType: startLandmarkType)
            for endLandmarkType in endLandmarkTypesArray {
                let endLandmark = pose.landmark(ofType: endLandmarkType)
                let startLandmarkPoint = positionTransformationClosure(startLandmark.position)
                let endLandmarkPoint = positionTransformationClosure(endLandmark.position)
                let landmarkZRatio = (startLandmark.position.z - nearZExtent) / zColorRange
                let connectedLandmarkZRatio = (endLandmark.position.z - nearZExtent) / zColorRange
                let startColor = UIUtilities.interpolatedColor(
                    fromColor: nearZColor, toColor: farZColor, ratio: landmarkZRatio)
                let endColor = UIUtilities.interpolatedColor(
                    fromColor: nearZColor, toColor: farZColor, ratio: connectedLandmarkZRatio)
                UIUtilities.addLineSegment(
                    fromPoint: startLandmarkPoint,
                    toPoint: endLandmarkPoint,
                    inView: overlayView,
                    colors: [startColor, endColor],
                    width: lineWidth)
            }
        }
        for landmark in pose.landmarks {
            let landmarkPoint = positionTransformationClosure(landmark.position)
            UIUtilities.addCircle(
                atPoint: landmarkPoint,
                to: overlayView,
                color: UIColor.green,
                radius: dotRadius
            )
        }
        return overlayView
    }
    private static func addLineSegment(
        fromPoint: CGPoint, toPoint: CGPoint, inView: UIView, colors: [UIColor], width: CGFloat
    ) {
        let viewWidth = inView.bounds.width
        let viewHeight = inView.bounds.height
        if viewWidth == 0.0 || viewHeight == 0.0 {
            return
        }
        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        let lineMaskLayer = CAShapeLayer()
        lineMaskLayer.path = path.cgPath
        lineMaskLayer.strokeColor = UIColor.black.cgColor
        lineMaskLayer.fillColor = nil
        lineMaskLayer.opacity = 1.0
        lineMaskLayer.lineWidth = width
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: fromPoint.x / viewWidth, y: fromPoint.y / viewHeight)
        gradientLayer.endPoint = CGPoint(x: toPoint.x / viewWidth, y: toPoint.y / viewHeight)
        gradientLayer.frame = inView.bounds
        var CGColors = [CGColor]()
        for color in colors {
            CGColors.append(color.cgColor)
        }
        if CGColors.count == 1 {
            CGColors.append(colors[0].cgColor)
        }
        gradientLayer.colors = CGColors
        gradientLayer.mask = lineMaskLayer
        let lineView = UIView(frame: inView.bounds)
        lineView.layer.addSublayer(gradientLayer)
        inView.addSubview(lineView)
    }
    private static func interpolatedColor(
        fromColor: UIColor, toColor: UIColor, ratio: CGFloat
    ) -> UIColor {
        var fromR: CGFloat = 0
        var fromG: CGFloat = 0
        var fromB: CGFloat = 0
        var fromA: CGFloat = 0
        fromColor.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        var toR: CGFloat = 0
        var toG: CGFloat = 0
        var toB: CGFloat = 0
        var toA: CGFloat = 0
        toColor.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        let clampedRatio = max(0.0, min(ratio, 1.0))
        let interpolatedR = fromR + (toR - fromR) * clampedRatio
        let interpolatedG = fromG + (toG - fromG) * clampedRatio
        let interpolatedB = fromB + (toB - fromB) * clampedRatio
        let interpolatedA = fromA + (toA - fromA) * clampedRatio
        return UIColor(
            red: interpolatedR, green: interpolatedG, blue: interpolatedB, alpha: interpolatedA)
    }
    private static func distance(fromPoint: Vision3DPoint, toPoint: Vision3DPoint) -> CGFloat {
        let xDiff = fromPoint.x - toPoint.x
        let yDiff = fromPoint.y - toPoint.y
        let zDiff = fromPoint.z - toPoint.z
        return CGFloat(sqrt(xDiff * xDiff + yDiff * yDiff + zDiff * zDiff))
    }
    private static func poseConnections() -> [PoseLandmarkType: [PoseLandmarkType]] {
        struct PoseConnectionsHolder {
            static var connections: [PoseLandmarkType: [PoseLandmarkType]] = [
                PoseLandmarkType.leftEar: [PoseLandmarkType.leftEyeOuter],
                PoseLandmarkType.leftEyeOuter: [PoseLandmarkType.leftEye],
                PoseLandmarkType.leftEye: [PoseLandmarkType.leftEyeInner],
                PoseLandmarkType.leftEyeInner: [PoseLandmarkType.nose],
                PoseLandmarkType.nose: [PoseLandmarkType.rightEyeInner],
                PoseLandmarkType.rightEyeInner: [PoseLandmarkType.rightEye],
                PoseLandmarkType.rightEye: [PoseLandmarkType.rightEyeOuter],
                PoseLandmarkType.rightEyeOuter: [PoseLandmarkType.rightEar],
                PoseLandmarkType.mouthLeft: [PoseLandmarkType.mouthRight],
                PoseLandmarkType.leftShoulder: [
                    PoseLandmarkType.rightShoulder,
                    PoseLandmarkType.leftHip
                ],
                PoseLandmarkType.rightShoulder: [
                    PoseLandmarkType.rightHip,
                    PoseLandmarkType.rightElbow
                ],
                PoseLandmarkType.rightWrist: [
                    PoseLandmarkType.rightElbow,
                    PoseLandmarkType.rightThumb,
                    PoseLandmarkType.rightIndexFinger,
                    PoseLandmarkType.rightPinkyFinger
                ],
                PoseLandmarkType.leftHip: [PoseLandmarkType.rightHip, PoseLandmarkType.leftKnee],
                PoseLandmarkType.rightHip: [PoseLandmarkType.rightKnee],
                PoseLandmarkType.rightKnee: [PoseLandmarkType.rightAnkle],
                PoseLandmarkType.leftKnee: [PoseLandmarkType.leftAnkle],
                PoseLandmarkType.leftElbow: [PoseLandmarkType.leftShoulder],
                PoseLandmarkType.leftWrist: [
                    PoseLandmarkType.leftElbow, PoseLandmarkType.leftThumb,
                    PoseLandmarkType.leftIndexFinger,
                    PoseLandmarkType.leftPinkyFinger
                ],
                PoseLandmarkType.leftAnkle: [PoseLandmarkType.leftHeel, PoseLandmarkType.leftToe],
                PoseLandmarkType.rightAnkle: [PoseLandmarkType.rightHeel, PoseLandmarkType.rightToe],
                PoseLandmarkType.rightHeel: [PoseLandmarkType.rightToe],
                PoseLandmarkType.leftHeel: [PoseLandmarkType.leftToe],
                PoseLandmarkType.rightIndexFinger: [PoseLandmarkType.rightPinkyFinger],
                PoseLandmarkType.leftIndexFinger: [PoseLandmarkType.leftPinkyFinger]
            ]
        }
        return PoseConnectionsHolder.connections
    }
}

// MARK: - Constants

private enum Constants {
    static let circleViewAlpha: CGFloat = 0.7
    static let rectangleViewAlpha: CGFloat = 0.3
    static let shapeViewAlpha: CGFloat = 0.3
    static let rectangleViewCornerRadius: CGFloat = 10.0
    static let maxColorComponentValue: CGFloat = 255.0
    static let originalScale: CGFloat = 1.0
    static let bgraBytesPerPixel = 4
}

extension CGRect {
    /// Returns a `Bool` indicating whether the rectangle's values are valid`.
    func isValid() -> Bool {
        return
            !(origin.x.isNaN || origin.y.isNaN || width.isNaN || height.isNaN || width < 0 || height < 0
                || origin.x < 0 || origin.y < 0)
    }
}
