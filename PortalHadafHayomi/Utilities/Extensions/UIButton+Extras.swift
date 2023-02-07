//
//  UIButton+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

fileprivate var userInfo_private:[String:Any]?

extension UIButton
{
    @objc var userInfo:[String:Any]? {
        
          get{
             return objc_getAssociatedObject(self, &userInfo_private) as? [String:Any]
          }
          set (userInfo){
             objc_setAssociatedObject(self, &userInfo_private, userInfo, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
          }
      }
    
    func setImageTintColor(_ tintColor:UIColor) {
        if let image = self.image(for: .normal) {
            self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        if let image = self.image(for: .highlighted) {
            self.setImage(image.withRenderingMode(.alwaysTemplate), for: .highlighted)
        }
        if let image = self.image(for: .selected) {
            self.setImage(image.withRenderingMode(.alwaysTemplate), for: .selected)
        }
        self.tintColor = tintColor
    }
}
