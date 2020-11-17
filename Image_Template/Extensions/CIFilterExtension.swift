//
//  CIFilterExtension.swift
//  Image_Template
//
//  Created by Miguel Sicart on 11/11/2020.
//

import Foundation
import CoreImage
import UIKit

extension CIFilter
{
    static let mono = CIFilter(name: "CIPhotoEffectMono")!
    static let noir = CIFilter(name: "CIPhotoEffectNoir")!
    static let tonal = CIFilter(name: "CIPhotoEffectTonal")!
    static let invert = CIFilter(name: "CIPhotoEffectInvert")!
    
    static func contrast(amount: Double = 2.0) -> CIFilter
    {
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(amount, forKey: kCIInputContrastKey)
        return filter
    }
    
    static func brighten(amount:Double = 0.1) -> CIFilter
    {
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(amount, forKey: kCIInputBrightnessKey)
        return filter
    }
}
