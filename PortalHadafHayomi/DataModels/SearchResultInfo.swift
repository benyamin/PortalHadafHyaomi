//
//  SearchResultInfo.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 12/06/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class SearchResultInfo:DataObject
{
    var numberOfDataPages:Int?
    
    var dataPageNumber:Int?
   
    var searchResults = [Any]()
}
