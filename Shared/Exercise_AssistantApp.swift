//
//  Exercise_AssistantApp.swift
//  Shared
//
//  Created by Sam Engel on 4/11/22.
//

import SwiftUI
import FirebaseCore

class FSSceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneWillEnterForeground(_ scene: UIScene) {
    // ...
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    // ...
    }

    func sceneWillResignActive(_ scene: UIScene) {
    // ...
    }
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    //        let alertController = UIAlertController(title: "Alert", message: "performActionFor \(shortcutItem.type)", preferredStyle: .alert)
    //        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    //        window?.rootViewController?.present(alertController, animated: true, completion: nil)
        print("gotwindowscene")
    }
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("gotscene")
    //    let contentView = ContentView()
    //    if let windowScene = scene as? UIWindowScene {
    //        let window = UIWindow(windowScene: windowScene)
    //        window.rootViewController = UIHostingController(rootView: contentView)
    //        self.window = window
    //        window.makeKeyAndVisible()
    //    }
    //
    //    if let shortcutItem = connectionOptions.shortcutItem {
    //        let alertController = UIAlertController(title: "ActionSheet", message: "Launched with \(shortcutItem.type)", preferredStyle: .actionSheet)
    //        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    //        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    //    }
    }

  // ...
}
class FSAppDelegate: NSObject, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = FSSceneDelegate.self
    FirebaseApp.configure()
    return sceneConfig
  }
}
@main
struct Exercise_AssistantApp: App {
    @UIApplicationDelegateAdaptor var delegate: FSAppDelegate
    var body: some Scene {
        WindowGroup {
            if (WorkoutAPI.userID == .none) {
                LoginScreen()
            } else {
                ContentView()
            }
        }
    }
    
}
