//
//  GameProtocol.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 12/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit

protocol GameProtocol {
    var scene: SCNScene { get }
    var isLookingForSurface: Bool { get }
    func tapped()
    func swipped(direction: CGPoint)
    func update(cameraTransform: SCNMatrix4)
    func update(surfaceTransform: SCNMatrix4)
}

extension GameProtocol where Self: SCNScene {
    var scene: SCNScene { return self }
}
