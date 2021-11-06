//
//  GetLessonVenuesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 18/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetLessonVenuesProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        // let params = obj as! [String:String]
        var params = [String:String]()
        params["lesson"] = "1"
        
        let request = MSRequest()
        request.baseUrl = "https://daf-yomi.com/mobile" 
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
            
            if let lessonVenuesInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var lessonVenues = [LessonVenue]()
                
                for lessonVenueInfo in lessonVenuesInfo
                {
                    let lessonVenue = LessonVenue(dictionary: lessonVenueInfo)
                    lessonVenues.append(lessonVenue)
                }
                
                self.onComplete!(lessonVenues)
            }
                
            else{
                if error == nil
                {
                    self.onComplete!(responseDctinoary)
                }
                else {
                    self.onFaile!(responseDctinoary, error!)
                }
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile!(object, error)
            
        })
    }
}
