//
//  Masechet.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 28/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Masechet:DataObject
{
    var id:String?
    var name:String!
    var englishName:String?
    var numberOfPages:Int!
    var firstPageNumber:Int!
    var firstPageIndex:Int!
    var lastPageIndex:Int!
    var lastPageSide:String!
    var maggidShiurs = [MaggidShiur]()
    var pagesWithSavedLessons = [Page]()

    var hasSavedLessons = false
    var hasSavedPages = false
        
    var index:Int {
        get {
            if let idNumber = Int(self.id ?? "0") {
                return 282 + idNumber
            }
            else{
                return 0
            }
        }
    }
    
    var savedLessons:[Lesson]?
    
    var savedPages:[Page]{
        get{
            var savedPages = [Page]()
            
            let array = ["maschet", "page"]
            let query = "maschet='\(self.name!)'"
            
            if let queryObjectsInfo = SQLmanager.getData(array, from: "savedPages", where: query, fromDBFile: "DafYomi.sqlite")
                ,queryObjectsInfo.count > 0
            {
                for page in self.pages
                {
                    for objectInfo in queryObjectsInfo
                    {
                        if let pageSymbol = objectInfo["page"] as? String
                        {
                            if page.symbol == pageSymbol
                            {
                                savedPages.append(page)
                                break
                            }
                        }
                    }
                }
            }
            
            return savedPages
        }
    }
        
    
    lazy var pages:[Page] = {
        
        var pages = [Page]()
        
        for index in 1 ... numberOfPages
        {
            let page = Page(index: index)
            pages.append(page)
        }
        
        return pages
    }()
    
    override init()
    {
        super.init()
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.englishName = dictionary["EnglishName"] as? String
        self.numberOfPages = Int(dictionary["numberOfPages"] as! String)! //+ 1// Needes to be changed in the data base
        self.firstPageIndex = Int(dictionary["firstPageIndex"] as! String)
        self.lastPageSide = dictionary["lastPageSide"] as? String
        
        let amodAlef = "א"
        
        self.lastPageIndex = self.firstPageIndex + (self.numberOfPages * 2) - (self.lastPageSide == amodAlef ? 1 : 0) - 1
    }
    
    func hasSavedLessonForMaggidShiour(_ maggidShiour:MaggidShiur?, andPage page:Page?) -> Bool
    {
        let array = ["maschet"]
        
        var query = "maschet='\(self.name!)'"
        
        if maggidShiour != nil
        {
            query += " And magidShior='\(maggidShiour!.name!)'"
        }
        
        if page != nil
        {
            query += " And page = '\(page!.symbol!)'"
        }
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            return true
        }
        
        return false
    }
    
    func setSavedLessons()
    {
        self.savedLessons = [Lesson]()
       
        let array = ["magidShior","page"]
        
        let query = "maschet='\(self.name!)'"
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            for objectInfo in queryObjectsInfo
            {
                
                if let magidShiorName = objectInfo["magidShior"] as? String
                ,let pageSymbol = objectInfo["page"] as? String
                {
                    let maggidShiour = MaggidShiur()
                    maggidShiour.name = magidShiorName
                    
                    let page = Page()
                    page.symbol = pageSymbol
                    
                    let lesson = Lesson()
                    lesson.masechet = self
                    lesson.maggidShiur = maggidShiour
                    lesson.page = page
                    
                    self.savedLessons?.append(lesson)
                }
            }
        }
    }
    
    func getWebId() -> String?
    {
        if self.id == "06"{
            return "07"
        }
        
        if self.id == "07"{
            return "08"
        }
        
        if self.id == "08"{
            return "09"
        }
        
        if self.id == "09"{ // מסכת ראש השנה
            return "06"
        }
        
        if self.id == "40"{ // מסכת נידה
            return "37"
        }
        
        else{
            return self.id
        }
    }
    
    
    func getPageByIndex(_ index:String) -> Page?
    {
        var pageIndex = Int((Double(index)! - 3.0) / 2.0)
        if pageIndex < 0 {
            pageIndex = 0
        }
        
        if  pageIndex < self.pages.count
        {
            return  self.pages[pageIndex]
        }
        else{
            return nil
        }
    }
    
    func getSavedPageSidesForPage(_ page:Page) -> [Int]
    {
        var savedPageSides = [Int]()
        
        let array = ["pageside"]
        let query = "maschet='\(self.name!)' AND page='\(page.symbol!)'"
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedPages", where: query, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            for objectInfo in queryObjectsInfo
            {
                if let pageSide = objectInfo["pageside"] as? String{
                    
                    if pageSide == "1" //עמוד א
                    {
                         savedPageSides.append(0)
                    }
                    if pageSide == "2" // עמוד ב
                    {
                        savedPageSides.append(1)
                    }
                }
            }
        }
        
        return savedPageSides
    }
    
    func copy() -> Masechet
    {
        let masechet = Masechet()
        
        masechet.id = self.id
         masechet.name = self.name
         masechet.englishName = self.englishName
         masechet.numberOfPages = self.numberOfPages
         masechet.firstPageIndex = self.firstPageIndex
         masechet.lastPageIndex = self.lastPageIndex
         masechet.lastPageSide = self.lastPageSide
         masechet.maggidShiurs = self.maggidShiurs
         masechet.pagesWithSavedLessons = [Page]()
        
        for pageWithSavedLessoon in self.pagesWithSavedLessons
        {
            masechet.pagesWithSavedLessons.append(pageWithSavedLessoon.copy())
        }
        
         masechet.hasSavedLessons = self.hasSavedLessons
         masechet.hasSavedPages = self.hasSavedPages
        masechet.savedLessons = self.savedLessons
        
        return masechet
    }
    
    func updatePagesWithNotes()
    {
        for page in self.pages
        {
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor( self, page:page, pageSide :1)
            {
                if HadafHayomiManager.sharedManager.hasNoteOnPage(pageId:"\(pageIndex)")
                {
                    page.note = HadafHayomiManager.sharedManager.getNoteByPageIndex("\(pageIndex)")
                    continue
                }
            }
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor( self, page:page, pageSide :2)
            {
                if HadafHayomiManager.sharedManager.hasNoteOnPage(pageId:"\(pageIndex)")
                {
                     page.note = HadafHayomiManager.sharedManager.getNoteByPageIndex("\(pageIndex)")
                }
            }
        }
    }
    
    func updateMarkedPages()
    {
        for page in self.pages
        {
            if let dateForPage = HadafHayomiManager.sharedManager.dateForPageNumber(self.firstPageIndex + page.index-1)
            {
                if dateForPage.isMarkedAsLearned()
                {
                    page.isMarkedAsLearned = true
                }
                else{
                    page.isMarkedAsLearned = false
                }
            }
        }
    }
}
