//
//  HomeViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var photoButton: UIButton!
    
    let videoManager = VideoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        goButton.layer.cornerRadius = 10
        photoButton.layer.cornerRadius = 10
        
        setupTitle()
        
    }
    
    @IBAction func goToNext(_ sender: UIButton) {
        guard let poseVC = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
//        poseVC.hidesBottomBarWhenPushed = true
//        self.navigationItem.backButtonTitle = ""
//        self.navigationController?.pushViewController(poseVC, animated: true)
        poseVC.modalPresentationStyle = .fullScreen
        self.present(poseVC, animated: true)
    }
    
    func setupTitle() {
        let titleView = UIImageView()
        titleView.image = UIImage(named: "TirelessLogo")
        titleView.contentMode = .scaleAspectFill
        titleView.clipsToBounds = true
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        titleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120).isActive = true
    }
    
    @IBAction func photoButtonTap(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imagePath = documentsPath?.appendingPathComponent("image.jpg")
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let imageData = pickedImage.jpegData(compressionQuality: 0.75)
            try? imageData?.write(to: imagePath!)
            videoManager.uploadPicture(picture: Picture(userId: "liamTest",
                                                        pictureName: UUID().uuidString,
                                                        pictureURL: imagePath!,
                                                        createdTime: Date().millisecondsSince1970,
                                                        content: "")) { _ in
                self.dismiss(animated: true)
            }
        }
    }
}
