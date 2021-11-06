//
//  SearchArticleResultTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 17/12/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class SearchArticleResultTableCell:MSBaseTableViewCell
{
    var articleSearchResult:ArticleSearchResult?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var publisherLabel:UILabel?
    @IBOutlet weak var masechetLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.articleSearchResult = object as? ArticleSearchResult
        
        self.titleLabel?.text = self.articleSearchResult?.articleTitle ?? ""
        self.publisherLabel?.text = self.articleSearchResult?.publisher?.name ?? ""
        
        if let masechetName = self.articleSearchResult?.masechetName
        , let page = self.articleSearchResult?.page
        {
            self.masechetLabel?.text = "מסכת " + masechetName + " דף " + page
        }
        else{
            self.masechetLabel?.text = ""
        }
    }
    
}
