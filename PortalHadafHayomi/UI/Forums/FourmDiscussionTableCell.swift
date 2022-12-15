//
//  FourmDiscussionTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/09/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol FourmDiscussionTableCellDelegate: class
{
    func fourmDiscussionTableCell(_ fourmDiscussionTableCell:FourmDiscussionTableCell, showFullDiscussion discussion:ForumPost)
    
    func fourmDiscussionTableCell(_ fourmDiscussionTableCell:FourmDiscussionTableCell, shouldStartLoadURL url:URL)
}

class FourmDiscussionTableCell: MSBaseTableViewCell, UITextViewDelegate {

    var delegate:FourmDiscussionTableCellDelegate?
    
    var discussion:ForumPost?
    
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var userNameLabel:UILabel?
    @IBOutlet weak var masechetLabel:UILabel?
    @IBOutlet weak var publishDateLabel:UILabel?
    @IBOutlet weak var publishTimeLabel:UILabel?
    @IBOutlet weak var commentsNumLabel:UILabel?
    @IBOutlet weak var contentTextView:UITextView?
    @IBOutlet weak var showFullDiscussionButton:UIButton?
    @IBOutlet weak var fileIncludedButton:UIButton?
    @IBOutlet weak var contnetTopToUserNameConstrint:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor(HexColor: "FAF2DD")
        
        self.cardView?.layer.cornerRadius = 5.0
        self.cardView?.layer.borderWidth = 1.0
        
        self.cardView?.semanticContentAttribute = .forceLeftToRight
        
        self.showFullDiscussionButton?.setTitle("st_view_discussion".localize(), for: .normal)
        
        self.fileIncludedButton?.setTitle("st_attachment".localize(), for: .normal)

    }

    override func reloadWithObject(_ object: Any) {
        self.discussion = object as? ForumPost
        
        self.reloadData()
        
    }
        
    override func reloadData()
    {
        if let title = self.discussion?.title
        {
            self.titleLabel?.text = title.stringAfterReplacingHtmlEscapeCharacters()
        }
        if let content = self.discussion?.content
        {
            self.contentTextView?.attributedText = content.htmlAttributedString(textDirection: "rtl", fontSize: 4.5, color:"000000")
        }
        
        self.userNameLabel?.text = self.discussion?.username
            
        if let massechet = self.discussion?.massechet
        {
            var massecehtDisplayText = massechet.stringAfterReplacingHtmlEscapeCharacters()
            massecehtDisplayText = massecehtDisplayText.replacingOccurrences(of: "|", with: " ")
            
            self.masechetLabel?.text = ("(\(massecehtDisplayText))")
        }
        
        self.publishDateLabel?.text = self.discussion?.date?.hebrewDispaly()
        self.publishTimeLabel?.text = self.discussion?.date?.stringWithFormat("HH:mm:ss")
        
        self.commentsNumLabel?.text = "st_comments".localize(withArgumetns: ["\(self.discussion?.children ?? 0)"])
        
        if let filename = self.discussion?.filename, filename.count > 0
        {
            self.fileIncludedButton?.isHidden = false
            self.contnetTopToUserNameConstrint?.priority =  UILayoutPriority(rawValue: 500)
        }
        else{
            self.fileIncludedButton?.isHidden = true
            self.contnetTopToUserNameConstrint?.priority =  UILayoutPriority(rawValue: 900)
        }
        
        self.setBorderColor()
    }
    
    func setBorderColor() {
        
        if let loggedInUser = HadafHayomiManager.sharedManager.logedInUser
                ,loggedInUser.name == self.discussion?.username {
                
                self.cardView?.layer.borderColor = UIColor.systemBlue.cgColor
            }
            else {
                self.cardView?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
            }
    }
    
    func setMainLayout()
    {
        self.cardView?.backgroundColor = .white

        let color = UIColor(HexColor:"6A2423")
        
        self.cardView?.layer.borderColor = color.cgColor
        
        self.titleLabel?.textColor = color
        self.userNameLabel?.textColor = color
        self.publishDateLabel?.textColor = color
        
        if let content = self.discussion?.content
        {
            self.contentTextView?.attributedText = content.htmlAttributedString(textDirection: "rtl", fontSize: 4.5, color:"000000")
        }
        
        self.showFullDiscussionButton?.isHidden = true
    }
    
    func setDefaultLahyout()
    {
        self.cardView?.backgroundColor = UIColor(HexColor: "FAF2DD")
        
        let color = UIColor(HexColor:"6A2423")
                
        self.titleLabel?.textColor = color
        self.userNameLabel?.textColor = color
        self.publishDateLabel?.textColor = color
        
        if let content = self.discussion?.content
        {
            self.contentTextView?.attributedText = content.htmlAttributedString(textDirection: "rtl", fontSize: 4.5, color:"000000")
        }
        
         self.showFullDiscussionButton?.isHidden = true
        
         if let childern = self.discussion?.children, childern > 0
         {
            self.showFullDiscussionButton?.isHidden = false

            self.showFullDiscussionButton?.setTitle(("הצג \(childern) תגובות"), for: .normal)
         }
        
        self.setBorderColor()
    }
    
    @IBAction func showFullDiscussionButtonClicked(_ sender:UIButton)
    {
        self.delegate?.fourmDiscussionTableCell(self, showFullDiscussion: self.discussion!)
    }
    
    @IBAction func fileIncludedButtonClicked(_ sender:UIButton)
    {
        if let fileName = self.discussion?.filename
            ,let url = URL(string:fileName)
        {
            self.delegate?.fourmDiscussionTableCell(self, shouldStartLoadURL: url)
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
            self.delegate?.fourmDiscussionTableCell(self, shouldStartLoadURL: url)
        }
        
        return false
    }
}
