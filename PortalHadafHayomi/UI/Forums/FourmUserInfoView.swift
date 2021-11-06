//
//  FourmUserInfoView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 12/09/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class FourmUserInfoView: UIView {
    
    @IBOutlet weak var addMessageButton:UIButton?
    @IBOutlet weak var loginButton:UIButton?
    @IBOutlet weak var userTitleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loginButton?.setTitle("st_login".localize(), for: .normal)
        self.addMessageButton?.setTitle("st_add_message".localize(), for: .normal)
        
        self.updateUI()
    }
    func updateUI() {
           
           if let user = HadafHayomiManager.sharedManager.logedInUser {
               
            self.userTitleLabel?.text = "st_user_title".localize(withArgumetns:[user.name])
            
            self.loginButton?.setTitle("st_logout".localize(), for: .normal)
            self.userTitleLabel?.isHidden = false
           }
           else {
            self.loginButton?.setTitle("st_login".localize(), for: .normal)
            self.userTitleLabel?.isHidden = true
        }
    }
    
    @IBAction func loginButtonClicked(_ sender:UIButton)
    {
        if HadafHayomiManager.sharedManager.logedInUser != nil {
            self.logout()
        }
        else{
            self.login()
        }
    }
    
    func displayLoginView(){
        
    }
    
    func login()
    {
        if let loginView = UIView.viewWithNib("LoginView") as? LoginView
        {
            var popupView:BTPopUpView?
            
            loginView.onLoggedUser = {(user) in
                HadafHayomiManager.sharedManager.logedInUser = user
                self.updateUI()
                popupView?.dismiss()
            }
            popupView = BTPopUpView.show(view: loginView, onComplete:{ })
        }
    }
    
    func logout() {
           
           let alertTitle = "st_logout_alert_title".localize()
           let alertMessage = "st_logout_alert_message".localize(withArgumetns: [HadafHayomiManager.sharedManager.logedInUser?.name ?? ""])
           
           let cancelTitle = "st_cancel".localize()
           let okTitle = "st_ok".localize()
           BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [cancelTitle,okTitle], onComplete:{ (dismissButtonKey) in
               
               if dismissButtonKey == okTitle
               {
                   HadafHayomiManager.sharedManager.logedInUser = nil
                   self.updateUI()
               }
           })
           
       }
}
