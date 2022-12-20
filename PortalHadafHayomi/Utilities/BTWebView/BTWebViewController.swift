//
//  BTWebViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//


import UIKit
import WebKit

class BTWebViewController: MSBaseViewController, WKNavigationDelegate, WKUIDelegate {
    
     weak var delegate:WKNavigationDelegate?
    
    var url:URL?
    var pageTitle:String?
    
    var scalesPageToFit:Bool = true {
        didSet{
            /*
            if self.webView != nil
            {
                self.webView.scalesPageToFit = scalesPageToFit
            }
 */
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var webView:WKWebView?
    
    @IBOutlet weak var webViewTopConstraint:NSLayoutConstraint?
    
    @IBOutlet public weak var loadingView:UIView!
    @IBOutlet public weak var loadingGifImageview:UIImageView!
    @IBOutlet public weak var loadingImageBackGroundView:UIView!
    @IBOutlet public weak var errorMessageLabel:UILabel!
    
    @IBOutlet weak var lockRotationContentView:UIView!
    @IBOutlet weak var lockRotationButton:UIButton!
    @IBOutlet weak var lockRotationArrowImageView:UIImageView!
    
    @IBOutlet weak var shareButton:UIButton!
    
    //MARK: - Actions
    @IBAction override func backButtonClicked(_ sender: AnyObject) {
    
        if webView?.canGoBack ?? false {
            webView?.goBack()
        }
        else {
            super.backButtonClicked(sender)
        }

    }
    
    @IBAction func lockRotationButtonClicked(_ sender:UIButton)
    {
        self.lockRotationButton.isSelected = !self.lockRotationButton.isSelected
        
        //If should rotate
        if self.lockRotationButton.isSelected == false
        {
            self.rotated()
        }
    }
        
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        
         if(UIDevice.current.userInterfaceIdiom == .pad)//IPad
         {
            self.lockRotationContentView.isHidden = true
            self.topBarTitleLabel?.textAlignment = .right
        }
         else{
            self.backButton.isHidden = false
            self.topBarTitleLabel?.textAlignment = .center
        }
        
        //self.webView.scalesPageToFit = self.scalesPageToFit
        
        self.loadingView.isHidden = true
        self.loadingGifImageview.image = nil
     
        self.shareButton.setImageTintColor(UIColor(HexColor: "781F24"))
        
        self.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
          NotificationCenter.default.removeObserver(self)
    }
    
    // Load url to webview
    open func loadUrl(_ urlString : String, title:String?)
    {
        var urlPath = urlString.lowercased()
        urlPath = urlPath.replacingOccurrences(of: "questionary", with: "mobile/questionary")
        urlPath = urlPath.replacingOccurrences(of: "mobile/mobile/questionary", with: "mobile/questionary")
        
        print("Web Page: \(urlPath)")
        
        self.pageTitle = title
        
        self.url = nil
        
        if let url = URL(string: urlPath)
        {
            self.url = url
        }
        self.reloadData()

    }
    
    override func reloadData() {
        
        if self.url != nil
        {
            if self.pageTitle != nil
            {
                self.topBarTitleLabel?.text = self.pageTitle!
            }
            
            self.webView?.isHidden = true
            var request = URLRequest(url: self.url!)
            request.addValue("http://daf-yomi.com", forHTTPHeaderField: "Referer")
        
            self.webView?.load(request)
            
        }
    }
    
    func loadRequest(_ request: URLRequest)
    {
        self.url = request.url
        self.reloadData()
    }
    
    func showLoadingView()
    {
        self.loadingView.isHidden = false
        self.errorMessageLabel.isHidden = true
        self.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingGifImageview.image = UIImage.gifWithName("ajax-loader")
        self.loadingImageBackGroundView.layer.cornerRadius = 5.0
    }
    
    func hideLoadingView()
    {
        self.loadingView.isHidden = true
        self.loadingGifImageview.image = nil
    }
    
    @objc func rotated()
    {
        if self.lockRotationButton.isSelected
        {
            self.lockRotationArrowImageView.rotateAnimation(duration: 0.6, repeatCount:2.0)
            
            return
        }
        
        self.webView?.translatesAutoresizingMaskIntoConstraints = true
        self.lockRotationContentView.translatesAutoresizingMaskIntoConstraints = true
        
        if UIDevice.current.orientation.isLandscape {
            
            self.setLandscapeLayout()
        }
        else {
            
            //Is alredy in protert mode
          
            if self.webView?.superview == self.view
            {
                return
            }

            self.setProtraitLayout()
        }
    }
    
    func setLandscapeLayout()
    {
        var rotationAngle:Double!
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let webViewCenterOnRootView = self.view.convert(self.webView!.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.webView!)
        self.webView!.center = webViewCenterOnRootView
        
        if UIDevice.current.orientation == .landscapeLeft
        {
            rotationAngle = Double.pi/2
        }
        else if UIDevice.current.orientation == .landscapeRight
        {
            rotationAngle = -Double.pi/2
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
               self.webView?.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
                let webViewFrameSize = CGSize(width: rootViewController.view.bounds.size.width, height: rootViewController.view.bounds.size.height)
                let webViewCenter = CGPoint(x: webViewFrameSize.width/2, y: webViewFrameSize.height/2)
                
                self.webView?.frame.size = webViewFrameSize
                self.webView?.center = webViewCenter
                
        }, completion: {_ in
            
            let lockRotationCenter = self.view.convert(self.lockRotationContentView.center, to:rootViewController.view)
            rootViewController.view.addSubview(self.lockRotationContentView)
            self.lockRotationContentView.center = lockRotationCenter
            
            self.lockRotationContentView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        })
    }
    
