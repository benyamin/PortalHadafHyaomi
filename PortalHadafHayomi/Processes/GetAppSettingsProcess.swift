//
//  GetAppSettingsProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 7 Adar II 5779.
//  Copyright © 5779 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetAppSettingsProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        // let params = obj as! [String:String]
        var params = [String:String]()
        params["mobilesettings"] = "1"
        params["platformid"] = "1"
        
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
            
            if let settingsInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var settings = [SetableItem]()
                for settingInfo in settingsInfo
                {
                    if let name = settingInfo["name"] as? String
                        ,let value = settingInfo["value"]
                    {
                        let settableItem = SetableItem()
                        settableItem.key = name
                        
                        if value is String
                        {
                            if (value as! String) == "1"
                            {
                                settableItem.value = true
                            }
                            else if (value as! String) == "0"
                            {
                                settableItem.value = false
                            }
                            else{
                               settableItem.value = value
                            }
                        }
                        else{
                            settableItem.value = value
                        }
                        
                        settings.append(settableItem)
                    }
                }
                
                self.onComplete!(settings)
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

