//
//  ArticleSearchResult.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/12/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class ArticleSearchResult:DataObject
{
    var ct:String?
    var categoryName:String?
    var publisher:Publisher?
    var articleTitle:String?
    var articleUrlPath:String?
    var masechetName:String?
    var page:String?
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.ct = dictionary["ct"] as? String
        self.categoryName = dictionary["c"] as? String
        
        if let masechetName = dictionary["m"] as? String
        {
            if masechetName.hasPrefix("&") == false
            {
                self.masechetName = masechetName
            }
        }
        
        if let page = dictionary["d"] as? String
        {
            if page.hasPrefix("&") == false
            {
                 self.page = page
            }
        }
        
        if let publisherInfo = dictionary["p"] as? String
        {
            self.publisher = Publisher()
            self.publisher?.id  = publisherInfo.slice(from: "pid=", to: "\"")
            self.publisher?.name  = publisherInfo.slice(from: ">", to: "</a>")
            
            if self.publisher?.name == nil
            {
                self.publisher?.name = publisherInfo
            }
        }
        
        if let articaleInfo = dictionary["t"] as? String
        {
            self.articleTitle = articaleInfo.slice(from: ">", to: "</a>")
            
            if let link =  articaleInfo.slice(from: "href=\"", to: "\">")
            {
                 var fullPath = ""
                if link.hasPrefix("http") == false
                {
                    fullPath = "http://daf-yomi.com"
                    if link.hasPrefix("/") == false
                    {
                        fullPath += "/"
                    }
                    fullPath += link
                }
                else{
                    fullPath = link
                }
          
                
                self.articleUrlPath = fullPath.stringByReplacingFirstOccurrenceOfString(target: "DYItemDetails.aspx?itemId", withString: "mobile/DYItem.aspx?itemId")
            }
        }
        
    }
}
