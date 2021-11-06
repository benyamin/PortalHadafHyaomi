//
//  ArticlesManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/12/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class ArticlesManager
{
    static let sharedManager =  ArticlesManager()
    
    var publishers:[Publisher]?
    
    lazy var allArticlesCategoryOptions:[ArticleCategory] = {
        
        var articlesCategorys = [ArticleCategory]()
        articlesCategorys.append(ArticleCategory(id: "1", title: "learn_and_understand", iconImage: "Lilmod_icon_ios.png"))
        articlesCategorys.append(ArticleCategory(id: "2", title: "deepen", iconImage: "leaamik_icon_ios.png"))
        articlesCategorys.append(ArticleCategory(id: "3", title: "sharpen", iconImage: "lehaded_icon_ios.png"))
        articlesCategorys.append(ArticleCategory(id: "4", title: "expand", iconImage: "Learchiv_icon_ios.png"))
        articlesCategorys.append(ArticleCategory(id: "5", title: "page_articles", iconImage: "Maamarim_icon_ios.png"))
        articlesCategorys.append(ArticleCategory(id: "6", title: "recommended_books", iconImage: "Books_icon_ios.png"))
        
        return articlesCategorys
    }()
}

