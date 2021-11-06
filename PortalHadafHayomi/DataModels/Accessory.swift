//
//  Accessory.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Accessory:DataObject
{
    var id:String!
    var title:String!
    var iconImage:String!
    var expressions:[Expression]?
    var dataType:String!
    
    override init(dictionary:[String:Any]) {
        super.init()
    }
    
    init(id:String, title:String, iconImage:String, dataType:String) {
         super.init()
        
        self.id = id
        self.title = title
        self.iconImage = iconImage
        self.dataType = dataType
    }
}
