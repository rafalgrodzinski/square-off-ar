//
//  GameSceneViewController.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 12/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import UIKit
import ARKit

class GameSceneViewController: UIViewController, Presentable {
    // MARK: - Initialization
     let game: GameProtocol
    init(game: GameProtocol) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        view = ARSCNView()
    }

    override func viewDidLoad() {
        setupARScene()
        setupTouchDetection()
    }

    private func setupARScene() {
        guard let arView = view as? ARSCNView else { fatalError() }
        arView.delegate = self
        arView.scene = game.scene
        arView.automaticallyUpdatesLighting = true
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        arView.session.run(arConfig)
        arView.showsStatistics = true
    }

    private func setupTouchDetection() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAction)))
    }

    // MARK: - Actions
    @objc private func tappedAction(_ sender: UITapGestureRecognizer) {
    }
}

extension GameSceneViewController: ARSCNViewDelegate {
}
