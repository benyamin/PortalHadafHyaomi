//
//  LessonVenue.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 18/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class  LessonVenue:Venue
{
    var maggid:String!
    var hour:String!
    var pratim:String?
    var sregionname:String!
    var house_number:Int?
    var location:String?
    var distanceFromUser:Double = 0.0
    var class_size:String?
    
    lazy var dispalyedInformation:String = {
        
        var dispalyedInformation = ""
        
        dispalyedInformation += "st_country".localize() + ": "
        dispalyedInformation += self.sregionname! + "\n"
        
        dispalyedInformation += "st_lesson_location".localize() + ": "
        dispalyedInformation += self.location!
        dispalyedInformation += "\n"
        
        dispalyedInformation += "st_lesson_address".localize() + ": "
        dispalyedInformation += self.address! + " "
        dispalyedInformation += "\n"
        
        dispalyedInformation += "st_lesson_time".localize() + ": "
        dispalyedInformation += self.hour! + "\n"
        
        dispalyedInformation += "st_class_size".localize() + ": "
        dispalyedInformation += self.class_size ?? "st_class_size_unknown".localize()
        dispalyedInformation += "\n"
        
        dispalyedInformation += "st_additional_info".localize() + ": "
        dispalyedInformation += self.pratim!.htmlToString
        
        return dispalyedInformation
        
    }()
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id =  dictionary["id"] as? Int ?? -1
        
        self.latitude = dictionary["latitude"] as? Double ?? 0.0
        self.longitude = dictionary["longitude"] as? Double ?? 0.0
        
        self.city = dictionary["city"] as? String ?? ""
        self.address = self.getFullAddressFromDictoianry(dictionary)
        self.location = dictionary["location"] as? String ?? ""
        
        self.maggid = dictionary["maggid"] as? String ?? ""
         self.hour = dictionary["hour"] as? String ?? ""
         self.pratim = dictionary["pratim"] as? String ?? ""
         self.sregionname = dictionary["sregionname"] as? String ?? ""
         self.house_number = dictionary["house_number"] as? Int
        self.class_size = dictionary["class_size"] as? String
    }
    
    func getFullAddressFromDictoianry(_ dictionary:[String:Any]) -> String
    {
        var fullAddress = ""
        
        if let address = dictionary["address"] as? String
        {
            fullAddress += address
           
            if let house_number = dictionary["house_number"] as? String
            {
                fullAddress += " \(house_number)"
            }
        }
        return fullAddress
    }
    
    func isWithinTimeRange(from fromDate: Date?, to toDate: Date?) -> Bool {
        // No time filter → always valid
        guard fromDate != nil || toDate != nil else { return true }

        // Extract venue start/end (e.g. "8:30 - 9:30")
        guard let venueRange = extractStartAndEndComponents(from: hour) else {
            return true
        }

        // Convert venue START time to minutes
        let venueStartMinutes =
            (venueRange.start.hour ?? 0) * 60 +
            (venueRange.start.minute ?? 0)

        // Convert filters to minutes
        let fromMinutes = fromDate.map(minutes) ?? 0
        let toMinutes   = toDate.map(minutes) ?? (24 * 60)

        // ✅ Only check venue START
        return venueStartMinutes >= fromMinutes
            && venueStartMinutes <= toMinutes
    }
    
    private func timeComponentsAsIs(from date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: date)
    }
    
    private func minutes(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
    
    func extractStartAndEndComponents(
        from timeRange: String,
        calendar: Calendar = .current
    ) -> (start: DateComponents, end: DateComponents)? {

        let parts = timeRange
            .split(separator: "-")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        guard parts.count == 2 else { return nil }

        func components(from time: String) -> DateComponents? {
            let timeParts = time.split(separator: ":")
            guard timeParts.count == 2,
                  let hour = Int(timeParts[0]),
                  let minute = Int(timeParts[1]) else {
                return nil
            }

            var components = DateComponents()
            components.calendar = calendar
            components.hour = hour
            components.minute = minute
            return components
        }

        guard
            let end = components(from: parts[0]),     // left
            let start = components(from: parts[1])    // right
        else {
            return nil
        }

        return (start: start, end: end)
    }
    
    private func parseHourRange(_ hour: String) -> (start: Int, end: Int)? {
        let parts = hour.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2 else { return nil }

        func parse(_ time: String) -> Int? {
            let comps = time.split(separator: ":")
            guard comps.count == 2,
                  let h = Int(comps[0]),
                  let m = Int(comps[1]) else { return nil }
            return h * 60 + m
        }

        guard let start = parse(parts[0]),
              let end = parse(parts[1]) else { return nil }

        return (start, end)
    }
}
