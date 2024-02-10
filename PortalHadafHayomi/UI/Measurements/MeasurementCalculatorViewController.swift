//
//  MeasurementCalculatorViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MeasurementCalculatorViewController: MSBaseViewController, UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource
{

    @IBOutlet weak var unitTypeSegmentedControler:UISegmentedControl?
    
    @IBOutlet weak var fromMesurementTextField:UITextField?
    @IBOutlet weak var toMesurementTextField:UITextField?
    @IBOutlet weak var amountTextField:UITextField?
    @IBOutlet weak var convertedAmountTextField:UITextField?
    @IBOutlet weak var basic_valuetTextField:UITextField?
    
    @IBOutlet weak var rebChimNoehTitleLabel:UILabel?
    @IBOutlet weak var chazonIshTitleLabel:UILabel?
    @IBOutlet weak var rambamTitleLabel:UILabel?
    @IBOutlet weak var rebChimNoeh_valueTextField:UITextField?
    @IBOutlet weak var chazonIsh_valueTextField:UITextField?
    @IBOutlet weak var rambam_valueTextField:UITextField?
    
    @IBOutlet weak var basic_unitTypeLabel:UILabel?
    @IBOutlet weak var rebChimNoeh_unitTypeLabel:UILabel?
    @IBOutlet weak var chazonIsh_unitTypeLabel:UILabel?
    @IBOutlet weak var rambam_unitTypeLabel:UILabel?
    
    @IBOutlet weak var pickerBaseView:UIView?
    @IBOutlet weak var pickerBaseViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var pickerView:UIPickerView?
    @IBOutlet weak var pickerArrowDirectionLable:UILabel?
    
    @IBOutlet weak var fromValueLabel:UILabel?
    @IBOutlet weak var toValueLabel:UILabel?
    
    @IBOutlet weak var quantityTitleLabel:UILabel?
    @IBOutlet weak var convertTitleLabel:UILabel?
    
    @IBOutlet weak var convertArrowDirectrionLabel:UILabel?
    
    var fromMesurmentKey:String?
    var toMesurmentKey:String?
    
    var dispalyedMeasurementsKeys = [String]()
    var selectedMeasurementType:MeasurementType = .length
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
       self.unitTypeSegmentedControler?.setTitle("st_volume".localize(), forSegmentAt: 0)
        self.unitTypeSegmentedControler?.setTitle("st_weight".localize(), forSegmentAt: 1)
        self.unitTypeSegmentedControler?.setTitle("st_length".localize(), forSegmentAt: 2)
        self.unitTypeSegmentedControler?.setTitle("st_area".localize(), forSegmentAt: 3)
        
        self.unitTypeSegmentedControlerValueChanged(self.unitTypeSegmentedControler!)
        
        self.fromValueLabel?.text = "st_from_value".localize()
         self.toValueLabel?.text = "st_to_value".localize()
        
        self.convertArrowDirectrionLabel?.text = "st_convert_arrow_directrion_label".localize()
        
        self.quantityTitleLabel?.text = "st_quantity".localize()
        self.convertTitleLabel?.text = "st_convert".localize()
        
        self.pickerArrowDirectionLable?.text = "st_convert_arrow_directrion_label".localize()
        
        self.rebChimNoehTitleLabel?.text = String(format: "st_rate_method".localize(), arguments: ["st_rabbi_chaim_naeh".localize()])
        self.chazonIshTitleLabel?.text = String(format: "st_rate_method".localize(), arguments: ["st_chazonIsh".localize()])
        self.rambamTitleLabel?.text = String(format: "st_rate_method".localize(), arguments: ["st_rambam".localize()])
        
    }
    
    //MARK: - Textview Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == fromMesurementTextField
            || textField == toMesurementTextField
        {
            self.showMesurmentPickerView()
            self.amountTextField?.resignFirstResponder()
            
            return false
        }
        else
        {
            self.hideMesurmentPickerView()
            return true
        }
    }
    
    func showMesurmentPickerView()
    {
        self.pickerBaseViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration:0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func hideMesurmentPickerView()
    {
        self.pickerBaseViewBottomConstraint?.constant = -1 * (self.pickerBaseView?.frame.size.height ?? 300)
        
        UIView.animate(withDuration:0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    @IBAction func unitTypeSegmentedControlerValueChanged(_ sedner:AnyObject)
    {
        switch unitTypeSegmentedControler!.selectedSegmentIndex {
        case 0://נפח
             self.dispalyedMeasurementsKeys = MesurementsManager.volumeMeasurementsKeys
             self.selectedMeasurementType = .volume
            break
            
        case 1://משקל
            self.selectedMeasurementType = .weight
            self.dispalyedMeasurementsKeys = MesurementsManager.weightMeasurementsKeys
            break
            
        case 2://אורך
            self.selectedMeasurementType = .length
            self.dispalyedMeasurementsKeys = MesurementsManager.lengthMeasurementsKeys
            break
            
        case 3://שטח
            self.selectedMeasurementType = .surface
            self.dispalyedMeasurementsKeys = MesurementsManager.surfaceMeasurementsKeys
            break
            
        default:
            break
        }
      
        self.pickerView?.reloadAllComponents()
        
        self.fromMesurmentKey = self.dispalyedMeasurementsKeys[0]
        self.fromMesurementTextField?.text =  self.fromMesurmentKey!.localize()
        
        self.toMesurmentKey = self.dispalyedMeasurementsKeys[1]
        self.toMesurementTextField?.text = toMesurmentKey!.localize()
        
         self.amountTextField?.text = ""
         self.convertedAmountTextField?.text = ""
         self.basic_valuetTextField?.text = ""
         self.rebChimNoeh_valueTextField?.text = ""
         self.chazonIsh_valueTextField?.text = ""
         self.rambam_valueTextField?.text = ""
    }
    
    @IBAction func switchButtonClicked(_ sender:UIButton)
    {
        let old_fromMesurmentKey = self.fromMesurmentKey
        let old_toMesurmentKey = self.toMesurmentKey
        
        self.toMesurmentKey = old_fromMesurmentKey
        self.fromMesurmentKey = old_toMesurmentKey
        
        self.fromMesurementTextField?.text =  self.fromMesurmentKey!.localize()
        self.toMesurementTextField?.text = toMesurmentKey!.localize()
        
        self.runMesurments()
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField)
    {
       self.runMesurments()
    }
    
    //MARK: - UIPickerView Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch component
        {
        case 0://from mesurement
            return self.dispalyedMeasurementsKeys.count
            
        case 1://to mesurement
            return self.dispalyedMeasurementsKeys.count
       
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        return pickerView.frame.size.width/2
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pikerLabel = view as? UILabel ?? UILabel()
        pikerLabel.textAlignment = .center
        
        pikerLabel.font = UIFont(name:"BroshMF", size: 20)!
        pikerLabel.textColor = UIColor(HexColor: "781F24")
        pikerLabel.text = ""
        
        let mesurementKey = self.dispalyedMeasurementsKeys[row]
        
        pikerLabel.text = mesurementKey.localize()
        
        return pikerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        let mesurementKey = self.dispalyedMeasurementsKeys[row]
        
        if component == 0
        {
            self.fromMesurementTextField?.text = mesurementKey.localize()
            self.fromMesurmentKey = mesurementKey
        }
        
        if component == 1
        {
            self.toMesurementTextField?.text = mesurementKey.localize()
            self.toMesurmentKey = mesurementKey
        }
        
        self.runMesurments()
        
    }
    
    func runMesurments()
    {
        self.rebChimNoeh_valueTextField?.text = ""
        self.chazonIsh_valueTextField?.text = ""
        self.rambam_valueTextField?.text = ""
        
        if let amountText = self.amountTextField?.text
            , let amount = Double(amountText)
        {
            if fromMesurmentKey != nil && toMesurmentKey != nil
            {
                if let result = MesurementsManager.sharedManager.convertFrom(mesurment_a_name: fromMesurmentKey!, amountA: amount, to: toMesurmentKey!, measurementType:self.selectedMeasurementType)
                {
                   
                    if self.selectedMeasurementType == .length
                    {
                        let rebChimNoehValue = result
                        
                        self.convertedAmountTextField?.text = self.appendString(value: rebChimNoehValue)
                        
                        //Check at least one mesurment key is old mesurments
                        if MesurementsManager.modern_lengthMeasurementsKeys.contains(fromMesurmentKey!)
                            ||  MesurementsManager.modern_lengthMeasurementsKeys.contains(toMesurmentKey!)
                        {
                            self.rebChimNoeh_valueTextField?.text = self.appendString(value: rebChimNoehValue)
                            self.chazonIsh_valueTextField?.text = self.appendString(value: rebChimNoehValue*1.2)
                            self.rambam_valueTextField?.text = self.appendString(value: rebChimNoehValue*0.95)
                        }
                    }
                    else if self.selectedMeasurementType == .volume
                    {
                        let rebChimNoehValue = result
                        
                        self.convertedAmountTextField?.text = self.appendString(value: rebChimNoehValue)
                        
                        if MesurementsManager.modern_volumeMeasurementsKeys.contains(fromMesurmentKey!)
                            ||  MesurementsManager.modern_volumeMeasurementsKeys.contains(toMesurmentKey!)
                        {
                            self.rebChimNoeh_valueTextField?.text = self.appendString(value: rebChimNoehValue)
                            self.chazonIsh_valueTextField?.text = self.appendString(value: rebChimNoehValue*(17/10))
                            self.rambam_valueTextField?.text = self.appendString(value: result * 0.85)
                        }
                    }
                    else if self.selectedMeasurementType == .surface
                    {
                        let rebChimNoehValue = result
                        
                        self.convertedAmountTextField?.text = self.appendString(value: rebChimNoehValue)
                        
                        if MesurementsManager.modern_surfaceMeasurementsKeys.contains(fromMesurmentKey!)
                            ||  MesurementsManager.modern_surfaceMeasurementsKeys.contains(toMesurmentKey!)
                        {
                            self.rebChimNoeh_valueTextField?.text = self.appendString(value: rebChimNoehValue)
                            self.chazonIsh_valueTextField?.text = self.appendString(value: rebChimNoehValue*1.44)
                            self.rambam_valueTextField?.text = self.appendString(value: rebChimNoehValue*0.9020833333)
                        }
                    }
                    else{
                        
                        self.convertedAmountTextField?.text = self.appendString(value: result)
                    }
                }
            }
            
        }
    }
    
    func appendString(value: Double) -> String
    {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0 // for float
        formatter.maximumFractionDigits = 8 // for float
        formatter.minimumIntegerDigits = 1
        formatter.paddingPosition = .afterPrefix
        formatter.paddingCharacter = "0"
        
        return formatter.string(from: NSNumber(floatLiteral: value))! // here double() is not required as data is already double
    }
}
