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
    var delegate: GameDelegate?
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
        floorNode.physicsBody?.contactTestBitMask = 1
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
        delegate?.showInfo(message: "Tap to Place")
    }

    private func placeBoard() {
        rootNode.opacity = 1.0
        gameLogic.boardPlaced()
        delegate?.height = Measurement(value: 0.0, unit: UnitLength.meters)
    }

    private func update(sceneTransform: SCNMatrix4) {
        boardNode?.transform = sceneTransform
        floorNode?.transform = sceneTransform
    }

    private func rotateCurrentBlock(angleX: Float, angleY: Float) {
        // X Axis
        var xAxisRotation = GLKVector3Make(1.0, 0.0, 0.0)
        xAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(currentBlockQuaternion), xAxisRotation)
        currentBlockQuaternion = GLKQuaternionMultiply(currentBlockQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(-angleX), xAxisRotation))

        // Y Axis
        var yAxisRotation = GLKVector3Make(0.0, 1.0, 0.0)
        yAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(currentBlockQuaternion), yAxisRotation)
        currentBlockQuaternion = GLKQuaternionMultiply(currentBlockQuaternion, GLKQuaternionMakeWithAngleAndVector3Axis(Float(angleY), yAxisRotation))
    }

    private func updateCurrentBlockTransform(transform: SCNMatrix4, rotationQuaternion: GLKQuaternion) {
        guard let currentBlock = currentBlock else { fatalError() }

        let newTransform = rootNode.convertTransform(transform, from: nil)
        let translation = SCNMatrix4MakeTranslation(0.0, 0.0, -1.0)
        let translated = SCNMatrix4Mult(translation, newTransform)
        currentBlock.transform = translated

        let newRotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuaternion)
        let scnNewRotationMatrix = SCNMatrix4FromGLKMatrix4(newRotationMatrix)
        currentBlock.transform = SCNMatrix4Mult(scnNewRotationMatrix, currentBlock.transform)
    }

    private func showStabilizingMessage() {
        let messages = ["Will it stand? 😯", "... 😳", "Settling down... 😨", "It should work 😨", "Uh oh 😬"]
        let message = messages[Int(arc4random() % UInt32(messages.count))]
        delegate?.showInfo(message: message)
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

    func startGame() {
        gameLogic.gameStarted()
        delegate?.showInfo(message: "Looking for Surface")
    }

    func restartGame() {
        rootNode.childNodes.forEach {
            $0.removeAllActions()
            $0.removeFromParentNode()
        }
        delegate?.height = Measurement(value: 0.0, unit: UnitLength.meters)
        gameLogic.gameStarted()
        delegate?.showInfo(message: "Looking for Surface")
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
                showStabilizingMessage()
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

        let angleX = Float(direction.x - currentBlockLastSwipe.x) * Float.pi
        let angleY = Float(direction.y - currentBlockLastSwipe.y) * Float.pi
        rotateCurrentBlock(angleX: angleX, angleY: angleY)

        currentBlockLastSwipe = direction
    }

    func updated(cameraTransform: SCNMatrix4) {
        if gameLogic.state != .waitingForMove { return }

        updateCurrentBlockTransform(transform: cameraTransform, rotationQuaternion: currentBlockQuaternion)
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
            delegate?.height = Measurement(value: Double(height), unit: UnitLength.meters)
            gameLogic.blockStabilized()
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

        let angX = Float.pi * 2.0 / (1000.0 / Float(arc4random() % 1000))
        let angY = Float.pi * 2.0 / (1000.0 / Float(arc4random() % 1000))
        rotateCurrentBlock(angleX: angX, angleY: angY)
    }
}

extension Game: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let isCurrentNode = contact.nodeA == currentBlock || contact.nodeB == currentBlock
        if isCurrentNode && currentBlock!.opacity < 0.9 {
            return
        }
        var isFloor = false
        isFloor = contact.nodeA === floorNode || contact.nodeB === floorNode
        var isBoard = false
        isBoard = contact.nodeA === boardNode || contact.nodeB === boardNode

        if isFloor && !isBoard {
            delegate?.showInfo(message: "It collapsed! 😓")
            gameLogic.blocksCollapsed()
            delegate?.gameOver()
        }
    }
}
