//
//  RegistrationProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/08/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class RegistrationProcess: MSBaseProcess
{    
    open override func executeWithObj(_ obj:Any?)
    {
        let params = obj as! [String:Any]
        
        let request = MSRequest()
        request.baseUrl =
        "https://app.daf-yomi.com/mobile/jsonservice.ashx?forumregistertoken=1"
        request.serviceName = ""
        request.requiredResponseType = .JSON
        request.httpMethod = POST
        request.params = params
        
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let userData = request.params.merging(dictionary) { $1 }
            let user = User.init(dictionary: userData)
            
            self.onComplete?(user)
            
        },onFaile: { (object, error) in
            
            
            if let responseData = (object as? BaseRequest)?.responseData
            {
                if responseData.isNumeric
                {
                    self.onComplete?(responseData)
                }
                else{
                     self.onFaile?(responseData, error)
                }
                
            }
            else{
                self.onFaile?(object, error)
            }
        })
    }
    
    override open func cancel()
    {
        super.cancel()
    }
}
