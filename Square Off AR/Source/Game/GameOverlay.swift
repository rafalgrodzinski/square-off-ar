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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Private
    var playButton: Button!
}

// MARK: - GameOverlayProtocol
extension GameOverlay: GameOverlayProtocol {
    var playButtonPressed: (() -> Void)? {
        get { return playButton.callback }
        set { playButton.callback = newValue }
    }

    func showMainMenu() {
        playButton = Button(defaultTexture: SKTexture(imageNamed: "Play Button"))
        playButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(playButton)
    }

    func showGameOverlay() {
    }
}
