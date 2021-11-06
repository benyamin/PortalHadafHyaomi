//
//  GetRegionsProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetRegionsProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        // let params = obj as! [String:String]
        var params = [String:String]()
        params["regions"] = "1"
        
        let request = MSRequest()
        request.baseUrl = "http://daf-yomi.com/mobile"
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
            
            if let regionsInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var regions = [Region]()
                
                let allRegions = Region()
                allRegions.ID = -1
                allRegions.sRegionName = "st_all_countries".localize()
                regions.append(allRegions)
                
                for regionInfo in regionsInfo
                {
                    let region = Region(dictionary: regionInfo)
                    regions.append(region)
                }
                
                //Get all cities and sort them by region
                GetCitiesProcess().executeWithObject(nil, onStart: { () -> Void in
                    
                }, onComplete: { (object) -> Void in
                    
                    let cities = object as! [City]
                    
                    for city in cities
                    {
                        //Add all cities to the All regions object
                        allRegions.cities.append(city)
                        
                        for region in regions
                        {
                            if city.RegionID == region.ID
                            {
                                region.cities.append(city)
                                break
                            }
                        }
                    }
                    
                    self.onComplete!(regions)
                    
                },onFaile: { (object, error) -> Void in
                    
                    self.onFaile!(responseDctinoary as NSObject?, error)
                    
                })
            }
                
            else{
                if error == nil
                {
                    self.onComplete?(responseDctinoary)
                }
                else {
                    self.onFaile?(responseDctinoary as NSObject?, error!)
                }
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile!(object, error)
            
        })
    }
}
