//
//  CallendarMonth.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/05/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class CallendarMonth:NSObject
{
    var name:String!
    var numberOfDays:Int!
    
    var startDayDate:Date!
    var endDayDate:Date!
    var startDay:Int?
    var endDay:Int?
    
    override init() {
        super.init()
    }
    
    init(dictionary:[String:Any]) {
        super.init()
    }
}
