//
//  SettableItemCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 02/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol SettableItemCellDelegate {
    func settableItemCell(_ settableItemCell:SettableItemCell, showItemInfo item:SetableItem)
}

class SettableItemCell: MSBaseTableViewCell, BTTablePopUpViewDelegate
{
    weak var delegate:SettableItemCellDelegate?
    
    var setableItem:SetableItem?
    
    var popupView:BTPopUpView?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var descriptionLabel:UILabel?
    @IBOutlet weak var selectButton:UIButton?
    @IBOutlet weak var infoButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.selectButton?.setTitle("st_select".localize(), for: .normal)
        self.selectButton?.layer.cornerRadius = 3.0
    }

    func reloadWithItem(_ setableItem: SetableItem)
    {
        self.setableItem = setableItem
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.infoButton?.isHidden = (self.setableItem?.infoUrlPath == nil)
        
        if let title = self.setableItem?.title
        {
            self.titleLabel?.text = ("st_" + title).localize()
             self.descriptionLabel?.text = ("st_" + title + "_description").localize()
        }
        
        if let key = self.setableItem?.key
        {
            if key == "TalmudDisplayType"
            , let selectedTalmudDisplayType =  UserDefaults.standard.object(forKey: key) as? String
            {
                self.titleLabel?.text = "תצוגת תלמוד - " + selectedTalmudDisplayType
            }
            else if key == "DefaultMagidShiour"
                , let selectedMagidShiourId =  UserDefaults.standard.object(forKey: key) as? String
            {
                for maggidShiour in HadafHayomiManager.sharedManager.maggidShiurs
                {
                    if maggidShiour.id == selectedMagidShiourId
                    {
                        self.titleLabel?.text =  "st_maggid_shiour".localize() + " - " + maggidShiour.name
                        
                        break
                    }
                }
            }
            else if key == "DefaultMenuItem"
            {
                self.setTitleForDefaultMenuItem()
            }
            
            else if key == "Languages"
            {
                let selectedLanguage =  UserDefaults.standard.object(forKey: "selectedLanguage") as? String ?? "language_he_IL"
                
                self.titleLabel?.text = String(format: "st_Languages_title".localize(), arguments: [("language_\(selectedLanguage)").localize()])
            }
            
            else if key == "LessonSkipInterval" {
                
                let selectedLessonSkipInterval =  UserDefaults.standard.object(forKey: "selectedLessonSkipInterval") as? String ?? "30"
                
                self.titleLabel?.text = String(format: "st_Lesson_skip_time_interval_title".localize(), arguments: [selectedLessonSkipInterval])
            }
        }
       
    }
    
    @IBAction func selectButtonClicked(_ sender:UIButton)
    {
        if self.setableItem?.key == "TalmudDisplayType"
        {
            self.showPageDisplayOptions()
            
        }
        else if self.setableItem?.key == "DefaultMagidShiour"
        {
            self.showMagidShiourOptions()
        }
        else if self.setableItem?.key == "DefaultMenuItem"
        {
            self.showMenuItemOptoins()
        }
        else if self.setableItem?.key == "Languages"
        {
            self.showLanguagesList()
        }
        else if self.setableItem?.key == "LessonSkipInterval"
        {
            self.showLessonSkipIntervalOptoins()
        }
            
        else{
            
            if let tableView = self.tableView
                , let indexPath = tableView.indexPath(for: self)
            {
                tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    @IBAction func infoButtonClicked(_ sender:UIButton)
    {
        if self.setableItem != nil
        {
              self.delegate?.settableItemCell(self, showItemInfo: self.setableItem!)
        }
    }
    
    func showPageDisplayOptions()
    {
        var talmudDisplayTypes = [String]()
        for avalibleDispalyType in HadafHayomiManager.sharedManager.avalibleDisplayTypes
        {
            switch avalibleDispalyType
            {
            case .Vagshal: talmudDisplayTypes.append("צורת הדף")
                break
            case .Text: talmudDisplayTypes.append("טקסט הדף")
                break
                
            case .TextWithScore: talmudDisplayTypes.append("טקסט הדף (מנוקד)")
                break
                
            case .EN: talmudDisplayTypes.append("Steinsaltz")
                break
            case .Chavruta: talmudDisplayTypes.append("חברותא")
                break
            case .Steinsaltz: talmudDisplayTypes.append("שטיינזלץ")
                break
            case .Meorot: break
                
            }
        }
        
        let selectedOption =  UserDefaults.standard.object(forKey: "TalmudDisplayType") as? String ?? talmudDisplayTypes.first!
        
        self.showListOptions(talmudDisplayTypes, selectedOption: selectedOption, andTitle: "st_select_talmud_display_type".localize())
    }
    
    func showMagidShiourOptions()
    {
        let selectedMaggidShiourId = UserDefaults.standard.object(forKey: "DefaultMagidShiour") as? String
        
        var magidShioursOptions = [String]()
        let magidShiours = HadafHayomiManager.sharedManager.maggidShiurs
        
        var selectedOption:String?
        
        magidShioursOptions.append("st_default".localize())
        
        for magidShiour in magidShiours
        {
            magidShioursOptions.append(magidShiour.name)
            
            if magidShiour.id == selectedMaggidShiourId
            {
               selectedOption = magidShiour.name
            }
        }
        
        self.showListOptions(magidShioursOptions, selectedOption: selectedOption ?? magidShioursOptions.first!, andTitle: "st_select_maggid_shiur".localize())
    }
    
    func showMenuItemOptoins()
    {
        var menuItems = [String]()
        
        menuItems.append("Home_page".localize())
        
        for menuItem in HadafHayomiManager.sharedManager.homeMenuItems
        {
            menuItems.append(menuItem.title.localize())
        }
        
        var selectedOption = "Home_page".localize()
        
        if let setableItemKey = self.setableItem?.key
            ,let selectedItemName = UserDefaults.standard.object(forKey: setableItemKey) as? String
        {
            selectedOption = selectedItemName
        }

         self.showListOptions(menuItems, selectedOption: selectedOption, andTitle: "st_select_opening_page".localize())
    }
    
    func showListOptions(_ listOptions:[String], selectedOption:String, andTitle title:String)
    {
        let tablePopUpView = UIView.loadFromNibNamed("BTTablePopUpView") as! BTTablePopUpView
        tablePopUpView.delegate = self
        
        tablePopUpView.identifier = self.setableItem?.key
        
        tablePopUpView.reloadWithOptions(listOptions, title:title, selectedOption: selectedOption)
        
        self.popupView = BTPopUpView.show(view: tablePopUpView, onComplete:{ })
    }
    
    func showLanguagesList()
    {
        var avalibleLanguages = [String]()
        
        var hebrewLanguage = ""
        
        for language in LanguageManager.shared.supportedLanguages
        {
            if language.id?.hasPrefix("he") ?? false
            {
                hebrewLanguage = language.displayName ?? ""
            }
            
            if let languageName = language.displayName
            {
                avalibleLanguages.append(languageName)
            }
        }
        
        let selectedLanguage =  UserDefaults.standard.object(forKey: "selectedLanguage") as? String ?? hebrewLanguage
        
        self.showListOptions(avalibleLanguages, selectedOption: selectedLanguage, andTitle: "st_select_language".localize())
    }
    
    func showLessonSkipIntervalOptoins() {
        
        let selectedLessonSkipInterval =  UserDefaults.standard.object(forKey: "selectedLessonSkipInterval") as? String ?? "30"
        
        self.showListOptions(["5","10","15","30","60"], selectedOption: selectedLessonSkipInterval, andTitle: "selectedLessonSkipInterval".localize())
    }
    
    //MARK:  BTTablePopUpView Delegate Methods
    func tablePopUpView(_ tablePopUpView:BTTablePopUpView, didSelectOption option:String!)
    {
        if tablePopUpView.identifier == "TalmudDisplayType"
        {
            UserDefaults.standard.set(option, forKey: self.setableItem!.key!)
            UserDefaults.standard.synchronize()
            
             self.titleLabel?.text = "תצוגת תלמוד - " + option
        }
        else if tablePopUpView.identifier == "DefaultMagidShiour"
        {
            if option == "st_default".localize()
            {
                UserDefaults.standard.removeObject(forKey: self.setableItem!.key!)
                UserDefaults.standard.synchronize()
            }
            else{
                
                for maggidShiour in HadafHayomiManager.sharedManager.maggidShiurs
                {
                    if maggidShiour.name == option
                    {
                        UserDefaults.standard.set(maggidShiour.id, forKey: self.setableItem!.key!)
                        UserDefaults.standard.synchronize()
                        break
                    }
                }
            }
           
            self.titleLabel?.text = "st_maggid_shiour".localize() + " - " + option
        }
        else if tablePopUpView.identifier == "DefaultMenuItem"
        {
            if option == "Home_page".localize()
            {
                UserDefaults.standard.removeObject(forKey: self.setableItem!.key!)
                UserDefaults.standard.synchronize()
                
            }
            else{
                for menuItem in HadafHayomiManager.sharedManager.homeMenuItems
                {
                    let menuItemNameDisplay = menuItem.title.localize()
                    if menuItemNameDisplay == option
                    {
                        UserDefaults.standard.set(menuItem.name, forKey: self.setableItem!.key!)
                        UserDefaults.standard.synchronize()
                        
                        break
                    }
                }
            }
            
            self.setTitleForDefaultMenuItem()
            
            self.popupView?.dismiss()
        }
        else if tablePopUpView.identifier == "Languages"
        {
            for language in LanguageManager.shared.supportedLanguages
            {
                if language.displayName == option
                {
                    //Yiddish in no supported by apple
                    if language.id == "yi" {
                        UserDefaults.standard.set(["he_IL","yi"], forKey: "AppleLanguages")
                        UserDefaults.standard.set("he_IL", forKey: "selectedLanguage")
                    }
                    else{
                        UserDefaults.standard.set([language.id], forKey: "AppleLanguages")
                        UserDefaults.standard.set(language.id, forKey: "selectedLanguage")
                    }
                }
            }
            
            UserDefaults.standard.synchronize()
            
             self.popupView?.dismiss()
            
            /*
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate
            {
                if option == "עברית"
                {
                     LanguageManager.shared.defaultLanguage = .he
                }
                else if option == "English"
                {
                     LanguageManager.shared.defaultLanguage = .en
                }
               
                 appDelegate.setIphoneRootView()
            }
 */
           //else{
                
                let alertTitle = "st_language_changed_alert_title".localize()
                let alertMessage = "st_language_changed_alert_message".localize()
                
                let alertOkButtonTitle = "st_ok".localize()
                BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertOkButtonTitle], onComplete:{ (dismissButtonKey) in
                })
           // }
           
        }
        else if tablePopUpView.identifier == "LessonSkipInterval" {
                
            UserDefaults.standard.setValue(option, forKey: "selectedLessonSkipInterval")
                    UserDefaults.standard.synchronize()
                
                self.titleLabel?.text = String(format: "st_Lesson_skip_time_interval_title".localize(), arguments: [option])
        }
    }
    
    func setTitleForDefaultMenuItem()
    {
        if let selectedDefaultMenuItemName = UserDefaults.standard.object(forKey: "DefaultMenuItem") as? String
        {
            for menuItem in HadafHayomiManager.sharedManager.homeMenuItems
            {
                if menuItem.name == selectedDefaultMenuItemName
                {
                    let menuItemNameDisplayName = menuItem.title.localize()
                    
                    let argument = String(format: "st_at_page".localize(), arguments: [menuItemNameDisplayName])
                    
                    self.titleLabel?.text = String(format: "st_Default_MenuItem".localize(), arguments: [argument])
                    
                    break
                }
               
            }
        }
        else{
            self.titleLabel?.text = String(format: "st_Default_MenuItem".localize(), arguments: ["st_at_home_page".localize()])
        }
    }

}
