//
//  GetTalmudExpressionProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTalmudExpressionProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            var expressions = [Expression]()
            
            let plistPath = Bundle.main.path(forResource: "Munahim_talmudim", ofType: "plist")
            let talmudExpressions = NSArray(contentsOfFile: plistPath!) as! [[String]]
            
            for expressionInfo in talmudExpressions
            {
                let expression = Expression()
                expression.key = expressionInfo[0]
                expression.value = expressionInfo[1]
                
                expressions.append(expression)
            }
            
            DispatchQueue.main.async {
                self.onComplete!(expressions)
            }
        }
    }
}
