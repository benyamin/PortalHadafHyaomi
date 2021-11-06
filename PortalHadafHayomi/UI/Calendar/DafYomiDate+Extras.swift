//
//  DafYomiDate+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 04/02/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

public extension Date
{
    static let savedDatesKey = "learndPagesDictionary"
    static let savedMessagesKey = "messagesDictionary"

    func hasSavedInformation() -> Bool
    {
       return self.savedMessage() != nil ? true : false
    }
    
    func isMarkedAsLearned() -> Bool
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_yyyy"
        
        if let learndPagesDictionary = UserDefaults.standard.object(forKey:Date.savedDatesKey)  as? [String:[Date]]
        {
            let yearAndMonthForDate = dateFormatter.string(from: self)
            
            if let datesArray = learndPagesDictionary[yearAndMonthForDate]
            {
                for date in datesArray
                {
                    if self.isDateSameDay(date)
                    {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func markAsLearned()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_yyyy"
        
        let yearAndMonthForDate = dateFormatter.string(from: self)
        
        var learndPagesDictionary = [String:[Date]]()
        if UserDefaults.standard.object(forKey:Date.savedDatesKey) != nil
        {
            learndPagesDictionary = UserDefaults.standard.object(forKey: Date.savedDatesKey) as! [String:[Date]]
        }
        
        var datesArray = learndPagesDictionary[yearAndMonthForDate] ?? [Date]()
        datesArray.append(self)
        
        learndPagesDictionary[yearAndMonthForDate] = datesArray
        
        UserDefaults.standard.set(learndPagesDictionary, forKey: Date.savedDatesKey)
        UserDefaults.standard.synchronize()
    }
    
    func unMarAsLearned()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_yyyy"
        
        if var learndPagesDictionary = UserDefaults.standard.object(forKey:Date.savedDatesKey) as? [String:[Date]]
        {
            let yearAndMonthForDate = dateFormatter.string(from: self)
            
            if var datesArray = learndPagesDictionary[yearAndMonthForDate]
            {
                for date in datesArray
                {
                    if self.isDateSameDay(date)
                    {
                        datesArray.remove(date as AnyObject)
                        break
                    }
                }
                
                learndPagesDictionary[yearAndMonthForDate] = datesArray
                
                UserDefaults.standard.set(learndPagesDictionary, forKey: Date.savedDatesKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func svaeMessage(_ message:String)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_yyyy"
        
        let yearAndMonthForDate = dateFormatter.string(from: self)
        
        var allMessagesDictionary = UserDefaults.standard.object(forKey: Date.savedMessagesKey) as? [String:[String:String]]
            ?? [String:[String:String]]()
        
       var monthMessagesDictionary = allMessagesDictionary[yearAndMonthForDate] ?? [String:String]()
        
        monthMessagesDictionary[self.stringWithFormat("dd_MM_yyyy")] = message
        
        allMessagesDictionary[yearAndMonthForDate] = monthMessagesDictionary
        
        UserDefaults.standard.set(allMessagesDictionary, forKey: Date.savedMessagesKey)
        UserDefaults.standard.synchronize()
    }
    
    func removeMessage()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_yyyy"
        
        let yearAndMonthForDate = dateFormatter.string(from: self)
        
        var allMessagesDictionary = UserDefaults.standard.object(forKey: Date.savedMessagesKey) as? [String:[String:String]]
            ?? [String:[String:String]]()
        
        var monthMessagesDictionary = allMessagesDictionary[yearAndMonthForDate] ?? [String:String]()
        
        monthMessagesDictionary.removeValue(forKey: self.stringWithFormat("dd_MM_yyyy"))
        
        allMessagesDictionary[yearAndMonthForDate] = monthMessagesDictionary
        
        UserDefaults.standard.set(allMessagesDictionary, forKey: Date.savedMessagesKey)
        UserDefaults.standard.synchronize()
    }
    
    func savedMessage() -> String?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_yyyy"
        
        let yearAndMonthForDate = dateFormatter.string(from: self)
        
        if let allMessagesDictionary = UserDefaults.standard.object(forKey: Date.savedMessagesKey) as? [String:[String:String]]
        {
            if let monthMessagesDictionary = allMessagesDictionary[yearAndMonthForDate]
            {
                if let message = monthMessagesDictionary[self.stringWithFormat("dd_MM_yyyy")]
                {
                    return message
                }
            }
        }
        
        return nil
    }
}
