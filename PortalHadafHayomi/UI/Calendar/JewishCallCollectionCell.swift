//
//  JewishCallCollectionCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 27/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class JewishCallCollectionCell: MSBaseCollectionViewCell
{
    @IBOutlet weak var mainDateLabel:UILabel!
    @IBOutlet weak var secondaryDateLabel:UILabel!
    @IBOutlet weak var pageLabel:UILabel!
    @IBOutlet weak var stripeImageView:UIImageView!
    @IBOutlet weak var backGroundImageView:UIImageView!
    
    var date:Date!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        self.setLocalizatoin()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.date = object as? Date
                
        let markAsLearned = self.date.isMarkedAsLearned() ? true : false
        let hasSavedInformation = self.date.hasSavedInformation()
        
         self.stripeImageView.isHidden = false
        if markAsLearned == true && hasSavedInformation == true
        {
            self.stripeImageView.image = UIImage(named: "Strip_With_Dot3.png")
        }
        else if markAsLearned == true && hasSavedInformation == false
        {
            self.stripeImageView.image = UIImage(named: "Strip3.png")
        }
        else if markAsLearned == false && hasSavedInformation == true
        {
            self.stripeImageView.image = UIImage(named: "Dot3.png")
        }
        else if markAsLearned == false && hasSavedInformation == false
        {
           self.stripeImageView.isHidden = true
        }
        
        if self.date.isToday(){
            print ("")
        }
        
        if let masechet = HadafHayomiManager.sharedManager.maschetForDate(self.date)
            , let page = HadafHayomiManager.sharedManager.pageForDate(self.date, addOnePage:true)
        {
            
            let masechetName = HadafHayomiManager.sharedManager.getMasechetNameforMasechet(masechet, page: page)
            self.pageLabel.text = "\(masechetName)\nדף \(page.symbol!)"
        }
      
        self.backGroundImageView.image = self.isSelected ? UIImage(named: "boxShadow.png") :  UIImage(named: "kal_tile.png")
        
    }
    
    override func reloadInputViews() {
        super.reloadInputViews()
        
          self.backGroundImageView.image = self.isSelected ? UIImage(named: "boxShadow.png") :  UIImage(named: "kal_tile.png")
    }
    
    func setEnabledLayout()
    {
        self.backgroundColor = UIColor(HexColor: "DCDCDC")
        
        self.isUserInteractionEnabled = true
        
        self.mainDateLabel.isHidden = false
        self.secondaryDateLabel.isHidden = false
        self.pageLabel.isHidden = false
        
        if self.date.isMarkedAsLearned()
        {
            self.stripeImageView.isHidden = false
        }
        
        self.alpha = 1.0
    }
    
    func setDisabledLayout()
    {
        self.isUserInteractionEnabled = false
        
        self.mainDateLabel.isHidden = true
        self.secondaryDateLabel.isHidden = true
        self.pageLabel.isHidden = true
        self.stripeImageView.isHidden = true
        
         self.alpha = 0.6
    }
}
