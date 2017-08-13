//
//  CGRectExtension.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 13/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: width/2.0, y: height/2.0)
    }
}
