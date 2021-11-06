//
//  LessonPickerDefaultCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 16/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class LessonPickerDefaultCell: UIView {

    @IBOutlet weak var titleLabel:UILabel!
    
    func reloadWithtitle(_ title:String, isSelected:Bool)
    {
        self.titleLabel.text = title
        self.titleLabel.textColor = isSelected ?  UIColor(HexColor: "08506E") : UIColor(HexColor: "781F24")
    }
}
