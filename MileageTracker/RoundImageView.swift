//
//  RoundImageView.swift
//  leroy
//
//  Created by Vlad Alexandru on 18/08/16.
//  Copyright © 2016 Cypien. All rights reserved.
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
