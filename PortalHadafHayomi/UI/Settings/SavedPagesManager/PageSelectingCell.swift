//
//  PageSelectingCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 14/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

protocol PageSelectingCellDelegate {
    
    func pageSelectingCell(_ pageSelectingCell:PageSelectingCell, didSelectNoteOnPage page:Page)
}

class PageSelectingCell: MSBaseCollectionViewCell {
    
    var delegate:PageSelectingCellDelegate?
    
    var page:Page?
        
    @IBOutlet weak var pageLabel:UILabel?
    @IBOutlet weak var checkBoxButton:UIButton?
    @IBOutlet weak var noteButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var checkBoxOffImage = UIImage(named: "Checkbox_off.png")
        checkBoxOffImage = UIImage.imageWithTintColor(checkBoxOffImage!, color: UIColor(HexColor: "781F24"))
        self.checkBoxButton?.setImage(checkBoxOffImage, for: .normal)
        
        var checkBoxOnImage = UIImage(named: "Checkbox_on.png")
        checkBoxOnImage = UIImage.imageWithTintColor(checkBoxOnImage!, color: UIColor(HexColor: "781F24"))
        self.checkBoxButton?.setImage(checkBoxOnImage, for: .selected)
    }
    
    override func reloadWithObject(_ object: Any) {
        self.page = object as? Page
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.pageLabel?.text = self.page?.symbol
        
        self.checkBoxButton?.isSelected = self.page?.isSelected ?? false
        
        if self.page?.note != nil
        {
             self.noteButton?.isHidden = false
        }
        else{
             self.noteButton?.isHidden = true
        }
        
        self.noteButton?.isSelected = self.page?.isMarkedAsLearned ?? false
    }
    
    @IBAction func checkBoxButton(_ sener:UIButton)
    {
        self.page?.isSelected = !(self.page?.isSelected ?? false)
        self.checkBoxButton?.isSelected = self.page?.isSelected ?? false
    }
    
    @IBAction func noteButtonClicked(_ sener:UIButton)
    {
        self.delegate?.pageSelectingCell(self, didSelectNoteOnPage: self.page!)
    }
}
