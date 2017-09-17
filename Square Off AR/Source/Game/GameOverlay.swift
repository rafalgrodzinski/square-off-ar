//
//  GameOverlay.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 16/09/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import SpriteKit


class GameOverlay: SKScene {
    // MARK: - Initialization
    override init() {
        super.init(size: UIScreen.main.bounds.size)
        setupMenuItems()
        setupGameItems()
        setupGameOverItem()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setupMenuItems() {
        logo = SKSpriteNode(texture: SKTexture(imageNamed: "Logo"))
        logo.position = CGPoint(x: size.width * 0.5,
                                y: size.height - logo.size.height*0.5 - 50.0)

        playButton = Button(defaultTexture: SKTexture(imageNamed: "Play Button"))
        playButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }

    private func setupGameItems() {
        replayButton = Button(defaultTexture: SKTexture(imageNamed: "Replay Button"))
        replayButton.setScale(0.5)
        replayButton.position = CGPoint(x: replayButton.size.width * 0.5,
                                        y: size.height - replayButton.size.height * 0.5)

        heightLabel = SKLabelNode()
        heightLabel.fontSize = 32.0
        heightLabel.position = CGPoint(x: size.width * 0.5, y: replayButton.position.y)
    }

    private func setupGameOverItem() {
        finalScoreLabel = SKLabelNode()
        finalScoreLabel.fontSize = 32.0
        finalScoreLabel.position = CGPoint(x: size.width * 0.5,
                                           y: size.height * 0.5 + 80.0)

        playAgainLabel = SKLabelNode()
        playAgainLabel.text = "Play Again?"
        playAgainLabel.fontSize = 32.0
        playAgainLabel.position = CGPoint(x: size.width * 0.5,
                                          y: size.height * 0.5 + 40.0)

        playAgainButton = Button(defaultTexture: SKTexture(imageNamed: "Replay Button"))
        playAgainButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }

    // MARK: - Update
    private func updateHeightLabel() {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [ .naturalScale ]
        heightLabel.text = "Height: \(formatter.string(from: privateHeight))"
        finalScoreLabel.text = "Height: \(formatter.string(from: privateHeight))"
    }

    // MARK: - Private
    private var logo: SKSpriteNode!
    private var playButton: Button!
    private var replayButton: Button!
    private var heightLabel: SKLabelNode!
    private var finalScoreLabel: SKLabelNode!
    private var playAgainLabel: SKLabelNode!
    private var playAgainButton: Button!
    private var privateHeight: Measurement<UnitLength> = Measurement(value: 0.0, unit: UnitLength.meters)
}

// MARK: - GameOverlayProtocol
extension GameOverlay: GameOverlayProtocol {
    var playButtonPressed: (() -> Void)? {
        get { return playButton.callback }
        set { playButton.callback = newValue }
    }
    var restartButtonPressed: (() -> Void)? {
        get {
            return replayButton.callback
        }
        set {
            replayButton.callback = newValue
            playAgainButton.callback = newValue
        }
    }
    var height: Measurement<UnitLength> {
        get {
            return privateHeight
        }
        set {
            privateHeight = newValue
            updateHeightLabel()
        }
    }

    func showMainMenu() {
        removeAllChildren()
        addChild(playButton)
        addChild(logo)
    }

    func showGameOverlay() {
        removeAllChildren()
        addChild(replayButton)
        addChild(heightLabel)
        updateHeightLabel()
    }

    func showGameOverOverlay() {
        removeAllChildren()
        addChild(playAgainLabel)
        addChild(finalScoreLabel)
        addChild(playAgainButton)
    }
}
