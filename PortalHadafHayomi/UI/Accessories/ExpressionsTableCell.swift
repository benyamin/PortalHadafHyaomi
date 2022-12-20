//
//  ExpressionsTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol ExpressionsTableCellDelegate: class
{
    func expressionsTableCell(_ expressionsTableCell:ExpressionsTableCell, shouldStartLoadURL url:URL)
    func expressionsTableCell(_ expressionsTableCell:ExpressionsTableCell, shareExpression expression:Expression)
}

class ExpressionsTableCell: MSBaseTableViewCell, UITextViewDelegate
{
     weak var delegate:ExpressionsTableCellDelegate?
    
    var expression:Expression!
    var textSize = 18
    
    @IBOutlet weak var keyLabel:UILabel!
    @IBOutlet weak var valueTextView:UITextView!
    @IBOutlet weak var shareButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.shareButton.setImageTintColor(UIColor(HexColor: "781F24"))
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.expression = object as? Expression
       
        self.keyLabel.font = self.keyLabel.font.withSize(CGFloat(self.textSize))
        self.keyLabel.text = self.expression.key
        
        if var expressionValue = self.expression.value
        {
            expressionValue = "<!DOCTYPE html><html dir=\"rtl\" lang=\"he\">><head><meta charset=\"utf-8\"><body><p style=font-size:\(textSize)px;\">\(expressionValue)</p> </body>"
            
            self.valueTextView.attributedText = expressionValue.htmlAttributedString()
        }
        else{
             self.valueTextView.text = ""
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
            self.delegate?.expressionsTableCell(self, shouldStartLoadURL: url)
            return false
        }
        else{
            return true
        }
    }
    
    @IBAction func  shareButtonClicked(_ sender:UIButton){
        if self.expression != nil {
            self.delegate?.expressionsTableCell(self, shareExpression: self.expression!)
        }
    }
    
    @IBAction func copyButtonClicked(_ sender:UIButton){
        if let expressionValue = self.expression.value
        {
            UIPasteboard.general.string = expressionValue
            
            let okButtonTitle = "st_ok".localize()
            BTAlertView.show(title:"", message: "st_copied_successfully".localize(), buttonKeys: [okButtonTitle], onComplete:{ (dismissButtonKey) in })
        }
    }
}
