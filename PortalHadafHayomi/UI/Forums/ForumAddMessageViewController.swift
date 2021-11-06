//
//  ForumAddMessageViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 08/09/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ForumAddMessageViewController: MSBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate ,UITextFieldDelegate {
    
    @IBOutlet weak var messageTitleLabel:UILabel!
    @IBOutlet weak var messageContentLabel:UILabel!
    @IBOutlet weak var selectTopicLabel:UILabel?
    @IBOutlet weak var sendButton:UIButton!
    @IBOutlet weak var selectMasechetTitleLabel:UILabel!
    
    @IBOutlet weak var titleTextField:UITextField!
    @IBOutlet weak var contentTextView:UITextView!
    @IBOutlet weak var topicTextField:UITextField?
    
    @IBOutlet weak var pagePickerContentView:UIView!
    @IBOutlet weak var pagePickerView:UIPickerView!
    
    @IBOutlet weak var sendButtonButtonConstraint:NSLayoutConstraint!
    
    var discussion:ForumPost?
    
    var onMessageAdded:((_ messageId:Int) -> Void)?
    
    var selectedMasecht:Masechet?{
        didSet{
            self.updateMasechetAndPageTextFieldText()
        }
    }
    
    var selectedPage:Page?{
        didSet{
            self.updateMasechetAndPageTextFieldText()
        }
    }
    
    func updateMasechetAndPageTextFieldText() {
        if let masechet = self.selectedMasecht
            , let page = self.selectedPage {
            self.topicTextField?.text = "st_masechet_and_page_textField_display".localize(withArgumetns: [masechet.name, page.symbol])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBarTitleLabel?.text = "st_add_message_title".localize()
        self.messageTitleLabel.text = "st_message_title_label".localize()
        self.messageContentLabel.text = "st_message_content_label".localize()
        self.selectTopicLabel?.text = "st_masecht_and_page_label".localize()
        self.sendButton.setTitle("st_send".localize(), for: .normal)
        self.selectMasechetTitleLabel.text = "st_selected_masechet".localize()
        
        self.sendButton.layer.cornerRadius = 3.0
        self.sendButton.layer.borderWidth = 1.0
        self.sendButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        self.selectedMasecht = HadafHayomiManager.sharedManager.todaysMaschet
        if let selectedMasechtIndex = HadafHayomiManager.sharedManager.masechtot.index(of: self.selectedMasecht!) {
            self.pagePickerView.selectRow(selectedMasechtIndex, inComponent: 0, animated: false)
            self.pagePickerView.reloadComponent(1)
            
            if let page = selectedMasecht!.getPageByIndex("\(HadafHayomiManager.sharedManager.todaysPage?.index ?? 0)")
            {
                self.selectedPage = page
                if let selectedPageIndex = selectedMasecht!.pages.index(of: self.selectedPage!){
                    self.pagePickerView.selectRow(selectedPageIndex, inComponent: 1, animated: false)
                }
            }
        }
        self.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.titleTextField.becomeFirstResponder()
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.discussion = object as? ForumPost
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        if let discussion = self.discussion {
            
            self.selectTopicLabel?.text = "st_selected_discussion".localize()
            
            if let title = discussion.title
            {
                self.topicTextField?.text = " \(title.stringAfterReplacingHtmlEscapeCharacters())"
            }
            
            self.topicTextField?.isUserInteractionEnabled = false
            
            self.topicTextField?.borderStyle = .line
        }
    }
    
    func showPicerView() {
        self.titleTextField.resignFirstResponder()
        self.contentTextView.resignFirstResponder()
        
        self.pagePickerContentView.isHidden = false
        
         self.sendButtonButtonConstraint.priority = UILayoutPriority(rawValue: 500)
    }
    
    func hidePickerView() {
         self.pagePickerContentView.isHidden = true
        self.sendButtonButtonConstraint.priority = UILayoutPriority(rawValue: 900)
    }
    
   @IBAction func sendMessageButtonClicked(_ sender:UIButton) {
    
    if let messageTitle = self.titleTextField.text
        ,messageTitle.count > 0
        ,let content = self.contentTextView.text
        , content.count > 0 {
        
        if let user = HadafHayomiManager.sharedManager.logedInUser {
            
            let fourmInfo = ForumPost()
            
            fourmInfo.massechetId = self.selectedMasecht?.index
            fourmInfo.pageId = self.selectedPage?.index
            fourmInfo.title = self.titleTextField.text
            fourmInfo.content = self.contentTextView.text
            
            ForumAddMessageProcess().executeWithObject((user:user, fourminfo:fourmInfo, discussion:discussion), onStart: {
                
            }, onComplete: { (object) in
                
                self.navigationController?.popViewController(animated: true)
                self.onMessageAdded?(object as! Int)
                
            },onFaile: { (object, error) -> Void in
                
                let errorTitle = "st_error".localize()
                let errorOkButton = "st_ok".localize()
                let errorMessage = "st_default_error_message".localize()
                BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [errorOkButton], onComplete:{ (dismissButtonKey) in
                })
            })
        }
    }
    else {
        let errorTitle = "st_error".localize()
        let errorOkButton = "st_ok".localize()
        let errorMessage = "st_fourm_error_missing_Info".localize()
        BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [errorOkButton], onComplete:{ (dismissButtonKey) in
        })
    }
    
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //MARK: PickerView delegate methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:
            return HadafHayomiManager.sharedManager.masechtot.count
        case 1:
            return self.selectedMasecht?.numberOfPages ?? 0
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return HadafHayomiManager.sharedManager.masechtot[row].name
        case 1:
            return self.selectedMasecht?.pages[row].symbol ?? ""
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let selectedIndex = pickerView.selectedRow(inComponent: component)
            self.selectedMasecht = HadafHayomiManager.sharedManager.masechtot[selectedIndex]
            pickerView.reloadComponent(1)
            break
            
        case 1:
            let selectedIndex = pickerView.selectedRow(inComponent: component)
            
            if let selectedMasecht = self.selectedMasecht {
                if selectedIndex > selectedMasecht.numberOfPages-1 {
                    selectedPage = selectedMasecht.pages.last
                }
                else{
                    selectedPage = selectedMasecht.pages[selectedIndex]
                }
            }
            break
            
        default:
            break
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.topicTextField{
            self.showPicerView()
            return false
        }
        else{
            self.hidePickerView()
            return true
        }
    }
    
    //MARK: UITextView Delegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.hidePickerView()
        return true
    }
    
    //ForumAddMessageProcess
}
