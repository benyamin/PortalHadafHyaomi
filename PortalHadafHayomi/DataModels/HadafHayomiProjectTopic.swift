//
//  HadafHayomiProjectTopic.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class HadafHayomiProjectTopic:DataObject
{
    var id:String!
    var title:String!
    var iconImage:String!
    var link:String?
    
    override init(dictionary:[String:Any]) {
        super.init()
    }
    
    init(id:String, title:String, iconImage:String, link:String?) {
        super.init()
        
        self.id = id
        self.title = title
        self.iconImage = iconImage
        self.link = link
    }
}
