//
//  GameLogic.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 13/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

class GameLogic {
    // MARK: - Initialization
    private var blockFactory: BlockGeneratable

    init(blockFactory: BlockGeneratable) {
        self.blockFactory = blockFactory
    }

    // MARK: - State
    var gameState: GameState = .showingMenu
    var delegate: GameLogicDelegate?

    func showNewBlock() {
        let block = blockFactory.generateBlock()
        delegate?.present(block: block)
    }
}

extension GameLogic: GameLogicProtocol {
    var state: GameState { return gameState }

    func gameStarted() {
        gameState = .lookingForSurface
    }

    func surfaceFound() {
        gameState = .placingBoard
    }

    func boardPlaced() {
        gameState = .waitingForMove
        showNewBlock()
    }

    func blockPlaced() {
        gameState = .checkingResult
    }

    func blockStabilized() {
        gameState = .waitingForMove
        showNewBlock()
    }

    func blocksCollapsed() {
        gameState = .gameFinished
    }
}
