//
//  Calendar+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 27/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

extension Calendar {
    static  let hebrew = Calendar(identifier: .hebrew)
    static  let gregorian = Calendar(identifier: .gregorian)
        
    func startDayForDate(_ date:Date) -> Int?
    {
        guard let interval = self.dateInterval(of: .month, for: date) else { return nil }
        let weekday = self.component(.weekday, from: interval.start)
        
        return weekday
    }
    
    func endDayForDate(_ date:Date) -> Int?
    {
        guard let interval = self.dateInterval(of: .month, for: date) else { return nil }
        let weekday = self.component(.weekday, from: interval.end) - 1
        
        return weekday
    }
    
    func numberOfDaysInDate(_ date:Date) -> Int
    {
        let range = self.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func startDateForDate(_ date:Date) -> Date
    {        
        // Get range of days in month
        let range = self.range(of: .day, in: .month, for: date)! // Range(1..<32)
        
        // Get first day of month
        var firstDayComponents = self.dateComponents([.year, .month], from: date)
        firstDayComponents.day = range.lowerBound
        let firstDay = self.date(from: firstDayComponents)!
        
        return firstDay
    }
    
    func endDateForDate(_ date:Date) -> Date
    {
        // Get range of days in month
        let range = self.range(of: .day, in: .month, for: date)! // Range(1..<32)
        
        // Get first day of month
        var endDayComponents = self.dateComponents([.year, .month], from: date)
        endDayComponents.day = range.upperBound
        let endDay = self.date(from: endDayComponents)!
        
        return endDay
    }
    
    func monthDisaplyName(from date:Date, forLocal local:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        dateFormatter.locale = Locale(identifier: local)
        dateFormatter.calendar = self
        
        let monthDisaplyName = dateFormatter.string(from: date)
        
        return monthDisaplyName
    }
    
    func yearDisaplyName(from date:Date, forLocal local:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.locale = Locale(identifier: local)
        dateFormatter.calendar = self
        
        let monthDisaplyName = dateFormatter.string(from: date)
        
        return monthDisaplyName
    }
    
    func dayDisaplyName(from date:Date, forLocal local:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "d"
        dateFormatter.locale = Locale(identifier: local)
        dateFormatter.calendar = self
        
        let dayDisaplyName = dateFormatter.string(from: date)
        
        return dayDisaplyName
    }
    
    func longDateDisplay(from date:Date, local:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: local)
        dateFormatter.calendar = self
        
        let longDateDisplay = dateFormatter.string(from: date)
        
        return longDateDisplay
    }
    
    func monthBetweenDates(firstDate:Date, secondDate:Date) -> Int
    {
        let components = Set<Calendar.Component>([.month])//([.second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = self.dateComponents(components, from: firstDate, to: secondDate)
        
        return differenceOfDate.month!
    }
}
