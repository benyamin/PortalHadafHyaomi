//
//  GetLaazy_rashiProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetLaazy_rashiProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            var expressions = [Expression]()
            
            let plistPath = Bundle.main.path(forResource: "Laazy_rashi", ofType: "plist")
            let Laazy_rashi = NSArray(contentsOfFile: plistPath!) as! [[String]]
            
            for var expressionInfo in Laazy_rashi
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
