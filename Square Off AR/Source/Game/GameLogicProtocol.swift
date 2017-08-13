//
//  GameLogicProtocol.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 13/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

enum GameState {
    case lookingForSurface
    case placingBoard
    case waitingForMove
    case checkingResult
}

protocol GameLogicProtocol {
    var state: GameState { get }

    func surfaceFound()
    func boardPlaced()
}
