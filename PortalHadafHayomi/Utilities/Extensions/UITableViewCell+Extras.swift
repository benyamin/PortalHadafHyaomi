//
//  UITableViewCell+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell
{
    var tableView: UITableView?
    {
        var view = self.superview
        while (view != nil && view!.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as? UITableView
    }
}
