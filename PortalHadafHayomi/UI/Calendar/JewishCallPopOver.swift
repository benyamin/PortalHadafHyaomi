//
//  JewishCallPopOver.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/02/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol JewishCallPopOverDelegate: class
{
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, didChangeStatusForDate date:Date)
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, dismissButtonClicked button:UIButton)
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, didSelectDisplayPageForDate date:Date)
}

class JewishCallPopOver: UIView, UITextViewDelegate
{
    weak var delegate:JewishCallPopOverDelegate?
    
    var centerPoint:CGPoint?
    
    var isEditingMessage = false
    
    var placeHolderText = "st_add_comment".localize()
    
    @IBOutlet weak var messageTextView:UITextView!
    @IBOutlet weak var saveRemoveButton:UIButton!
    @IBOutlet weak var saveMessageButton:UIButton!
    @IBOutlet weak var closeButton:UIButton!
    
    @IBOutlet weak var closeButtonConstraintToSaveRemoveButton:NSLayoutConstraint!
    @IBOutlet weak var closeButtonEqualWidthConstraintToSaveRemoveButton:NSLayoutConstraint!
    
    var date:Date!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.date != nil
        {
            self.setLayout()
        }
        
        self.messageTextView.layer.borderWidth = 1.0
        self.messageTextView.layer.borderColor = UIColor(HexColor: "791F23").cgColor
        
        self.closeButton.setTitle("st_close".localize(), for: .normal)
    }
    
    func reloadWithDate(_ date:Date)
    {
        self.date = date
        
        self.setLayout()
    }
    
    @IBAction func saveRemoveButtonClicked(_ sender:AnyObject)
    {
        if self.date.isMarkedAsLearned()
        {
            self.date.unMarAsLearned()
        }
        else{
            self.date.markAsLearned()
        }
        
        self.setLayout()
        
        self.delegate?.JewishCallPopOver(self, didChangeStatusForDate: self.date)
    }
    
    @IBAction func saveDeleteMessageButtonClicked(_ sender:AnyObject)
    {
        //Save message
        if saveMessageButton.tag == 0
        {
            self.saveMessage()
        }
        //Delete Message
        else if saveMessageButton.tag == -1
        {
            self.deleteMessage()
        }
    }
    
    @IBAction func displayPageButtonClicked(_ sender:AnyObject)
    {
        self.delegate?.JewishCallPopOver(self, didSelectDisplayPageForDate: self.date)
    }
    
   func saveMessage()
    {
        self.messageTextView.resignFirstResponder()
        
        if self.messageTextView.text == self.placeHolderText || self.messageTextView.text == ""
        {
            return
        }
        self.date.svaeMessage(self.messageTextView.text)
        
        self.delegate?.JewishCallPopOver(self, didChangeStatusForDate: self.date)
        
        self.saveMessageButton.setTitle("st_delete".localize(), for: .normal)
        self.saveMessageButton.tag = -1
    }
    
    func deleteMessage()
    {
        let alertTitle = "st_delete_comment_alert_title".localize()
         let alertMessage = "st_delete_comment_alert_message".localize()
         let cancelButtonTitle = "st_cancel".localize()
         let deleteButtonTitle = "st_delete".localize()
        
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [deleteButtonTitle,cancelButtonTitle], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == deleteButtonTitle
            {
                self.date.removeMessage()
                self.messageTextView.resignFirstResponder()
                self.delegate?.JewishCallPopOver(self, didChangeStatusForDate: self.date)
                self.delegate?.JewishCallPopOver(self, dismissButtonClicked: self.closeButton)
            }
        })
    }
    
    @IBAction func closeButtonButtonClicked(_ sender:AnyObject)
    {
        if isEditingMessage
        {
            self.messageTextView.resignFirstResponder()
        }
        else{
            self.delegate?.JewishCallPopOver(self, dismissButtonClicked: sender as! UIButton)
        }
    }
    
    
    func setLayout()
    {
        if self.saveRemoveButton != nil
        {
            if self.date.isMarkedAsLearned()
            {
                self.saveRemoveButton.setTitle("st_remove_mark".localize(), for: .normal)
            }
            else{
                self.saveRemoveButton.setTitle("st_add_mark".localize(), for: .normal)
            }
        }
        
        if let message = self.date.savedMessage()
        {
            self.messageTextView.text = message
            
            self.saveMessageButton.setTitle("st_delete".localize(), for: .normal)
            saveMessageButton.tag = -1
            self.showSaveMessageButton(animated: false)
            
        }
        else{
            self.messageTextView.text = placeHolderText
            self.hideSaveMessageButton(animated:false)
        }
    }
    
    
    func showSaveMessageButton(animated:Bool)
    {
        if self.saveMessageButton.isHidden == true
        {
            self.saveMessageButton.isHidden = false

            self.closeButtonConstraintToSaveRemoveButton.priority = UILayoutPriority(rawValue: 500)
            self.closeButtonEqualWidthConstraintToSaveRemoveButton.priority = UILayoutPriority(rawValue: 500)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    self.layoutIfNeeded()
                    
            }, completion: {_ in
            })
        }
    }
    func hideSaveMessageButton(animated:Bool)
    {
        if self.saveMessageButton.isHidden == false
        {
            self.closeButtonConstraintToSaveRemoveButton.priority = UILayoutPriority(rawValue: 900)
            self.closeButtonEqualWidthConstraintToSaveRemoveButton.priority = UILayoutPriority(rawValue: 900)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    self.layoutIfNeeded()
                    
            }, completion: {_ in
                
                self.saveMessageButton.isHidden = true
            })
        }
    }
    
    func animateToCenterPoint(_ point:CGPoint)
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.superview!.center = point
                
        }, completion: {_ in
        })
    }
    
    //MARK Textview Delegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        self.isEditingMessage = true
        
        if self.messageTextView.text == placeHolderText
        {
            self.messageTextView.text = ""
        }
        
        let popover = self.superview!
        self.centerPoint = popover.center
        
        if let window = UIApplication.shared.keyWindow
        {
            let centerX =  window.frame.size.width/2
            self.animateToCenterPoint(CGPoint(x:centerX, y: window.frame.size.height/2))
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        if self.messageTextView.text == ""
        {
            self.messageTextView.text = self.placeHolderText
        }
        
        self.isEditingMessage = false
        
        if self.centerPoint != nil
        {
             self.animateToCenterPoint(self.centerPoint!)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
       self.saveMessageButton.setTitle("st_save".localize(), for: .normal)
        saveMessageButton.tag = 0
        
        if textView.text != ""
        {
            self.showSaveMessageButton(animated:true)
        }
        else{
            self.hideSaveMessageButton(animated:true)
        }
    }
}
