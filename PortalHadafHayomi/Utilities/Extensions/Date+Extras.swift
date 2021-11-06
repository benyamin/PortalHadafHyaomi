//
//  Date+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 28/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

public extension Date
{
    static func dateFromString(_ dateString:String, withFormat format:String) -> Date?
    {
        
        if dateString.hasPrefix("today-plus-")
        {
            //remove the prefix from the string
            let daysFromToday = Double(dateString.replacingOccurrences(of: "today-plus-", with: ""))!
            let date = Date(timeInterval: 60*60*24 * daysFromToday, since: Date())
            
            return date
        }
        else
        {
            let dateFormatter = DateFormatter()
            //dateFormatter.locale = Locale.current //Locale(identifier: "en_US_POSIX")
            dateFormatter.calendar = Calendar.current
            
            dateFormatter.dateFormat = format
            
            let date = dateFormatter.date(from: dateString)
            
            return date
        }
    }
    
    func localTimeZoneDate() -> Date {
        
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = self.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        let localDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        return localDate
    }
    
   func stringWithFormat(_ format:String) -> String
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.locale =  Locale.current //Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar.current
        
        let dateStringDisplay = dateFormatter.string(from: self)
        
        return dateStringDisplay
    }
    func isGreaterThanDate(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func isBetweenDates(_ firstdate : Date, secondDate: Date) -> Bool
    {
        if self.isGreaterThanDate(firstdate) && self.isLessThanDate(secondDate)
        {
            return true
        }
        return false
    }
    
    func isEqual(to : Date) -> Bool
    {
        if self.compare(to) == ComparisonResult.orderedSame
        {
            return true
        }
        return false
    }
    
    
    func isEqualDayAsDate(_ date:Date) -> Bool
    {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
        //        return (Calendar.current as NSCalendar).isDate(self, equalTo: date, toUnitGranularity: .day)
    }
    
    func numberOfDaysToDate(_ date:Date) -> Int
    {
        let cal = Calendar.current
        //        let unit:NSCalendar.Unit = .day
        let components = cal.dateComponents([.day], from: self, to: date)
        //        let components = (cal as NSCalendar).components(unit, from: self, to: date, options: [])
        return components.day!
    }
    
    static func JSONdateFromString(_ jsonStringDisplay:String) -> Date?
    {
        let dateFormatter =  DateFormatter()
        //dateFormatter.locale =  Locale.current //Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar.current
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let date = dateFormatter.date(from: jsonStringDisplay)
        
        return date
    }
    
    var millisecondsSince1970:Double
    {
        let millisecondsSince1970 = ((self.timeIntervalSince1970 * 1000.0).rounded())
        return millisecondsSince1970
    }
    
    static func daysBetweenDates(firstDate:Date, secondDate:Date) -> Int {
        
      let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        return components.day ?? 0
    }
    
    func sharedCalendar(){
    
    }
    
    func firstDayOfMonth () -> Date {
    let calendar = Calendar.current
    var dateComponent = calendar.dateComponents([.year, .month, .day ], from: self)
    dateComponent.day = 1
    return calendar.date(from: dateComponent)!
    }
    
    init(year : Int, month : Int, day : Int) {
    
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    dateComponent.year = year
    dateComponent.month = month
    dateComponent.day = day
    self.init(timeInterval:0, since:calendar.date(from: dateComponent)!)
    }
    
    func dateByAddingMonths(_ months : Int ) -> Date {
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    dateComponent.month = months
    return calendar.date(byAdding: dateComponent, to: self)!
    //        return calendar.date(byAdding: dateComponent, to: self, wrapp: NSCalendar.Options.matchNextTime)!
    }
    
    func dateByAddingDays(_ days : Int ) -> Date {
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    dateComponent.day = days
    return calendar.date(byAdding: dateComponent, to: self)!
    //        return (calendar as NSCalendar).date(byAdding: dateComponent, to: self, options: NSCalendar.Options.matchNextTime)!
    }
    
    func hour() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.hour, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.hour, from: self)
    return dateComponent
    }
    
    func second() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.second, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.second, from: self)
    return dateComponent
    }
    
    func minute() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.minute, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.minute, from: self)
    return dateComponent
    }
    
    func day() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.day, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.day, from: self)
    return dateComponent
    }
    
    func weekday() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.weekday, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.weekday, from: self)
    return dateComponent
    }
    
    func month() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.month, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.month, from: self)
    return dateComponent
    }
    
    func year() -> Int {
    let calendar = Calendar.current
    let dateComponent = calendar.component(.year, from: self)
    //        let dateComponent = (calendar as NSCalendar).components(.year, from: self)
    return dateComponent
    }
    
    func numberOfDaysInMonth() -> Int {
    let calendar = Calendar.current
    let days = calendar.range(of:.day, in: Calendar.Component.month, for: self)!
    //        let days = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
    return days.count
    }
    
    func dateByIgnoringTime() -> Date {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day ], from: self)
    //        let dateComponent = (calendar as NSCalendar).components([.year, .month, .day ], from: self)
    return calendar.date(from: dateComponents)!
    }
    
    func monthNameFull() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: self)
    }
    
    func isSunday() -> Bool
{
    return (self.getWeekday() == 1)
    }
    
    func isMonday() -> Bool
{
    return (self.getWeekday() == 2)
    }
    
    func isTuesday() -> Bool
{
    return (self.getWeekday() == 3)
    }
    
    func isWednesday() -> Bool
{
    return (self.getWeekday() == 4)
    }
    
    func isThursday() -> Bool
{
    return (self.getWeekday() == 5)
    }
    
    func isFriday() -> Bool
{
    return (self.getWeekday() == 6)
    }
    
    func isSaturday() -> Bool
{
    return (self.getWeekday() == 7)
    }
    
    func getWeekday() -> Int {
    let calendar = Calendar.current
    return calendar.component(.weekday, from: self)
    //        return (calendar as NSCalendar).components( .weekday, from: self).weekday!
    }
    
    func isToday() -> Bool {
    return self.isDateSameDay(Date())
    }
    
    func isDateSameDay(_ date: Date) -> Bool {
    
    return (self.day() == date.day()) && (self.month() == date.month() && (self.year() == date.year()))
    
    }
    
    func hebrewDispaly() -> String
    {
        return Calendar.hebrew.longDateDisplay(from: self, local: "he_IL")
    }
    
    func isBetweeen(date startDate: Date, andDate endDate: Date) -> Bool {
        return (startDate ... endDate).contains(Date())
    }
}
