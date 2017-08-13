//
//  AppDelegate.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 10/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let container: Container = {
        let container = Container()
        container.register(Presentable.self, name: "GameScene") { r in
            GameSceneViewController(game: r.resolve(GameProtocol.self)!)
        }
        container.register(GameProtocol.self) { r in
            Game(gameLogic: r.resolve(GameLogicProtocol.self)!)
        }
        container.register(GameLogicProtocol.self) { _ in
            GameLogic()
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let gameScene = container.resolve(Presentable.self, name: "GameScene")
        window?.rootViewController = gameScene?.viewController
        window?.makeKeyAndVisible()

        return true
    }
}
