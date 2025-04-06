//
//  AppCoordinator.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-04.
//


import UIKit
// MARK: - AppCoordinator
class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let homeViewController = HCChatViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
