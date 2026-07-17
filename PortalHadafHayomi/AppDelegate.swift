//
//  AppDelegate.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit
import OneSignalFramework
import CarPlay

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AnalyticsManager.shared.startTracking()
        AnalyticsManager.shared.logEvent("app_launch", info: nil)
        
        if  launchOptions != nil
        {
            if let sourceApplication = launchOptions?[.sourceApplication] as? String
                , sourceApplication == "com.apple.assistant.assistantd"
            {
                //BTAlertView.show(title: "siri", message: "siri", buttonKeys: ["ok"], onComplete:{_ in })
                print ("siri")
            }
          
        }
     
        //RunLoop.current.run(until: NSDate(timeIntervalSinceNow: 1) as Date)
        //Sleep for showing launcScreen for 1 more second
        sleep(UInt32(0.5))
        
        self.setAPN(launchOptions: launchOptions)
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "st_cancel".localize()

        if let autoLock = UserDefaults.standard.object(forKey: "setableItem_AutoLock") as? Bool
        {
           UIApplication.shared.isIdleTimerDisabled = autoLock
        }
        else{
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        self.getUserSettings()
        
        // Window setup is now handled in SceneDelegate for iOS 13+
        // Keep localization and opening screen logic for older iOS versions or when scenes aren't used
        if #available(iOS 13.0, *) {
            // Scene-based app lifecycle - window setup handled in SceneDelegate
        } else {
            // Legacy app lifecycle - set up window here
            if(UIDevice.current.userInterfaceIdiom == .pad) { // iPad
               let storyboard = UIStoryboard(name: "Main_IPadStoryboard", bundle: nil)
                self.window?.rootViewController = storyboard.instantiateInitialViewController()
                
                self.window?.makeKeyAndVisible()
            } else { // iPhone
                self.setIphoneRootView()
            }
            
            self.handleLocalization()
            self.showOpeningScreenIfRequired()
        }
        
        return true
    }
    
    func setIphoneRootView()
    {
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let rootViewController =  storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.setNavigationBarHidden(true, animated: false)
        
        self.window?.rootViewController = navController
        
        self.window?.makeKeyAndVisible()
    }
    
    func handleLocalization()
    {
        //If new version
        if UserDefaults.standard.object(forKey: "lastSavedVersion") == nil
        {
            if let localLanguages = Locale.current.languageCode
            {
                //if Local language is not hebrew suggest the user to select language
                if localLanguages.hasSuffix("he") == false
                {
                    let alertTitle = "st_launch_language_selection_title".localize()
                    let alertMessage = "st_launch_language_selection_message".localize()
                    
                    let localLanguageButtonTitle = "st_local_language".localize()
                    let hebrewLanguageButtonTitle = "st_hebrew_language".localize()
                    BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [localLanguageButtonTitle,hebrewLanguageButtonTitle], onComplete:{ (dismissButtonKey) in
                        
                        if dismissButtonKey == hebrewLanguageButtonTitle
                        {
                            self.setHebrewLanguage()
                            
                            // Refresh the interface to apply language changes
                            if #available(iOS 13.0, *) {
                                // For scene-based apps, we might need to update the interface differently
                                // The root view is already set up in SceneDelegate
                            } else {
                                self.setIphoneRootView()
                            }
                        }
                    })
                }
            }
        }
        else{
            //If user did not select language, force Hebrew languange
            if  UserDefaults.standard.object(forKey: "selectedLanguage") == nil
            {
                self.setHebrewLanguage()
            }
        }
    }
    
    func setHebrewLanguage()
    {
        UserDefaults.standard.set(["he_IL"], forKey: "AppleLanguages")
        
        UserDefaults.standard.set("he_IL", forKey: "selectedLanguage")
        
        UserDefaults.standard.synchronize()

        
        if let localLanguages = Locale.current.languageCode
            ,localLanguages.hasSuffix("he")
        {
        }
        else{
            LanguageManager.shared.defaultLanguage = .he
        }
    }
    
    func showOpeningScreenIfRequired()
    {        
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            if let lastSavedVersion = UserDefaults.standard.object(forKey: "lastSavedVersion") as? String
            {
                if Double(lastSavedVersion)! < Double(currentVersion)!
                {
                    self.showOpeningScreen()
                }
            }
            else{
                self.showOpeningScreen()
            }
            
            UserDefaults.standard.set(currentVersion, forKey: "lastSavedVersion")
            UserDefaults.standard.synchronize()
        }
       
    }
    
    @objc func showOpeningScreen()
    {
        if(UIDevice.current.userInterfaceIdiom == .pad)//IPad
        {
            return
        }
        
        let openingScreeLink = "https://app.daf-yomi.com/mobile/content.aspx?id=331"
        if let url = URL(string:openingScreeLink)
            ,UIApplication.shared.canOpenURL(url)
        {
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            
            self.window?.rootViewController?.present(webViewController, animated: false, completion: nil)
            
            webViewController.loadUrl(openingScreeLink, title:"st_portal_hadaf_hayomi".localize())
        }
    }
    
    func getUserSettings()
    {
        GetUserSettingsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            HadafHayomiManager.sharedManager.userSettings = object as? [SetableItem]
            
            self.getAppSettings()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func getAppSettings()
    {
        GetAppSettingsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            HadafHayomiManager.sharedManager.appSettings = object as? [SetableItem]
            
             self.showAddIfRequired()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showAddIfRequired()
    {
       if let show_ad_page = HadafHayomiManager.sharedManager.getAppSettingValueByKey("show_ad_page") as? Bool
        , show_ad_page == true
        {
           if let ad_page_link = HadafHayomiManager.sharedManager.getAppSettingValueByKey("ad_page_link") as? String
            {
                if let viewedAds = UserDefaults.standard.object(forKey: "viewedAds") as? [String]
                {
                    //If user did  view the required add and clicked on "do not show again"
                    if viewedAds.index(of: ad_page_link) != nil
                    {
                        return
                    }
                }
                
                 self.showAdd(addLink: ad_page_link)
            }
        }
    }
    
    func showAdd(addLink:String)
    {
        let webViewController = BTAddViewController(nibName: "BTAddViewController", bundle: nil)
        
        self.window?.rootViewController?.present(webViewController, animated: false, completion: nil)
        
        webViewController.reloadWithImageUrl(addUrlPath: addLink)
        
    }
    
    func setAPN(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    {
        // Enable verbose logging to debug notification issues
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
        OneSignal.initialize("f97a170e-e77e-408a-b6a0-3ac6adcf4ad3", withLaunchOptions: launchOptions)
        
        // Request push notification permission
        OneSignal.Notifications.requestPermission({ accepted in
            print("OneSignal notification permission accepted: \(accepted)")
        }, fallbackToSettings: true)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
       
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationWillTerminate"), object: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
       
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationWillTerminate"), object: nil)
    }
    
    // MARK: - Scene Support for CarPlay
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {

        if connectingSceneSession.role == .carTemplateApplication {
            // CarPlay Scene
            let carPlaySceneConfig = UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
            carPlaySceneConfig.delegateClass = CarPlaySceneDelegate.self
            return carPlaySceneConfig
        } else {
            // Default iPhone Scene
            let config = UISceneConfiguration(
                name: "Default Configuration",
                sessionRole: connectingSceneSession.role
            )
            config.delegateClass = SceneDelegate.self
            return config
        }
    }
}

