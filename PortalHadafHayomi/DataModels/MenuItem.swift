//
//  MenuItem.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 28/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class  MenuItem:DataObject
{
    var name:String!
    var title:String!
    var imageName:String!
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.name = dictionary["name"] as? String
        self.title = dictionary["title"] as? String
        self.imageName = dictionary["imageName"] as? String
    }
}
