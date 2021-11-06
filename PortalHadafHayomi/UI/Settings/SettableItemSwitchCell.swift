//
//  SettableItemSwitchCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 02/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SettableItemSwitchCell: SettableItemCell
{
    @IBOutlet weak var switchValue:UISwitch?
    
    override func reloadData()
    {
        self.infoButton?.isHidden = (self.setableItem?.infoUrlPath == nil)

        if let title = self.setableItem?.title
        {
            self.titleLabel?.text = ("st_" + title).localize()
            self.descriptionLabel?.text = ("st_" + title + "_description").localize()
        }
        
        self.switchValue?.isOn = self.setableItem?.value as? Bool ?? false
    }
    
    @IBAction func switchValueChanged(_ sender:UISwitch)
    {
        self.setableItem?.setValue(sender.isOn)
        
        //If the item is SpeechActivatoin the switch button will remain off if the user did not otharize speech
        if self.setableItem?.key == "SpeechActivatoin"
           , let value = self.setableItem?.value as? Bool
        {
            sender.isOn = value
        }
        
        if self.setableItem?.key == "AutoLock"
        {
            UIApplication.shared.isIdleTimerDisabled = self.setableItem?.value as? Bool ?? true
        }
    }
}
