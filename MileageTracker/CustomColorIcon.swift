//
//  CustomColorIcon.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
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
