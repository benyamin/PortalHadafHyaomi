//
//  BTPlayerRateSpeedView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 13/10/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

protocol BTPlayerRateSpeedViewDelegate: class {
    
    func rateSpeedView(_ rateSpeedView:BTPlayerRateSpeedView, valueChanged value:Float)
}

class BTPlayerRateSpeedView: UIView
{
    weak var delegate:BTPlayerRateSpeedViewDelegate?
    
    @IBOutlet weak var backGroundView:UIView?
    @IBOutlet weak var rateSpeedTitleLabel:UILabel?
    @IBOutlet weak var rateSpeedSlider:UISlider?
    @IBOutlet weak var rateSpeedSliderValue:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backGroundView?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
         backGroundView?.layer.borderWidth = 2.0
        
        self.backGroundView?.layer.cornerRadius = 5.0
        
        self.rateSpeedTitleLabel?.text = "st_speed_rate".localize()
        /*
        let snailImage = UIImage(named:"snail_icon.png")
        
        self.rateSpeedSlider?.setThumbImage(snailImage, for: .normal)
        self.rateSpeedSlider?.setThumbImage(snailImage, for: .highlighted)
 */
    }
    
    @IBAction func sliderChanged(_ slider:UISlider)
    {
        self.delegate?.rateSpeedView(self, valueChanged: slider.value)
    }
}
