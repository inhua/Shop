//
//  AppDelegate.swift
//  shop
//
//  Created by MS.L on 2026/4/6.
//

import UIKit
import ShopRouter
import ShopHome
import ShopCart
import ShopMine
import ShopMessage
import ShopLogin
import ShopProduct

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MTRouter.shared.registerAll([
            ShopHomeRouteRegistrar.self,
            ShopCartRouteRegistrar.self,
            ShopMineRouteRegistrar.self,
            ShopMessageRouteRegistrar.self,
            ShopLoginRouteRegistrar.self,
            ShopProductRouteRegistrar.self,
        ])
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
