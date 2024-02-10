//
//  NoteViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/03/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class NoteViewController: MSBaseViewController, UITextViewDelegate
{
    var note:Note?
    
    @IBOutlet weak var noteTextView:UITextView?
     @IBOutlet weak var saveButton:UIButton?
    @IBOutlet weak var deleteButton:UIButton?
    @IBOutlet weak var noteTextViewBottomConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.noteTextView?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        self.noteTextView?.layer.borderWidth = 1.0
        self.noteTextView?.layer.cornerRadius = 3.0
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any) {
        self.note = object as? Note
        
      self.reloadData()
    }
    
    override func reloadData() {
        
        self.topBarTitleLabel?.text = self.note?.title
        
        if let noteContent = self.note?.content
            , noteContent.count > 0
        {
            self.noteTextView?.text = noteContent
            self.noteTextView?.textColor = UIColor(HexColor:"6A2423")
            
            self.saveButton?.isHidden = true
            self.deleteButton?.isHidden = false
        }
        else{
            self.setPlaceHotelderLayout()
            
            self.saveButton?.isHidden = false
            self.deleteButton?.isHidden = true
        }
    }
    
    func setPlaceHotelderLayout()
    {
        self.noteTextView?.text = "st_add_comment".localize()
        self.noteTextView?.textColor = UIColor.lightGray
    }
    
    @IBAction func saveButtonClicked(_ id:UIButton)
    {
        self.saveButton?.isHidden = true
        self.deleteButton?.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonClicked(_ id:UIButton)
    {
        let alertTitle = "st_delete".localize()
        
        let alertMessage = String(format: "st_delete_message_alert_message".localize(), arguments: [self.note!.title!])
        
        let alertDeleteButtonTitle = "st_delete".localize()
        let alertCancelButtonTitle = "st_cancel".localize()
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertDeleteButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == alertDeleteButtonTitle
            {
                HadafHayomiManager.sharedManager.removeNote(self.note!)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    //Mark: - TextView Delegate Methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        if self.note == nil
            || self.note!.content == nil
            || self.note!.content!.count == 0
        {
            textView.text = ""
            self.noteTextView?.textColor = UIColor(HexColor:"6A2423")
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.note?.content = textView.text
        
        if self.note != nil
        {
            if let content = self.note?.content
            {
                if content.count > 2
                {
                     HadafHayomiManager.sharedManager.saveNote(self.note!)
                }
                else{
                     HadafHayomiManager.sharedManager.removeNote(self.note!)
                }
            }
            self.saveButton?.isHidden = false
            self.deleteButton?.isHidden = true
        }
    }
    
    //MARK: - Keyboard notifications
    @objc override func keyboardWillAppear(_ notification: Notification)
    {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            var bottomBarHeight:CGFloat = 0
            if let superViewHeight = self.navigationController?.view.superview?.frame.size.height
            {
                 bottomBarHeight = superViewHeight - self.view.frame.size.height
            }
           
            self.noteTextViewBottomConstraint?.constant = (keyboardSize.height + 16) - bottomBarHeight
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
                {
                    self.view.setNeedsLayout()
                    
            }, completion: {_ in
            })
        }
    }
    
    @objc override func keyboardWillDisappear(_ notification: Notification)
    {
        self.noteTextViewBottomConstraint?.constant = 16
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.setNeedsLayout()
                
        }, completion: {_ in
        })
    }

}
