//
//  HCKeyboardListenerDelegate.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-05.
//
import UIKit



protocol HCKeyboardListenerDelegate: AnyObject {
    func keyboardListener(_ listener: HCKeyboardListener, willShowWith model: HCKeyboardListener.Model)
    func keyboardListener(_ listener: HCKeyboardListener, willHideWith model: HCKeyboardListener.Model)
}


class HCKeyboardListener {

    public private(set) var isUp: Bool = false
    public var height: CGFloat = 0

    public struct Model {
        let duration: TimeInterval
        let animationOptions: UIView.AnimationOptions
        let frame: CGRect
    }

    public weak var delegate: HCKeyboardListenerDelegate?
    public weak var keyboardWindow: UIWindow?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisible(_:)), name: UIWindow.didBecomeVisibleNotification, object: nil)

    }

    @objc private func windowDidBecomeVisible(_ info: Notification) {
        let type = String(describing: info.object)
        if type.range(of: "UIRemoteKeyboardWindow") != nil {
            if let window = info.object as? UIWindow {
                self.keyboardWindow = window
            }
        }
    }

    private func getModel(notification: Notification) -> Model {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.3

        let animationOptions: UIView.AnimationOptions
        if let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            animationOptions = UIView.AnimationOptions(rawValue: curve << 16)
        } else {
            animationOptions = .curveEaseOut
        }

        var frame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero

        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        
        for window in windows {
            if String(describing: type(of: window)) == "UIRemoteKeyboardWindow" {
                keyboardWindow = window
                let keyboardViewController = window.rootViewController
                for view in keyboardViewController?.view.subviews ?? [] {
                    if String(describing: type(of: view)) == "UIInputSetHostView" {
                        if frame.minY <= 0 {
                            frame = view.frame
                        }
                    }
                }
            }
        }

        if frame.minY <= 0 {
            let safeAreaBottomInset = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .safeAreaInsets.bottom ?? 0

            let screenHeight = UIScreen.main.bounds.height

            let y = screenHeight - frame.height - safeAreaBottomInset
            frame.origin.y = y
        }

        self.height = frame.height

        return Model(duration: duration, animationOptions: animationOptions, frame: frame)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {

        isUp = true

        if let delegate {
            delegate.keyboardListener(self, willShowWith: getModel(notification: notification))
        }
    }

    func findKeyboardWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            // Iterate over all connected scenes
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    // Iterate over all windows in the window scene
                    for window in windowScene.windows {
                        if NSStringFromClass(window.classForCoder) == "UIRemoteKeyboardWindow" {
                            return window
                        }
                    }
                }
            }
        } else {
            // Iterate over all windows in the application (for iOS 12 and below)
            for window in UIApplication.shared.windows {
                if NSStringFromClass(window.classForCoder) == "UIRemoteKeyboardWindow" {
                    return window
                }
            }
        }
        return nil
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        isUp = false

        if let delegate {
            delegate.keyboardListener(self, willHideWith: getModel(notification: notification))
        }
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        isUp = false
        keyboardWindow = nil
    }

}
