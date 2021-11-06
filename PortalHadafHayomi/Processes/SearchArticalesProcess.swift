//
//  SearchArticalesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 08/12/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class SearchArticalesProcess: MSBaseProcess
{
    var request:MSRequest?
    
    open override func executeWithObj(_ obj:Any?)
    {
        var searchInfo = obj as! [String:String]
        
        var massechetIndex = ""
        if let massechetID = searchInfo["massechet"]
        {
            if let index =  Int(massechetID)
            {
                 massechetIndex = ("\(282 + index)")
            }
           
        }
       // https://daf-yomi.com/AjaxHandler.ashx?searchlist=1&dir=1&massechet=322&sort=iorder&page=1&category=9&term=%D7%90%D7%91%D7%99%D7%99&titleonly=0&pagesize=50
        
        //https://daf-yomi.com/AjaxHandler.ashx?searchlist=1&page=1&massechet=322&medaf=2&addaf=73&publisher=&category=9&titleonly=0&term=&sort=iorder&dir=1
        
        var params = [String:Any]()
        params["searchlist"] = "1"
        params["page"] = searchInfo["dataPageNumber"]
        params["massechet"] = massechetIndex
        params["medaf"] = searchInfo["medaf"]
        params["addaf"] = searchInfo["addaf"]
        params["publisher"] = searchInfo["selectedPublisherId"]
        params["category"] = searchInfo["selectedCategoryId"]
        params["titleonly"] = searchInfo["titleOnly"]
        params["term"] = searchInfo["text"]
        params["sort"] = "iorder"
        params["dir"] = "1"
        params["pagesize"] = "50"
        
        self.request = MSRequest()
     
        request?.baseUrl = "https://daf-yomi.com"
        request?.serviceName = "AjaxHandler.ashx"
        request?.requiredResponseType = .JSON
        request?.httpMethod = GET
        request?.params = params
    
        if let dataPageNumber = Int(searchInfo["dataPageNumber"]!)
        {
            self.runWebServiceWithRequest(request!, dataPageNumber:dataPageNumber)
        }
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest, dataPageNumber:Int)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            self.request = nil
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if let JsonResponse = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var articleSearchResults = [ArticleSearchResult]()
                for resultinfo in JsonResponse
                {
                    let articleSearchResult = ArticleSearchResult.init(dictionary: resultinfo)
                    if articleSearchResult.articleTitle != nil
                    {
                        articleSearchResults.append(articleSearchResult)
                    }
                }
                
                let searchResultInfo = SearchResultInfo()
                searchResultInfo.dataPageNumber = dataPageNumber
                searchResultInfo.searchResults = articleSearchResults
                self.onComplete?(searchResultInfo)
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
            
            self.request = nil
            
            self.onFaile?(object, error)
        })
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

