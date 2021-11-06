//
//  MSRequest.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 05/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

open class MSRequest: BaseRequest
{
    override open func buildUrlPath()
    {
        if (baseUrl != nil)
        {
            var urlPath = "\(baseUrl!)"
            if serviceName != nil && serviceName != ""
            {
                 urlPath += "/\(serviceName!)"
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
            
            if url != nil
            {
                _ = self.setHeader()
            }
            else
            {
                print("URL path is invalid:\(urlPath)")
            }
        }
    }
    
    internal func setHeader() -> [String:String]
    {
        var headerFields = [String:String]()
        
        if self.requiredResponseType == .JSON
        {
            headerFields["Content-Type"] = "application/json; charset=utf-8"
            headerFields["Accept-Encoding"] = "gzip, deflate, br"
        }
        
        return headerFields
    }
}
