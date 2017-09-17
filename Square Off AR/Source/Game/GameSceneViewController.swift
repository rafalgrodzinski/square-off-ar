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
    let gameOverlay: GameOverlayProtocol
    init(game: GameProtocol, gameOverlay: GameOverlayProtocol) {
        self.game = game
        self.gameOverlay = gameOverlay
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        view = ARSCNView()
    }

    override func viewDidLoad() {
        setupOverlay()
        setupARScene()
        setupTouchDetection()
    }

    private lazy var arView: ARSCNView = {
        guard let arView = view as? ARSCNView else { fatalError() }
        return arView
    }()

    private func setupOverlay() {
        arView.overlaySKScene = gameOverlay.scene
        gameOverlay.showMainMenu()
        gameOverlay.playButtonPressed = { [weak self] in
            self?.gameOverlay.showGameOverlay()
            self?.game.startGame()
        }
        gameOverlay.restartButtonPressed = { [weak self] in
            self?.gameOverlay.showGameOverlay()
            self?.game.restartGame()
        }
    }

    private func setupARScene() {
        arView.delegate = self
        arView.scene = game.scene
        let arConfig = ARWorldTrackingConfiguration()
        arView.session.run(arConfig)
        //arView.showsStatistics = true
    }

    private func setupTouchDetection() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAction)))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pannedAction)))
    }

    // MARK: - Actions
    @objc private func tappedAction(_ sender: UITapGestureRecognizer) {
        game.tapped()
    }

    @objc private func pannedAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            game.swipped(direction: CGPoint.zero)
        } else {
            let translation = sender.translation(in: view)
            let swipeTranslation = CGPoint(x: translation.x / view.frame.width,
                                           y: translation.y / view.frame.width)
            game.swipped(direction: swipeTranslation)
        }
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
                self?.game.updated(surfaceTransform: transform)
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
        game.updated(cameraTransform: transform)
    }

    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        game.updatedPhysics()
    }
}

// MARK: - GameDelegate
extension GameSceneViewController: GameDelegate {
    var height: Measurement<UnitLength> {
        get { return gameOverlay.height }
        set { gameOverlay.height = newValue }
    }

    func gameOver() {
        gameOverlay.showGameOverOverlay()
    }
}
