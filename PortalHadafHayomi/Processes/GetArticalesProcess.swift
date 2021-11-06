//
//  GetArticalesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 17/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetArticalesProcess: MSBaseProcess
{    
    open override func executeWithObj(_ obj:Any?)
    {
        let requiredArticalesInfo = obj as! [String:Any]
        let requiredMasechet = requiredArticalesInfo["masechet"] as! Masechet
        let requiredPage = requiredArticalesInfo["page"] as! Page
        
        var masechetId = Int(requiredMasechet.id!)!
        
        if masechetId == 40 //נידה
        {
            masechetId = 37
        }
        
        let pageIndex = requiredPage.index

        
       // let params = obj as! [String:String]
        var params = [String:String]()
        params["itemsort"] = "1"
        params["massechet"] = "\(masechetId)"
        params["pn"] = "\(pageIndex! + 1)"
        
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
            
            if let articlesInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
            {
                var articlesCategorys = [ArticleCategory]()
                
                for articleInfo in articlesInfo
                {
                    let article = Article(dictionary: articleInfo)
                    
                    //Do not add this article
                    if article.title == "ספריית שיעורי דף יומי"
                    {
                        continue
                    }
                    //check if the category for the articale dos exsist in the articlesCategorysarray
                    if let i = articlesCategorys.index(where: {$0.id! == article.category})
                    {
                        let articleCategory = articlesCategorys[i]
                        articleCategory.articles.append(article)
                    }
                    else // Create new Category
                    {
                        for articleCategory in ArticlesManager.sharedManager.allArticlesCategoryOptions
                        {
                            if articleCategory.id == article.category
                            {
                                let newArticleCategory = ArticleCategory()
                                newArticleCategory.id = articleCategory.id
                                newArticleCategory.title = articleCategory.title
                                newArticleCategory.iconImage = articleCategory.iconImage
                                newArticleCategory.articles.append(article)

                                articlesCategorys.append(newArticleCategory)
                                
                                break
                            }
                        }
                    }
                }
                
               let sortedArticlesCategorys = articlesCategorys.sorted(by: { $0.id < $1.id })

                self.onComplete?(sortedArticlesCategorys)

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
