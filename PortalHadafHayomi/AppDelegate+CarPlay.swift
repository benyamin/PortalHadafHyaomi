//
//  AppDelegate+CarPlay.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import UIKit

// Add these methods to your existing AppDelegate class
extension AppDelegate {
    
    // MARK: UISceneSession Lifecycle (iOS 13+)
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Determine the scene type based on the session role
        switch connectingSceneSession.role {
        case .carTemplateApplication:
            // CarPlay scene
            let config = UISceneConfiguration(name: "CarPlay Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = CarPlaySceneDelegate.self
            return config
            
        case .windowApplication:
            // Regular iOS app scene
            let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = SceneDelegate.self
            config.storyboard = UIStoryboard(name: "Main", bundle: nil)
            return config
            
        default:
            // Fallback
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}