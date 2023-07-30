//
//  TalmudPageCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 31/05/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

class TalmudPageCell: MSBaseCollectionViewCell, WKNavigationDelegate, WKUIDelegate, PDFViewDelegate
{
    @IBOutlet var pagPDFView: PDFView?
    
    @IBOutlet weak var pageWebView:WKWebView!
    @IBOutlet weak var pageTextView:UITextView?
    
    @IBOutlet weak var loadingView:UIView!
    @IBOutlet weak var loadingMessgaeView:UIView!
    @IBOutlet weak var loadingMessageLabel:UILabel!
    @IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView!
    
    var heightLightedAnnotatoins = [PDFAnnotation]()
    
    var displayType:TalmudDisplayType = .Vagshal
    var pageIndex:Int!
    
    var getWebPageProcess:MSBaseProcess?
    
    var searchText:String = ""
    
    lazy var bookmarkView:BookmarkView? = {
        if let pdfDocumentView = self.pagPDFView?.documentView {
            let bookmarkView = BookmarkView(frame: pdfDocumentView.bounds)
            bookmarkView.onDidMoveTo = { [weak self] (point) in
                var savedBookmarks = UserDefaults.standard.value(forKey: "bookmarks") as? [String:Double] ?? [String:Double]()
                
                if let selectedPageIndex = self?.pageIndex {
                    savedBookmarks["\(selectedPageIndex)"] = point.y
                    UserDefaults.standard.set(savedBookmarks, forKey: "bookmarks")
                    UserDefaults.standard.synchronize()
                }
          }
            return bookmarkView
        }
        else{
            return nil
        }
    }()
    
    let basicfontSize = 100
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageWebView.scrollView.bounces = false;
        
        self.loadingMessgaeView.layer.cornerRadius = 5.0
        
        self.pageWebView.navigationDelegate = self
        self.pageWebView.uiDelegate = self
        
