//
//  CategoryTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class CategoryTableCell: MSBaseTableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var iconImageView:UIImageView!
    
    var category:Category!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.category = object as? Category
        
        titleLabel.text = "st_\(self.category.title!)".localize()
        iconImageView.image = UIImage(named:self.category.iconImage)
    }
    
}
