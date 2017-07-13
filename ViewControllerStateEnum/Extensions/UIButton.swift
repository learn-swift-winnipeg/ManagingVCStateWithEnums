//
//  UIButton.swift
//  BBLinks
//
//  Created by Justin Stanley on 2016-07-02.
//  Copyright © 2016 Justin Stanley. All rights reserved.
//

import UIKit

internal enum CornerType {
    case square
    case slightlyRounded(radius: CGFloat)
    case fullyRounded
    
    internal static let defaultRadius: CGFloat = 6
}

internal extension UIButton {
    internal func addCornersAndShadow(cornerType: CornerType) {
        let cornerRadius: CGFloat
        
        switch cornerType {
        case .square: cornerRadius = 0
        case .slightlyRounded(let radius): cornerRadius = radius
        case .fullyRounded: cornerRadius = self.bounds.height / 2
        }
        
        clipsToBounds = false
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.25
    }
}
