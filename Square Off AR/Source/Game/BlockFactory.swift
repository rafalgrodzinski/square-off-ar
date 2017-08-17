//
//  BlockFactory.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 13/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import SceneKit

class BlockFactory {
    // MARK: - Private
    private let blockNames: [String] = ["Block A"]
}

extension BlockFactory: BlockGeneratable {
    func generateBlock() -> SCNNode {
        let blockNameIndex = Int(arc4random_uniform(UInt32(blockNames.count)))
        let blockName = blockNames[blockNameIndex]
        let blockFileName = blockName + ".scn"
        guard let blockNode = SCNScene(named: blockFileName)?.rootNode.childNode(withName: "Block", recursively: true) else { fatalError() }
        return blockNode
    }
}
