//
//  ViewController.swift
//  Image_Template
//
//  Created by Miguel Sicart on 01/10/2020.
//

import UIKit
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    var imageView: UIImageView!
    var libraryButton: UIButton!
    var cameraButton: UIButton!
    
    let pickerController = UIImagePickerController()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        pickerController.delegate = self
        
        //ImageView
        imageView = UIImageView()
        if traitCollection.userInterfaceStyle == .dark
        {
            imageView.backgroundColor = .white
        }
        else
        {
            imageView.backgroundColor = .black
        }
        imageView.frame = CGRect(x: 10, y: (self.view.frame.midY - self.view.frame.height/4), width: (self.view.frame.width - 20), height: self.view.frame.height/2)
        
        imageView.imageViewRoundCorners()
        view.addSubview(imageView)
        
        //CameraButton
        cameraButton = UIButton(frame: CGRect(x: 30, y: self.view.frame.height - 75, width: 100, height: 50))
        cameraButton.backgroundColor = .blue
        cameraButton.setTitle("Camera", for: .normal)
        cameraButton.addTarget(self, action: #selector(takePic), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        //libraryButton
        libraryButton = UIButton(frame: CGRect(x: self.view.frame.width - 130, y: self.view.frame.height - 75, width: 100, height: 50))
        libraryButton.backgroundColor = .blue
        libraryButton.setTitle("Library", for: .normal)
        libraryButton.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
        view.addSubview(libraryButton)
    }
    
    @objc func takePic(_ sender: Any)
    {
        print("taking a picture")
        
        pickerController.sourceType = .camera
        pickerController.allowsEditing = false
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc func openLibrary(_ sender: Any)
    {
        print("opening the library")
        
        pickerController.sourceType = .savedPhotosAlbum
        pickerController.allowsEditing = true
        
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("called")
        if let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageView.contentMode = .scaleAspectFit
            imageView.image = picture
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
}

