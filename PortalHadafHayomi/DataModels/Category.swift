//
//  Category.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Category:DataObject
{
    var id:String!
    var title:String!
    var iconImage:String!
    
    override init() {
        super.init()
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
    }
    
    init(id:String, title:String, iconImage:String) {
        super.init()
        
        self.id = id
        self.title = title
        self.iconImage = iconImage
    }
}
