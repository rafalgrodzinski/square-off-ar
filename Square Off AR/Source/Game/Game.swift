//
//  Game.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 12/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit

class Game: SCNScene, GameProtocol {
    // MARK: - Initialization
    private let gameLogic: GameLogicProtocol

    init(gameLogic: GameLogicProtocol) {
        self.gameLogic = gameLogic
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func startGame() {
    }

    // MARK: - Update
    func tapped() {
    }

    func updated(cameraTransform: SCNMatrix4) {
    }

    func updated(lightIntensity: CGFloat) {
    }

    var isLookingForSurface: Bool {
        return false
    }

    func foundSurface(for result: ARHitTestResult) {
    }
}
