//
//  SurveyTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 19/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SurveyTableCell: MSBaseTableViewCell {

    var survey:Survey?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var votersLabel:UILabel?
    @IBOutlet weak var arrowImageView:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let arrowImage = UIImage(named: "arrowLeft.png")
        let tintableArrowImage = UIImage.imageWithTintColor(arrowImage!, color: UIColor(HexColor: "781F24"))
        self.arrowImageView?.image = tintableArrowImage

    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.survey = object as? Survey
        
        self.titleLabel?.text = survey?.title
        
        if let voters = self.survey?.voters
        {
             self.votersLabel?.text = "(" + voters + ")"
        }
        else{
            self.votersLabel?.text = ""
        }
       
    }
}
