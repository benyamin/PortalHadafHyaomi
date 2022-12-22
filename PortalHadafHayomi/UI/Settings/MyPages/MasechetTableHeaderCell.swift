//
//  MasechetTableHeaderCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/03/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MasechetTableHeaderCell: MSBaseTableViewCell {

    var masechet:Masechet?
    var onToggleButtonClicked:(() -> Void)?
    
    @IBOutlet weak var masechetNameLabel:UILabel?
    @IBOutlet weak var toggleButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reloadData()
    }

    override func reloadWithObject(_ object: Any)
    {
        self.masechet = object as? Masechet
     
        self.reloadData()
    }
    
    override func reloadData() {
        self.masechetNameLabel?.text = self.masechet?.name
    }
    
    @IBAction func toggleButtonClicked(_ sender:UIButton){
        
        self.toggleButton.isEnabled = false
        
        self.toggleButton.isSelected = !self.toggleButton.isSelected
        self.toggleButton.transform = self.toggleButton.isSelected ? CGAffineTransform(rotationAngle: CGFloat(Double.pi/2)) : .identity
        
        self.onToggleButtonClicked?()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.toggleButton?.isEnabled = true
        }
    }
}
