//
//  GetTalmudQAProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/09/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTalmudQAProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let searchInfo = obj as! (masechetId:Int, minPage:Int, maxPage:Int)
        
        //יש באג בפורטל שהאינדקס של מסכת ראש השנה משנה את הסדר של חלק מהמסכתות
       
        var requestMasechetID = searchInfo.masechetId
        if searchInfo.masechetId == 9{ //ראש השנה
            requestMasechetID = 6
        }
        if searchInfo.masechetId >= 6 && searchInfo.masechetId <= 8{
            requestMasechetID = searchInfo.masechetId+1
        }
        
        var params = [String:Any]()
        params["qa"] = 1
        params["massechet"] = requestMasechetID
        params["minpage"] = searchInfo.minPage*2+1//pages are calculated by page side
        params["maxpage"] = searchInfo.maxPage*2+2
        
        let request = MSRequest()
     
        request.baseUrl = "https://app.daf-yomi.com"
        request.serviceName = "mobile/jsonservice.ashx"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        request.params = params
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest) {
    
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            if let examsInfo = dictionary["JsonResponse"] as? [[String:Any]]
            {
                var exams = [Exam]()
                for examInfo in examsInfo{
                    let exam = Exam(dictionary: examInfo)
                    exams.append(exam)
                }
                
                if exams.count == 0 {
                    self.onComplete?(exams)
                }
                else{
                    DispatchQueue.main.async {
                        self.getExamsFullInfo(exams: exams, onReceivedExamsFullInfo:{
                            self.onComplete?(exams)
                        })
                    }
                }
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
                        
            self.onFaile?(object, error)
        })
    }
    
    override open func cancel()
    {
        super.cancel()
    }
    
    func getExamsFullInfo(exams:[Exam],onReceivedExamsFullInfo:(() -> Void)? = nil){
        var examsToFatch = exams.map {$0} as! [Exam]
        if let exam = examsToFatch.first {
            self.getExamsQuestions(exam: exam) {
                examsToFatch.remove(exam)
                if examsToFatch.count > 0 {
                    self.getExamsFullInfo(exams: examsToFatch ,onReceivedExamsFullInfo:onReceivedExamsFullInfo)
                }
                else{
                    onReceivedExamsFullInfo?()
                }
            }
        }
    }
    
    func getExamsQuestions(exam:Exam,onComplete:@escaping () -> Void){
        
        GetTalmudQAInfoProcess().executeWithObject(exam.id, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            exam.questions = object as? [ExamQuestion]
            
            onComplete()
            
        },onFaile: { (object, error) -> Void in
            onComplete()
        })
    }
}
