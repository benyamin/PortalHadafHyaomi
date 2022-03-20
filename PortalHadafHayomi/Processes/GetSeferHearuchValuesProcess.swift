//
//  GetSeferHearuchValuesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 13/03/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetSeferHearuchValuesProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            var expressions = [Expression]()
            
            let plistPath = Bundle.main.path(forResource: "seferHearuch", ofType: "plist")
            let hearuchValues = NSArray(contentsOfFile: plistPath!) as! [[String]]
            
            for var expressionInfo in hearuchValues
            {
                let expression = Expression()
                expression.key = expressionInfo.first ?? ""
                
                //Remove the key from the expressoin
                expressionInfo.removeFirst()
                
                var expressionValue = ""
                for valueComponent in expressionInfo
                {
                    expressionValue += valueComponent
                    if valueComponent != expressionInfo.last
                    {
                        expressionValue += "\n"
                    }
                }
                
                expression.value = expressionValue
                
                expressions.append(expression)
            }
            
            DispatchQueue.main.async {
                self.onComplete!(expressions)
            }
        }
       
    }
}
