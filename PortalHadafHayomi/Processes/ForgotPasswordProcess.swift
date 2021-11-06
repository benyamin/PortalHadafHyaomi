//
//  ForgotPasswordProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/10/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class ForgotPasswordProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
       let params = obj as! [String:Any]
        
        //var params = [String:Any]()
       // params["username"] = "Benya14"
       // params["email"] = "binyamin.mishour@gmail.com"
        
        let request = MSRequest()
        request.baseUrl = "https://daf-yomi.com/mobile/jsonservice.ashx?forgotpassword=1"
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
}
