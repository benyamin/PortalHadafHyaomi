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
        
        if var expressionValue = self.expression?.value
        {
            expressionValue = "<!DOCTYPE html><html dir=\"rtl\" lang=\"ar\"><head><meta charset=\"utf-8\"><font size=\"5\">" + expressionValue + "</font>"
            self.detailsTextView?.attributedText = expressionValue.htmlAttributedString()
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
}
