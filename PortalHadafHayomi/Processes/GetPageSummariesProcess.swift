//
//  GetPageSummariesProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 21/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class  GetPageSummariesProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            var masechtotSummaries = [MasechetSummary]()
            
            let plistPath = Bundle.main.path(forResource: "PagesSummary", ofType: "plist")
            let pageSummariesInfo = NSArray(contentsOfFile: plistPath!) as! [[String]]
            
            pagesLoop: for index in 0 ..< pageSummariesInfo.count
            {
                let pageSummaryInfo = pageSummariesInfo[index]
                
                let pageSummary = PageSummary()
                
                pageSummary.pageIndex = index
                pageSummary.key = pageSummaryInfo[0]
                pageSummary.summary = pageSummaryInfo[1]
                
                let masechetName = self.getMaschetNameFromPageSummary(pageSummary)
                
                for masechetSummary in masechtotSummaries
                {
                    if masechetSummary.masechetName == masechetName
                    {
                        masechetSummary.pagesSummary.append(pageSummary)
                        continue pagesLoop
                    }
                }
                
                //If not found a masechetSummary for the pageSummery maschet, create a new masechetSummary
                let masechetSummary = MasechetSummary()
                masechetSummary.masechetName = masechetName
                masechetSummary.pagesSummary.append(pageSummary)
                
                masechtotSummaries.append(masechetSummary)
            }
            
            DispatchQueue.main.async {
                
                self.onComplete!(masechtotSummaries)
            }
        }
    }
    
    func getMaschetNameFromPageSummary(_ pageSummary:PageSummary) -> String
    {
        var pageInfo = pageSummary.key.components(separatedBy:" ")
        pageInfo.removeLast()// Remove page
        pageInfo.removeLast()// Remove ״דף״
        
        var masechetName = ""
        for text in pageInfo
        {
            masechetName += text
            
            if text != pageInfo.last
            {
                masechetName += " "
            }
        }
        
        return masechetName
    }
}
