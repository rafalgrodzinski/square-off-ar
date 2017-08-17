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

    private lazy var arView: ARSCNView = {
        guard let arView = view as? ARSCNView else { fatalError() }
        return arView
    }()
    private func setupARScene() {
        arView.delegate = self
        arView.scene = game.scene
        let arConfig = ARWorldTrackingConfiguration()
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        game.touchedDown()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        game.touchedUp()
    }

    // MARK: - Private
    private func hitTestSurface() {
        if !game.isLookingForSurface { return }

        DispatchQueue.main.async { [weak self] in
            if let result = self?.arView.hitTest(self!.view.frame.center, types: .featurePoint).first {
                var transform: SCNMatrix4!
                if let anchor = result.anchor {
                    transform = SCNMatrix4(simdMatrix: anchor.transform)
                } else {
                    transform = SCNMatrix4(simdMatrix: result.worldTransform)
                }
                self?.game.update(surfaceTransform: transform)
            }
        }
    }
}

extension GameSceneViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        hitTestSurface()
        // Camera
        guard let currentFrame = arView.session.currentFrame else { return }
        let transform = SCNMatrix4(simdMatrix: currentFrame.camera.transform)
        game.update(cameraTransform: transform)
    }
}
