//
//  BTAlertView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

public class BTAlertView: UIView {
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var bottomBarView:UIView!
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    
    var buttonKeys:[String]!
    weak var popupView:BTPopUpView!
    
    var onComplete:((_ dismissButtonKey:String) -> Void)?
    
    public class func show(title:String, message:String, buttonKeys:[String], onComplete:@escaping (_ dismissButtonKey:String) -> Void )
    {
        let alertView:BTAlertView = UIView.loadFromNibNamed("BTAlertView") as! BTAlertView
        
        alertView.show(title: title, message: message, buttonKeys: buttonKeys, onComplete: onComplete)
    }
    
    public func show(title:String, message:String, buttonKeys:[String], onComplete:@escaping (_ dismissButtonKey:String) -> Void)
    {
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        
        self.onComplete = onComplete
        
        self.loadingIndicator.isHidden = true
        
        self.buttonKeys = buttonKeys
        self.titleLabel.font = UIFont(name: "BroshMF", size: self.titleLabel.font.pointSize)//UIFont.boldSystemFont(ofSize: self.titleLabel.font.pointSize)
        self.titleLabel.text = title
        
        self.messageLabel.font = UIFont(name: "BroshMF", size: self.messageLabel.font.pointSize)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.text = message
        
        self.layer.cornerRadius = 5.0;
        self.bottomBarView.layer.cornerRadius = 5.0;
        
        
        
        self.popupView = BTPopUpView.show(view: self, onComplete:{ })
        self.popupView.desableBackGorundTapGesture()
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64( 0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                                      execute: {
                                        
                                        self.translatesAutoresizingMaskIntoConstraints = true
                                        
                                        self.center.x = self.popupView.center.x // for horizontal
                                        self.center.y = self.popupView.center.y // for vertical
                                        
                                        self.setNeedsDisplay()
                                        self.setNeedsLayout()
                                        
        })
        
        
        for index in 0 ..< self.buttonKeys.count {
            
            let buttonKey = self.buttonKeys[index]
            let button = UIButton(type: .custom)
            button.tag = index
            
            let buttonWidth =  Int(self.frame.size.width) / self.buttonKeys.count
            let buttonOrigenX = Int(buttonWidth) * index
            button.frame = CGRect(x: buttonOrigenX, y: 0, width: buttonWidth, height: Int(bottomBarView.frame.size.height))
            button.backgroundColor = UIColor.clear
            button.setTitle(buttonKey, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(dismissButtonclicked(_:)), for: .touchUpInside)
            button.titleLabel!.font =  UIFont(name: "BroshMF", size: button.titleLabel!.font.pointSize)
            button.setTitleColor(UIColor(HexColor: "6A2423"), for: .normal)
            button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            
            if index < self.buttonKeys.count-1 {
                let lineView = UIView(frame: CGRect(x: button.frame.width - 1, y: 0, width: 1, height: button.frame.size.height))
                lineView.backgroundColor = UIColor.lightGray
                //button.titleLabel?.font = UIFont(name: "Lato-Regular", size: 20)
                button.addSubview(lineView)
            }
            //titleLabel.font = UIFont(name: "Lato-Regular", size: 20)
            //messageLabel.font = UIFont(name: "Lato-Regular", size: 16)
            
            
            //            if index < self.buttonKeys.count
            //            {
            //                if index == 0 {
            //                    button.backgroundColor = UIColor.yellow
            //                }
            //
            //                if index == 1 {
            //                    button.backgroundColor = UIColor.cyan
            //                }
            //            }
            
            
            self.bottomBarView.addSubview(button)
        }
        
        //        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: 340/*bottomBarView.frame.size.width*/, height: 4))
        //        lineView.backgroundColor = UIColor.lightGray
        //        self.bottomBarView.addSubview(lineView)
        
        
        
    }
    
    public func update(title:String, message:String)
    {
        self.titleLabel.isHidden = false
        self.messageLabel.isHidden = false
        self.bottomBarView.isHidden = false
        
        if self.loadingIndicator.isAnimating
        {
            self.loadingIndicator.stopAnimating()
        }
        self.loadingIndicator.isHidden = true
        
        self.titleLabel.text = title
        self.messageLabel.text = message
        
        self.popupView.show(view: self)
    }
    
    @objc func dismissButtonclicked(_ button:UIButton)
    {
        self.popupView.dismiss()
        
        self.onComplete?(self.buttonKeys[button.tag])
    }
    
    public func showLoadingLayout()
    {
        self.titleLabel.isHidden = true
        self.messageLabel.isHidden = true
        self.bottomBarView.isHidden = true
        
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
    }
}
