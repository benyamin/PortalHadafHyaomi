//
//  HomeBottomBarCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 28/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class HomeBottomBarCell: MSBaseCollectionViewCell {
    
    var menuItem:MenuItem?
    
    @IBOutlet weak var itemImageView:UIImageView?
    @IBOutlet weak var itemImageLabel:UILabel?
    @IBOutlet weak var itemTitleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object:Any){
        
        self.menuItem = object as? MenuItem
        
        self.reloadData()
    }
    
    override func reloadData(){
        
        if let menuItem = self.menuItem
        {
            self.itemTitleLabel?.text =  menuItem.title.localize()
            
            if menuItem.name == "Calendar"
            {
                itemImageLabel?.isHidden = false
                itemImageLabel?.text = Calendar.hebrew.dayDisaplyName(from: Date(), forLocal: "he_IL")
            }
            else{
                itemImageLabel?.isHidden = true
            }
            
            self.setSelected(false)
        }
    }
    
    func setSelected(_ selected:Bool)
    {
        let defaultColor = UIColor(HexColor: "791F23")
        let selectedColor = UIColor(HexColor: "FAF2DD")
        
        self.backgroundColor = selected ? selectedColor : defaultColor
        let defaultImage = UIImage(named: self.menuItem!.imageName)
        self.itemImageView!.image = UIImage.imageWithTintColor(defaultImage!, color: selected ? defaultColor : selectedColor)

        self.itemTitleLabel?.textColor = selected ? defaultColor : selectedColor
    }
    
}
