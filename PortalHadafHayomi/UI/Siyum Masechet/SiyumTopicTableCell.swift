//
//  HadafHayomiProjectTopicTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SiyumTopicTableCell: MSBaseTableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var iconImageView:UIImageView?
    
    var topic:SiyumTopic!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.topic = object as? SiyumTopic
        
        titleLabel.text = self.topic.title
        
        iconImageView?.image = UIImage(named:" star_icon.png")

        /*
        if let topicImage = UIImage(named:self.topic.iconImage)
        {
            iconImageView.image = topicImage
        }
        else{
            iconImageView.image = UIImage(named:" star_icon.png")

        }
 */
    }
    
}
