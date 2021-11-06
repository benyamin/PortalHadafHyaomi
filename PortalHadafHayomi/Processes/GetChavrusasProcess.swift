//
//  GetChavrusasProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetChavrusasProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        var params = obj as! [String:String]
        
        params["board"] = "1"
        
        let request = MSRequest()
        request.baseUrl = "https://daf-yomi.com/mobile"
        request.serviceName = "jsonservice.ashx"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        request.params = params
        
        
      //  http://daf-yomi.com/mobile/jsonservice.ashx?board=1&chofshi={}&city={}&ezor={}&page={}&pagesize={}
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if let chavrusasInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var chavrusas = [Chavrusa]()
                
                for chavrusaInfo in chavrusasInfo
                {
                    let chavrusa = Chavrusa(dictionary: chavrusaInfo)
                    
                    chavrusas.append(chavrusa)
                }
                
               self.onComplete!(chavrusas)
            }
                
            else{
                if error == nil
                {
                    self.onComplete?(responseDctinoary)
                }
                else {
                    self.onFaile?(responseDctinoary, error!)
                }
            }
            
        },onFaile: { (object, error) in
            
            if let responseData = (object as? BaseRequest)?.responseData, responseData == "1"
            {
                self.onComplete!(object)
            }
            else{
                self.onFaile!(object, error)
            }
        })
    }
}
