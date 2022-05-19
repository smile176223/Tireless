//
//  PoseDetectView.swift
//  Tireless
//
//  Created by Hao on 2022/5/18.
//

import UIKit
import MLKit
import AVFoundation

class PoseDetectView: UIView {
    
    private lazy var previewOverlayView: UIImageView = {
        let previewOverlayView = UIImageView(frame: .zero)
        previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
        previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return previewOverlayView
    }()
    
    private lazy var annotationOverlayView: UIView = {
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    private enum Constant {
        static let smallDotRadius: CGFloat = 4.0
        static let lineWidth: CGFloat = 3.0
    }
    
    var viewModel: PoseDetectViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        setUpPreviewOverlayView()
        setUpAnnotationOverlayView()
    }
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: "\(PoseDetectView.self)", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func drawPoseOverlay(poses: [Pose],
                         width: CGFloat,
                         height: CGFloat,
                         previewLayer: AVCaptureVideoPreviewLayer) {
        DispatchQueue.main.async {
            poses.forEach { poses in
                let poseOverlayView = UIUtilities.createPoseOverlayView(
                    forPose: poses,
                    inViewWithBounds: self.annotationOverlayView.bounds,
                    lineWidth: Constant.lineWidth,
                    dotRadius: Constant.smallDotRadius,
                    positionTransformationClosure: { (position) -> CGPoint in
                        return normalizedPoint(
                            fromVisionPoint: position, width: width, height: height)
                    }
                )
                self.annotationOverlayView.addSubview(poseOverlayView)
            }
        }
        func normalizedPoint(
            fromVisionPoint point: VisionPoint,
            width: CGFloat,
            height: CGFloat
        ) -> CGPoint {
            let cgPoint = CGPoint(x: point.x, y: point.y)
            var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
            normalizedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint:
                                                                normalizedPoint)
            return normalizedPoint
        }
    }
    
    private func setUpPreviewOverlayView() {
        self.addSubview(previewOverlayView)
        NSLayoutConstraint.activate([
            previewOverlayView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            previewOverlayView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            previewOverlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            previewOverlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            previewOverlayView.topAnchor.constraint(equalTo: self.topAnchor),
            previewOverlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setUpAnnotationOverlayView() {
        self.addSubview(annotationOverlayView)
        NSLayoutConstraint.activate([
            annotationOverlayView.topAnchor.constraint(equalTo: self.topAnchor),
            annotationOverlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            annotationOverlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            annotationOverlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func updatePreviewOverlayViewWithLastFrame(lastFrame: CMSampleBuffer?, isUsingFrontCamera: Bool) {
        guard let lastFrame = lastFrame, let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
        else {
            return
        }
        self.updatePreviewOverlayViewWithImageBuffer(imageBuffer, isUsingFrontCamera: isUsingFrontCamera)
    }
    
    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?, isUsingFrontCamera: Bool) {
        guard let imageBuffer = imageBuffer else {
            return
        }
        let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
        let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
        previewOverlayView.image = image
    }
    
    func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
}
