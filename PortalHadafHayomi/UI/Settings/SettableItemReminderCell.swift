//
//  SettableItemReminderCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit
import UserNotifications

class SettableItemReminderCell: SettableItemCell, BTTimePickerviewDelegate
{
    @IBOutlet weak var switchValue:UISwitch?
    @IBOutlet weak var setReminderTimeButton:UIButton?
    
    var popover:Popover?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setReminderTimeButton?.setTitle("st_set_reminder_time_button_title".localize(), for: .normal)
    }
    
    override func reloadData()
    {
        if let title = self.setableItem?.title
        {
            self.titleLabel?.text = ("st_" + title).localize()
            
            var date = Date()
            if let savedDate = UserDefaults.standard.object(forKey: "dateReminder") as? Date
            {
                date = savedDate
            }
            
            self.setDescriptionTextForDate(date)
        }
        
        if let dateReminderIsEnabled = UserDefaults.standard.object(forKey: "dateReminderIsEnabled") as? Bool
            ,dateReminderIsEnabled == true
        {
            self.setableItem?.value = true
        }
        else{
             self.setableItem?.value = false
        }
        
        self.switchValue?.isOn = self.setableItem?.value as? Bool ?? false
    }
    
    @IBAction func setReminderTimeButtonClicked(_ sender:UIButton)
    {
        self.showTimePicker()
    }
    
    func showTimePicker()
    {
        if let timePickerview = UIView.viewWithNib("BTTimePickerview") as? BTTimePickerview
        {
            if let selectedDate =  UserDefaults.standard.object(forKey: "dateReminder") as? Date
            {
                 timePickerview.datePicker?.setDate(selectedDate, animated: false)
            }
           
            timePickerview.delegate = self
            let arrowHight = CGFloat(15)
            let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: arrowHight))
            arrow.image = UIImage.imageWithTintColor(UIImage(named: "Triangle.png")!, color: UIColor(HexColor: "791F23"))
            
            let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: timePickerview.frame.size.height + arrowHight))
            popUpView.addSubview(arrow)
            popUpView.layer.cornerRadius = 3.0
            arrow.center = CGPoint(x: popUpView.frame.size.width/2, y:  arrow.center.y)
            timePickerview.layer.borderColor = UIColor(HexColor:"791F23").cgColor
            
            timePickerview.layer.borderWidth = 2.0
            timePickerview.layer.cornerRadius = 3.0
            timePickerview.frame.origin.y = arrowHight
            timePickerview.frame.size.width = popUpView.frame.size.width
            popUpView.addSubview(timePickerview)
            let options = [
                .type(.down)
                ] as [PopoverOption]
            
          
            self.popover = Popover(options: options, showHandler: nil, dismissHandler: {
                
                if let selectedDate = timePickerview.date
                {
                    self.didSelectDate(selectedDate)
                }
            })
            popover?.show(popUpView, fromView: self, inView: self.tableView!.superview!)
        }
    }
    
    @IBAction func switchValueChanged(_ sender:UISwitch)
    {
        self.setableItem?.setValue(sender.isOn)
        
        if sender.isOn
        {
            self.enableReminder()
        }
        else{
            self.disableReminder()
        }
       
    }
    
    func enableReminder()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("yes")
                
                self.setReminderNotification()
            } else {
                
                let alertTitle = "st_allow_notifications_title".localize()
                let alertMessage = "st_allow_notifications_message".localize()
                
                let alertOkButtonTitle = "st_ok".localize()
                BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertOkButtonTitle], onComplete:{ (dismissButtonKey) in
                })
                
                print("No")
            }
        }
    }
   
    func setReminderNotification()
    {
        let content = UNMutableNotificationContent()
        content.title = "st_portal_hadaf_hayomi".localize()
        content.subtitle = "st_Daily_Reminder".localize()
        content.body = "st_cancel_reminder_message".localize()
        
        let imageName = "defaultIcon"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        
        content.attachments = [attachment]
        
        if let selectedDate =  UserDefaults.standard.object(forKey: "dateReminder") as? Date
        {
            print ("selectedDate:\(selectedDate)")
            let triggerDaily = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute], from: selectedDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
           
             //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
           
            
            let request = UNNotificationRequest(identifier: "dateReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dateReminder"])
            
            UNUserNotificationCenter.current().add(request) { (nil) in
                   DispatchQueue.main.async {
                    
                    let alertTitle = "st_reminder".localize()
                    let alertMessage = String(format: "st_reminder_message".localize(), arguments: [selectedDate.stringWithFormat("HH:mm")])
                    
                    let alertOkButtonTitle = "st_ok".localize()
                     let alertCancelButtonTitle = "st_cancel".localize()
                    BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertOkButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
                        
                        if dismissButtonKey == alertCancelButtonTitle
                        {
                            self.switchValue?.setOn(false, animated: true)
                            self.switchValueChanged(self.switchValue!)
                        }
                        else{
                            UserDefaults.standard.set(true, forKey: "dateReminderIsEnabled")
                            UserDefaults.standard.synchronize()
                        }
                    })
                }
            }
         
        }
    }
    
    func disableReminder()
    {
        UserDefaults.standard.set(false, forKey: "dateReminderIsEnabled")
        UserDefaults.standard.synchronize()
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dateReminder"])
    }
    
    func setDescriptionTextForDate(_ date:Date)
    {
        if let title = self.setableItem?.title
        {
            let reminderTime = date.stringWithFormat("HH:mm")
            self.descriptionLabel?.text = String(format: ("st_" + title + "_description").localize(), arguments: [reminderTime])
        }
    }
    
    //MARK BTTimePickerview delegate methods
    func timePickerView(_ timePickerView:BTTimePickerview, didSelectDate date:Date)
    {
        self.setDescriptionTextForDate(date)
    }
    
    func timePickerView(_ timePickerView:BTTimePickerview, cancelButtonClicked sender:AnyObject)
    {
        
    }
    
    func didSelectDate(_ date:Date)
    {
        UserDefaults.standard.set(date, forKey: "dateReminder")
        UserDefaults.standard.synchronize()
        
        if self.switchValue?.isOn ?? false
        {
            self.enableReminder()
        }
    }
}
