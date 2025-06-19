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
    static let savedLegacyDatesKey = "learndPagesDictionary"
    static let savedLegacyMessagesKey = "messagesDictionary"
    
    func hasSavedInformation() -> Bool
    {
       return self.savedMessage() != nil ? true : false
    }
   
    func status() -> String
    {
        if let pageInfo = HadafHayomiManager.sharedManager.savedPagesStatus[self.stringWithFormat("dd_MM_yyyy")] {
            return pageInfo["status"] as? String ?? "none"
        }
        else if self.isLegacyMarkedAsLearned() {
            return "learned"
        }
        
        return "none"
    }
    
    func savedMessage() -> String?
    {
        if let pageInfo = HadafHayomiManager.sharedManager.savedPagesStatus[self.stringWithFormat("dd_MM_yyyy")] {
            return pageInfo["note"] as? String ?? nil
        }
        
        return nil
    }
    
    func isLegacyMarkedAsLearned() -> Bool
       {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MM_yyyy"
           
           if let learndPagesDictionary = UserDefaults.standard.object(forKey:Date.savedLegacyDatesKey)  as? [String:[Date]]
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
}
