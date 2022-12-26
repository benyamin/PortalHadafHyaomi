//
//  ExamAnswer.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation

class ExamAnswer:DataObject {
    
    var id:Int?
    var Adescription:String?
    var isSelected = false
    var isCorrect = false
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        
        if var answer = dictionary["answer"] as? String {
            let subStringsToBeRemoved = ["א.","ב.","ג.","ד.","א-","ב-","ג-","ד-"]
            
            for subStringToBeRemoved in subStringsToBeRemoved {
                answer = answer.replacingOccurrences(of: subStringToBeRemoved, with: "")
            }
            self.Adescription = answer.trimmingCharacters(in: .whitespaces)
        }
    }
}
