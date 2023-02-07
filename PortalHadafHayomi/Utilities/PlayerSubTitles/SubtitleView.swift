//
//  SubtitleView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 06/02/2023.
//  Copyright © 2023 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class SubtitleView:UIView {
    
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var toggleButton:UIButton!
    @IBOutlet weak var textLabel:UILabel!
    
    
    class func create() -> SubtitleView? {
        let subtitleView = UIView.viewWithNib("SubtitleView") as? SubtitleView
        return subtitleView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.toggleButton.setImageTintColor(UIColor.white)
        self.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.toggleButton.isSelected = true
    }
    
    @IBAction func toggleButtonClicked(_ sender:UIButton){
        toggleButton.isSelected = !toggleButton.isSelected
        
        if toggleButton.isSelected {
            self.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.textLabel.isHidden = false
        }
        else{
            self.contentView.backgroundColor = UIColor.clear
            self.textLabel.isHidden = true
        }
    }
}
