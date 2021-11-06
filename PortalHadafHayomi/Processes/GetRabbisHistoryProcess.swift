//
//  GetRabbisHistoryProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetRabbisHistoryProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
           
            var expressions = [Expression]()
            
            let plistPath = Bundle.main.path(forResource: "Toldot", ofType: "plist")
            let rabbis = NSArray(contentsOfFile: plistPath!) as! [[String]]
            
            for rabbyInfo in rabbis
            {
                let expression = Expression()
                expression.key = rabbyInfo[0]
                expression.value = rabbyInfo[1]
                
                expressions.append(expression)
            }
            DispatchQueue.main.async {
                  self.onComplete!(expressions)
            }
        }
    }
}
