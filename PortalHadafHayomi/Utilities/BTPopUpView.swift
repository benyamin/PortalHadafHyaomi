//
//  BTPopUpView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

public class BTPopUpView:UIView
{
    var view:UIView!
    var backGroundView:UIView!
    var onComplete:(() -> Void)?
    var backGroundTapGesture:UITapGestureRecognizer!
    
    private class func targetWindow() -> UIWindow?
    {
        if  let applicationWindow = UIApplication.shared.keyWindow
        {
            return applicationWindow
        }
        else if let appDelegate = UIApplication.shared.delegate as? AppDelegate
            ,let window = appDelegate.window
        {
            return window
        }
        
        return nil
    }
    
    public class func show(view:UIView, onComplete:@escaping (() -> Void)) -> BTPopUpView?
    {
        if let window = BTPopUpView.targetWindow()
        {
            let popupView = BTPopUpView(frame:window.bounds)
            popupView.onComplete = onComplete
            
            popupView.show(view: view)
            
            return popupView
            
        }
        return nil
    }
    
    func show(view:UIView)
    {
        self.view = view
        self.backgroundColor = UIColor.clear
        self.view.layer.cornerRadius = 5.0
        self.view.clipsToBounds = true
        
        
        self.backGroundView = UIView(frame:self.bounds)
        
        self.backGroundView.backgroundColor = UIColor.darkGray
        self.backGroundView.alpha = 0.0
        
        self.backGroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        
        self.backGroundView.addGestureRecognizer(self.backGroundTapGesture)
        
        self.addSubview(backGroundView)
        
        view.alpha = 0.0
        self.addSubview(view)
        
       BTPopUpView.targetWindow()?.addSubview(self)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if view is BTPopUpView
        {
            view.translatesAutoresizingMaskIntoConstraints = true
            
            self.view.frame.size.width = self.bounds.size.width - 80
            self.view.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
        else{
            
            let leadingConstraint = NSLayoutConstraint(item:  view, attribute: .leading, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem:  self, attribute: .leading, multiplier: 1, constant: 20)
            self.addConstraint(leadingConstraint)
            
            let trailingConstraint = NSLayoutConstraint(item:  view, attribute: .trailing, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem:  self, attribute: .trailing, multiplier: 1, constant: 20)
            self.addConstraint(trailingConstraint)
            
            
            let horizontalConstraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            
            let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.size.width)
            
            
            self.addConstraint(widthConstraint)
            self.addConstraint(horizontalConstraint)
            self.addConstraint(verticalConstraint)
        }
        
        UIView.animate(withDuration: 0.10, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.backGroundView.alpha = 0.6
                
        }, completion: {_ in
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    view.alpha = 1.0
                    
            }, completion: {_ in
            })
            
        })
        
    }
    
    @objc public func dismiss()
    {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.alpha = 0.0
                
        }, completion: {_ in
            
            UIView.animate(withDuration: 0.10, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    self.backGroundView.alpha = 0.0
                    
            }, completion: {_ in
                
                self.onComplete?()
                
                self.removeFromSuperview()
                
            })
            
        })
    }
    
    public func desableBackGorundTapGesture()
    {
        self.backGroundView.removeGestureRecognizer( self.backGroundTapGesture)
    }
}

