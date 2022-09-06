//
//  SceneDelegate.swift
//  ExitekTechTask
//
//  Created by Maksim Malofeev on 05/09/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let navigationController = UINavigationController(rootViewController: MobileViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

