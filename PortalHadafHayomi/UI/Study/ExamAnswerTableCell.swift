//
//  ExamAnswerTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ExamAnswerTableCell: MSBaseTableViewCell {

    var answer:ExamAnswer?
    
    @IBOutlet weak var checkBoxButton:UIButton?
    @IBOutlet weak var descriptionLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.checkBoxButton?.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.checkBoxButton?.isSelected = selected
    }
    
    override func reloadWithObject(_ object: Any) {
        self.answer = object as? ExamAnswer
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.checkBoxButton?.isSelected = self.answer?.isSelected ?? false
        self.descriptionLabel?.text = self.answer?.Adescription
    }
}
