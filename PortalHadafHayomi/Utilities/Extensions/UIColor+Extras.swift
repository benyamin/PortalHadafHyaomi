//
//  UIColor+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/7/15.
//  Copyright © 2015 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor
{    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(HexColor:String) {
        let hexString:String = HexColor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as String
        let scanner            = Scanner(string: HexColor)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
                
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        var alpha = CGFloat(1.0)
        if hexString.count == 8 //The hex string includes alpha
        {
            let index = hexString.index(hexString.startIndex, offsetBy: 2)
            let a = Float(hexString.substring(to: index))!
            
            if a == 10{
                alpha = 1.0
            }
            else{
                alpha = CGFloat(a/10.0)
            }
        }
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
