//
//  AppDelegate.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 28.01.2021.
//

import UIKit
import UserNotifications
import Resolver

//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, _) in
            
        }
        
        let IS_UI_TESTS = ProcessInfo.processInfo.arguments.contains("UI_TESTS")
        
        if IS_UI_TESTS {
            setupDependenciesForUITesting()
        } else {
            setupDependencies()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension AppDelegate {
    func setupDependenciesForUITesting() {
        let env = ProcessInfo.processInfo.environment
        if let code = env["pinCode"] {
            MockPrefs.shared.pinCode = code
        }
        
        if let code = env["pinIsOn"] {
            MockPrefs.shared.pinIsOn = code == "true"
        }
        
        if let bio = env["biometricsIsEnabled"] {
            MockPrefs.shared.biometricsIsOn = bio == "true"
        }
        
        Resolver.register(factory: { GeocodedLocationProviderImpl() })
        Resolver.register(factory: { MockPrefs.shared as PreferencesProtocol })
        Resolver.register(factory: { AccountManager() })
    }
    
    func setupDependencies() {
        Resolver.register(factory: { GeocodedLocationProviderImpl() })
        Resolver.register(factory: { Preferences() as PreferencesProtocol })
        Resolver.register(factory: { AccountManager() })
    }
}
