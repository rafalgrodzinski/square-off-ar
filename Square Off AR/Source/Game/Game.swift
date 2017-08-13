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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Private
    private let sceneNode = SCNNode()
    private func setupScene() {
        rootNode.addChildNode(sceneNode)
        setupLight()
        setupFloor()
        setupBoard()
    }

    private func setupLight() {
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = .spot
        spotLightNode.light?.intensity = 40.0
        spotLightNode.light?.shadowMode = .deferred
        spotLightNode.light?.castsShadow = true
        spotLightNode.light?.shadowBias = 8.0
        spotLightNode.light?.shadowColor = UIColor(white: 0.5, alpha: 0.5)
        spotLightNode.constraints = [SCNLookAtConstraint(target: sceneNode)]
        spotLightNode.position = SCNVector3(x: 1.0, y: 1.0, z: -1.0)
        sceneNode.addChildNode(spotLightNode)
    }

    private func setupFloor() {
        let floorNode = SCNNode(geometry: SCNFloor())
        floorNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        floorNode.geometry?.firstMaterial?.colorBufferWriteMask = []
        sceneNode.addChildNode(floorNode)
    }

    private func setupBoard() {
        guard let boardNode = SCNScene(named: "Board.scn")?.rootNode.childNode(withName: "Board", recursively: true) else { fatalError() }
        sceneNode.addChildNode(boardNode)
    }

    private func updateSceneNode(with transform: SCNMatrix4) {
        sceneNode.transform = transform
    }

    private func showPlaceholder() {
        if gameLogic.state != .lookingForSurface { return }
        setupScene()
        sceneNode.opacity = 0.5
    }

    private func placeBoard() {
        sceneNode.opacity = 1.0
        gameLogic.boardPlaced()
    }
}

extension Game: GameProtocol {    
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
        return gameLogic.state == .lookingForSurface || gameLogic.state == .placingBoard
    }

    func foundSurface(for result: ARHitTestResult) {
        var transform: SCNMatrix4!
        if let anchor = result.anchor {
            transform = SCNMatrix4(simdMatrix: anchor.transform)
        } else {
            transform = SCNMatrix4(simdMatrix: result.worldTransform)
        }
        updateSceneNode(with: transform)
        showPlaceholder()
        gameLogic.surfaceFound()
    }
}
