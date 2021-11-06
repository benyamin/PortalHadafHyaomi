//
//  Article.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 17/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Article:DataObject
{
    var id:Int!
    var category:String!
    var massechet:String!
    var daf:String!
    var publisher:String!
    var link:String!
    var link_type:Int!
    var file1:String?
    var title:String!
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int ?? 0
        self.category = ("\(dictionary["category"] as? Int ?? 0)")
        self.massechet = dictionary["massechet"] as? String ?? ""
        self.daf = dictionary["daf"] as? String ?? ""
        self.publisher = dictionary["publisher"] as? String ?? ""
        self.link = dictionary["link"] as? String ?? ""
        self.link_type = dictionary["link_type"] as? Int ?? 0
        self.file1 = dictionary["file1"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        
        if link == nil || link == ""
        {
            if link_type == 2
            {
                self.link = ("https://daf-yomi.com/Data/UploadedFiles/DY_Item/\(self.id!)-sFile.pdf")
            }
            else if link_type == 3
            {
                self.link = ("https://daf-yomi.com/mobile/DYItem.aspx?itemId=\(self.id!)")
            }
            
        }
    }
}
