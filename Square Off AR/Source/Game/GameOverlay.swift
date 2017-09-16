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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setupMenuItems() {
        logo = SKSpriteNode(texture: SKTexture(imageNamed: "Logo"))
        logo.position = CGPoint(x: size.width * 0.5, y: size.height * 0.8)

        playButton = Button(defaultTexture: SKTexture(imageNamed: "Play Button"))
        playButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }

    private func setupGameItems() {
        replayButton = Button(defaultTexture: SKTexture(imageNamed: "Replay Button"))
        replayButton.position = CGPoint(x: replayButton.size.width * 0.75,
                                        y: size.height - replayButton.size.height * 0.75)
    }

    // MARK: - Private
    var logo: SKSpriteNode!
    var playButton: Button!
    var replayButton: Button!
}

// MARK: - GameOverlayProtocol
extension GameOverlay: GameOverlayProtocol {
    var playButtonPressed: (() -> Void)? {
        get { return playButton.callback }
        set { playButton.callback = newValue }
    }

    func showMainMenu() {
        removeAllChildren()
        addChild(playButton)
        addChild(logo)
    }

    func showGameOverlay() {
        removeAllChildren()
        addChild(replayButton)
    }
}
