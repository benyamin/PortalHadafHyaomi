//
//  QandADetailsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class QandADetailsViewController: MSBaseViewController, UITextViewDelegate
{

    var mainTopic:String?
    var expression:Expression?
    
    @IBOutlet weak var qustionTopicLabel:UILabel?
    @IBOutlet weak var detailsTextView:UITextView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        if object is String
        {
            self.mainTopic = object as? String
        }
        else{
            self.expression = object as? Expression
        }
        
       self.reloadData()
    }
    
    override func reloadData()
    {
        self.topBarTitleLabel?.text = self.mainTopic
        
        self.qustionTopicLabel?.text = self.expression?.key
        
        if let expressionValue = self.expression?.value
        {
            let style = "<style>body {text-align: right; font-size:20px; }</style>"

            self.detailsTextView?.attributedText = expressionValue.htmlAttributedString(style:style)
        }
        else{
            self.detailsTextView?.text = ""
        }
    }
    
    
    //MARK: - UITextField Delegate methods
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool
    {
        return self.shouldInteractWithUrl(url)
    }
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return self.shouldInteractWithUrl(url)
    }
    
    func shouldInteractWithUrl(_ url: URL) -> Bool
    {
        //Loading a sub url
        if url.absoluteString.hasPrefix("http")
        {
            //Load a webView with the  request
            self.loadURL(url: url)
            
            return false
        }
        else{
            return true
        }
    }
    
    //MARK ExpressionsWebTableCell Delegate methods
    func loadURL (url:URL)
    {
         let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                ,rootViewController is Main_IPadViewController
            {
                let mainViewController = rootViewController as! Main_IPadViewController
                
                mainViewController.presentViewController(webViewController, onContainer: mainViewController.mainContainerView)
            }
        }
        else{
            self.navigationController?.pushViewController(webViewController, animated: true)
            
        }
        
        webViewController.loadUrl(url.absoluteString, title: self.topBarTitleLabel?.text)
    }
    
    @IBAction func shareButtonClicked(_ sender:UIButton){
        
        if let text = self.detailsTextView?.attributedText
        {
            if let image = UIImage(named: "Icon-App-60x60@2x.png"){
                
                let shareAll = [text ,image] as [Any]
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
}
