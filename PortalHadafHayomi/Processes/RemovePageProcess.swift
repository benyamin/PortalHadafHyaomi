//
//  RemovePageProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 27/11/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class RemovePageProcess: MSBaseProcess//, LessonDownLoaderDelegate, UIAlertViewDelegate
{
    open override func executeWithObj(_ obj:Any?)
    {
        //One page to delete
        if obj is Int
        {
            let pageIndex = obj as! Int
            self.removePage(pageIndex)
        }
         
        //Multiple pages to delete
        else if obj is [Int]
        {
            let pagesIndexes = obj as! [Int]
            self.removePages(pagesIndexes)
        }
       
    }
    
    func removePage(_ pageIndex:Int)
    {
        let path = LessonsManager.sharedManager.pathForPage(pageIndex: pageIndex)
        
        if FileManager.default.fileExists(atPath: path)
        {
            do{
                try FileManager.default.removeItem(atPath:path)
                
                let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex)
                
                if let masechet = pageInfo["maschet"] as? Masechet
                    , let page = pageInfo["page"] as? Page
                    , let pageSide =  pageInfo["pageSide"] as? Int
                {
                    let pageInfo:[String:String] = ["number":("\(pageIndex)"),
                                                    "maschet":masechet.name,
                                                    "page":page.symbol,
                                                    "pageside": ("\(pageSide)")]
                    
                    SQLmanager.deleteData(dataDictionary: pageInfo, fromTable: "savedPages", inDBFile: "DafYomi.sqlite")
                    
                }
                self.onComplete?(pageIndex)
                
            }catch{
                print(error)
                
                self.onFaile!(pageIndex, error as NSError)
            }
        }
    }
    
    func removePages(_ pagesIndexes:[Int])
    {
        var pagesInfo = [[String:String]]()
        for pageIndex in pagesIndexes
        {
            let path = LessonsManager.sharedManager.pathForPage(pageIndex: pageIndex)
            
            if FileManager.default.fileExists(atPath: path)
            {
                do{
                    try FileManager.default.removeItem(atPath:path)
                    
                    let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex)
                    
                    if let masechet = pageInfo["maschet"] as? Masechet
                        , let page = pageInfo["page"] as? Page
                        , let pageSide =  pageInfo["pageSide"] as? Int
                    {
                        let pageSqlInfo:[String:String] = ["number":("\(pageIndex)"),
                                                        "maschet":masechet.name,
                                                        "page":page.symbol,
                                                        "pageside": ("\(pageSide)")]
                        
                        pagesInfo.append(pageSqlInfo)
                    }
                    
                }catch{
                    print(error)
                }
            }
        }
        
        SQLmanager.deleteData(dataArray: pagesInfo, fromTable: "savedPages", inDBFile: "DafYomi.sqlite")
        
         self.onComplete?(pagesInfo)
    }
}
