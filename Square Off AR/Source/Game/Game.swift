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

    private func setupScene() {
        setupBoard()
        setupFloor()
        setupGravity()
    }

    var boardNode: SCNNode?
    private func setupBoard() {
        guard let boardNode = SCNScene(named: "Board.scn")?.rootNode.childNode(withName: "Board", recursively: true) else { fatalError() }
        rootNode.addChildNode(boardNode)
        self.boardNode = boardNode
    }

    var floorNode: SCNNode?
    private func setupFloor() {
        let floorNode = SCNNode(geometry: SCNFloor())
        floorNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        floorNode.geometry?.firstMaterial?.colorBufferWriteMask = []
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.physicsBody?.isAffectedByGravity = false
        rootNode.addChildNode(floorNode)
        self.floorNode = floorNode
    }

    private func setupGravity() {
        scene.physicsWorld.gravity = SCNVector3(0.0, -9.8, 0.0)
    }

    // MARK: - Update
    private func showPlaceholder() {
        if gameLogic.state != .lookingForSurface { return }
        setupScene()
        rootNode.opacity = 0.5
    }

    private func placeBoard() {
        rootNode.opacity = 1.0
        gameLogic.boardPlaced()
    }

    private func update(sceneTransform: SCNMatrix4) {
        boardNode?.transform = sceneTransform
        floorNode?.transform = sceneTransform
    }

    // MARK: - Private
    private var currentBlock: SCNNode?
    private var isHoldingCamera = false
}

extension Game: GameProtocol {    
    func tapped() {
        switch gameLogic.state {
            case .placingBoard:
                placeBoard()
            case .waitingForMove:
                currentBlock?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                currentBlock = nil
                gameLogic.blockPlaced()
            default:
                break
        }
    }

    func touchedDown() {
        isHoldingCamera = true
    }

    func touchedUp() {
        isHoldingCamera = false
    }

    func update(cameraTransform: SCNMatrix4) {
        if isHoldingCamera { return }
        let newTransform = rootNode.convertTransform(cameraTransform, from: nil)
        let translation = SCNMatrix4MakeTranslation(0.0, 0.0, -0.5)
        currentBlock?.transform = SCNMatrix4Mult(translation, newTransform)
    }

    var isLookingForSurface: Bool {
        return gameLogic.state == .lookingForSurface || gameLogic.state == .placingBoard
    }

    func update(surfaceTransform: SCNMatrix4) {
        showPlaceholder()
        gameLogic.surfaceFound()
        update(sceneTransform: surfaceTransform)
    }
}

extension Game: GameLogicDelegate {
    func present(block: SCNNode) {
        currentBlock = block
        rootNode.addChildNode(block)
    }
}
