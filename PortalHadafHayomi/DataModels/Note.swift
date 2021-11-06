//
//  Note.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/03/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class Note: DataObject {

    var id:String?
    var title:String?
    var content:String?
    
    override init() {
        super.init()
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? String
        self.title = dictionary["title"] as? String
        self.content = dictionary["content"] as? String
    }
    
    func deserializeDictioanry() -> [String:Any]
    {
        var deserializeDictioanry = [String:Any]()
        
        deserializeDictioanry["id"] = id
        deserializeDictioanry["title"] = title
        deserializeDictioanry["content"] = content
        
        return deserializeDictioanry
    }
}
