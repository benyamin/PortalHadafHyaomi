//
//  GetTalmudQAInfoProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 23/10/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTalmudQAInfoProcess: MSBaseProcess
{
    var request:MSRequest?
    
    open override func executeWithObj(_ obj:Any?)
    {
        let examId = obj as? Int
        
        var params = [String:Any]()
        params["questions"] = examId
        
        let request = MSRequest()
     
        request.baseUrl = "https://daf-yomi.com"
        request.serviceName = "mobile/jsonservice.ashx"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        request.params = params
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            if let examsQuestionsInfo = dictionary["JsonResponse"] as? [[String:Any]]
            {
                var questions = [ExamQuestion]()
                
                for questionInfo in examsQuestionsInfo {
                    let question = ExamQuestion(dictionary: questionInfo)
                    questions.append(question)
                }
                
                self.onComplete?(questions)
            }
            else{
                if error == nil {
                    self.onComplete?(dictionary)
                }
                else {
                    self.onFaile?(dictionary, error!)
                }
            }
        },onFaile: { (object, error) in
            
            self.request = nil
            
            self.onFaile?(object, error)
        })
    }
    
    override open func cancel()
    {
        super.cancel()
        
        if self.request != nil
        {
            NetworkingManager.sharedManager.cancelRequest(self.request!)
        }
    }
}

