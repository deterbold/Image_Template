//
//  UIImage_xts.swift
//  Image_Template
//
//  Created by Miguel Sicart on 01/10/2020.
//

import Foundation
import UIKit
import Vision


public extension UIImage
{
    
    //MARK: - VARIABLES
    var width: CGFloat
    {
        return self.size.width
    }
    var height: CGFloat
    {
        return self.size.height
    }
    var rect: CGRect
    {
        return CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
    
    var invertTransform:CGAffineTransform
    {
        return CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -self.height)
    }
    
    func fixOrientation() -> UIImage?
    {
            UIGraphicsBeginImageContext(self.size)
            self.draw(at: .zero)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }

    
    //handling the orientation of the image
    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation
        {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
        }
    }
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: - CROPPING
    
    //CROPPING TO SIZE
    func cropped(to size: CGSize, centering: Bool = true) -> UIImage?
    {
        let newRect = self.rect.cropped(to: size, centering: centering)
        return self.cropped(to: newRect, centering: centering)
    }
    
    //CROPPING TO RECT
    func cropped(to rect: CGRect, centering: Bool = true) -> UIImage?
    {
        let newRect = rect.applying(self.invertTransform)
        
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        
        guard let cgImage = self.cgImage, let context = UIGraphicsGetCurrentContext() else {return nil}
        
        context.translateBy(x: 0.0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.draw(cgImage, in: CGRect(
                        x: -newRect.origin.x, y: newRect.origin.y, width: self.width, height: self.height), byTiling: false)
        context.clip(to: [newRect])
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // MARK: - SCALING
    
    func scaled(by scaleFactor: CGFloat) -> UIImage? {
        if scaleFactor.isZero { return self }

        let newRect = self.rect
            .scaled(by: scaleFactor)
            .applying(self.invertTransform)

        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        guard let cgImage = self.cgImage,
                let context = UIGraphicsGetCurrentContext() else { return nil }

            context.translateBy(x: 0.0, y: newRect.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(
                cgImage,
                in: CGRect(
                    x: 0,
                    y: 0,
                    width: newRect.width,
                    height: newRect.height),
                byTiling: false)

            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resizedImage
        }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //MARK: FITTING IN
    //https://stackoverflow.com/questions/17882567/fitting-a-uiimage-in-uiimageview
    func fitImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.width))
            let newImage : UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext();
            return newImage;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //MARK: DETECTING FACES
    
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {

            guard let image = self.cgImage else { return completion(nil) }
            let request = VNDetectFaceRectanglesRequest()

            DispatchQueue.global().async {
                let handler = VNImageRequestHandler(
                    cgImage: image,
                    orientation: self.cgImageOrientation
                )

                try? handler.perform([request])

                guard let observations =
                    request.results as? [VNFaceObservation] else {
                        return completion(nil)
                }

                completion(observations)
            }
        }
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: VISION: RECTANGLES & BARCODES
    //RECTANGLES
    func detectRectangles(completion: @escaping ([VNRectangleObservation]) -> ())
        {
            let request = VNDetectRectanglesRequest()
            request.minimumConfidence = 0.8
            request.minimumAspectRatio = 0.3
            request.maximumObservations = 3
            
            request.queueFor(image: self)
            {
                result in
                completion(result as? [VNRectangleObservation] ?? [])
            }
        }
        
    //BARCODES
    func detectBarcodes(types symbologies: [VNBarcodeSymbology] = [.QR], completion: @escaping ([VNBarcodeObservation]) -> ())
        {
            let request = VNDetectBarcodesRequest()
            request.symbologies = symbologies
            request.queueFor(image: self) { result in
                completion(result as? [VNBarcodeObservation] ?? [])
            }
        }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //MARK: VISION: SALIENCY
    // BEGIN saliency1
        enum SaliencyType
        {
            case objectnessBased, attentionBased
            
            var request: VNRequest
            {
                switch self {
                case .objectnessBased:
                    return VNGenerateObjectnessBasedSaliencyImageRequest()
                case .attentionBased:
                    return VNGenerateAttentionBasedSaliencyImageRequest() //detects part of an image that are interesting
                }
            }
        }
        // END saliency1
        
        // BEGIN saliency2
        func detectSalientRegions(
            prioritising saliencyType: SaliencyType = .attentionBased,
            completion: @escaping (VNSaliencyImageObservation?) -> ()) {

            let request = saliencyType.request
            
            request.queueFor(image: self) { results in
                completion(results?.first as? VNSaliencyImageObservation)
            }
        }
        // END saliency2
        
        // BEGIN saliency3
        func cropped(
            with saliencyObservation: VNSaliencyImageObservation?,
            to size: CGSize? = nil) -> UIImage? {

            guard let saliencyMap = saliencyObservation,
                let salientObjects = saliencyMap.salientObjects else {
                    return nil
            }
            
            // merge all detected salient objects into one big rect of the
            // overaching 'salient region'
            let salientRect = salientObjects.reduce(into: CGRect.zero) {
                rect, object in
                rect = rect.union(object.boundingBox)
            }
            let normalizedSalientRect =
                VNImageRectForNormalizedRect(
                    salientRect, Int(self.width), Int(self.height)
                )
            
            var finalImage: UIImage?
            
            // transform normalized salient rect based on larger or smaller
            // than desired size
            if let desiredSize = size {
                if self.width < desiredSize.width ||
                    self.height < desiredSize.height { return nil }
                
                let scaleFactor = desiredSize
                    .scaleFactor(to: normalizedSalientRect.size)
                
                // crop to the interesting bit
                finalImage = self.cropped(to: normalizedSalientRect)
        
                // scale the image so that as much of the interesting bit as
                // possible can be kept within desiredSize
                finalImage = finalImage?.scaled(by: -scaleFactor)

                // crop to the final desiredSize aspectRatio
                finalImage = finalImage?.cropped(to: desiredSize)
            } else {
                finalImage = self.cropped(to: normalizedSalientRect)
            }
            
            return finalImage
        }
        // USAGE
    // saliencyTestImage.detectSalientRegions(prioritising: .attentionBased)
    //{
    //     result in
    //
    //     if result == nil {
    //         print("The entire image was found equally interesting!")
    //     }

    //     attentionCrop = saliencyTestImage
    //         .cropped(with: result, to: thumbnailSize)

    //     print("Image was \(saliencyTestImage.width) * " +
    //         "\(saliencyTestImage.height), now " +
    //         "\(attentionCrop?.width ?? 0) * \(attentionCrop?.height ?? 0).")
    // }

    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //MARK: VISION: SIMILARITY
    func similarity(to image: UIImage) -> Float?
        {
            var similarity: Float = 0
            guard let firstImageFPO = self.featurePrintObservation(),
                let secondImageFPO = image.featurePrintObservation(),
                let _ = try? secondImageFPO.computeDistance(
                    &similarity,
                    to: firstImageFPO
                ) else {
                    return nil
            }
            
            return similarity
        }
            private func featurePrintObservation() -> VNFeaturePrintObservation? {
            guard let cgImage = self.cgImage else { return nil }
            
            let requestHandler =
                VNImageRequestHandler(cgImage: cgImage,
                orientation: self.cgImageOrientation,
                options: [:]
            )

            let request = VNGenerateImageFeaturePrintRequest()
            if let _ = try? requestHandler.perform([request]),
                let result = request.results?.first
                    as? VNFeaturePrintObservation {
                return result
            }
            
            return nil
        }

}




