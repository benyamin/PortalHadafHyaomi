//
//  Window+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 08/07/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow
{
    func mainViewController() -> Main_IPadViewController?
    {
        if(UIDevice.current.userInterfaceIdiom == .pad)
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
