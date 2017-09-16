//
//  UIViewExtension.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 16/09/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import UIKit

private var _topMargin: CGFloat = 0.0
extension UIView {
    class var topMargin: CGFloat {
        get {
            return _topMargin
        }
        set {
            _topMargin = newValue
        }
    }
}
