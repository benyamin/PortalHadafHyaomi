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
        var searchInfo = obj as! (masechetId:Int, minPage:Int, maxPage:Int)
        
        var params = [String:Any]()
        params["questions"] = 382
        
        self.request = MSRequest()
     
        request?.baseUrl = "https://daf-yomi.com"
        request?.serviceName = "mobile/jsonservice.ashx"
        request?.requiredResponseType = .JSON
        request?.httpMethod = GET
        request?.params = params
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest, dataPageNumber:Int)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
           
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

