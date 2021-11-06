//
//  LessonSelectionCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class LessonSelectionCell: MSBaseTableViewCell {

    var lesson:Lesson?
    
    @IBOutlet weak var lessonDescriptionLabel:UILabel?
     @IBOutlet weak var checkBoxButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var checkBoxOffImage = UIImage(named: "Checkbox_off.png")
        checkBoxOffImage = UIImage.imageWithTintColor(checkBoxOffImage!, color: UIColor(HexColor: "781F24"))
        self.checkBoxButton?.setImage(checkBoxOffImage, for: .normal)
        
        var checkBoxOnImage = UIImage(named: "Checkbox_on.png")
        checkBoxOnImage = UIImage.imageWithTintColor(checkBoxOnImage!, color: UIColor(HexColor: "781F24"))
        self.checkBoxButton?.setImage(checkBoxOnImage, for: .selected)
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.lesson = object as? Lesson
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        if let page = self.lesson?.page
        {
            self.lessonDescriptionLabel?.text =  "דף " + page.symbol + " - ֿ\(self.lesson!.maggidShiur.name!)"
            
             self.checkBoxButton?.isSelected = self.lesson?.isSelected ?? false
        }
    }
    
    @IBAction func checkBoxButtonClicked(_ sener:UIButton)
    {
        self.lesson?.isSelected = !(self.checkBoxButton?.isSelected ?? true)
        
        self.checkBoxButton?.isSelected =  self.lesson!.isSelected
    }
}
