//
//  SearchSuggestionTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SearchSuggestionTableCell: MSBaseTableViewCell {

    @IBOutlet weak var searchTextLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object: Any)
    {
        let aramicWord = object as! TranslatedWord
        
        self.searchTextLabel?.text = aramicWord.key
    }

}