//MARK: - EXTRA EXTENSIONS

//MARK: - CGSize
public extension CGSize
{
    func scaleFactor(to size: CGSize) -> CGFloat
    {
        let horizontalScale = self.width/size.width
        let verticalScale = self.height/size.height
        
        return max(horizontalScale, verticalScale)
    
    }
}
//MARK: - CGRect
public extension CGRect{
    func scaled(by scaleFactor: CGFloat) -> CGRect
    {
        let horizontalInsets = (self.width - (self.width * scaleFactor)) / 2.0
        let verticalInsets = (self.height - (self.height * scaleFactor)) / 2.0
        let edgeInsets = UIEdgeInsets(
            top:verticalInsets,
            left: horizontalInsets,
            bottom: verticalInsets,
            right: horizontalInsets
        )
        let leftOffset = min(self.origin.x + horizontalInsets, 0)
        let upOffset = min(self.origin.y + verticalInsets, 0)
        return self
            .inset(by: edgeInsets)
            .offsetBy(dx: -leftOffset, dy: -upOffset)
    }
    
    func cropped(to size: CGSize, centering: Bool = true) -> CGRect
    {
        if centering
        {
            let horizontalDifference = self.width - size.height
            let verticalDifference = self.height - size.height
            let newOrigin = CGPoint(x: self.origin.x + (horizontalDifference / 2.0), y: self.origin.y + (verticalDifference / 2.0))
            return CGRect(x: newOrigin.x, y: newOrigin.y, width: size.width, height: size.height)
        }
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

//MARK: - Vision Extensions

//It acts as a handle for an image that we’re working with, so we don’t need to mess with the real definitive copy of an image.
extension VNImageRequestHandler
{
    convenience init?(uiImage: UIImage)
    {
        guard let cgImage = uiImage.cgImage else {return nil}
        let orientation = uiImage.cgImageOrientation
        self.init(cgImage: cgImage, orientation: orientation)
    }
}

//This queues up requests for the VNImageRequestHandler: it allows us to push things into Vision to be processed.
extension VNRequest
{
    func queueFor(image: UIImage,  completion: @escaping ([Any]?) -> ())
    {
        DispatchQueue.global().async {
            if let handler = VNImageRequestHandler(uiImage: image) {
                try? handler.perform([self])
                completion(self.results)
            } else {
                return completion(nil)
            }
        }
    }
}

