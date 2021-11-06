//
//  ArticleTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class ArticleTableCell:MSBaseTableViewCell
{
    var article:Article!
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var publisherLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func reloadWithObject(_ object: Any)
    {
        self.article = object as? Article
        
        self.titleLabel.text = self.article.title
        self.publisherLabel.text = self.article.publisher
    }
}
