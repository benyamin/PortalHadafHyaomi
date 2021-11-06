//
//  AccessoryTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class AccessoryTableCell: MSBaseTableViewCell {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var iconImageView:UIImageView!

    var accessory:Accessory!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func reloadWithObject(_ object: Any)
    {
        self.accessory = object as? Accessory
        
        titleLabel.text = self.accessory.title.localize()
        
        if let iconImage = UIImage(named:self.accessory.iconImage) {
            
            self.iconImageView.image = UIImage.imageWithTintColor(iconImage, color: UIColor(HexColor: "faf2dd"))
        }
    }

}
