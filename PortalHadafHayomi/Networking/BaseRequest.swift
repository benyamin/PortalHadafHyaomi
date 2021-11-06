//
//  BaseRequest.swift
//
//  Created by Binyamin Trachtman on 7/18/16.
//  Copyright © 2016 Binyamin Trachtman. All rights reserved.
//

import Foundation

public let GET =  "GET"
public let POST = "POST"

public enum ResponseType:String {
    case JSON = "JSON"
    case XML = "XML"
    case HTML = "HTML"
}

public let RequestHeaderKey = "RequestHeaderKey"

open class BaseRequest: NSObject
{
    open var url: URL?
    open var timeoutInterval: TimeInterval?
    
    open var responseData:String?
    
    open var requiredResponseType:ResponseType = .JSON
    
    open lazy var headerFields:[String:String] = {
       
        return [String:String]()
    }()
    
    open var baseUrl:String! {
        didSet {
            self.buildUrlPath()
        }
    }
    
    open var serviceName:String!{
        didSet {
            self.buildUrlPath()
        }
    }
    
    open var params:[String:Any]! {
        didSet {
            
            self.buildUrlPath()
        }
    }
    
    open var httpBody: Data? {
        
        didSet {
          //  self.request.httpBody = httpBody
        }
    }
    
    open var httpMethod: String! {
        
        didSet {
            
            self.buildUrlPath()
           // self.request.httpMethod = httpMethod
        }
    }
    
 
    open func buildUrlPath()
    {
        if baseUrl != nil
        {
            var urlPath = baseUrl!
            
            if  serviceName != nil && serviceName != ""
            {
                urlPath += ("/\(serviceName!)")
            }
            
            if (params != nil)
            {
                if self.httpMethod == GET
                {
                    urlPath += "?"
                    
                    let keys = [String] (params.keys)
                    
                    for key in keys
                    {
                        var value = String(describing: params[key]!)
                        
                        if value.hasPrefix("Optional(")
                        {
                            value = value.replacingOccurrences(of: "Optional(", with: "")
                            value = String(value.dropLast())
                        }
                        
                        urlPath += ("\(key)=\(value)")
                        
                        if key != keys.last
                        {
                            urlPath += "&"
                        }
                    }
                    
                    urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                }
                else if self.httpMethod == POST
                {
                    let JSONData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
                    
                    let JsonSting = NSString(data: JSONData!,encoding: String.Encoding.ascii.rawValue)
                    
                    print ("POST Body:\(JsonSting!)")
                    
                    self.httpBody = JSONData
                }
            }
            
            url = Foundation.URL(string: urlPath)
            
            if url == nil
            {
                print("URL path is invalid:\(urlPath)")
            }
        }
    }

    open func getUrlRequest() -> URLRequest?
    {
        if self.url != nil{
            
            var urlRequest = URLRequest(url: self.url!)
            urlRequest.timeoutInterval = self.timeoutInterval!
            urlRequest.httpMethod = self.httpMethod
            urlRequest.httpBody = self.httpBody
            
            for (key,value) in self.headerFields
            {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            return urlRequest
        }
        
        return nil
        
    }
}
