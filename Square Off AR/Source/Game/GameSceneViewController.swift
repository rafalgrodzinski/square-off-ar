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
        game.startGame()
    }

    private lazy var arView: ARSCNView = {
        guard let arView = view as? ARSCNView else { fatalError() }
        return arView
    }()
    private func setupARScene() {
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
        game.tapped()
    }

    // MARK: - Private
    private func hitTestSurface() {
        if !game.isLookingForSurface { return }

        DispatchQueue.main.async { [weak self] in
            if let result = self?.arView.hitTest(self!.view.frame.center, types: .featurePoint).first {
                self?.game.foundSurface(for: result)
            }
        }
    }
}

extension GameSceneViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let currentFrame = arView.session.currentFrame else { return }
        // Camera
        let cameraTransform = SCNMatrix4(simdMatrix: currentFrame.camera.transform)
        game.updated(cameraTransform: cameraTransform)
        // Light
        guard let ligthEstimate = currentFrame.lightEstimate else { return }
        game.updated(lightIntensity: ligthEstimate.ambientIntensity)
    }
}
