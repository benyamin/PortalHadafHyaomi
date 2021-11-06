//
//  City.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class City:DataObject
{
    var ID:Int?
    var sCityName:String = ""
    var RegionID:Int?
    
    override init(dictionary:[String:Any])
    {
        super.init()
        
        self.ID =  dictionary["ID"] as? Int ?? -1
        self.sCityName =  dictionary["sCityName"] as? String ?? ""
        self.RegionID =  dictionary["RegionID"] as? Int
    }
}

