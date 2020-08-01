//
//  UICollectionView+Extension.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 01/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    /// Call this method from `prepareForReuse`, because the cell needs to be already rendered (and have a size) in order for this to work
    func shadowDecorate(radius: CGFloat = 15,
                        shadowColor: UIColor = UIColor.black,
                        shadowOffset: CGSize = CGSize(width: 0, height: 0),
                        shadowRadius: CGFloat = 4,
                        shadowOpacity: Float = 0.5) {
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}
