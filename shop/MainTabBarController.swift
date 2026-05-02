// MainTabBarController.swift - 壳工程主TabBar
// 仅依赖 ShopMediator（CTMediator）和 ShopRouter（MTRouter / RouterPath）
// 不直接 import 任何业务组件类
import UIKit
import ShopMediator
import ShopRouter
import ShopLogin   // 提供 RouterPath.Login 扩展

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
        observeCartChange()
        observeLoginState()
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
    }

    private func setupViewControllers() {
        let homeVC    = CTMediator.shared.homeViewController()    ?? UIViewController()
        let messageVC = CTMediator.shared.messageViewController() ?? UIViewController()
        let cartVC    = CTMediator.shared.cartViewController()    ?? UIViewController()
        let mineVC    = CTMediator.shared.mineViewController()    ?? UIViewController()

        let home    = makeNav(homeVC,    title: "首页",  image: "house",   selected: "house.fill")
        let message = makeNav(messageVC, title: "消息",  image: "bell",    selected: "bell.fill")
        let cart    = makeNav(cartVC,    title: "购物车", image: "cart",    selected: "cart.fill")
        let mine    = makeNav(mineVC,    title: "我的",  image: "person",  selected: "person.fill")

        viewControllers = [home, message, cart, mine]
        updateCartBadge()
    }

    private func makeNav(_ vc: UIViewController, title: String, image: String, selected: String) -> UINavigationController {
        vc.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selected)
        )
        return UINavigationController(rootViewController: vc)
    }

    // MARK: - Notifications
    private func observeCartChange() {
        // 使用原始字符串避免直接 import ShopBusinessBase
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCartBadge),
            name: Notification.Name("cartDidChange"),
            object: nil
        )
    }

    private func observeLoginState() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: Notification.Name("userDidLogout"),
            object: nil
        )
    }

    @objc private func updateCartBadge() {
        let count = CTMediator.shared.cartBadgeCount()
        let cartNav = viewControllers?[2]
        cartNav?.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }

    @objc private func handleLogout() {
        MTRouter.shared.open(RouterPath.Login.main, style: .present, from: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
