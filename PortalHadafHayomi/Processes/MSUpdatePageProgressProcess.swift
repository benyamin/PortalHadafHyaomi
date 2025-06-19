//
//  MSUpdatePageProgressProcess.swift
//  DafYomiTrakingBoard
//
//  Created by Binyamin Trachtman on 14/02/2024.
//

import Foundation

class MSUpdatePageProgressProcess:MSBaseProcess
{
    struct DataModel {
        var date:Date
        var masechetName:String
        var pageSymbol:String
        var status:String
        var note:String? = nil
    }
    
    override func executeWithObj(_ obj:Any?) {
        
        let progressInfo = obj as! DataModel
        
        (progressInfo.status != "none" || progressInfo.note != nil)
        ? self.updatePageStatusForDate(progressInfo.date, info:progressInfo)
        : self.removePageStatusForDate(progressInfo.date)
    }
    
    func updatePageStatusForDate(_ date:Date, info:DataModel)
    {
        var pageData = [String: Any]()
        pageData["masechet"] = info.masechetName
        pageData["page"] = info.pageSymbol
        pageData["status"] = info.status
        pageData["note"] = info.note == "" ? nil : info.note
        
        let pageId = date.stringWithFormat("dd_MM_yyyy")
        var learndPagesDictionary = UserDefaults.standard.object(forKey:"pages") as? [String:[String:Any]] ?? [String:[String:Any]]()
        learndPagesDictionary[pageId] = pageData
        UserDefaults.standard.set(learndPagesDictionary, forKey: "pages")
        UserDefaults.standard.synchronize()
        
        self.onCompleteWithObj([pageId:pageData])
    }
    
    func removePageStatusForDate(_ date:Date)
    {
        let pageId = date.stringWithFormat("dd_MM_yyyy")
        var learndPagesDictionary = UserDefaults.standard.object(forKey:"pages") as? [String:[String:Any]] ?? [String:[String:Any]]()
        learndPagesDictionary.removeValue(forKey: pageId)
        UserDefaults.standard.set(learndPagesDictionary, forKey: "pages")
        UserDefaults.standard.synchronize()
        
        self.onCompleteWithObj(pageId)
    }
}
