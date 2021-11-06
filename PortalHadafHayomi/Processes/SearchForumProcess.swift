//
//  SearchForumProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/10/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class SearchForumProcess: MSBaseProcess
{
    var request:MSRequest?
    
    var forumid:String?
    
    open override func executeWithObj(_ obj:Any?)
    {
        var params = obj as! [String:String]
        
        self.forumid = params["forumid"]
        
        params["forummessages"] = "1"
        params["order"] = "0"
        
        self.request = MSRequest()
        request?.baseUrl = "https://daf-yomi.com/mobile"
        request?.serviceName = "jsonservice.ashx"
        request?.requiredResponseType = .JSON
        request?.httpMethod = GET
        request?.params = params
        
       // http://daf-yomi.com/mobile/jsonservice.ashx?forumid=1&page=1&pagesize=20&chofshi=%D7%9B%D7%94%D7%A0%D7%99%D7%9D%20%D7%94%D7%9E%D7%95%D7%9C%D7%99%D7%9B%D7%99%D7%9D
        
        self.runWebServiceWithRequest(request!)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            self.request = nil
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if let postsInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var posts = [ForumPost]()
                
                for postInfo in postsInfo
                {
                    let post = ForumPost(dictionary: postInfo)
                    post.forumid = self.forumid
                    
                    posts.append(post)
                }
                
                self.onComplete!(posts)
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
            
            self.request = nil
            
            if let responseData = (object as? BaseRequest)?.responseData, responseData == "1"
            {
                self.onComplete?(object)
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
