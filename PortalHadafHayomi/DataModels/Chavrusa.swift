//
//  Chavrusa.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Chavrusa:DataObject
{
    var cityId:Int?
    var Id:Int?
    var pubDate:String?
    var rownumber:Int?
    var cityName:String?
    var DellPass:String?
    var email:String?
    var fullName:String?
    var regionName:String?
    var text:String?
    
    var dateDisplay:String {
        get{
            if let date = self.pubDate?.toDate(fromat: "yyyy-MM-dd HH:mm:ss"){
                return "\(date.hebrewDispaly())\n\(date.stringWithFormat("HH:mm"))"
            }
            else{
                return pubDate ?? ""
            }
        }
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.cityId = dictionary["CityId"] as? Int
        self.Id = dictionary["ID"] as? Int
        self.pubDate = dictionary["dPubDate"] as? String
        self.rownumber = dictionary["rownumber"] as? Int
        self.cityName = dictionary["sCityName"] as? String
        self.DellPass = dictionary["sDellPass"] as? String
        self.email = dictionary["sEmail"] as? String
        self.fullName = dictionary["sFullName"] as? String
        self.regionName = dictionary["sRegionName"] as? String
        self.text = dictionary["stext"] as? String
    }
}
