//
//  MasechetTableHeaderCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/03/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MasechetTableHeaderCell: MSBaseTableViewCell {

    var masechet:Masechet?
    
     @IBOutlet weak var masechetNameLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reloadData()
    }

    override func reloadWithObject(_ object: Any)
    {
        self.masechet = object as? Masechet
     
        self.reloadData()
    }
    
    override func reloadData() {
        self.masechetNameLabel?.text = self.masechet?.name

    }

}
