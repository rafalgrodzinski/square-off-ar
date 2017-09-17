//
//  GameOverlayProtocol.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 16/09/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import SpriteKit

protocol GameOverlayProtocol: class {
    var scene: SKScene { get }
    var playButtonPressed: (() -> Void)? { get set }
    var restartButtonPressed: (() -> Void)? { get set }
    var height: Measurement<UnitLength> { get set }

    func showMainMenu()
    func showGameOverlay()
    func showGameOverOverlay()
    func showInfo(message: String)
}

extension GameOverlayProtocol where Self: SKScene {
    var scene: SKScene { return self }
}
