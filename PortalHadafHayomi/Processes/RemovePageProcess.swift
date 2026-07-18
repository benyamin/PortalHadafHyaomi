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
        //One page to delete with display type
        if let pageInfo = obj as? (pageIndex:Int, type:TalmudDisplayType)
        {
            self.removePage(pageInfo.pageIndex, displayType: pageInfo.type)
        }
        //One page to delete (legacy - defaults to Vagshal)
        else if obj is Int
        {
            let pageIndex = obj as! Int
            self.removePage(pageIndex, displayType: .Vagshal)
        }
         
        //Multiple pages to delete (legacy - defaults to Vagshal)
        else if obj is [Int]
        {
            let pagesIndexes = obj as! [Int]
            self.removePages(pagesIndexes, displayType: .Vagshal)
        }
       
    }
    
    func removePage(_ pageIndex:Int, displayType:TalmudDisplayType)
    {
        var fileNamed = "\(pageIndex)"
        if displayType != .Vagshal {
            fileNamed += "_\(displayType.rawValue)"
        }
        let fileExtension: String
        switch displayType {
        case .Vagshal, .Chavruta:
            fileExtension = "pdf"
        default:
            fileExtension = "html"
        }
        let filePath = FileManager.filePathFor(fileNamed: fileNamed, ofType: fileExtension)
        let path = filePath.path
        
        if FileManager.default.fileExists(atPath: path)
        {
            do{
                try FileManager.default.removeItem(atPath:path)
                
                if displayType == .Vagshal {
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
                }
                self.onComplete?(pageIndex)
                
            }catch{
                print(error)
                
                self.onFaile!(pageIndex, error as NSError)
            }
        }
    }
    
    func removePages(_ pagesIndexes:[Int], displayType:TalmudDisplayType)
    {
        var pagesInfo = [[String:String]]()
        for pageIndex in pagesIndexes
        {
            var fileNamed = "\(pageIndex)"
            if displayType != .Vagshal {
                fileNamed += "_\(displayType.rawValue)"
            }
            let fileExtension: String
            switch displayType {
            case .Vagshal, .Chavruta:
                fileExtension = "pdf"
            default:
                fileExtension = "html"
            }
            let filePath = FileManager.filePathFor(fileNamed: fileNamed, ofType: fileExtension)
            let path = filePath.path
            
            if FileManager.default.fileExists(atPath: path)
            {
                do{
                    try FileManager.default.removeItem(atPath:path)
                    
                    if displayType == .Vagshal {
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
                    }
                    
                }catch{
                    print(error)
                }
            }
        }
        
        if !pagesInfo.isEmpty {
            SQLmanager.deleteData(dataArray: pagesInfo, fromTable: "savedPages", inDBFile: "DafYomi.sqlite")
        }
        
         self.onComplete?(pagesInfo)
    }
}
