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
        //https://stackoverflow.com/questions/14134035/how-to-manage-uiimageview-content-mode/14134357#14134357
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth,
                                      .flexibleHeight,
                                      .flexibleBottomMargin,
                                      .flexibleTopMargin,
                                      .flexibleLeftMargin,
                                      .flexibleRightMargin]
        imageView.clipsToBounds = true
        
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
    //MARK: - BUTTON FUNCTIONS
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
    
    //MARK: - IMAGE PROCESSING HAPPENS HERE
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageView.image = picture
            picture.detectRectangles { rectangles in
                for rectangle in rectangles
                {
                    print("rectangles")
                }
                print("calling")
            }
            picture.detectBarcodes(completion: { barcodes in
                for barcode in barcodes
                {
                    print(barcode)
                }
            })
            
            getFaces(picture: picture)
            
            //getSaliency(picture: picture)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func getFaces(picture: UIImage)
    {
        var faces: [VNFaceObservation] = []
        picture.detectFaces(completion: { result in
            faces = result!
            print(faces)
            if let np = picture as UIImage?,
                let annotatedPicture = result?.drawnOn(picture)
                {
                DispatchQueue.main.sync {
                    self.imageView.image = annotatedPicture
                }
                }
        })
    }
    
    func getSaliency(picture: UIImage)
    {
        print("detecting Saliency")
        
        picture.detectSalientRegions(prioritising: .objectnessBased, completion: {
            result in
            self.drawSalient(picture, result: result!)
            
        })
       
    }
    
    func drawSalient(_ image: UIImage, result: VNSaliencyImageObservation)
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        image.draw(in: CGRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height))

        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.01 * image.size.width)

        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -image.size.height)
        
        guard let objects = result.salientObjects as [VNRectangleObservation]? else {return}
        for object in objects
        {
            let rect = object.boundingBox
            let normalizedRect = VNImageRectForNormalizedRect(rect,
                                Int(image.size.width),
                                Int(image.size.height))
                            .applying(transform)
            
            context.stroke(normalizedRect)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()   
        
        DispatchQueue.main.async {
            
            self.imageView.image = result
        }
    }
}

