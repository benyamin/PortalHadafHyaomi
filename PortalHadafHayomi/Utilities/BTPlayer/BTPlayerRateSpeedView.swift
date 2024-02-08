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
    @IBOutlet weak var rightRateLabel:UILabel?
    @IBOutlet weak var leftRateLabel:UILabel?
    @IBOutlet var rateButtonsCollectoion:[UIButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backGroundView?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
         backGroundView?.layer.borderWidth = 2.0
        
        self.backGroundView?.layer.cornerRadius = 5.0
        
        self.rateSpeedTitleLabel?.text = "st_speed_rate".localize()
        
        if let currentLanguage = Locale.current.languageCode
            ,currentLanguage.hasSuffix("he"){
            //self.rateSpeedSlider?.semanticContentAttribute = .forceRightToLeft
            self.rateSpeedSlider?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

            //self.rightRateLabel?.text = "x0.5"
           // self.leftRateLabel?.text = "x2.0"
        }
        
        for button in self.rateButtonsCollectoion{
            button.layer.borderColor = UIColor(HexColor: "FFDB77").cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 3
        }
        /*
        let snailImage = UIImage(named:"snail_icon.png")
        
        self.rateSpeedSlider?.setThumbImage(snailImage, for: .normal)
        self.rateSpeedSlider?.setThumbImage(snailImage, for: .highlighted)
 */
    }
    
    func setValue(_ value: Float, animated: Bool) {
        
        self.rateSpeedTitleLabel?.text = "\("st_speed_rate".localize()) \(String(format: "%.1f",  value))"
        
        self.rateSpeedSlider?.setValue(value, animated: animated)
    }
    
    @IBAction func sliderChanged(_ slider:UISlider)
    {
        self.setRateValue(value: slider.value)
    }
    
    @IBAction func rateButtonClicked(_ button:UIButton){
        let value = Float(button.tag)/100.0
        self.rateSpeedSlider?.value = value
        self.setRateValue(value: value)
    }
    
    func setRateValue(value:Float){
        self.rateSpeedTitleLabel?.text = "\("st_speed_rate".localize()) \(String(format: "%.1f", value))"

        self.delegate?.rateSpeedView(self, valueChanged: value)
    }
}
