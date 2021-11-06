//
//  MasechetSelectionCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MasechetSelectionCell: MSBaseTableViewCell {

    var masechet:Masechet?
    @IBOutlet weak var checkBoxButton:UIButton?
    
    @IBOutlet weak var titleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var checkBoxOffImage = UIImage(named: "Checkbox_off.png")
        checkBoxOffImage = UIImage.imageWithTintColor(checkBoxOffImage!, color: UIColor(HexColor: "FAF2DD"))
        self.checkBoxButton?.setImage(checkBoxOffImage, for: .normal)
        
        var checkBoxOnImage = UIImage(named: "Checkbox_on.png")
        checkBoxOnImage = UIImage.imageWithTintColor(checkBoxOnImage!, color: UIColor(HexColor: "FAF2DD"))
        self.checkBoxButton?.setImage(checkBoxOnImage, for: .selected)
    }

    override func reloadWithObject(_ object: Any)
    {
        self.masechet = object as? Masechet
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.titleLabel?.text = self.masechet?.name
        
       self.setCheckBoxButtonState()
       
    }
    
    func setCheckBoxButtonState()
    {
        self.checkBoxButton?.isSelected = false
        
        if let savedLessons = self.masechet?.savedLessons
        {
            for lesson in savedLessons
            {
                if lesson.isSelected == false{
                    return
                }
            }
        }
        
        //All lessons are selected
        self.checkBoxButton?.isSelected = true
    }
    
    @IBAction func checkBoxButtonClicked(_ sener:UIButton)
    {
        self.checkBoxButton?.isSelected = !(self.checkBoxButton?.isSelected ?? true)
        
        if self.masechet?.savedLessons != nil
        {
            for lesson in  self.masechet!.savedLessons!
            {
                lesson.isSelected = self.checkBoxButton?.isSelected ?? false
            }
        }
        
        self.tableView?.reloadData()
    }
}
