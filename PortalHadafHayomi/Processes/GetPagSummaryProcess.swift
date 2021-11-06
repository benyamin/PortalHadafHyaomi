//
//  GetPagSummaryProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 07/05/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

class GetPagSummaryProcess: MSBaseProcess
{
    var runningTask: URLSessionDataTask?
    
    var request:MSRequest?
    
    open override func executeWithObj(_ obj:Any?)
    {
        var params = obj as! [String:String]
        params["summary"] = "1"
        
        self.request = MSRequest()
        self.request?.baseUrl = "http://daf-yomi.com/mobile"
        self.request?.serviceName = "jsonservice.ashx"
        self.request?.requiredResponseType = .JSON
        self.request?.httpMethod = GET
        
        self.request?.params = params
        
        self.runWebServiceWithRequest(self.request!)
    }
    
    func runWebServiceWithRequest(_ request:MSRequest)
    {
        if let url = request.url
        {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            self.runningTask = session.dataTask(with: request) {data, response, error in
                if error != nil {
                    
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        self.onFaile?(request.url?.absoluteString, error! as NSError)
                    }
                    return
                }
                
                if data != nil
                {
                    if String(data: data!, encoding: String.Encoding.utf8) != nil
                    {
                        if let responseDctinoary = MSWebService.serializeData(jsonData:data!) as? [String:Any]
                            , let pageSummary = responseDctinoary["rich"] {
                            DispatchQueue.main.async {
                                self.onComplete?(pageSummary)
                            }
                        }
                    }
                }
                else{
                    let errorCode = -999
                    let userInfo = ["Description": "serverError".localize()]
                    let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
                    
                    DispatchQueue.main.async {
                        self.onFaile?(request.url?.absoluteString, error as NSError)
                    }
                }
            }
            
            self.runningTask?.resume()
        }
        else{
            
            let errorCode = -999
            let userInfo = ["Description": "serverError".localize()]
            let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
            
            DispatchQueue.main.async {
                self.onFaile?(request.url?.absoluteString, error as NSError)
            }
        }
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
