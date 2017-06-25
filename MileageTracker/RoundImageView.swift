//
//  RoundImageView.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.image = self.image?.imageWithInsets(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
}
