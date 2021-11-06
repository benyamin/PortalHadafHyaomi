//
//  HomeSideMenuCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class HomeSideMenuCell: MSBaseTableViewCell {

    var menuItem:MenuItem!
    
    @IBOutlet weak var titleLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func reloadWithObject(_ object: Any) {
        self.menuItem = object as? MenuItem
        
       self.titleLabel.text =  menuItem.title.localize()
    }

}
