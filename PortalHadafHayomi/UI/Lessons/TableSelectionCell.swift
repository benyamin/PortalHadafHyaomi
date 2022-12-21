//
//  TableSelectionCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 21/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TableSelectionCell: MSBaseTableViewCell {

    var onSelectioinChanged:((_ selected:Bool) -> Void)?
    
    @IBOutlet weak var checkBoxButton:UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func reloadWithObject(_ object: Any) {
        
        let userInfo = object as! (title:String, isSelected:Bool)
        self.titleLabel.text = userInfo.title
        self.checkBoxButton.isSelected = userInfo.isSelected
    }
    
    @IBAction func checkBoxButtonClicked(_ sener:UIButton)
    {
        self.checkBoxButton.isSelected = !self.checkBoxButton.isSelected
        self.onSelectioinChanged?(self.checkBoxButton.isSelected)
    }
}
