//
//  Collection_Faces_xts.swift
//  Image_Template
//
//  Created by Miguel Sicart on 03/10/2020.
//

import Foundation
import UIKit
import Vision

extension Collection where Element == VNFaceObservation
{
    func drawnOn(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
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

        for observation in self {
            let rect = observation.boundingBox

            let normalizedRect =
                VNImageRectForNormalizedRect(rect,
                    Int(image.size.width),
                    Int(image.size.height))
                .applying(transform)

            context.stroke(normalizedRect)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return result
        
    }
}

