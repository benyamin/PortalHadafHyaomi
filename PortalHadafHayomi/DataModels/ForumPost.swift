//
//  ForumPost.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/09/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class  ForumPost:DataObject
{
    var content:String?
    var filename:String?
    var id:Int?
    var massechet:String?
    var rownumber:Int?
    var pdate:String?
    var date:Date?
    var title:String?
    var realdate:String?
    var username:String?
    var children:Int?
    var forumid:String?
    
    var massechetId:Int?
    var pageId:Int?

    
    var discussions:[ForumPost]?
    
    override init() {
        super.init()
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.content = dictionary["content"] as? String
        self.filename = dictionary["filename"] as? String
        self.id = dictionary["id"] as? Int
        self.massechet = dictionary["massechet"] as? String
        self.rownumber = dictionary["rownumber"] as? Int
        self.pdate = dictionary["pdate"] as? String
        self.realdate = dictionary["realdate"] as? String
        self.username = dictionary["username"] as? String
        self.children = dictionary["children"] as? Int
        
        self.title = dictionary["title"] as? String
        self.title?.removeHtmlNodes()
        
        if let date = dictionary["date"] as? String
        {
            self.date = Date.dateFromString(date, withFormat: "yyyy-MM-dd HH:mm:ss")
        }
    }
}

