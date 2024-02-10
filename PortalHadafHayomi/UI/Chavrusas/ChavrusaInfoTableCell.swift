//
//  ChavrusaInfoTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol ChavrusaInfoTableCellDelegate: class
{
       func chavrusaInfoTableCell(_ chavrusaInfoTableCell:ChavrusaInfoTableCell, onContactChavrusa chavrusa:Chavrusa?)
}

class ChavrusaInfoTableCell: MSBaseTableViewCell {

    weak var delegate:ChavrusaInfoTableCellDelegate?
    
    var chavrusa:Chavrusa?
    
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var dateLabel:UILabel?
    @IBOutlet weak var locationLabel:UILabel?
    @IBOutlet weak var messagTextView:UITextView?
    @IBOutlet weak var selectButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       // self.messagTextView?.contentInset = UIEdgeInsetsMake(0,0,0,0);
       // self.messagTextView?.textContainerInset = UIEdgeInsets.zero
        self.messagTextView?.textContainerInset =  UIEdgeInsets(top: 0,left: 0,bottom: -25,right: 0)
        self.messagTextView?.textContainer.lineFragmentPadding = 0
        
        self.selectButton?.layer.borderWidth = 1.0
        self.selectButton?.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        self.selectButton?.layer.cornerRadius = 3.0
        
        self.selectButton?.setTitle("st_connect_button".localize(), for: .normal)
    }

    override func reloadWithObject(_ object: Any) {
        
        self.chavrusa = object as? Chavrusa
        
        self.nameLabel?.text = chavrusa?.fullName
        self.dateLabel?.text = chavrusa?.dateDisplay
        
        var locatoin = chavrusa?.regionName ?? ""
        locatoin += " - "
        locatoin +=  chavrusa?.cityName ?? ""
        self.locationLabel?.text = locatoin
        
        
        if var messageValue = self.chavrusa?.text
        {
            messageValue = "<!DOCTYPE html><html dir=\"rtl\" lang=\"ar\"><head><meta charset=\"utf-8\"><font size=\"4.5\">" + messageValue + "</font>"
            self.messagTextView?.attributedText = messageValue.htmlAttributedString()
        }
        else{
            self.messagTextView?.text = ""
        }
    }
    
    @IBAction func selectButtonClicked(_ sender:UIButton)
    {
        self.delegate?.chavrusaInfoTableCell(self, onContactChavrusa: self.chavrusa)
    }

}
