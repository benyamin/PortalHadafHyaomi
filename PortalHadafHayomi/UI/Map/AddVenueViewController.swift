//
//  AddVenueViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 18/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class AddVenueViewController: MSBaseViewController, UITextFieldDelegate, BTTablePopUpViewDelegate
{
    
    @IBOutlet weak var scrollView:UIScrollView?
    @IBOutlet weak var regionTextField:UITextField?
    @IBOutlet weak var cityTextField:UITextField?
    @IBOutlet weak var locationTextField:UITextField?
    @IBOutlet weak var adressTextField:UITextField?
    @IBOutlet weak var houseNumberTextField:UITextField?
    @IBOutlet weak var timeTextField:UITextField?
    @IBOutlet weak var maggidShiourTextField:UITextField?
    @IBOutlet weak var emailTextField:UITextField?
    @IBOutlet weak var additionalInfoTextView:UITextView?
    
    @IBOutlet weak var regionTitleLabel:UILabel?
    @IBOutlet weak var cityTitleLabel:UILabel?
    @IBOutlet weak var locatoinTitleLabel:UILabel?
    @IBOutlet weak var addressTitleLabel:UILabel?
    @IBOutlet weak var houseNumberTitleLabel:UILabel?
    @IBOutlet weak var timeTitleLabel:UILabel?
    @IBOutlet weak var maggidShiourTitleLabel:UILabel?
    @IBOutlet weak var emailTitleLabel:UILabel?
    @IBOutlet weak var additionalInfoTotleLabel:UILabel?
    
    @IBOutlet weak var emailInfoLabel:UILabel?
    @IBOutlet weak var addVenueButton:UIButton?
    
    var regions = [Region]()
    
    var popupview:BTPopUpView?
    
    var selectedRegion:Region?
    {
        didSet{
            self.regionTextField?.text = selectedRegion?.sRegionName
            
            if let city = selectedRegion?.cities.first
            {
                self.cityTextField?.text = city.sCityName
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topBarTitleLabel?.text = "st_add_venue".localize()
        
        self.additionalInfoTextView?.layer.borderColor = UIColor.lightGray.cgColor
        self.additionalInfoTextView?.layer.borderWidth = 1.0
         self.additionalInfoTextView?.layer.cornerRadius = 3.0
        
        self.addVenueButton?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        self.addVenueButton?.layer.borderWidth = 1.0
        self.addVenueButton?.layer.cornerRadius = 3.0
        
        self.addVenueButton?.setTitle("st_send".localize(), for: .normal)
        
        self.emailInfoLabel?.text = "st_email_info_label".localize()
        
        if let regions = HadafHayomiManager.sharedManager.regions
        {
            self.regions = regions
        }
        
        if self.regions.count == 0
        {
            self.getRegions()
        }
        else{
            self.selectedRegion = self.regions.first
        }
        
       self.regionTitleLabel?.text = "* " + "st_country".localize()
        self.cityTitleLabel?.text = "* " +  "st_city".localize()
        self.locatoinTitleLabel?.text = "* " +  "st_map_location".localize()
        self.addressTitleLabel?.text = "st_address".localize()
        self.houseNumberTitleLabel?.text = "st_house_number".localize()
        self.timeTitleLabel?.text = "* " +  "st_time".localize()
        self.maggidShiourTitleLabel?.text = "st_maggid_shiour".localize()
        self.emailTitleLabel?.text = "* " +  "st_email".localize()
        self.additionalInfoTotleLabel?.text = "st_additional_information".localize()
        
    }
    
    @IBAction func addVenueButtonCliced(_ sender:AnyObject)
    {
        if self.validateMandatoryFields()
        {
             self.addVenue()
        }
    }
    
    func validateMandatoryFields() -> Bool
    {
        if self.regionTextField?.text == nil || regionTextField?.text?.count == 0
            || self.selectedRegion == self.regions.first
        {
            self.showMissingValueAlert(textField: self.regionTextField)
            return false
        }
        
        if self.cityTextField?.text == nil || cityTextField?.text?.count == 0
        {
            self.showMissingValueAlert(textField: self.cityTextField)
            return false
        }
        
        if self.locationTextField?.text == nil || locationTextField?.text?.count == 0
        {
            self.showMissingValueAlert(textField: self.locationTextField)
            return false
        }
        
        if self.timeTextField?.text == nil || timeTextField?.text?.count == 0
        {
            self.showMissingValueAlert(textField: self.timeTextField)
            return false
        }
        
        if self.emailTextField?.text == nil ||  self.emailTextField!.text?.isValidEmail() == false
        {
             self.showMissingValueAlert(textField: self.emailTextField)
            return false
        }
        
        return true
    }
    
    func showMissingValueAlert(textField:UITextField?)
    {
        if textField == nil
        {
            return
        }
        
        var missingValueName = ""
        
        if textField == regionTextField
        {
            missingValueName = "st_country".localize()
        }
        else if textField == cityTextField
        {
            missingValueName =  "st_city".localize()
        }
        
        else if textField == locationTextField
        {
            missingValueName = "st_lesson_location".localize()
        }
        
        else if textField == timeTextField
        {
            missingValueName = "st_missing_lesson_time".localize()
        }
        
        else if textField == emailTextField
        {
            missingValueName = "st_valid_email".localize()
        }
        
        let alertTitle = "st_missing_field_alert_title".localize()
        let alertMessage = String(format: "st_missing_field_alert_message".localize(), arguments: [missingValueName])
        
        
        let continueButton = "st_continue".localize()
       
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [continueButton], onComplete:{ (dismissButtonKey) in
        
            textField?.becomeFirstResponder()
        })
    }
    
    func getRegions()
    {
        if let regions = HadafHayomiManager.sharedManager.regions
            , regions.count > 0
        {
            self.regions =  regions
            self.selectedRegion = self.regions.first
            
            return
        }
        
      Util.showDefaultLoadingView()
        
        GetRegionsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
             Util.hideDefaultLoadingView()
            
            HadafHayomiManager.sharedManager.regions = object as? [Region]
            
            self.regions =  HadafHayomiManager.sharedManager.regions!
           
            self.selectedRegion = self.regions.first
            
        },onFaile: { (object, error) -> Void in
            
            Util.hideDefaultLoadingView()
           
            let alertTitle = ""
            let alertMessage = "st_loading_data_error".localize()
            let alertTryAgionButtonTitle = "st_try_again".localize()
            let alertCancelButtonTitle = "st_return".localize()
            
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertTryAgionButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
                
                if dismissButtonKey == alertTryAgionButtonTitle
                {
                    self.getRegions()
                }
                else if dismissButtonKey == alertCancelButtonTitle
                {
                    self.navigationController?.popViewController(animated: true)
                }
            })
           
        })
    }
    
    @objc override func keyboardWillAppear(_ notification: Notification)
    {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            if let bottomContraint = self.scrollView?.constraintForAttribute(.bottom)
            {
                bottomContraint.constant = keyboardSize.height
            }
        }
    }
    
    @objc override func keyboardWillDisappear(_ notification: Notification)
    {
        if let bottomContraint = self.scrollView?.constraintForAttribute(.bottom)
        {
            bottomContraint.constant = 0
        }
    }
    
    func addVenue()
    {
        var venueParams = [String:String]()
        
        if let cities = self.selectedRegion?.cities
        {
            for city in cities
            {
                if city.sCityName == self.cityTextField?.text
                {
                    venueParams["city"] = ("\(city.ID ?? -1)")
                }
            }
        }
        
        venueParams["location"] = self.locationTextField?.text ?? ""
        venueParams["address"] = self.adressTextField?.text ?? ""
        venueParams["bayit"] = self.houseNumberTextField?.text ?? ""
        venueParams["email"] = self.emailTextField?.text ?? ""
        venueParams["hour"] = self.timeTextField?.text ?? ""
        venueParams["maggid"] = self.maggidShiourTextField?.text ?? ""
        venueParams["pratim"] = self.additionalInfoTextView?.text ?? ""
        
        Util.showDefaultLoadingView()
        
        AddLessonVenueProcess().executeWithObject(venueParams, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            Util.hideDefaultLoadingView()
            
            let alertTitle = "st_added_lesson_success_alert_title".localize()
            let alertMessage = "st_added_lesson_success_alert_message".localize()
            
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: ["st_return_to_previous_page".localize()], onComplete:{ (dismissButtonKey) in
                
                    self.navigationController?.popViewController(animated: true)
            })
            
        },onFaile: { (object, error) -> Void in
            
            Util.hideDefaultLoadingView()
            
            let alertTitle = ""
            let alertMessage = "st_added_lesson_failure_alert_message".localize()
            
            let alertTryAgionButtonTitle = "st_try_again".localize()
            let alertCancelButtonTitle = "st_update_Info".localize()
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertTryAgionButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
                
                if dismissButtonKey == alertTryAgionButtonTitle
                {
                    self.addVenue()
                }
            })
        })
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == self.regionTextField
        {
            self.showRegionOptions()
            
            return false
        }
        else if textField == self.cityTextField
        {
            self.showCitiesOptions()
            
            return false
        }
        
        return true
    }
    
    func showRegionOptions()
    {
        self.resignFirstResponder()
        
        let tablePopUpView = UIView.loadFromNibNamed("BTTablePopUpView") as! BTTablePopUpView
        tablePopUpView.delegate = self
        
        tablePopUpView.identifier = "regions"
        
        var regionNames = [String]()
        for region in self.regions
        {
            regionNames.append(region.sRegionName)
        }
        
        let selectedOption = regionNames.first!
        
        let popupTitle = "st_select_country".localize()
        tablePopUpView.reloadWithOptions(regionNames, title:popupTitle, selectedOption: selectedOption)
        
        self.popupview = BTPopUpView.show(view: tablePopUpView, onComplete:{ })
    }
    
    func showCitiesOptions()
    {
        self.resignFirstResponder()
        
        
        if let selectedRegion = self.selectedRegion
        {
            let tablePopUpView = UIView.loadFromNibNamed("BTTablePopUpView") as! BTTablePopUpView
            tablePopUpView.delegate = self
            
            tablePopUpView.identifier = "cities"
            
            var cityNames = [String]()
            
            for city in selectedRegion.cities
            {
                cityNames.append(city.sCityName)
            }
            
            let selectedOption = cityNames.first!
            
            let popupTitle = "st_select_city".localize()
            tablePopUpView.reloadWithOptions(cityNames, title:popupTitle, selectedOption: selectedOption)
            
            self.popupview = BTPopUpView.show(view: tablePopUpView, onComplete:{ })
        }
    }
    
    //MARK: BTTablePopUpView delegate methods
    func tablePopUpView(_ tablePopUpView: BTTablePopUpView, didSelectOption option: String!)
    {
        if tablePopUpView.identifier == "regions"
        {
            for region in self.regions
            {
                if region.sRegionName == option
                {
                    self.selectedRegion = region
                    
                    break
                }
            }
        }
        else if tablePopUpView.identifier == "cities"
        {
            self.cityTextField?.text = option
        }
        
        self.popupview?.dismiss()
    }
}
