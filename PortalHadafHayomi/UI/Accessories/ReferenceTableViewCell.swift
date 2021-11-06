//
//  ReferenceTableViewCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/11/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ReferenceTableViewCell: MSBaseTableViewCell {

    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        /*
        self.cardView?.backgroundColor = UIColor(HexColor: "FAF2DD")
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        
        self.cardView?.semanticContentAttribute = .forceLeftToRight
        
        self.titleLabel?.textColor = UIColor(HexColor:"6A2423")
        self.subTitleLabel?.textColor = UIColor(HexColor:"6A2423")
 */
    }
    
    override func reloadWithObject(_ object: Any)
    {
        if let linkInfo = object as? LinkInfo
        {
            if let title = linkInfo.title
            {
              self.titleLabel?.text = title.localize()
            }
            
            if let subTitle = linkInfo.subTitle
            {
                self.subTitleLabel?.text = subTitle.localize()
            }
        }
    }
}
