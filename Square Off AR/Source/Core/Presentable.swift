//
//  Presentable.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 12/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import UIKit

protocol Presentable {
    var viewController: UIViewController { get }
}

extension Presentable where Self: UIViewController {
    var viewController: UIViewController { return self }
}
