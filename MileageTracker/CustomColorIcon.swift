//
//  CustomColorIcon.swift
//  whatsinit
//
//  Created by Vlad Alexandru on 16/01/2017.
//  Copyright © 2017 Cypien. All rights reserved.
//

import UIKit

class CustomColorIcon: UIImageView {
    @IBInspectable var iconColor: UIColor! {
        didSet {
            image = image?.withRenderingMode(.alwaysTemplate)
            self.tintColor =  iconColor

        }
    }
    
}
