//
//  ExamQuestion.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

class ExamQuestion:DataObject
{
    var id:Int?
    var Qdescription:String?
    var answers:[ExamAnswer]?
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        self.Qdescription = dictionary["question"] as? String
        if let answersInfo = dictionary["answers"] as? [[String:AnyObject]] {
            
            var answers = [ExamAnswer]()
            
            for index in 0 ..< answersInfo.count {
                                
                let answer = ExamAnswer(dictionary: answersInfo[index])
                
                //The First answer in the list is the currect answer
                answer.isCorrect = (index == 0)
                
                answers.append(answer)
            }
            //answers.shuffle()
            
            self.answers = answers.sorted { $0.Adescription < $1.Adescription }
        }
    }
}
