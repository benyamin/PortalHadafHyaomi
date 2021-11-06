//
//  QandATopicTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class QandATopicTableCell: MSBaseTableViewCell {
    
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var iconImageView:UIImageView!
    
    var topic:HadafHayomiProjectTopic!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.topic = object as? HadafHayomiProjectTopic
        
        titleLabel.text = self.topic.title
        iconImageView.image = UIImage(named: self.topic.iconImage)
    }
    
}
