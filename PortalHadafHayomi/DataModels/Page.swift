//
//  Page.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 28/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Page:DataObject
{
    var symbol:String!
    var index:Int!
    
    var isSelected:Bool = false
    
    var hasSavedLessons:Bool = false
    var hasSavedPages:Bool = false
    var note:Note?
    
    var isMarkedAsLearned = false
        
    override init() {
        super.init()
    }
    
    init(index:Int){
        super.init()
        
        self.index = index
        self.symbol = HebrewUtil.hebrewDisplayFromNumber(self.index+1)
    }
    
    func hasSavedLessonForMasechet(_ masechet:Masechet?, andMagidShior magidShior:MaggidShiur?) -> Bool
    {
        if masechet == nil
        {
            return false
        }
        
        let array = ["magidShior"]
        
        var query = "page='\(self.symbol!)'"
        
        query += " And maschet='\(masechet!.name!)'"
        
        if magidShior != nil
        {
            query += " And magidShior = '\(magidShior!.name!)'"
        }
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            return true
        }
        
        return false
    }
    
    func copy() -> Page
    {
        let page = Page()
        
        page.symbol = self.symbol
        page.index = self.index
        page.isSelected = self.isSelected
        page.hasSavedLessons = self.hasSavedLessons
        page.hasSavedPages = self.hasSavedPages
        page.note = self.note
        page.isMarkedAsLearned = self.isMarkedAsLearned
     
        return page
    }
}
