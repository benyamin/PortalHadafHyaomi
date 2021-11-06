//
//  SearchTalmudProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 31/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class SearchTalmudProcess: MSBaseProcess
{
    var runningTask: URLSessionDataTask?
    
    var searchText = ""
    
    open override func executeWithObj(_ obj:Any?)
    {
        let params = obj as! [String:String]
        
        self.searchText = params["text"]!
        
        let matching = params["matching"]!
        
         var searchText = ""
        if matching == "true"
        {
            searchText = " " + self.searchText + " "
        }
        else{
             searchText = self.searchText
        }
       
        var baseUrl = "http://daf-yomi.com/DafYomi_Page_Search.aspx?"
        baseUrl += "text=" + searchText
        baseUrl += "&source=" + params["searchInId"]!
        baseUrl += "&massechet=" + params["massechet"]!
        baseUrl += "&medaf=" + params["medaf"]!
        baseUrl += "&addaf=" + params["addaf"]!
        baseUrl += "&page=" + params["dataPageNumber"]!
        
        print ("Serch request: \(baseUrl)")
        
        
        let request = MSRequest()
        request.baseUrl = baseUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        request.serviceName = ""
        request.requiredResponseType = .HTML
        request.httpMethod = GET
        
        self.runWebServiceWithRequest(request, dataPageNumber: Int(params["dataPageNumber"]!)!)
    }
    
    func runWebServiceWithRequest(_ request:MSRequest, dataPageNumber:Int)
    {
        let urlString = request.baseUrl!
        if let url = URL(string: urlString)
        {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            self.runningTask = session.dataTask(with: request) {data, response, error in
                if error != nil {
                    
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        self.onFaile?(urlString, error! as NSError)
                    }
                    return
                }
                
                if data != nil
                {
                    if let responseData = String(data: data!, encoding: String.Encoding.utf8)
                    {
                        let searchResultInfo = self.parseseResultsFromData(responseData)
                        searchResultInfo.dataPageNumber = dataPageNumber
                        
                        DispatchQueue.main.async {
                            self.onComplete!(searchResultInfo)
                        }
                    }
                }
                
            }
            
            self.runningTask?.resume()
        }
        else{
            
            let errorCode = -999
            let userInfo = ["Description": "serverError".localize()]
            let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
            
            DispatchQueue.main.async {
               self.onFaile?(urlString, error as NSError)
            }
        }
    }
    
    func parseseResultsFromData(_ responseData:String) -> SearchResultInfo
    {
        let searchResultInfo = SearchResultInfo()
        
        let tableTags = responseData.components(separatedBy: "</tr>")
        
        let optionTags = self.matches(for: "option value=(.*)>", in: responseData)
        
        if optionTags.count > 0
        {
            if let lastOption = optionTags.last
            {
                if let range = lastOption.range(of: "(?<=>)[^<]+", options: .regularExpression) {
                    let maxPageResutls = lastOption.substring(with: range)
                    
                    if let maxPageNumber = Int(maxPageResutls)
                    {
                         searchResultInfo.numberOfDataPages = maxPageNumber
                    }
                }
            }
        }
        var searchTalmudResults = [SearchTalmudResult]()
        
        for tableTag in tableTags
        {
            let tableLinesTags = self.matches(for: "<(.*)>", in: tableTag)
            
            //If is a line with search result info
            if tableLinesTags.count == 7
            {
                let searchTalmudResult = SearchTalmudResult()
                
                searchTalmudResult.searchText = self.searchText
                
                for tableLineTag in tableLinesTags
                {
                    if tableLineTag.range(of:"tdId") != nil {
                        
                        searchTalmudResult.pageId = tableLineTag.slice(from: ">", to: "<")
                    }
                    else if tableLineTag.range(of:"tdPage") != nil {
                        
                         searchTalmudResult.page = tableLineTag.slice(from: ">", to: "<")
                    }
                        
                    else if tableLineTag.range(of:"tdSource") != nil {
                        
                        if var source = tableLineTag.slice(from: ">", to: "<")
                        {
                            source = source.replacingOccurrences(of: "&quot;", with: "׳׳")
                            searchTalmudResult.source = source
                        }
                    }
                        
                    else if tableLineTag.range(of:"tdText") != nil {
                        
                        if tableLineTag.range(of:"tdText_1") != nil
                        {
                            searchTalmudResult.isMatching = false
                        }
                        else{
                            searchTalmudResult.isMatching = true
                        }
                    }
                    
                }
                
                if tableTag.range(of: "href(.*)/a", options: .regularExpression) != nil
                {
                    if let pageLinkRange = tableTag.range(of: "(?<=href=\\\")[^\\\"]+", options: .regularExpression) {
                        
                        searchTalmudResult.link = tableTag.substring(with: pageLinkRange)
                    }
                    
                    if let title = tableTag.slice(from: "title=", to: "</a")
                    {
                        let textComponents = self.matches(for: "(?<=>)[^<]+", in: title)
                        
                        var text = ""
                        
                        for textcompoenet in textComponents
                        {
                            text += textcompoenet
                        }
                        
                        searchTalmudResult.text = text.replacingOccurrences(of: "&#39;", with: "'")
                    }
                }
                
                searchTalmudResults.append(searchTalmudResult)
            }
        }
        
        searchResultInfo.searchResults = searchTalmudResults
        
        return searchResultInfo
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    override open func cancel()
    {
        super.cancel()
        
        self.runningTask?.cancel()
    }
}



