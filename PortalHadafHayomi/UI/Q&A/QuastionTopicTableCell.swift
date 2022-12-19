//
//  QuastionTopicTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 27/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class QuastionTopicTableCell: MSBaseTableViewCell {

    var expression:Expression?
    
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var quastionTopicLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView?.backgroundColor = UIColor(HexColor: "FAF2DD")
        self.cardView?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        self.cardView?.layer.borderWidth = 1
        self.cardView?.layer.cornerRadius = 3
        
        self.quastionTopicLabel?.textColor = UIColor(HexColor:"6A2423")
       
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.expression = object as? Expression
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        if let expressionValue = self.expression?.key
        {
            self.quastionTopicLabel?.text = expressionValue
        }
    }

}