        pagPDFView?.displayMode = .singlePageContinuous
        pagPDFView?.autoScales = true
        pagPDFView?.displayDirection = .vertical
        pagPDFView?.delegate = self
    }
    
    override func reloadWithObject(_ object: Any)
    {
        if let userInfo = object as? (displayType:TalmudDisplayType, pageIndex:Int){
            self.displayType = userInfo.displayType
            self.pageIndex = userInfo.pageIndex
        }
        else if let index = object as? Int{
            self.pageIndex = index
        }
        else{
            self.pageIndex = 0
        }
    
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
            self.pagPDFView?.isHidden = true
            self.pageWebView.isHidden = false
            return
        }
        else if displayType == .Steinsaltz
        {
            self.setSteinsaltzDisplay()
            self.pagPDFView?.isHidden = true
            self.pageWebView.isHidden = false
            return
        }
            
        else{
            self.pageTextView?.isHidden = true
            self.pageWebView.isHidden = false
            
            var urlString:String = ""
            
            if displayType == .Vagshal
            {
                self.pagPDFView?.isHidden = false
                self.pageWebView.isHidden = true
                
                if let savedPageFilePath = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:self.pageIndex, type: TalmudDisplayType.Vagshal)
                    ,let pdfDocument = PDFDocument(url: URL(fileURLWithPath: savedPageFilePath)) {
                    
                    self.loadingView.isHidden = true
                    self.loadingIndicatorView.stopAnimating()
                    self.pagPDFView?.document = pdfDocument
                                        
                    return
                    
                }
                else{
                    urlString = ("https://app.daf-yomi.com/Data/UploadedFiles/DY_Page/\(pageIndex!).pdf")
                }
            }
            else if displayType == .Text
                 || displayType == .TextWithScore
            {
                self.pagPDFView?.isHidden = true
                self.pageWebView.isHidden = false
                
                self.setPlaneTextDisplay()
                return
            }
            else if displayType == .Meorot
            {
                self.pagPDFView?.isHidden = true
                self.pageWebView.isHidden = false
                
                if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(self.pageIndex)
                {
                    let maschentNumber = 282 + Int(masechet.id!)!
                    urlString = ("https://daf-yomi.com/mobile/textrashi.aspx?massechet=\(maschentNumber)&page=\(pageIndex!)")
                }
            }
            else if displayType == .Chavruta
            {
                self.pagPDFView?.isHidden = false
                self.pageWebView.isHidden = true
                
                if let savedPageFilePath = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:self.pageIndex, type: TalmudDisplayType.Chavruta)
                {
                    self.pageWebView.load(URLRequest(url: URL(fileURLWithPath: savedPageFilePath)))
                }
                else{
                    urlString = "http://files.daf-yomi.com/files/app/chavruta/\(pageIndex!).pdf"
                }
            }
            
            if let url = URL(string: urlString)
            {
                if pagPDFView?.isHidden == false {
                        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {
                            (data, response, error) -> Void in

                            if let httpResponse = response as? HTTPURLResponse
                            {
                                let statusCode = httpResponse.statusCode
                                if (statusCode == 200) {
                                    print("file downloaded successfully.")
                                } else  {
                                    print("Failed")
                                }
                            }

                            if let actualData = data {
                                
                                DispatchQueue.main.async {
                                    self.loadingView.isHidden = true
                                    self.loadingIndicatorView.stopAnimating()
                                    self.pagPDFView?.document = PDFDocument(data: actualData)
                                    
                                    self.addBookmark()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        self.markPDF()
                                    }
                                }
                            }
                        }
                        task.resume()
                }
                else {
                    self.pageWebView.load(URLRequest(url: url))
                }
            }
        }
    }
    
     func addBookmark(){
         
         if let pdfDocumentView = self.pagPDFView?.documentView
                , let bookmarkView = self.bookmarkView{
             pdfDocumentView.addSubview(bookmarkView)
         }
         
         let savedBookmarks = UserDefaults.standard.value(forKey: "bookmarks") as? [String:Double] ?? [String:Double]()
         if let selectedPageIndex = self.pageIndex
                ,let savedOrigenY = savedBookmarks["\(selectedPageIndex)"] {
             self.bookmarkView?.scroll(to:savedOrigenY, animated:false)
         }
         else{
             self.bookmarkView?.scroll(to:30, animated:false)
         }
         
         let displayDafBookMark =  UserDefaults.standard.bool(forKey: "displayDafBookMark")
         self.bookmarkView?.isHidden = !displayDafBookMark
     }
        
    func markPDF(){
        // Find all instances of the text in the PDF document
        //let highlightText = "Â‡"
        //let highlightText = " ̇"
    
        for annotation in self.heightLightedAnnotatoins {
            pagPDFView?.currentPage?.removeAnnotation(annotation)
        }
        
        self.heightLightedAnnotatoins.removeAll()
        
        let highlightText = HadafHayomiManager.sharedManager.convertTextToVagshalEncoding(text: self.searchText)
        let selections = pagPDFView?.document?.findString(highlightText, withOptions: .caseInsensitive)

        // Loop through the selections and add a highlight annotation for each one
        if let currentPage = pagPDFView?.currentPage{
            if let selections = selections, !selections.isEmpty {
                for selection in selections {
                    let highlight = PDFAnnotation(bounds: selection.bounds(for: currentPage), forType: .highlight, withProperties: nil)
                    highlight.color = UIColor.yellow.withAlphaComponent(0.5)
                    self.heightLightedAnnotatoins.append(highlight)
                    pagPDFView?.currentPage?.addAnnotation(highlight)
                }
            }
        }
    }
    
    override func reloadData() {
        self.setTextSize()
    }
    
    func highlightText(_ text:String){
        self.searchText = text
        pageWebView.clearHighlightedText()
        if self.searchText.count > 0 {
            pageWebView.highlightText(self.searchText)
            self.markPDF()
        }
        else{
            for annotation in self.heightLightedAnnotatoins {
                pagPDFView?.currentPage?.removeAnnotation(annotation)
            }
            self.heightLightedAnnotatoins.removeAll()
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
            
            if let pageText = object as? String {
                self.pageWebView.loadHTMLString("<font size=\"25\">\(pageText)</font>", baseURL: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.setTextSize()
                    
                    self.loadingView.isHidden = true
                    self.loadingIndicatorView.stopAnimating()
                    
                    if self.searchText.count > 0 {
                        self.pageWebView.highlightText(self.searchText)
                    }
                }
            }
            else if let pageURL = object as? URL {
                 self.pageWebView.load(URLRequest.init(url: pageURL))
            }
            
        },onFaile: { (object, error) -> Void in
            
            self.loadingIndicatorView.stopAnimating()
        })
    }
    
    func setTextSize(){
        
        let textSizeKey = HadafHayomiManager.sharedManager.textSizeKeyForDisplayType(displayType)
        
        if let additionalTextSize = UserDefaults.standard.object(forKey: textSizeKey) as? Int{
            let requiredfontSize = self.basicfontSize+additionalTextSize
            let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(requiredfontSize)%'"
            pageWebView.evaluateJavaScript(js, completionHandler: nil)
        }
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
        
        if self.searchText.count > 0 {
            pageWebView.highlightText(self.searchText)
        }
    }
        
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        if webView.url?.absoluteString == "about:blank"
        {
            return
        }
        self.loadingIndicatorView.stopAnimating()
    }
    
    func pdfViewWillCopy(_ sender: PDFView) {
         // Your code here
         print("User selected Copy")
     }
    
}
