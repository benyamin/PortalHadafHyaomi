//
//  SceneDelegate.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 04/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be set and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the window for this scene
        window = UIWindow(windowScene: windowScene)
        
        // Set up the root view controller by screen size: iPad layout on big screens (iPad, iPhone Fold open)
        let wide = AppLayout.shouldUseWide(for: windowScene.coordinateSpace.bounds.size)
        window?.rootViewController = self.makeRootViewController(wide: wide)
        
        window?.makeKeyAndVisible()
        
        // Handle localization and opening screen after window is set up
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.handleLocalization()
            appDelegate.showOpeningScreenIfRequired()
        }
    }

    // MARK: - iPhone layout / iPad layout
    
    func makeRootViewController(wide:Bool) -> UIViewController
    {
        if wide { // iPad layout
            let storyboard = UIStoryboard(name: "Main_IPadStoryboard", bundle: nil)
            return storyboard.instantiateInitialViewController()!
        }
        // iPhone layout
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.setNavigationBarHidden(true, animated: false)
        return navController
    }
    
    /// Called when the screen size changes: fold / unfold, Split View, Stage Manager
    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection)
    {
        let wide = AppLayout.shouldUseWide(for: windowScene.coordinateSpace.bounds.size)
        guard let window = self.window, wide != AppLayout.isWide else { return }
        self.switchLayout(toWide: wide, in: window)
    }
    
    func switchLayout(toWide wide:Bool, in window:UIWindow)
    {
        // Keep the page the user is reading
        TalmudViewController.shared?.saveSelectedPage()
        AppLayout.restorePageAfterSwitch = true
        
        window.rootViewController?.dismiss(animated: false, completion: nil)
        
        let newRoot = self.makeRootViewController(wide: wide)
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let animationsWereEnabled = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = newRoot
            UIView.setAnimationsEnabled(animationsWereEnabled)
        }, completion: nil)
        
        // iPhone layout: open the Talmud screen again (the iPad layout always shows it)
        if !wide, let nav = newRoot as? UINavigationController, let home = nav.viewControllers.first as? HomeViewController {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                home.displayTalmudView()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
