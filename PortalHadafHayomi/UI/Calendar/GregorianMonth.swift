//
//  GregorianMonth.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/05/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class GregorianMonth:CallendarMonth
{
    
    class func monthForDate(_ date:Date) -> GregorianMonth
    {
        let month = GregorianMonth()
        
        month.startDay = Calendar.gregorian.startDayForDate(date)
        month.endDay = Calendar.gregorian.endDayForDate(date)
        
        month.numberOfDays = Calendar.gregorian.numberOfDaysInDate(date)
        
        month.name = Calendar.gregorian.monthDisaplyName(from: date, forLocal: "en_US")
        
        month.startDayDate = Calendar.gregorian.startDateForDate(date)
        month.endDayDate = Calendar.gregorian.endDateForDate(date)
        
        return month
    }
    
    class func monthByAddingNumberOfMonth(_ numberOfMofMonth:Int, toMonth month:GregorianMonth) -> GregorianMonth
    {
        let firstDayDate = Calendar.gregorian.date(byAdding: .month, value: numberOfMofMonth, to:  month.startDayDate)!
        
        let month = GregorianMonth.monthForDate(firstDayDate)
        
        return month
    }
}
