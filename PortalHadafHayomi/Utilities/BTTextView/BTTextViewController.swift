//
//  BTTextViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 17/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class BTTextViewController: MSBaseViewController {

    @IBOutlet weak var textView:UITextView?
    @IBOutlet weak var increaseTextSizeButton:UIButton!
    @IBOutlet weak var dicreaseTextSizeButton:UIButton!
    
    var pageTitle:String?
    var fileName:String?
    var fileType:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentLanguage = Locale.current.languageCode
            ,currentLanguage.hasSuffix("he")
        {
            self.increaseTextSizeButton.setImage(UIImage(named: "AH+_icon"), for: .normal)
            self.dicreaseTextSizeButton.setImage(UIImage(named: "AH-_icon"), for: .normal)
        }
        else{
            self.increaseTextSizeButton.setImage(UIImage(named: "A+_icon"), for: .normal)
            self.dicreaseTextSizeButton.setImage(UIImage(named: "A-_icon"), for: .normal)
        }
        
        self.reloadData()
    }
    
    func relodWithFile(fileName:String, fileType:String, title:String)
    {
        self.pageTitle = title
        self.fileName = fileName
        self.fileType = fileType
        
        self.reloadData()
        
    }
    
    override func reloadData() {
        
        if textView == nil
        {
            return
        }
        
        self.topBarTitleLabel?.text = self.pageTitle ?? ""
        
        if self.fileType == "rtf"
        {
            if let filePath = Bundle.main.url(forResource: self.fileName, withExtension:self.fileType) {
                do {
                    let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: filePath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                                        
                    self.textView?.attributedText = attributedStringWithRtf
                    
                    if let savedFontSize = UserDefaults.standard.value(forKey: "textViewControllerFontSize") as? CGFloat {
                        self.setFontSize(savedFontSize)
                    }
                } catch let error {
                    print("Got an error \(error)")
                }
            }
        }
    }
    
    @IBAction func dicreaseTextSizeButtonClicked(_ sender:UIButton) {
     
        self.changeFontSizeBy(-1)
    }
    
    @IBAction func increaseTextSizeButtonClicked(_ sender:UIButton) {
        
        self.changeFontSizeBy(1)
    }
    
    func changeFontSizeBy(_ change:CGFloat){
        
        if let newStr = self.textView?.attributedText?.mutableCopy() as? NSMutableAttributedString{
        newStr.beginEditing()
        newStr.enumerateAttribute(.font, in: NSRange(location: 0, length: newStr.string.utf16.count)) { (value, range, stop) in
            if let oldFont = value as? UIFont {
                let newFont = oldFont.withSize(oldFont.pointSize+change)
                newStr.addAttribute(.font, value: newFont, range: range)
                
                UserDefaults.standard.set(newFont.pointSize, forKey: "textViewControllerFontSize")
               UserDefaults.standard.synchronize()
            }
        }
        newStr.endEditing()
            self.textView?.attributedText = newStr
        }
    }
    
    func setFontSize(_ fontSize:CGFloat){
        
        if let newStr = self.textView?.attributedText?.mutableCopy() as? NSMutableAttributedString{
            
            newStr.beginEditing()
            newStr.enumerateAttribute(.font, in: NSRange(location: 0, length: newStr.string.utf16.count)) { (value, range, stop) in
                if let oldFont = value as? UIFont {
                    let newFont = oldFont.withSize(fontSize)
                    newStr.addAttribute(.font, value: newFont, range: range)
                    
                    UserDefaults.standard.set(newFont.pointSize, forKey: "textViewControllerFontSize")
                    UserDefaults.standard.synchronize()
                }
            }
            newStr.endEditing()
            self.textView?.attributedText = newStr
        }
    }
    
    @IBAction func shareButtonClicked(_ sender:UIButton){
        
        if let text = self.textView?.attributedText
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
