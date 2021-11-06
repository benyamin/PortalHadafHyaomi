//
//  LinkInfo.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 04/11/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class LinkInfo:DataObject
{
    var title:String?
    var subTitle:String?
    var path:String?
    
    override init() {
        super.init()
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.title = dictionary["title"] as? String
        self.subTitle = dictionary["subTitle"] as? String
        self.path = dictionary["link"] as? String
    }
}
