//
//  HomeMenuItemCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 28/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class HomeMenuItemCell: MSBaseCollectionViewCell {

    var menuItem:MenuItem?
    
    @IBOutlet weak var itemImageView:UIImageView?
    @IBOutlet weak var itemImageLabel:UILabel?
    @IBOutlet weak var itemTitleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func reloadWithObject(_ object:Any){
        
        self.menuItem = object as? MenuItem
        
        self.reloadData()
    }
    
    override func reloadData(){
        
        if let menuItem = self.menuItem
        {
            self.itemImageView?.image = UIImage(named: menuItem.imageName)
            self.itemTitleLabel?.text =  menuItem.title.localize()
            
            if menuItem.name == "Calendar"
            {
                itemImageLabel?.isHidden = false
                itemImageLabel?.text = Calendar.hebrew.dayDisaplyName(from: Date(), forLocal: "he_IL")
            }
            else{
                itemImageLabel?.isHidden = true
            }
        }
    }
}
