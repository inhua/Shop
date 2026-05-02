//
//  SceneDelegate.swift
//  shop
//
//  Created by MS.L on 2026/4/6.
//

import UIKit
import ShopMediator
import ShopRouter
import ShopLogin   // 提供 RouterPath.Login 扩展

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        // 根据登录状态决定根控制器，通过 CTMediator 获取，不直接引用业务类
        let isLoggedIn = CTMediator.shared.isLoggedIn()
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        //在程序加载完成后判断登录
        if !isLoggedIn {
            if let rootVC = window?.rootViewController, let loginVC = CTMediator.shared.loginViewController()  {
                loginVC.modalPresentationStyle = .fullScreen
                rootVC.present(loginVC, animated: true)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
