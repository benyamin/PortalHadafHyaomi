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
        
        var cleanString = HexColor.replacingOccurrences(of: "#", with: "")
               if cleanString.count == 3 {
                   cleanString = "\(cleanString[cleanString.index(cleanString.startIndex, offsetBy: 0)])\(cleanString[cleanString.index(cleanString.startIndex, offsetBy: 0)])\(cleanString[cleanString.index(cleanString.startIndex, offsetBy: 1)])\(cleanString[cleanString.index(cleanString.startIndex, offsetBy: 1)])\(cleanString[cleanString.index(cleanString.startIndex, offsetBy: 2)])\(cleanString[cleanString.index(cleanString.startIndex, offsetBy: 2)])"
               }
               if cleanString.count == 6 {
                   cleanString += "ff"
               }
               
               var baseValue: UInt64 = 0
               Scanner(string: cleanString).scanHexInt64(&baseValue)
               
               let red = CGFloat((baseValue >> 24) & 0xFF) / 255.0
               let green = CGFloat((baseValue >> 16) & 0xFF) / 255.0
               let blue = CGFloat((baseValue >> 8) & 0xFF) / 255.0
               let alpha = CGFloat((baseValue >> 0) & 0xFF) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
