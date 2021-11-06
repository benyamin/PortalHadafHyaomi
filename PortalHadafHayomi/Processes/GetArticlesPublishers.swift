//
//  GetArticlesPublishers.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/12/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetArticlesPublishers: MSBaseProcess
{
    var request:MSRequest?
    
    var discussoin:ForumPost?
    
    open override func executeWithObj(_ obj:Any?)
    {
        self.discussoin = obj as? ForumPost
        
        var params = [String:String]()
        
       // params["t"] = "0.2839485913669897"
        params["massechetpublisher"] = ""
       params["categorypublisher"] = "1"
        //params["allpublishers"] = "1"
        
        self.request = MSRequest()
        request?.baseUrl = "http://daf-yomi.com/AjaxHandler.ashx"
        request?.serviceName = ""
        request?.requiredResponseType = .JSON
        request?.httpMethod = GET
        request?.params = params
        
        self.runWebServiceWithRequest(request!)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            self.request = nil
            
            
        },onFaile: { (object, error) in
            
            self.request = nil
            
            if let baseRequest = object as? BaseRequest
                ,let responseData = baseRequest.responseData
            {
                var publishers = [Publisher]()
                let publishersInfo = responseData.components(separatedBy:"</option>")
                for publisherInfo in publishersInfo
                {
                    let publisher = Publisher()
                    if let publisherId = publisherInfo.slice(from: "=\"", to: "\">")
                        , let publisherName = publisherInfo.components(separatedBy:">").last
                    {
                        publisher.id = publisherId
                         publisher.name = publisherName
                        
                         publishers.append(publisher)
                    }
                    
                }
                self.onComplete?(publishers)
            }
            else{
                self.onFaile?(object, error)
            }
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

