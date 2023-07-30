//
//  TalmudDoublePageCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/01/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TalmudDoublePageCell: MSBaseCollectionViewCell, UIWebViewDelegate
{
    @IBOutlet weak var pageWebView:UIWebView!
    @IBOutlet weak var secondaryPageWebView:UIWebView?
    
    @IBOutlet weak var loadingView:UIView!
    @IBOutlet weak var loadingMessgaeView:UIView!
    @IBOutlet weak var loadingMessageLabel:UILabel!
    @IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView!
    
    @IBOutlet weak var dividerRightConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var creaditView:UIView?

    var displayType:TalmudDisplayType = .Vagshal
    
    var secondaryPageDisplayType:TalmudDisplayType = .EN
    
    var pageIndex:Int!
    
    var getENPageProcess:GetENPageProcess?
    var getSteinsaltzPageProcess:GetSteinsaltzPageProcess?
    var getPageTextProcess:GetPageTextProcess?
    
    lazy var bookmarkView:BookmarkView = {
        
        let bookmarkView = BookmarkView(frame: self.bounds)
        bookmarkView.onDidMoveTo = { [weak self] (point) in
            var savedBookmarks = UserDefaults.standard.value(forKey: "bookmarks") as? [String:Double] ?? [String:Double]()
            
            if let selectedPageIndex = self?.pageIndex {
                savedBookmarks["\(selectedPageIndex)"] = point.y
                UserDefaults.standard.set(savedBookmarks, forKey: "bookmarks")
                UserDefaults.standard.synchronize()
            }
        }
        return bookmarkView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageWebView.scrollView.bounces = false;
        
        self.loadingMessgaeView.layer.cornerRadius = 5.0
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.pageIndex = object as? Int
        
        if self.pageWebView.isLoading
        {
            self.pageWebView.stopLoading()
        }
        
        //clear web view
        self.pageWebView.loadRequest(URLRequest.init(url: URL.init(string: "about:blank")!))
        
        self.showLoadingView()
        
        self.setSecondaryPageDispaly()
        
        self.pageWebView.isHidden = false
        
        var urlString:String = ""
        
        self.bookmarkView.isHidden = true
        
        if displayType == .Vagshal
        {
            //Check if page is saved in documnets
            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            path += "/\(self.pageIndex!).pdf"
            
            if FileManager.default.fileExists(atPath: path)
            {
                self.pageWebView.loadRequest(URLRequest(url: URL(fileURLWithPath: path)))
            }
            else{
                urlString = ("https://app.daf-yomi.com/Data/UploadedFiles/DY_Page/\(pageIndex!).pdf")
            }
            
            self.addBookmark()
        }
        else if displayType == .Text
            || displayType == .TextWithScore
        {
            self.setPlaneTextDisplay()
        }
        else if displayType == .Meorot
        {
            if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(self.pageIndex)
            {
                let maschentNumber = 282 + Int(masechet.id!)!
                urlString = ("https://app.daf-yomi.com/mobile/textrashi.aspx?massechet=\(maschentNumber)&page=\(pageIndex!)")
            }
        }
        if let url = URL(string: urlString)
        {
            let requestObj = URLRequest(url: url)
            
            if self.pageWebView.isLoading
            {
                self.pageWebView.stopLoading()
            }
            self.pageWebView.loadRequest(requestObj)
        }
    }
    
    func addBookmark(){
        
        self.pageWebView.addSubview(self.bookmarkView)
        self.bookmarkView.isHidden = false
        self.bookmarkView.height = self.bounds.size.height
        bookmarkView.location = .left
        
        let savedBookmarks = UserDefaults.standard.value(forKey: "bookmarks") as? [String:Double] ?? [String:Double]()
        if let selectedPageIndex = self.pageIndex
               ,let savedOrigenY = savedBookmarks["\(selectedPageIndex)"] {
            self.bookmarkView.scroll(to:savedOrigenY, animated:false)
        }
        else{
            self.bookmarkView.scroll(to:30, animated:false)
        }
        
        let displayDafBookMark =  UserDefaults.standard.bool(forKey: "displayDafBookMark")
        self.bookmarkView.isHidden = !displayDafBookMark
    }
    
    func setSecondaryPageDispaly()
    {
        if secondaryPageDisplayType == .EN
        {
            self.setTranslatoinPageDispaly()
        }
        if secondaryPageDisplayType == .Steinsaltz
        {
            self.setSteinsaltzPageDispaly()
        }
        else if secondaryPageDisplayType == .Chavruta
        {
            self.setExplanationPageDispaly()
        }
    }
    
    func setPlaneTextDisplay()
    {
        self.getPageTextProcess?.cancel()
        self.getPageTextProcess = GetPageTextProcess()
        
        var pageInfo = [String:Any]()
        pageInfo["index"] = self.pageIndex
        pageInfo["scoring"] = true
        
        self.getPageTextProcess?.executeWithObject(pageInfo, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.loadingView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
            
            if let pageText = object as? String {
                 self.pageWebView.loadHTMLString("<font size=\"25\">\(pageText)</font>", baseURL: nil)
            }
            else if let pageURL = object as? URL {
                 self.pageWebView.loadRequest(URLRequest.init(url: pageURL))
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
            loadingDispalyText = "Loading Masechet"
            loadingDispalyText += " " + maschet.englishName!
            loadingDispalyText += " page " + ("\(page.index!)")
            loadingDispalyText += pageSide == 1 ? "a" : "b"
        }
        else{
            loadingDispalyText = "טוען מסכת"
            loadingDispalyText += " " + maschet.name
            loadingDispalyText += " דף " + page.symbol
            loadingDispalyText += " עמ׳ " + HebrewUtil.hebrewDisplayFromNumber(pageSide)
        }
        
        
        self.loadingMessageLabel.text = loadingDispalyText
        
        self.loadingView.isHidden = false
        
        self.loadingIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if webView.request?.url?.absoluteString == "about:blank"
        {
            return
        }
        self.loadingView.isHidden = true
        self.loadingIndicatorView.stopAnimating()
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        if webView.request?.url?.absoluteString == "about:blank"
        {
            return
        }
        self.loadingIndicatorView.stopAnimating()
    }
    
    func displayLayout(layout:String)
    {
        if layout == "mainPage"
        {
            self.dividerRightConstraint?.constant = self.frame.size.width
        }
        else if layout == "secondaryPage" //Translatoin
        {
            self.dividerRightConstraint?.constant = 0
        }
        else if layout == "centerPages" // show page and translation
        {
            self.dividerRightConstraint?.constant = self.frame.size.width/2
        }
        
        self.layoutIfNeeded()
    }
    
    func setTranslatoinPageDispaly()//Steinsaltz
    {
        self.getENPageProcess?.cancel()
         self.getSteinsaltzPageProcess?.cancel()
        self.getENPageProcess = GetENPageProcess()
        
        self.creaditView?.isHidden = false
        
        self.getENPageProcess?.executeWithObject(self.pageIndex, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.loadingView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
            
            let pageText = object as! String
            self.secondaryPageWebView?.loadHTMLString(pageText, baseURL: nil)
        },onFaile: { (object, error) -> Void in
            
            self.loadingIndicatorView.stopAnimating()
            
        })
    }
    
    func setSteinsaltzPageDispaly()//Steinsaltz
    {
        self.getENPageProcess?.cancel()
        self.getSteinsaltzPageProcess?.cancel()
        self.getSteinsaltzPageProcess = GetSteinsaltzPageProcess()
        
        self.creaditView?.isHidden = false
        
        self.getSteinsaltzPageProcess?.executeWithObject(self.pageIndex, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.loadingView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
            
            let pageText = object as! String
            self.secondaryPageWebView?.loadHTMLString(pageText, baseURL: nil)
        },onFaile: { (object, error) -> Void in
            
            self.loadingIndicatorView.stopAnimating()
            
        })
    }
    
    func setExplanationPageDispaly()//Chavrota
    {
        let urlString = "http://files.daf-yomi.com/files/app/chavruta/\(self.pageIndex!).pdf"
        
         self.creaditView?.isHidden = true
        
        if let url = URL(string: urlString)
        {
            self.secondaryPageWebView?.isHidden = false
            
            let requestObj = URLRequest(url: url)
            self.secondaryPageWebView?.loadRequest(requestObj)
        }
        else{
            self.secondaryPageWebView?.isHidden = true
        }
    }
}
