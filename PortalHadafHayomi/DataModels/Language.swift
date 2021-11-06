//
//  Language.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 23/03/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Language: DataObject {
    
    var id:String?
    var name:String?
    var displayName:String? {
        
        get{
            if self.id != nil
            {
               return "language_\(self.id!)".localize()
            }
            else{
                return self.id ?? ""
            }
        }
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
    }
}
