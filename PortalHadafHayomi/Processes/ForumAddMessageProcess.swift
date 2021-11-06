//
//  ForumAddMessageProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/09/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class ForumAddMessageProcess: MSBaseProcess
{
    var forumid:String?
    
    open override func executeWithObj(_ obj:Any?)
    {
        let requiredInfo = obj as! (user:User, fourminfo:ForumPost, discussion:ForumPost?)
        var params = [String:Any]()
        
        let newMessageInfo = requiredInfo.fourminfo
        let discussion = requiredInfo.discussion
        
        params["forumId"] = 1
        params["parentId"] = discussion?.id ?? 0
        params["content"] = newMessageInfo.content
        params["massechetId"] = (discussion != nil) ? 0 : newMessageInfo.massechetId
        params["pageId"] = (discussion != nil) ? 0 : newMessageInfo.pageId
        params["title"] = newMessageInfo.title
        params["token"] = requiredInfo.user.token
        
        let request = MSRequest()
        request.baseUrl = "https://daf-yomi.com/mobile/jsonservice.ashx?forumaddmessagetoken=1"
        request.serviceName = ""//"login.aspx"
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
                 if let messageCode = Int(responseData)
                    ,messageCode > 0
                {
                    self.onComplete?(messageCode)
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
