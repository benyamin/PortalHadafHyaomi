//
//  TalmudPageCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 31/05/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class TalmudPageCell: MSBaseCollectionViewCell, WKNavigationDelegate, WKUIDelegate/*, WKScriptMessageHandler*/
{
    
    @IBOutlet weak var pageWebView:WKWebView!
    @IBOutlet weak var pageTextView:UITextView?
    
    @IBOutlet weak var loadingView:UIView!
    @IBOutlet weak var loadingMessgaeView:UIView!
    @IBOutlet weak var loadingMessageLabel:UILabel!
    @IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView!
    
    var displayType:TalmudDisplayType = .Vagshal
    var pageIndex:Int!
    
    var getWebPageProcess:MSBaseProcess?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageWebView.scrollView.bounces = false;
        
        self.loadingMessgaeView.layer.cornerRadius = 5.0
        
        self.pageWebView.navigationDelegate = self
        self.pageWebView.uiDelegate = self
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.pageIndex = object as? Int

        if self.pageWebView.isLoading
        {
            //self.pageWebView.stopLoading()
        }
        
        //clear web view
        self.pageWebView.load(URLRequest.init(url: URL.init(string: "about:blank")!))
        
        self.showLoadingView()

        
        if displayType == .EN
        {           
            self.setEnglishDispaly()
            return
        }
        else if displayType == .Steinsaltz
        {
            self.setSteinsaltzDisplay()
            return
        }
            
        else{
       
            self.pageTextView?.isHidden = true
            self.pageWebView.isHidden = false
            
            var urlString:String = ""
            
            if displayType == .Vagshal
            {
                if let savedPageFilePath = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:self.pageIndex, type: TalmudDisplayType.Vagshal)
                {
                    self.pageWebView.load(URLRequest(url: URL(fileURLWithPath: savedPageFilePath)))
                }
                else{
                    urlString = ("https://www.daf-yomi.com/Data/UploadedFiles/DY_Page/\(pageIndex!).pdf")
                }
            }
            else if displayType == .Text
                 || displayType == .TextWithScore
            {
                self.setPlaneTextDisplay()
                return
            }
            else if displayType == .Meorot
            {
                if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(self.pageIndex)
                {
                    let maschentNumber = 282 + Int(masechet.id!)!
                    urlString = ("https://daf-yomi.com/mobile/textrashi.aspx?massechet=\(maschentNumber)&page=\(pageIndex!)")
                }
            }
            else if displayType == .Chavruta
            {
                if let savedPageFilePath = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:self.pageIndex, type: TalmudDisplayType.Chavruta)
                {
                    self.pageWebView.load(URLRequest(url: URL(fileURLWithPath: savedPageFilePath)))
                }
                else{
                    urlString = "http://files.daf-yomi.com/app/chavruta/\(pageIndex!).pdf"

                }
            }
            
            if let url = URL(string: urlString)
            {
                let requestObj = URLRequest(url: url)
                
                if self.pageWebView.isLoading
                {
                   // self.pageWebView.stopLoading()
                }
                self.pageWebView.load(requestObj)
            }
        }
    }
    
    func setEnglishDispaly()
    {
        self.runProcess(process: GetENPageProcess() ,withInfo:nil)
    }
    
    func setSteinsaltzDisplay()
    {
         self.runProcess(process: GetSteinsaltzPageProcess() ,withInfo:nil)
    }
    
    func setPlaneTextDisplay()
    {
        var pageInfo = [String:Any]()
        
        pageInfo["index"] = self.pageIndex
        
        if displayType == .TextWithScore
        {
             pageInfo["scoring"] = true
        }
        else{
             pageInfo["scoring"] = false
        }
       
        
        self.runProcess(process: GetPageTextProcess(), withInfo:pageInfo)
    }
    
    func runProcess(process:MSBaseProcess?, withInfo info:Any?)
    {
         self.getWebPageProcess?.cancel()
         self.getWebPageProcess = process
        
        let obj = info ?? self.pageIndex
        self.getWebPageProcess?.executeWithObject(obj, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.loadingView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
            
            if let pageText = object as? String {
                self.pageWebView.loadHTMLString("<font size=\"25\">\(pageText)</font>", baseURL: nil)
            }
            else if let pageURL = object as? URL {
                 self.pageWebView.load(URLRequest.init(url: pageURL))
            }
            
        },onFaile: { (object, error) -> Void in
            
            self.loadingIndicatorView.stopAnimating()
        })
    }
    
    func showLoadingView()
    {
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex)
        
        let maschet = pageInfo["maschet"] as! Masechet
        let page = pageInfo["page"] as! Page
        let pageSide =  pageInfo["pageSide"] as! Int
        
        var loadingDispalyText = ""
        if displayType == .EN
        {
            loadingDispalyText = "st_loading_masechet".localize()
            loadingDispalyText += " " + maschet.englishName!
            loadingDispalyText +=  ("\npage \(page.index!+1)")
            loadingDispalyText += pageSide == 1 ? "a" : "b"
        }
        else{
            loadingDispalyText = "st_loading_masechet".localize()
            loadingDispalyText += " " + maschet.name
            loadingDispalyText += ("\nדף \(page.symbol!)")
            loadingDispalyText += " עמ׳ " + HebrewUtil.hebrewDisplayFromNumber(pageSide)
        }
 
        
        self.loadingMessageLabel.text = loadingDispalyText

        self.loadingView.isHidden = false
   
        self.loadingIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        if webView.url?.absoluteString == "about:blank"
        {
            return
        }
     
        self.loadingView.isHidden = true
        self.loadingIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        if webView.url?.absoluteString == "about:blank"
        {
            return
        }
        self.loadingIndicatorView.stopAnimating()
    }
    
}
