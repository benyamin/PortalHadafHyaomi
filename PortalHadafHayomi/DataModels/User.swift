//
//  User.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/08/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

class User:DataObject
{
    var dictionaryRepresentation:[String:Any]?
    var token:String?
    var userId:Int?
    var name:String!
    var password:String?
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.dictionaryRepresentation = dictionary
        
        self.token = dictionary["token"] as? String
        self.userId = dictionary["userId"] as? Int
        self.name = dictionary["username"] as? String ?? ""
        self.password = dictionary["password"] as? String
    }
}
