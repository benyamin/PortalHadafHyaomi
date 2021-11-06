//
//  GetQandAProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetQandAProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let fileName = obj as! String
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var expressions = [Expression]()
            
            let plistPath = Bundle.main.path(forResource: fileName, ofType: "plist")
            let QandAList = NSArray(contentsOfFile: plistPath!) as! [[String]]
            
            for QandAInfo in QandAList
            {
                let expression = Expression()
                
                var key =  QandAInfo[0]
                key = key.replacingOccurrences(of: "&quot;", with: "׳׳")
                
                expression.key = key
                expression.value = QandAInfo[1]
                
                expressions.append(expression)
            }
            DispatchQueue.main.async {
                self.onComplete!(expressions)
            }
        }
    }
}
