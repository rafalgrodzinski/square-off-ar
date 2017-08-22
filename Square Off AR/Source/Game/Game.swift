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
        floorNode.name = "Floor"
        floorNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        floorNode.geometry?.firstMaterial?.colorBufferWriteMask = []
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.physicsBody?.isAffectedByGravity = false
        floorNode.physicsBody?.categoryBitMask = 1
        floorNode.physicsBody?.contactTestBitMask = -1
        floorNode.physicsBody?.collisionBitMask = 1
        rootNode.addChildNode(floorNode)
        self.floorNode = floorNode
    }

    private func setupGravity() {
        scene.physicsWorld.gravity = SCNVector3(0.0, -9.8, 0.0)
        physicsWorld.contactDelegate = self
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
    private var currentBlockLastSwipe = CGPoint.zero
    private var currentBlockQuaternion = GLKQuaternionIdentity
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
                currentBlock?.physicsBody?.categoryBitMask = 1
                currentBlock?.physicsBody?.isAffectedByGravity = true
                let fadeAction = SCNAction.fadeIn(duration: 0.3)
                fadeAction.timingMode = .easeInEaseOut
                currentBlock?.runAction(fadeAction)
                gameLogic.blockPlaced()
            default:
                break
        }
    }

    func swipped(direction: CGPoint) {
        if currentBlockLastSwipe == CGPoint.zero || direction == CGPoint.zero {
            currentBlockLastSwipe = direction
            return
        }

        // X Axis
        let angleX = Float(direction.x - currentBlockLastSwipe.x) * Float.pi

        var xAxisRotation = GLKVector3Make(1.0, 0.0, 0.0)
        xAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(currentBlockQuaternion), xAxisRotation)
        currentBlockQuaternion = GLKQuaternionMultiply(currentBlockQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(-angleX), xAxisRotation))

        // Y Axis
        let angleY = Float(direction.y - currentBlockLastSwipe.y) * Float.pi

        var yAxisRotation = GLKVector3Make(0.0, 1.0, 0.0)
        yAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(currentBlockQuaternion), yAxisRotation)
        currentBlockQuaternion = GLKQuaternionMultiply(currentBlockQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(angleY), yAxisRotation))

        currentBlockLastSwipe = direction
    }

    func updated(cameraTransform: SCNMatrix4) {
        if gameLogic.state != .waitingForMove { return }
        
        let newTransform = rootNode.convertTransform(cameraTransform, from: nil)
        let translation = SCNMatrix4MakeTranslation(0.0, 0.0, -1.0)
        let translated = SCNMatrix4Mult(translation, newTransform)
        currentBlock?.transform = translated

        let newRotationMatrix = GLKMatrix4MakeWithQuaternion(currentBlockQuaternion)
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
            let height = rootNode.boundingBox.max.y - rootNode.boundingBox.min.y
            gameLogic.blockStabilized(with: height)
        }
    }
}

extension Game: GameLogicDelegate {
    func present(block: SCNNode) {
        currentBlockQuaternion = GLKQuaternionIdentity
        currentBlock = block
        currentBlock?.opacity = 0.0
        let fadeAction = SCNAction.fadeOpacity(to: 0.5, duration: 0.3)
        fadeAction.timingMode = .easeInEaseOut
        currentBlock?.runAction(fadeAction)
        rootNode.addChildNode(block)
    }
}

extension Game: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if gameLogic.state != .checkingResult { return }
        var isFloor = false
        isFloor = contact.nodeA === floorNode || contact.nodeB === floorNode
        var isBoard = false
        isBoard = contact.nodeA === boardNode || contact.nodeB === boardNode

        if isFloor && !isBoard {
            gameLogic.blocksCollapsed()
        }
    }
}
