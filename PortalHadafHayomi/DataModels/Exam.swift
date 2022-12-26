//
//  Exam.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Exam:DataObject
{
    var id:Int?
    var massechetId:Int?
    var title:String?
    var examDescription:String?
    var minPage:Int?
    var maxPage:Int?
    var questions:[ExamQuestion]?
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        self.massechetId = dictionary["massechet"] as? Int
        self.title = dictionary["title"] as? String
        self.examDescription = dictionary["description"] as? String
        self.minPage = dictionary["minPage"] as? Int
        self.maxPage = dictionary["maxPage"] as? Int
    }
}
