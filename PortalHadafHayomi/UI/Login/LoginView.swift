//
//  LoginView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 13/09/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

private enum DisplayState {
    case login
    case signup
}

class LoginView: UIView {

    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var signinAdditioalDataContentView:UIView!
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var userNameTextField:UITextField!
    @IBOutlet weak var passwordLabel:UILabel!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var reEntnerPasswordLabel:UILabel!
    @IBOutlet weak var reEntnerpasswordTextField:UITextField!
    @IBOutlet weak var firstNameLabel:UILabel!
    @IBOutlet weak var firstNameTextField:UITextField!
    @IBOutlet weak var lastNameLabel:UILabel!
    @IBOutlet weak var lastNameTextField:UITextField!
    @IBOutlet weak var emailLabel:UILabel!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var loadingGifImageview:UIImageView!
    @IBOutlet weak var addinitalInfoViewHeightConstraint:NSLayoutConstraint!
    @IBOutlet weak var sendButton:UIButton!
    @IBOutlet weak var switchDisplayButton:UIButton!
    @IBOutlet weak var forgotPasswordButton:UIButton!
    
    private var displayState:DisplayState = .login
    
    
    var onLoggedUser:((_ user:User) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userNameLabel.text = "st_username".localize()
        self.passwordLabel.text = "st_password".localize()
         self.reEntnerPasswordLabel.text = "st_re_enter_password".localize()
         self.firstNameLabel.text = "st_first_name".localize()
         self.lastNameLabel.text = "st_last_name".localize()
         self.emailLabel.text = "st_email".localize()
        
        self.forgotPasswordButton.setTitle("st_forgot_password".localize(), for: .normal)
        
        self.switchDisplayButton.setTitle("st_login".localize(), for: .normal)
        
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        self.contentView.layer.cornerRadius = 3.0
        
        self.sendButton.layer.borderWidth = 1.0
         self.sendButton.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
         self.sendButton.layer.cornerRadius = 3.0
        
         self.switchDisplayButton.layer.borderWidth = 1.0
         self.switchDisplayButton.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
         self.switchDisplayButton.layer.cornerRadius = 3.0
        
        self.forgotPasswordButton.layer.borderWidth = 1.0
        self.forgotPasswordButton.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        self.forgotPasswordButton.layer.cornerRadius = 3.0
        
        self.loadingGifImageview.layer.cornerRadius = loadingGifImageview.frame.size.width/2
        
         self.loadingGifImageview.isHidden = true
        
        self.setLoginLayout(animated:false)
    }
    
    func setLoginLayout(animated:Bool) {
        
        self.sendButton.setTitle("st_login".localize(), for: .normal)
        self.switchDisplayButton.setTitle("st_signin".localize(), for: .normal)
        
        self.addinitalInfoViewHeightConstraint.priority = UILayoutPriority(rawValue: 900)
        
        var duraion =  0.3
        if animated == false {
            duraion = 0
        }
        UIView.animate(withDuration:duraion, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.layoutIfNeeded()
                
        }, completion: {_ in
            
            self.reEntnerPasswordLabel.isHidden = true
            self.reEntnerpasswordTextField.isHidden = true
            self.firstNameLabel.isHidden = true
            self.firstNameTextField.isHidden = true
            self.lastNameLabel.isHidden = true
            self.lastNameTextField.isHidden = true
            self.emailLabel.isHidden = true
            self.emailTextField.isHidden = true
        })
        
      
    }
    
    func setsignupLayout(){
        
        self.sendButton.setTitle("st_signin".localize(), for: .normal)
        self.switchDisplayButton.setTitle("st_login".localize(), for: .normal)
        
        self.reEntnerPasswordLabel.isHidden = false
        self.reEntnerpasswordTextField.isHidden = false
        self.firstNameLabel.isHidden = false
        self.firstNameTextField.isHidden = false
        self.lastNameLabel.isHidden = false
        self.lastNameTextField.isHidden = false
        self.emailLabel.isHidden = false
        self.emailTextField.isHidden = false
        
        self.addinitalInfoViewHeightConstraint.priority = UILayoutPriority(rawValue: 500)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.layoutIfNeeded()
                
                
        }, completion: {_ in
            
        })
    }
    
    @IBAction func sendButtonButtonClicked(_ sender:AnyObject) {
        
        if self.displayState == .signup {
            
            if let username = userNameTextField.text, username.count > 0
                , let password = passwordTextField.text, password.count > 0
               ,let rePassword = passwordTextField.text, rePassword.count > 0
               ,let firstName = firstNameTextField.text, firstName.count > 0
               ,let lastName = lastNameTextField.text, lastName.count > 0
               ,let email = emailTextField.text, email.count > 0{
                
                if password != rePassword {
                    
                    BTAlertView.show(title:"st_error".localize(), message: "st_not_matching_passwords".localize(), buttonKeys: ["st_ok".localize()], onComplete:{ (dismissButtonKey) in
                        
                    })
                }
                else {
                    let userInfo = ["username":username, "password":password, "firstname":firstName, "lastname":lastName, "email":email]
                    
                    self.runProcess(RegistrationProcess() , withInfo: userInfo)
                }
            }
        }
        
        else {
            if let username = userNameTextField.text, username.count > 0
                , let password = passwordTextField.text, password.count > 0 {
                
                let userInfo = ["username":username, "password":password]
                
                self.runProcess(LoginProcess() , withInfo: userInfo)
            }
        }
    }
    
    @IBAction func switchDisplayButtonClicked(_ sender:UIButton) {
        
        if self.displayState == .login {
            
            self.displayState = .signup
            self.setsignupLayout()
        }
        else{
            self.displayState = .login
            self.setLoginLayout(animated:true)
        }
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender:UIButton) {
        
        if let userName = self.userNameTextField.text,
            userName.count > 0{
            
            ForgotPasswordProcess().executeWithObject(["username":userName], onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                BTAlertView.show(title:"".localize(), message: "st_password_send_to_mail".localize(), buttonKeys: ["st_ok".localize()], onComplete:{ (dismissButtonKey) in
                               
                           })
                
            },onFaile: { (object, error) -> Void in
                
                var errorMessage = "st_forgot_password_recovery_error".localize()
                if  let errorInfo = object as? String {
                    errorMessage = errorInfo
                }
                BTAlertView.show(title:"", message: errorMessage, buttonKeys: ["st_ok".localize()], onComplete:{ (dismissButtonKey) in
                    
                })
            })
        }
        else{
            BTAlertView.show(title:"st_missing_filed".localize(), message: "st_missing_userName".localize(), buttonKeys: ["st_ok".localize()], onComplete:{ (dismissButtonKey) in
                
            })
        }
    }
    
    func runProcess(_ process:MSBaseProcess, withInfo info:[String:String])
    {
        
        self.loadingGifImageview.image = UIImage.gifWithName("ajax-loader")
        self.loadingGifImageview.isHidden = false
        
        process.executeWithObject(info, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.loadingGifImageview.image = nil
            self.loadingGifImageview.isHidden = true
            
            self.onLoggedUser?(object as! User)
            
        },onFaile: { (object, error) -> Void in
            
            self.loadingGifImageview.image = nil
            self.loadingGifImageview.isHidden = true
            
            if object is String
            {
                let alertTryAginButtonTitle = "st_tryAgin".localize()
                let alertCancelButtonTitle = "st_cancel".localize()
                
                BTAlertView.show(title:"st_error".localize(), message: object as! String, buttonKeys: [alertTryAginButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
                    
                })
            }
        })
    }
}
