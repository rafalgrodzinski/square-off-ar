//
//  Game.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 12/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit

class Game: SCNScene {
    // MARK: - Initialization
    private let gameLogic: GameLogicProtocol

    init(gameLogic: GameLogicProtocol) {
        self.gameLogic = gameLogic
        super.init()
        setupBoard()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private let sceneNode = SCNNode()
    private func setupBoard() {
    }

    // MARK: - Private
    private func updateSceneNode(with transform: SCNMatrix4) {
        sceneNode.transform = transform
    }

    private func showPlaceholder() {
    }

    private func placeBoard() {
    }
}

extension Game: GameProtocol {
    func startGame() {
    }

    func tapped() {
        switch gameLogic.state {
            case .placingBoard:
                placeBoard()
            default:
                break
        }
    }

    func updated(cameraTransform: SCNMatrix4) {
    }

    func updated(lightIntensity: CGFloat) {
    }

    var isLookingForSurface: Bool {
        return gameLogic.state == .lookingForSurface
    }

    func foundSurface(for result: ARHitTestResult) {
        var transform: SCNMatrix4!
        if let anchor = result.anchor {
            transform = SCNMatrix4(simdMatrix: anchor.transform)
        } else {
            transform = SCNMatrix4(simdMatrix: result.worldTransform)
        }
        updateSceneNode(with: transform)
    }
}
