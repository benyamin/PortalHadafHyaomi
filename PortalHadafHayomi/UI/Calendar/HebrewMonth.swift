//
//  HebrewMonth.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class HebrewMonth:CallendarMonth
{
    class func monthForDate(_ date:Date) -> HebrewMonth
    {
        let hebrewMonth = HebrewMonth()
        
        hebrewMonth.startDay = Calendar.hebrew.startDayForDate(date)
        hebrewMonth.endDay = Calendar.hebrew.endDayForDate(date)
        
        hebrewMonth.numberOfDays = Calendar.hebrew.numberOfDaysInDate(date)
    
        hebrewMonth.name = Calendar.hebrew.monthDisaplyName(from: date, forLocal: "he_IL")
        
        hebrewMonth.startDayDate = Calendar.hebrew.startDateForDate(date)
        hebrewMonth.endDayDate = Calendar.hebrew.endDateForDate(date)
        
        return hebrewMonth
    }
    
    class func monthByAddingNumberOfMonth(_ numberOfMofMonth:Int, toMonth month:HebrewMonth) -> HebrewMonth
    {
        let firstDayDate = Calendar.hebrew.date(byAdding: .month, value: numberOfMofMonth, to:  month.startDayDate)!
        
        let month = HebrewMonth.monthForDate(firstDayDate)
        
        return month
    }
}
