//
//  BTTimePickerview.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

public protocol BTTimePickerviewDelegate
{
    func timePickerView(_ timePickerView:BTTimePickerview, didSelectDate date:Date)
    func timePickerView(_ timePickerView:BTTimePickerview, cancelButtonClicked sender:AnyObject)
}

public class BTTimePickerview: UIView {

    var delegate:BTTimePickerviewDelegate?
    
    @IBOutlet weak var datePicker:UIDatePicker!
    
     var date:Date?
    
    @IBAction func datePickerValueChanged(_ sender:AnyObject)
    {
        self.date = datePicker.date
        self.delegate?.timePickerView(self, didSelectDate: self.date!)
        
    }
}
