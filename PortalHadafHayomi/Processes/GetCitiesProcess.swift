//
//  GetCitiesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetCitiesProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        // let params = obj as! [String:String]
        var params = [String:String]()
        params["cities"] = "1"
        
        let request = MSRequest()
        request.baseUrl = "https://app.daf-yomi.com/mobile"
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
            
            if let citiesInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var cities = [City]()
                
                for cityInfo in citiesInfo
                {
                    let city = City(dictionary: cityInfo)
                    cities.append(city)
                }
                
                self.onComplete?(cities)
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
            
            self.onFaile!(object, error)
            
        })
    }
}
