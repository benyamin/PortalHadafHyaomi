//
//  UIViewController+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController
{
    class func withName(_ VCIdentifier:String, storyBoardIdentifier:String) -> UIViewController
    {
        let storyboard = UIStoryboard(name: storyBoardIdentifier, bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: VCIdentifier)
        
        return viewController
    }
    
    func pushViewController(_ VCIdentifier:String, fromStoryBoard storyBoardIdentifier:String)
    {
        // self.menuCollectoinView.semanticContentAttribute = .forceLeftToRight
        let viewController =  UIViewController.withName(VCIdentifier, storyBoardIdentifier: storyBoardIdentifier)
        
        if let navController = self.navigationController
        {
            navController.pushViewController(viewController, animated: true)
        }
        else{
            let navController = UINavigationController(rootViewController: viewController)
            navController.isNavigationBarHidden = true
                        
            self.present(navController, animated: true, completion: nil)
        }
    }
}
