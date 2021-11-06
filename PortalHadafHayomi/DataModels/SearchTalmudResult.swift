//
//  SearchTalmudResult.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/06/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class SearchTalmudResult:DataObject
{
    var searchText:String!
    
    var pageId:String?
    var page:String?
    var source:String?
    var text:String?
    var link:String?
    var isMatching:Bool = true
}
