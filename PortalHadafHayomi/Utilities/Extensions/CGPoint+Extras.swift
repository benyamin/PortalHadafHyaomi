//
//  CGPoint+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
