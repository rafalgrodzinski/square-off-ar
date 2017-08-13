//
//  GameLogic.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 13/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

class GameLogic {
    // MARK: - State
    var gameState: GameState = .lookingForSurface
}

extension GameLogic: GameLogicProtocol {
    var state: GameState { return gameState }

    func surfaceFound() {
        gameState = .placingBoard
    }

    func boardPlaced() {
        gameState = .waitingForMove
    }
}
