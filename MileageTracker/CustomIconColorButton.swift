//
//  CustomIconColorButton.swift
//  whatsinit
//
//  Created by Vlad Alexandru on 16/01/2017.
//  Copyright © 2017 Cypien. All rights reserved.
//

import UIKit

class CustomIconColorButton: UIButton {
    @IBInspectable var iconColor: UIColor! {
        didSet {
            let origImage = imageView!.image
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            setImage(tintedImage, for: .normal)
            tintColor = iconColor
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        imageView?.tintColor = iconColor
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        tintColor = iconColor
    }
}
