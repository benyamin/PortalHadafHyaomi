//
//  LessonPickerMaggidShiourCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 16/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class LessonPickerMaggidShiourCell: UIView {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subTitleLabel:UILabel!
    @IBOutlet weak var titleLabelLeadingConstriant:NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.semanticContentAttribute = .forceLeftToRight
    }
    
    func reloadWithMaggidShiour(_ maggidShiour:MaggidShiur)
    {
        self.titleLabel.text = maggidShiour.name
        
        var subTitle = maggidShiour.language!
        if maggidShiour.hasSubtitles{
            subTitle += " | \("st_subtitles".localize())"
        }
        self.subTitleLabel.text = subTitle
        
        self.titleLabel.textColor = maggidShiour.hasSavedLessons ?  UIColor(HexColor: "08506E") : UIColor(HexColor: "781F24")
        self.subTitleLabel.textColor = maggidShiour.hasSavedLessons ?  UIColor(HexColor: "08506E") : UIColor(HexColor: "781F24")
    }
}
