//
//  GetCurrenySurveyProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetCurrenySurveyProcess: MSBaseProcess
{
    var runningTask: URLSessionDataTask?
    
    open override func executeWithObj(_ obj:Any?)
    {
        
        let request = MSRequest()
        
        request.baseUrl = "https://app.daf-yomi.com/mobile2"
        request.serviceName = "poll.aspx"
        
        request.httpMethod = GET
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:MSRequest)
    {
        let urlString = request.baseUrl! + "/" +  request.serviceName
        if let url = URL(string: urlString)
        {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            self.runningTask = session.dataTask(with: request) {data, response, error in
                if error != nil {
                    
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        self.onFaile?(urlString, error! as NSError)
                    }
                    return
                }
                
                if data != nil
                {
                    if let responseData = String(data: data!, encoding: String.Encoding.utf8)
                    {
                        print ("responseData:\(responseData)")
                        
                        var currentSurveyLink = urlString
                        var currentPollId = "-1"
                        
                        if let pollId = responseData.slice(from: "fPollVote(", to: ",")
                        {
                            currentPollId = pollId
                            
                            if let checkedServeys = UserDefaults.standard.object(forKey: "checkedServeys") as? [String]
                            {
                                if checkedServeys.contains(currentPollId)
                                {
                                    currentSurveyLink = "https://app.daf-yomi.com/pollResults.aspx?mobile=1&id=" + currentPollId
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            
                            let surveyInfo = ["link":currentSurveyLink,
                                              "id":currentPollId]
                            self.onComplete!(surveyInfo)
                        }
                    }
                }
                else{
                    self.unknownFaile()
                }
            }
            
            self.runningTask?.resume()
        }
        else{
            
            self.unknownFaile()
        }
    }
    
    func unknownFaile()
    {
        let errorCode = -999
        let userInfo = ["Description": "serverError".localize()]
        let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
        
        DispatchQueue.main.async {
            self.onFaile?("", error as NSError)
        }
    }
    
}
