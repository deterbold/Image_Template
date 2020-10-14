//
//  UIImageView_xts.swift
//  Image_Template
//
//  Created by Miguel Sicart on 01/10/2020.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/26569371/how-do-you-create-a-uiimage-view-programmatically-swift

extension UIImageView
{
    func imageViewRoundCorners()
    {
        layer.cornerRadius = 10
        layer.borderWidth = 1.0
        layer.masksToBounds = true
    }
}
