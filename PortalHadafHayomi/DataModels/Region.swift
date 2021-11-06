//
//  Region.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Region:DataObject
{
     var ID:Int!
     var sRegionName:String = ""
    
    var  cities = [City]()
    
    override init() {
        super.init()
    }
    override init(dictionary:[String:Any])
    {
        super.init()
        
        self.ID =  dictionary["ID"] as? Int ?? -1
        self.sRegionName =  dictionary["sRegionName"] as? String ?? ""
    }
}
