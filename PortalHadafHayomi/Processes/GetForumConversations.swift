//
//  GetForumConversations.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetForumConversations: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        var params = [String:String]()
      
        params["forumrootmessages"] = "1"
        params["forumid"] = "1"
        params["page"] = "1"
        params["chofshi"] = ""
        params["pagesize"] = "20"
        params["order"] = "0" //assanding, 1 for desanding
        
        let request = MSRequest()
        request.baseUrl = "http://daf-yomi.com/mobile"
        request.serviceName = "jsonservice.ashx"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        request.params = params
        
    
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if let conversationsInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
               // self.onComplete!(chavrusas)
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
                self.onComplete?(object)
            }
            else{
                self.onFaile?(object, error)
            }
        })
    }
}
