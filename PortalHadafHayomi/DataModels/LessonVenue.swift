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
}
