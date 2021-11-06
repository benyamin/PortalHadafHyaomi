//
//  PageSummary.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class PageSummary:DataObject
{
    var pageIndex = 0
    var maseceht:Masechet?
    var key:String!
    var summary:String?
    
    lazy var page:String! = {
        
        if let keyComponents = self.key?.components(separatedBy:" ")
            ,keyComponents.count > 0
        {
            let page = keyComponents.last
            return page
        }
        return ""
    }()
}
