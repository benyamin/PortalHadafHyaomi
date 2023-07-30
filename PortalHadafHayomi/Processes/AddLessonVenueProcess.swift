//
//  AddLessonVenueProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/03/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class AddLessonVenueProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
     
        var params = obj as! [String:String]
        params["lessonadd"] = "1"
        
        let request = MSRequest()
        request.baseUrl = "https://app.daf-yomi.com/mobile"//"https://app.daf-yomi.com/Mobile"
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
            
            if error == nil
            {
                self.onComplete?(responseDctinoary)
            }
            else {
                self.onFaile?(responseDctinoary, error!)
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
