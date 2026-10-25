//
//  Window+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 08/07/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

/// Which layout the app shows: the iPhone screens, or the wide (iPad) screens.
/// The wide layout is used when the screen is big enough — on iPad, and on iPhone Fold when it is open.
enum AppLayout
{
    /// Shortest screen side (points) from which the wide (iPad) layout is used
    static let wideMinShortSide:CGFloat = 600
    
    /// Set when the layout switches (fold / unfold) so the new Talmud screen opens on the same page
    static var restorePageAfterSwitch = false
    
    static func shouldUseWide(for size:CGSize) -> Bool
    {
        #if DEBUG
        // Testing on an iPhone simulator (Scheme > Run > Arguments):
        //   -forceWideLayout YES      -> always use the iPad layout
        //   -simulateFoldOnRotate YES -> landscape = "open" (iPad layout), portrait = "closed" (iPhone layout)
        if UserDefaults.standard.bool(forKey: "forceWideLayout") { return true }
        if UserDefaults.standard.bool(forKey: "simulateFoldOnRotate") { return size.width > size.height }
        #endif
        return min(size.width, size.height) >= wideMinShortSide
    }
    
    static var currentWindow:UIWindow? {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        return windows.first(where: { $0.isKeyWindow }) ?? windows.first
    }
    
    /// True while the wide (iPad) layout is on screen
    static var isWide:Bool {
        if let root = currentWindow?.rootViewController {
            return root is Main_IPadViewController
        }
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension UIWindow
{
    func mainViewController() -> Main_IPadViewController?
    {
        if(AppLayout.isWide)
        {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                ,rootViewController is Main_IPadViewController
            {
                let mainViewController = rootViewController as! Main_IPadViewController
                return mainViewController
            }
        }
        return nil
    }
}
