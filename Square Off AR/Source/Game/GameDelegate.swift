//
//  GameDelegate.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 16/09/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import Foundation

protocol GameDelegate {
    var height: Measurement<UnitLength> { get set }

    func gameOver()
    func showInfo(message: String)
}
