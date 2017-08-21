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
    private var currentBlockRotX: Float = 0.0
    private var currentBlockRotY: Float = 0.0
    private var currentBlockSavedRotX: Float = 0.0
    private var currentBlockSavedRotY: Float = 0.0
}

extension Game: GameProtocol {
    var isLookingForSurface: Bool {
        return gameLogic.state == .lookingForSurface || gameLogic.state == .placingBoard
    }
    
    func tapped() {
        switch gameLogic.state {
            case .placingBoard:
                placeBoard()
            case .waitingForMove:
                currentBlock?.physicsBody?.collisionBitMask = -1
                currentBlock?.physicsBody?.isAffectedByGravity = true
                currentBlock?.opacity = 1.0
                currentBlockRotX = 0.0
                currentBlockRotY = 0.0
                gameLogic.blockPlaced()
            default:
                break
        }
    }

    func swipped(direction: CGPoint) {
        let angleX = Float(direction.y) * Float.pi
        let angleY = -Float(direction.x) * Float.pi

        if direction == CGPoint.zero {
            currentBlockSavedRotX = currentBlockRotX
            currentBlockSavedRotY = currentBlockRotY
        }

        currentBlockRotX = currentBlockSavedRotX + angleX
        currentBlockRotY = currentBlockSavedRotY + angleY
    }

    func updated(cameraTransform: SCNMatrix4) {
        if gameLogic.state != .waitingForMove { return }
        
        let newTransform = rootNode.convertTransform(cameraTransform, from: nil)
        let translation = SCNMatrix4MakeTranslation(0.0, 0.0, -1.0)
        let translated = SCNMatrix4Mult(translation, newTransform)
        currentBlock?.transform = translated

        var rotationQuaternion = GLKQuaternionIdentity
        // X rotation
        var xAxisRotation = GLKVector3Make(0.0, 1.0, 0.0)
        xAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(rotationQuaternion), xAxisRotation)
        rotationQuaternion = GLKQuaternionMultiply(rotationQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(currentBlockRotX), xAxisRotation))

        // Y rotation
        var yAxisRotation = GLKVector3Make(1.0, 0.0, 0.0)
        yAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(rotationQuaternion), yAxisRotation)
        rotationQuaternion = GLKQuaternionMultiply(rotationQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(currentBlockRotY), yAxisRotation))

        let newRotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuaternion)
        let scnNewRotationMatrix = SCNMatrix4FromGLKMatrix4(newRotationMatrix)
        currentBlock?.transform = SCNMatrix4Mult(scnNewRotationMatrix, currentBlock!.transform)

    }

    func updated(surfaceTransform: SCNMatrix4) {
        showPlaceholder()
        gameLogic.surfaceFound()
        update(sceneTransform: surfaceTransform)
    }

    func updatedPhysics() {
        if gameLogic.state == .checkingResult && currentBlock?.physicsBody?.isResting == true {
            currentBlock = nil
            gameLogic.blockStabilized()
        }
    }
}

extension Game: GameLogicDelegate {
    func present(block: SCNNode) {
        currentBlock = block
        currentBlock?.opacity = 0.5
        rootNode.addChildNode(block)
    }
}
