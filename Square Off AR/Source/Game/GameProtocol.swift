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

    func startGame()
    func restartGame()
    func tapped()
    func swipped(direction: CGPoint)
    func updated(cameraTransform: SCNMatrix4)
    func updated(surfaceTransform: SCNMatrix4)
    func updatedPhysics()

}

extension GameProtocol where Self: SCNScene {
    var scene: SCNScene { return self }
}
