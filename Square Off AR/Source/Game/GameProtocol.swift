//
//  GameProtocol.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 12/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit

protocol GameProtocol {
    // MARK: - Initialization
    var scene: SCNScene { get }
    func startGame()
    
    // MARK: - Update
    func tapped()
    func updated(cameraTransform: SCNMatrix4)
    func updated(lightIntensity: CGFloat)
    var isLookingForSurface: Bool { get }
    func foundSurface(for result: ARHitTestResult)
}

extension GameProtocol where Self: SCNScene {
    var scene: SCNScene { return self }
}
