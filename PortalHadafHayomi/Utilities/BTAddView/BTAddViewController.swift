//
//  BTAddViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 06/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class BTAddViewController: MSBaseViewController, UIWebViewDelegate
{

    @IBOutlet weak var addWebView:UIWebView?
    @IBOutlet weak var checkBoxButton:UIButton?
    @IBOutlet weak var dontShowAgainButton:UIButton?
    
    var addUrlPath:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.addWebView?.scalesPageToFit = true
        
        let checkBoxOff = UIImage.imageWithTintColor(UIImage(named: "Checkbox_off.png")!, color: UIColor(HexColor: "781F24"))
        
        let checkBoxOn = UIImage.imageWithTintColor(UIImage(named: "Checkbox_on.png")!, color: UIColor(HexColor: "781F24"))
        self.checkBoxButton?.setImage(checkBoxOff, for: .normal)
         self.checkBoxButton?.setImage(checkBoxOn, for: .selected)
        
        if let show_do_not_show_again = HadafHayomiManager.sharedManager.getAppSettingValueByKey("show_do_not_show_again") as? Bool
        {
              self.dontShowAgainButton?.isHidden = !show_do_not_show_again
            self.checkBoxButton?.isHidden = !show_do_not_show_again
        }
        
        self.dontShowAgainButton?.setTitle("st_dont_show_again".localize(), for: .normal)
    }

    func reloadWithImageUrl(addUrlPath:String)
    {
        self.addUrlPath = addUrlPath
        
        if let url = URL(string: addUrlPath)
        {
            self.addWebView?.isHidden = true
            let requestObj = URLRequest(url: url)
            self.addWebView?.loadRequest(requestObj)
        }
    }
    
    @IBAction func onWebClick(_ sender:AnyObject)
    {
        if let ad_click_link = HadafHayomiManager.sharedManager.getAppSettingValueByKey("ad_click_link") as? String
        {
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            
            self.present(webViewController, animated: true, completion: nil)
            webViewController.backButton.isHidden = false
            
            webViewController.loadUrl(ad_click_link, title:"st_portal_hadaf_hayomi".localize())
        }
    }
    
    @IBAction func dismissButtonClicked(_ sender:AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dontShowAginButtonClicked(_ sender:AnyObject)
    {
        self.checkBoxButton?.isSelected = !(self.checkBoxButton?.isSelected ?? false)
        
        let addName = self.addUrlPath ?? ""
        
        var viewedAds:[String]
        if UserDefaults.standard.object(forKey: "viewedAds") != nil
        {
            viewedAds = UserDefaults.standard.object(forKey: "viewedAds") as! [String]
        }
        else{
            viewedAds = [String]()
        }
        
        if self.checkBoxButton?.isSelected ?? false
        {
            viewedAds.append(addName)
        }
        else{
            viewedAds.remove(addName as AnyObject)
        }
        
        UserDefaults.standard.set(viewedAds, forKey: "viewedAds")
        UserDefaults.standard.synchronize()
     }
    
    //MARK: - WebView Delegation
    open func webViewDidStartLoad(_ webView: UIWebView) {
        Util.showLoadingViewOnView(webView)
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        
        self.addWebView?.isHidden = false
        Util.removeLoadingViewFromView(webView)
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        Util.removeLoadingViewFromView(webView)
    }
    
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        return true
    }
}
