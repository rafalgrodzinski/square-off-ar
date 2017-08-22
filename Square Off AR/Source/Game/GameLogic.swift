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
    private var blocksHeight: Float = 0.0

    init(blockFactory: BlockGeneratable) {
        self.blockFactory = blockFactory
    }

    // MARK: - State
    var gameState: GameState = .lookingForSurface
    var delegate: GameLogicDelegate?

    func showNewBlock() {
        let block = blockFactory.generateBlock()
        delegate?.present(block: block)
    }
}

extension GameLogic: GameLogicProtocol {
    var state: GameState { return gameState }

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

    func blockStabilized(with height: Float) {
        gameState = .waitingForMove
        blocksHeight = height
        print("Current height \(blocksHeight)")
        showNewBlock()
    }

    func blocksCollapsed() {
        gameState = .gameFinished

        print("Game over at \(blocksHeight)")
    }
}
