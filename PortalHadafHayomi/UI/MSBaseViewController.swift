//
//  MSBaseViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MSBaseViewController: UIViewController {

    var isPresenterdModaly = false
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var topBarImageView:UIImageView?
    @IBOutlet weak var topBarTitleLabel:UILabel?
    
    var topBarHeightConstraint:NSLayoutConstraint?{
        get{
            return self.topBarView?.constraintForAttribute(.height) ?? nil
        }
    }
    
    @IBOutlet weak var backButton:UIButton!
    
    var homeViewController:HomeViewController?{
        get{
            //For Iphone
            if let rootNavController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
            {
                if let homeViewController = rootNavController.viewControllers.first as? HomeViewController
                {
                    return homeViewController
                }
                
            }
                
            //For Ipad
            else   if let rootNavController = UIApplication.shared.keyWindow?.rootViewController as? Main_IPadViewController
            {
                return rootNavController.homeViewController
            }
          
            return nil
        }
    }
    
    var homeButton:UIButton! = {
        
        let homeButton = UIButton(frame: CGRect(x: 8, y: 30, width: 24, height: 24))
        
        let homeImage = UIImage(named: "Home icon_ios.png")
        let homeButtonDefaultimage = UIImage.imageWithTintColor(homeImage!, color: UIColor(HexColor: "781F24"))
        
        homeButton.setImage(homeButtonDefaultimage, for: .normal)
        homeButton.setImage(homeImage, for: .highlighted)
        
        homeButton.addTarget(self, action: #selector(homeButtonClicked(_:)), for: .touchUpInside)
        
        return homeButton
        
    }()

    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print ("deinit ViewController: \(self.classForCoder)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = self.topBarTitleLabel?.text
        {
            let title = "st_\(text.lowercased())".localize()
            if title.hasPrefix("st_") == false
            {
                self.topBarTitleLabel?.text = title
            }
        }
        
        self.topBarView?.addBottomShadow()
        
        if self.topBarView != nil
        {
            //If is iPhoneX
            if let topSafeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets.top, topSafeAreaInsets > CGFloat(0.0)
            {
                self.topBarHeightConstraint?.constant = 80
            }
            else{
                self.topBarHeightConstraint?.constant = 60
            }
            
            self.view.bringSubviewToFront(self.topBarView!)
            
            if self.homeButton.tag == 1
            {
              self.addHomeButton()
            }
        }
    }
    
    func addHomeButton()
    {
        //If alredy added
        if self.homeButton.superview == self.topBarView
        {
            return
        }
        let topBarHeight = self.topBarHeightConstraint?.constant ?? self.topBarView!.frame.size.height
        
        if self.topBarView != nil {
            
            self.topBarView?.addSubview(self.homeButton)
            
            self.homeButton.frame.origin.y = topBarHeight - (16 + self.homeButton.frame.size.height)
            
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
            {
                self.homeButton.frame.origin.x = self.view!.frame.size.width - (self.homeButton.frame.size.width + 8)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isBeingPresented
        {
            print ("isPresenterdModaly")
            self.isPresenterdModaly = true
        }
                
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "applicationWillTerminate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name(rawValue: "applicationWillTerminate"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func reloadWithObject(_ object:Any){
        
    }
    
    func reloadData(){
        
    }
    
    func showHomeButton()
    {
        if self.topBarView != nil
        {
            self.addHomeButton()
        }
        else{
            //this will add the homebutton after viewDidLoad
            self.homeButton.tag = 1
        }
    }
    
    //MARK: - Keyboard notifications
    @objc func keyboardWillAppear(_ notification: Notification)
    {
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification)
    {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
         print ("didReceiveMemoryWarning: \(self.classForCoder)")
    }
    
    @IBAction func backButtonClicked(_ sender:AnyObject)
    {
      
        if let navController = self.navigationController
        {
            if self == navController.viewControllers.first
            {
                self.dismiss(animated: true, completion: nil)
            }
            else{
                navController.popViewController(animated: true)
            }
        }
        else{
            if self.isPresenterdModaly
            {
               self.dismiss(animated: true, completion: nil)
            }
            else{
                //If the viewController View was added as a subView
                if self.view.superview != nil
                {
                    self.view.removeFromSuperview()
                }
            }
        }
    }
    
    @IBAction func homeButtonClicked(_ sender:AnyObject)
    {
        //Return to homeViewController
        self.homeViewController?.returnToRoot()
    }
    
     @objc func applicationWillTerminate()
     {
        
    }
    
    func selectTabWithName(tabName:String){
        self.homeViewController?.selectItemWithName(itemName: tabName)
    }
}
