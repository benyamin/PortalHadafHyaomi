//
//  Util.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

open class Util{
    
    open class func showDefaultLoadingView(){
        
        //Check if a loading view is running
        if let applicationWindow = UIApplication.shared.keyWindow
        {
            for subView in applicationWindow.subviews
            {
                if subView is BTLoadingView
                {
                    return
                }
            }
        }
        
        //Else Crete and display a loading view
        if let loadingView = UIView.viewWithNib("BTLoadingView") as? BTLoadingView
        {
            if let applicationWindow = UIApplication.shared.keyWindow
            {
                loadingView.frame = applicationWindow.bounds
                applicationWindow.addSubview(loadingView)
            }
        }
    }
    
    open class func hideDefaultLoadingView(){
        
        if let applicationWindow = UIApplication.shared.keyWindow
        {
            for subView in applicationWindow.subviews
            {
                if subView is BTLoadingView
                {
                    subView.removeFromSuperview()
                    return
                }
            }
        }
    }
    
    open class func showLoadingViewOnView(_ view:UIView)
    {
        for subView in view.subviews
        {
            if subView is BTLoadingView
            {
                return
            }
        }
        
        if let loadingView = UIView.viewWithNib("BTLoadingView") as? BTLoadingView
        {
            loadingView.frame = view.bounds
            view.addSubview(loadingView)
        }
    }
    
    open class func removeLoadingViewFromView(_ view:UIView?)
    {
        if view == nil
        {
            return
        }
        
        for subView in view!.subviews
        {
            if subView is BTLoadingView
            {
                subView.removeFromSuperview()
                return
            }
        }
    }
}
