//
//  NetworkingManager.swift
//  MappMakers
//
//  Created by Binyamin Trachtman on 8/27/15.
//  Copyright (c) 2015 Binyamin Trachtman. All rights reserved.
//

import Foundation

public class NetworkingManager {
    
    static let sharedManager =  NetworkingManager()

    var runMock = false
    
    lazy var webService:MSWebService =
    {
        return MSWebService()
        
    }()
    
   lazy var mockService:MSWebService =
        {
            return MSWebService()
    }()
    
    
    func runRequest(_ request:BaseRequest,onStart:@escaping (() -> Void), onComplete:@escaping (_ dictionary:[String:Any], _ error:NSError?) -> Void , onFaile:@escaping (_ object:NSObject, _ error:NSError) -> Void)
     {
        if runMock
        {
            self.runMockRequest(request, onStart: onStart, onComplete: onComplete, onFaile: onFaile)
            return
        }
        
        else
        {
             NetworkingManager.sharedManager.webService.runRequest(request, onStart: onStart, onComplete: onComplete, onFaile: onFaile)
        }
    }
    
    func runMockRequest(_ request:BaseRequest,onStart:@escaping (() -> Void), onComplete:@escaping (_ dictionary:[String:Any], _ error:NSError?) -> Void , onFaile:@escaping (_ object:NSObject, _ error:NSError) -> Void)
    {
      NetworkingManager.sharedManager.mockService.runRequest(request, onStart: onStart, onComplete: onComplete, onFaile: onFaile)
    }
    func runTestSwiftRequest(_ request:BaseRequest,onStart:@escaping (() -> Void), onComplete:@escaping (_ dictionary:[String:Any], _ error:NSError?) -> Void , onFaile:@escaping (_ object:NSObject, _ error:NSError) -> Void)
    {
        NetworkingManager.sharedManager.webService.runRequest(request, onStart: onStart, onComplete: onComplete, onFaile: onFaile)

    }
    
   func cancelRequest(_ request:BaseRequest)
    {
        self.webService.cancelRequest(request)
    }
    
    class func composeGetUrlFromParams(_ params:[String:Any]) -> String
    {
        var GETUrl = ""
        
        let keys = [String] (params.keys)
        
        for key in keys
        {
            var value = String(describing: params[key]!)
            
            if value.hasPrefix("Optional(")
            {
                value = value.replacingOccurrences(of: "Optional(", with: "")
                value = String(value.dropLast())
            }
            
            GETUrl += ("\(key)=\(value)")
            
            if key != keys.last
            {
                GETUrl += "&"
            }
        }
        
        GETUrl = GETUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        return GETUrl
    }
}
