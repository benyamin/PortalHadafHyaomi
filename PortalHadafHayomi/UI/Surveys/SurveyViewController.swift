//
//  SurveyViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 25/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class SurveyViewController: MSBaseViewController, WKNavigationDelegate, WKUIDelegate
{
    var currentSurveyInfo:[String:String]?
    var currentUrlString:String?
    
    @IBOutlet public weak var loadingView:UIView?
    @IBOutlet public weak var loadingGifImageview:UIImageView?
    @IBOutlet public weak var loadingImageBackGroundView:UIView?
    @IBOutlet public weak var errorMessageLabel:UILabel?
    
    @IBOutlet weak var webView:WKWebView?
    @IBOutlet weak var showPreviousSurveysButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        
        self.loadingView?.isHidden = true
        self.loadingGifImageview?.image = nil
        
        self.showPreviousSurveysButton?.layer.borderWidth = 1.0
         self.showPreviousSurveysButton?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
         self.showPreviousSurveysButton?.layer.cornerRadius = 3.0
        
        self.showPreviousSurveysButton?.setTitle("st_show_previous_surveys".localize(), for: .normal)
        
         self.reloadCurrentSurvey()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func reloadCurrentSurvey()
    {
        self.showLoadingView()
        
        GetCurrenySurveyProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.currentSurveyInfo = object as? [String:String]
            
            if let link = self.currentSurveyInfo?["link"]
                ,let currentSurveyUrl = URL(string: link)
            {
                let request = URLRequest(url: currentSurveyUrl)
                
                self.webView?.load(request)
            }
            else{
                self.hideLoadingView()
            }
            
        },onFaile: { (object, error) -> Void in
            
             self.hideLoadingView()
           
        })
        
        /*
        if let currentSurveyUrl = URL(string: "https://app.daf-yomi.com/mobile2/poll.aspx")
        {
            let request = URLRequest(url: currentSurveyUrl)
            
            self.webView?.load(request)
        }
 */
    }
    
    func showPreviousSurveys()
    {
        if let surveysViewController = self.storyboard?.instantiateViewController(withIdentifier: "SurveysViewController")
        {
            self.navigationController?.pushViewController(surveysViewController, animated: true)
        }
        
    }
    
    func showLoadingView()
    {
        self.loadingView?.isHidden = false
        self.errorMessageLabel?.isHidden = true
        self.loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingGifImageview?.image = UIImage.gifWithName("ajax-loader")
        self.loadingImageBackGroundView?.layer.cornerRadius = 5.0
    }
    
    func hideLoadingView()
    {
        self.loadingView?.isHidden = true
        self.loadingGifImageview?.image = nil
    }
    
    @IBAction func showPreviousSurveysButtonClicked()
    {
        self.showPreviousSurveys()
    }
    
    //MARK:- WKNavigationDelegate
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        //If the user voted for sruvey od required survey results
        if let urlPath = navigationAction.request.url?.absoluteString
            ,self.currentUrlString == urlPath
        {
            decisionHandler(.cancel)
            
            if self.currentSurveyInfo != nil
                ,let currentSurveyId = currentSurveyInfo?["id"]
            {
                self.saveServeyId(currentSurveyId)
                
                let currentSurveyLink = "https://app.daf-yomi.com/pollResults.aspx?mobile=1&id=" + currentSurveyId
                if let currentSurveyUrl = URL(string: currentSurveyLink)
                {
                    let request = URLRequest(url: currentSurveyUrl)
                    self.webView?.load(request)
                }
            }
        }
        else{
            decisionHandler(.allow)
        }
    }
    
    func saveServeyId(_ surveyId:String)
    {
        var serveysIds = [String]()
        if let checkedServeys = UserDefaults.standard.object(forKey: "checkedServeys") as? [String]
        {
            serveysIds = checkedServeys
            if serveysIds.contains(surveyId) == false
            {
                serveysIds.append(surveyId)
            }
        }
        else{
            serveysIds.append(surveyId)
        }
        
        UserDefaults.standard.set(serveysIds, forKey: "checkedServeys")
        UserDefaults.standard.synchronize()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showLoadingView()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.hideLoadingView()
        
        self.currentUrlString = webView.url?.absoluteString
        
        let js = ("document.getElementsByClassName(\"clsMainTable\")[0].setAttribute('style',\"width:100%\");document.getElementsByClassName(\"clsContainer\")[0].setAttribute('style',\"width:auto\");document.getElementsByClassName(\"clsContentText\")[0].setAttribute('style',\"max-width:none;width:100%\");")
        
        webView.evaluateJavaScript(js) { (result, error) in
            if error != nil {
            }
        }
        
        self.webView?.isHidden = false

    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoadingView()
    }
    
    func webView(_ webView: WKWebView,createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?{
        
        self.webView?.load(navigationAction.request)
        
        
        
        return nil
    }
}
