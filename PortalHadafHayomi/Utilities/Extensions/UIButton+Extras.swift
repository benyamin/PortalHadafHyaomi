//
//  UIButton+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

extension UIButton
{
    func setImageTintColor(_ tintColor:UIColor) {
        if let image = self.image(for: .normal) {
            self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self.setImage(image.withRenderingMode(.alwaysTemplate), for: .highlighted)
            self.tintColor = tintColor
        }
    }
}
