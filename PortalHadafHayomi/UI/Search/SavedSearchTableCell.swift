//
//  SavedSearchTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SavedSearchTableCell: MSBaseTableViewCell {

    @IBOutlet weak var searchTextLabel:UILabel?
    @IBOutlet weak var searchLocationLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func reloadWithObject(_ object: Any)
    {
        let searchParams = object as! [String:String]
        
        self.searchTextLabel?.text = searchParams["text"]
        
        var searchLoactionText = ""
        if let masechet = HadafHayomiManager.sharedManager.getMasechetById(searchParams["massechet"]!)
        {
            searchLoactionText += "במסכת: " + masechet.name
            
            if let fromPage = searchParams["medaf"]
            {
                if fromPage == ""
                {
                    searchLoactionText += " - " + "כל הדפים"
                }
                else{
                    
                    if let page =  masechet.getPageByIndex(fromPage)
                    {
                        searchLoactionText += " מדף " + page.symbol
                    }
                }
            }
            
            if let toPage = searchParams["addaf"]
            {
                if toPage != ""
                {
                    if let page =  masechet.getPageByIndex(toPage)
                    {
                        searchLoactionText += " עד דף " + page.symbol
                    }
                }
            }
        }
        else{
            searchLoactionText = "בכל המסכתות"
        }
        
        self.searchLocationLabel?.text = searchLoactionText
    }
}
