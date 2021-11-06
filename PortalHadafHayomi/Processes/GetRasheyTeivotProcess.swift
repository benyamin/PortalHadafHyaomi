//
//  GetRasheyTeivotProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class  GetRasheyTeivotProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            var expressions = [Expression]()
            
            let plistPath = Bundle.main.path(forResource: "rasheyTeivot", ofType: "plist")
            let rasheyTeivot = NSArray(contentsOfFile: plistPath!) as! [[String: String]]
            
            for expressionInfo in rasheyTeivot
            {
                let expression = Expression()
                expression.key = expressionInfo["המונח"]
                expression.value = expressionInfo["ערך"]
                
                expressions.append(expression)
            }
            
            DispatchQueue.main.async {
                self.onComplete!(expressions)
            }
        }
    }
}
