//
//  GetPageTextProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 07/01/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetPageTextProcess: MSBaseProcess
{
    var dataTask: URLSessionDataTask?
    
    open override func executeWithObj(_ obj:Any?)
    {
        let pageInfo = obj as! [String:Any]
        
        let pageIndex = pageInfo["index"] as! Int
        let scoring = pageInfo["scoring"] as! Bool
        
        self.getPageByIndex(pageIndex, withScoring:scoring)
    }
    
    func getPageByIndex(_ pageIndex:Int, withScoring scoring:Bool)
    {
            dataTask?.cancel()
        
        let baseUrl = "https://app.daf-yomi.com/DafYomi_Page.aspx"

            if var urlComponents = URLComponents(string: baseUrl) {
                urlComponents.query = "vt=\(scoring ? 3 : 2)&context=1&id=\(pageIndex)&mobile=1"
                
                guard let url = urlComponents.url else {
                    self.didFaile(error: nil)
                    return
                }
                
                let defaultSession = URLSession(configuration: .default)
                dataTask = defaultSession.dataTask(with: url) { data, response, error in
                    defer { self.dataTask = nil }
                    
                    if let error = error
                    {
                        self.didFaile(error: error)
                        
                    } else if let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200 {
                        
                        if let responseData = String(data: data, encoding: String.Encoding.utf8)
                        {
                            if let talmudText = responseData.slice(from: "<div id=\"PageText\">", to: "</div>")
                            ,let rashiText = responseData.slice(from: "id=\"ContentPlaceHolderMain_oRashiTitle\">רש&quot;י</h2><div class=\"clsBody\">", to: "</div>")
                            ,let tosfotText = responseData.slice(from: "id=\"ContentPlaceHolderMain_oTosfotTitle\">תוספות</h2><div class=\"clsBody\">", to: "</div>")
                            {
                                
                                //var pageText = "<p style=\"line-height:1.5em;background-color:#6A2423;color:#FAF2DD\">גמרא</p>"
                                var pageText = "<p style=\"color:#6A2423\">גמרא</p>"
                                pageText += talmudText
                                pageText += "<br>"
                                
                                pageText += "<p style=\"color:#6A2423;\">רש׳׳י</p>"
                                pageText += rashiText
                                pageText += "<br>"
                                pageText += "<p style=\"color:#6A2423;\">תוס׳</p>"
                                pageText += tosfotText
                                pageText += "<br><br>"
                                
                                //<!DOCTYPE html><html dir=\"rtl\" lang=\"ar\"><head><meta charset=\"utf-8\">
                                
                                let fullText =  "<!DOCTYPE html> <html dir=\"rtl\"> <head> <style> p.padding {padding-left: 1em; padding-right: 2em; padding-bottom: 2cm; padding-left: 2cm;} p.padding2 { padding-left: 50%; } </style> </head> <body> <p class=\"padding\">\(pageText)</p> </body> </html>"
                                
                                DispatchQueue.main.async {
                                    self.onComplete?(fullText)
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.onComplete?(url)
                                }
                                 
                            }
                            
                            
                        }
                    }
                }
                dataTask?.resume()
            }
    }
    
    
    func didFaile(error:Error?)
    {
        if error == nil
        {
            let userInfo = ["Description": "serverError".localize()]
            let defaultError = NSError(domain: "PortalDomain", code: -1, userInfo: userInfo)
            
            self.onFaile?(self, defaultError as NSError)
        }
        else
        {
            self.onFaile?(self, error! as NSError)
        }
    }
    
    override open func cancel()
    {
        self.dataTask?.cancel()
        super.cancel()
    }
}

