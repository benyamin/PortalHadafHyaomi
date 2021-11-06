//
//  LoginProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 22/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class LoginProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let params = obj as! [String:Any]
                
       // params["username"] = "Benya14"
            // params["email"] = "binyamin.mishour@gmail.com"
       // params["password"] = "ggyamin1"
        
        let request = MSRequest()
        request.baseUrl = "https://daf-yomi.com/mobile/jsonservice.ashx?forumlogintoken=1"
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

//http://daf-yomi.com/forums/members/login.aspx?fp=%2fforums%2fforum.aspx%3fid%3d1&PageId=156&msg=
/*
 __VIEWSTATE: /wEPDwULLTE0OTQxNDYyMzQPZBYCAgIPZBYCAgUPD2QWAh4Hb25jbGljawUVcmV0dXJuIGZWYWxpZGF0Rm9ybSgpZGRNN0Z3y9buOarhoqW8KVAjkah0u/QubWulwMsbdo+OMQ==
 __VIEWSTATEGENERATOR: 5D025943
 __EVENTVALIDATION: /wEdAASsvZkyPLGQURCF0sXXkrSBK1PMeUoJX85hFNiqmBSgl0b4Jgz7HnIzKj7/kLiIRTvN+DvxnwFeFeJ9MIBWR693gic5DVGyfUC+vwV+ljPHS2hTKGAi4FtHbfK253OYZ+o=
 login: הראל
 pass: 111111
 Button1: כניסה
 */
