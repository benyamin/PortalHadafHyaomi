//
//  GetSubtitlesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/01/2023.
//  Copyright © 2023 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetSubtitlesProcess: MSBaseProcess
{
    var request:MSRequest?
    
    open override func executeWithObj(_ obj:Any?)
    {
        let examId = obj as? Int
        
        var params = [String:Any]()
        params["questions"] = examId
        
        let request = MSRequest()
     
        request.baseUrl = "https://files.daf-yomi.com"
        request.serviceName = "files/gutman/nedarim/nedarim091.srt"
        request.requiredResponseType = .HTML
        request.httpMethod = GET
        request.params = params
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            if let srtFile = dictionary["htmlContent"] as? String
            {
                let srtMap = self.mapSrt(srt: srtFile)
                self.onComplete?(srtMap)
            }
            else{
                if error == nil {
                    self.onComplete?(dictionary)
                }
                else {
                    self.onFaile?(dictionary, error!)
                }
            }
        },onFaile: { (object, error) in
            
            self.request = nil
            
            self.onFaile?(object, error)
        })
    }
    
    func mapSrt(srt:String) -> [[String:String]]{
        var srtMap = [[String:String]]()
        let scanner = Scanner(string: srt)
        
        while !scanner.isAtEnd{
            _ = scanner.scanUpToCharacters(from: NSCharacterSet.newlines)
            let startString = scanner.scanUpToString(" --> ")
            _ = scanner.scanString("-->")
            let endString = scanner.scanUpToCharacters(from: NSCharacterSet.newlines)
            let textString = scanner.scanUpToCharacters(from: NSCharacterSet.newlines)
            
            var dict = [String:String]()
            dict["startString"] = startString
            dict["endString"] = endString
            dict["textString"] = textString
            
            srtMap.append(dict)
        }
        
        return srtMap
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