    func setProtraitLayout()
    {
        let rotationAngle = 0
        
        let webViewHeight = self.view.bounds.size.height - (self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height)
        
        let webViewFrameSize = CGSize(width: self.view.bounds.size.width, height:webViewHeight)
        
        let webViewCenterY = (self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height) + (webViewHeight/2)
        let webViewCenter = CGPoint(x:  webViewFrameSize.width/2, y: webViewCenterY)
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let lockRotationCenter = rootViewController.view.convert(self.lockRotationContentView.center, to:self.topBarView!)
        self.topBarView!.addSubview(self.lockRotationContentView)
        self.lockRotationContentView.center = lockRotationCenter
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
               self.webView?.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                self.lockRotationContentView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
                
               self.webView?.frame.size = webViewFrameSize
               self.webView?.center = webViewCenter
                
        }, completion: {_ in
            
   
            let webViewCenter = rootViewController.view.convert(self.webView!.center, to:self.view)
            self.view.addSubview(self.webView!)
            self.webView!.center = webViewCenter
            self.view.sendSubview(toBack: self.webView!)

        })
    }
    
    //MARK:- WKNavigationDelegate
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let urlPath = navigationAction.request.url?.absoluteString
        {
            if urlPath.hasPrefix("https://www.jgive")
                || urlPath.hasPrefix("https://www.paypal")
            {
                let donationTitle = "st_donatoin_browser_alert_title".localize()
                let donationMesage = "st_donatoin_browser_alert_message".localize()
                let cancelButtonTitle = "st_cancel".localize()
                let continueButtonTitle = "st_continue".localize()
                BTAlertView.show(title: donationTitle, message:donationMesage
                    , buttonKeys: [cancelButtonTitle, continueButtonTitle], onComplete:{ (dismissButtonKey) in
                        
                        if dismissButtonKey == continueButtonTitle
                        {
                            UIApplication.shared.open(URL(string : urlPath)!, options: [:], completionHandler: { (status) in
                                
                            })
                        }
                })
                
                 decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
 
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { 
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(jscript)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
         self.showLoadingView()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.hideLoadingView()
        
        self.webView?.isHidden = false
        
        self.delegate?.webView!(webView, didFinish: navigation)
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoadingView()
    }
    
    
    func webView(_ webView: WKWebView,createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?{
      
       self.webView?.load(navigationAction.request)
        
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }
    
    @IBAction func shareButtonClicked() {
        self.share(sender: self.view)
    }
    
    func share(sender:UIView){
        let text = self.pageTitle ?? ""
        if let image = UIImage(named: "Icon-App-60x60@2x.png")
            ,let link = self.url {
            
            let shareAll = [text , image , link] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
           
}

