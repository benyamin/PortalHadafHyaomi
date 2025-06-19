//
//  JewishCallPopOver.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/02/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol JewishCallPopOverDelegate {
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, didChangeStatusForDate date:Date)
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, dismissButtonClicked button:UIButton?)
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, didSelectDisplayPageForDate date:Date)
}

class JewishCallPopOver: UIView, UITextViewDelegate
{
    weak var delegate:JewishCallPopOverDelegate?
    
    var centerPoint:CGPoint?
    
    var seletedStatus = "none"
        
    var placeHolderText = "st_add_comment".localize()
    
    @IBOutlet weak var messageTextView:UITextView!
    @IBOutlet weak var bottomBarView:UIView!
    @IBOutlet weak var closeButton:UIButton!
    @IBOutlet var statusButtonsCollection:[UIButton]!
    
    @IBOutlet weak var closeButtonConstraintToSaveRemoveButton:NSLayoutConstraint!
    @IBOutlet weak var closeButtonEqualWidthConstraintToSaveRemoveButton:NSLayoutConstraint!
    
    var date:Date!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
        if self.date != nil
        {
            self.setLayout()
        }
        
       // self.messageTextView.layer.borderWidth = 1.0
       // self.messageTextView.layer.borderColor = UIColor(HexColor: "791F23").cgColor
    }
    
    func setupUI(){
                
        let statusOptoins = [(identifier:"learned",imageName:"Strip_L")
        ,(identifier:"notLearned",imageName:"Strip_Red_L")
        ,(identifier:"hafhLearned",imageName:"Strip_RG_L")
        ,(identifier:"none",imageName:"Strip_yellow")]
        
        for button in self.statusButtonsCollection {
            if let buttonIndex = self.statusButtonsCollection.index(of: button) {
                let statusOption = statusOptoins[buttonIndex]
                button.identifier = statusOption.identifier
                button.setImage(UIImage(named: statusOption.imageName), for: .normal)
                button.addTarget(self, action: #selector(statusButtonClicked(_:)), for: .touchUpInside)
            }
        }
        
        self.bottomBarView.backgroundColor = UIColor(HexColor:"791F23")
    }
    
    func reloadWithDate(_ date:Date)
    {
        self.date = date
        
        self.setLayout()
    }
    
    @objc @IBAction func statusButtonClicked(_ sender:UIButton)
    {
        for button in self.statusButtonsCollection{
            button.backgroundColor = button == sender ? UIColor(HexColor: "DCDCDC") : UIColor(HexColor:"F7F0D3")
            
        }
        self.seletedStatus = sender.identifier ?? "none"

        self.saveChanges()
    }
    
    func saveChanges()
    {
     
        if let masechet = HadafHayomiManager.sharedManager.maschetForDate(self.date)
            , let page = HadafHayomiManager.sharedManager.pageForDate(self.date, addOnePage:true)
        {
            
            let status = self.seletedStatus
            var pageNote = ""
            if self.messageTextView.text != self.placeHolderText {
                pageNote = self.messageTextView.text ?? ""
            }
            
            let progressInfo = MSUpdatePageProgressProcess.DataModel(date: date, masechetName: masechet.name, pageSymbol: page.symbol, status:status, note: pageNote)
            MSUpdatePageProgressProcess().executeWithObject(progressInfo, onStart: {},onComplete: { (object) in
                
                //Page status was updated
                if let savedProgressInfo = object as? [String:[String:Any]] {
                    HadafHayomiManager.sharedManager.savedPagesStatus.merge(savedProgressInfo) { (_, new) in new }
                    masechet.refreshPagesStatus()
                }
                else { // Page staus was removed
                    let remvoedProgressId = object as! String
                    HadafHayomiManager.sharedManager.savedPagesStatus.removeValue(forKey: remvoedProgressId)
                }
                
                self.setLayout()
                self.delegate?.JewishCallPopOver(self, didChangeStatusForDate: self.date)
               
            },onFaile: { (object, error) in
                
            })
        }
    }
    
    
    @IBAction func displayPageButtonClicked(_ sender:AnyObject)
    {
        self.delegate?.JewishCallPopOver(self, didSelectDisplayPageForDate: self.date)
    }
            
    @IBAction func closeButtonButtonClicked(_ sender:AnyObject)
    {
        self.messageTextView.resignFirstResponder()
        self.close()
    }
    
    func close(){
        self.delegate?.JewishCallPopOver(self, dismissButtonClicked:self.closeButton)
    }
    
    
    func setLayout()
    {
        if let message = self.date.savedMessage()
        {
            self.messageTextView.text = message
        }
        else{
            self.messageTextView.text = placeHolderText
        }
        
        for button in self.statusButtonsCollection {
            button.backgroundColor = button.identifier == self.date.status() ? UIColor(HexColor: "DCDCDC") : UIColor(HexColor:"F7F0D3")
        }
    }
    
    func animateToCenterPoint(_ point:CGPoint)
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.superview!.center = point
                
        }, completion: {_ in
        })
    }
    
    //MARK Textview Delegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {        
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
        if self.centerPoint != nil
        {
             self.animateToCenterPoint(self.centerPoint!)
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
           // Your code here to handle the end of editing
        if self.messageTextView.text != self.placeHolderText
        && self.messageTextView.text != self.date.savedMessage()
        {
            self.saveChanges()
        }
    }
}
