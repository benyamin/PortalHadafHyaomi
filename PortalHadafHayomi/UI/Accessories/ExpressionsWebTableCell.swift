//
//  ExpressionsWebTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 30/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol ExpressionsWebTableCellDelegate: class
{
    func expressionsWebTableCell(_ expressionsWebTableCell:ExpressionsWebTableCell, shouldStartLoadURLRequest request:URLRequest)
}

class ExpressionsWebTableCell: MSBaseTableViewCell, UIWebViewDelegate
{
    weak var delegate:ExpressionsWebTableCellDelegate?
    
    var expression:Expression!
    
    @IBOutlet weak var keyLabel:UILabel!
    @IBOutlet weak var valueWebView:UIWebView!
    @IBOutlet weak var webViewHeightConstraint:NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.expression = object as? Expression
        
        self.keyLabel.text = self.expression.key
        let html = ("<html><body><p align=\"right\">\(self.expression.value!)</p></body></html>")
        self.valueWebView.loadHTMLString(html, baseURL: nil)
    }
    
    //MARK: - UIWebView Delegate methods
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
    {
        //Loading a sub url
        if request.url?.absoluteString.hasPrefix("http") ?? false
        {
            //Load a webView with the  request
            self.delegate?.expressionsWebTableCell(self, shouldStartLoadURLRequest: request)
            return false
        }
        else//Loading the expression html text
        {
            return true
        }
    }
        
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        /*
        let a = webView.sizeThatFits(CGSize.zero)
        self.webViewHeightConstraint.constant = a.height
        
        if let parentTableView = self.parentTableView()
        {
            parentTableView.beginUpdates()
            parentTableView.endUpdates()
        }
 */
    }
    
}
