//
//  NavigationActoinSheet.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class NavigationActoinSheet:UIAlertController
{
    class func createWith(address:String?, latitude:Double?, longitude:Double?) -> NavigationActoinSheet {
        
        let actionSheet = NavigationActoinSheet(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addActions(address: address, latitude: latitude, longitude: longitude)
        return actionSheet
    }
    
    private func addActions(address:String?, latitude:Double?, longitude:Double?){
        
        if address != nil {
            self.addAction(UIAlertAction(title: "st_copy.location.address".localize(), style: UIAlertAction.Style.default, handler: { (action) -> Void in
                UIPasteboard.general.string = address
            }))
        }
        
        if let requiredLatitude = latitude
            ,let requiredLongitude = longitude {
            
            self.addAction(UIAlertAction(title: "st_copy.location.coordinates".localize(), style: UIAlertAction.Style.default, handler: { (action) -> Void in
                UIPasteboard.general.string = "\(requiredLatitude) , \(requiredLongitude)"
            }))
            
            if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
                
                self.addAction(UIAlertAction(title: "st_open_in_apple_maps".localize(), style: UIAlertAction.Style.default, handler: { (action) -> Void in
                    UIApplication.shared.open(URL(string: "http://maps.apple.com/?ll=\(requiredLatitude),\(requiredLongitude)")!)
                    
                }))
            }
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
                
                self.addAction(UIAlertAction(title: "st_open_in_google_maps".localize(), style: UIAlertAction.Style.default, handler: { (action) -> Void in
                    UIApplication.shared.open(URL(string: "comgooglemaps://?center=\(requiredLatitude),\(requiredLongitude)&zoom=14&views=traffic")!)
                    
                }))
            }
            if (UIApplication.shared.canOpenURL(URL(string:"waze://")!)){
                
                self.addAction(UIAlertAction(title: "st_open_in_waze".localize(), style: UIAlertAction.Style.default, handler: { (action) -> Void in
                    UIApplication.shared.open(URL(string: "https://waze.com/ul?ll=\(requiredLatitude),\(requiredLongitude)&navigate=yes&utm_source=\(Bundle.main.bundleIdentifier ?? "PortalHadafHayomi")")!)
                }))
            }
        }
        self.addAction(UIAlertAction(title: "st_cancel".localize(), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
        }))
    }
}
