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
    
    var pageTitle:String?
    var fileName:String?
    var fileType:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                } catch let error {
                    print("Got an error \(error)")
                }
            }
        }
    }
}
