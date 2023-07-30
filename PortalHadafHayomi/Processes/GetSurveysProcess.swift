//
//  GetSurveysProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 21/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetSurveysProcess: MSBaseProcess
{
    var runningTask: URLSessionDataTask?
    
    open override func executeWithObj(_ obj:Any?)
    {
        let request = MSRequest()
        
        request.baseUrl = "https://app.daf-yomi.com"
         request.serviceName = "Polls.aspx"
        
        request.requiredResponseType = .JSON
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
                        let surveys = self.parseseResultsFromData(responseData)
                        
                        DispatchQueue.main.async {
                            self.onComplete!(surveys)
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
    
    func parseseResultsFromData(_ responseData:String) -> [Survey]
    {
        var surveys = [Survey]()

        let table = responseData.components(separatedBy: "table")
        if table.count > 1
        {
            let tableContent = table[1]
            let clsContainer = tableContent.components(separatedBy: "clsContainer")
            if clsContainer.count > 0
            {
                let surveysTableTag = clsContainer[1]
                
                let tableTags = surveysTableTag.components(separatedBy: "<br><br>")
                
                for tableTag in tableTags
                {
                    let survey = Survey()
                    
                    survey.Id = tableTag.slice(from: "d=", to: "\" title")
                    survey.title = tableTag.slice(from: "title=\"", to: "\"  >")
                    survey.voters = tableTag.slice(from: "(", to: ")")
                    
                    surveys.append(survey)
                }
            }
        }
        
        return surveys
    }
}
