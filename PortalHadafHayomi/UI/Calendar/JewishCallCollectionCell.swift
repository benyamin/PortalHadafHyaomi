//
//  JewishCallCollectionCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 27/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class JewishCallCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var mainDateLabel:UILabel!
    @IBOutlet weak var secondaryDateLabel:UILabel!
    @IBOutlet weak var pageLabel:UILabel!
    @IBOutlet weak var stripeImageView:UIImageView!
    @IBOutlet weak var backGroundImageView:UIImageView!
    @IBOutlet weak var noteImageView:UIImageView!
    
    var date:Date?
    var isSelectedDate = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        self.setLocalizatoin()
    }
    
    func reloadWithObject(_ object: Any?)
    {
        if let date = object as? Date {
            self.date = date
            self.reloadData()
        }
        else{
            self.date = nil
            self.backgroundColor = .white
            self.contentView.isHidden = true
        }
    }
    
   func reloadData() {
       
       guard let date = self.date else {return;}
       
       self.backgroundColor = UIColor(HexColor: "DCDCDC")
       self.contentView.isHidden = false
       
       self.mainDateLabel.textColor = UIColor(HexColor: "6A2423")
       self.secondaryDateLabel.textColor = UIColor(HexColor: "6A2423")
       self.pageLabel.textColor = UIColor(HexColor: "6A2423")
       
       if self.isUserInteractionEnabled == false {
           self.backgroundColor = UIColor(HexColor: "DCDCDC66")
       }
       else {
           if date.isToday() {
               self.backgroundColor = UIColor(HexColor: "F9F3DB")
           }
           else if self.isSelectedDate
           {
               self.backgroundColor = UIColor(HexColor: "6A2423")
               
               self.mainDateLabel.textColor = UIColor(HexColor: "F9F3DB")
               self.secondaryDateLabel.textColor = UIColor(HexColor: "F9F3DB")
               self.pageLabel.textColor = UIColor(HexColor: "F9F3DB")
           }
           else{
               self.backgroundColor = UIColor(HexColor: "DCDCDC")
           }
       }
       
       let status = date.status()
       self.noteImageView.isHidden = !date.hasSavedInformation()
       
       if status == "none"{
           self.stripeImageView.isHidden = true
       }
       else if status == "learned"{
           self.stripeImageView.isHidden = false
           self.stripeImageView.image = UIImage(named: "Strip_L.png")
       }
       else if status == "notLearned"{
           self.stripeImageView.isHidden = false
           self.stripeImageView.image = UIImage(named: "Strip_Red_L")
       }
       else if status == "hafhLearned"{
           self.stripeImageView.isHidden = false
           self.stripeImageView.image = UIImage(named: "Strip_RG_L")
       }
       
       if date.isToday(){
           print ("")
       }
       
       if let masechet = HadafHayomiManager.sharedManager.maschetForDate(date)
            , let page = HadafHayomiManager.sharedManager.pageForDate(date, addOnePage:true)
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
        
        self.isUserInteractionEnabled = true
        
        self.mainDateLabel.isHidden = false
        self.secondaryDateLabel.isHidden = false
        self.pageLabel.isHidden = false
        
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
