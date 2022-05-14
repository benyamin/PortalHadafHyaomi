//
//  HadafHayomiManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 29/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

enum TalmudDisplayType: String {
    case Vagshal = "Vagshal"
    case Text = "Text"
    case TextWithScore = "TextWithScore"
    case Meorot = "Meorot"
    case EN = "EN"
    case Chavruta = "Chavruta"
    case Steinsaltz = "Steinsaltz"
}

open class  HadafHayomiManager
{
    static public let sharedManager =  HadafHayomiManager()
    
    var userSettings:[SetableItem]?
    
    var appSettings:[SetableItem]?
    
    var regions:[Region]?
    
    var logedInUser:User? {
        
        didSet{
            if logedInUser == nil {
                UserDefaults.standard.removeObject(forKey: "loginUserData")
            }
            else {
                if let userData = logedInUser?.dictionaryRepresentation {
                    UserDefaults.standard.set(userData, forKey: "loginUserData")
                }
            }
            UserDefaults.standard.synchronize()
            
        }
    }
    
    lazy var savedNotes:[Note] = {
        
        var savedNotes = [Note]()
        
        if let savedNotesInfo = UserDefaults.standard.object(forKey:"savedNotes") as? [[String:Any]]
        {
            for noteInfo in savedNotesInfo
            {
               let note = Note(dictionary: noteInfo)
                
                savedNotes.append(note)
            }
        }
        
        return savedNotes
    }()
    
    lazy var cycleStaretDate:Date = {
        
        var numberOfDaysInCycle = 2711
        
        var cycleStaretDate = Date.dateFromString("2012-08-03", withFormat: "yyy-MM-dd")!
        
        while cycleStaretDate.numberOfDaysToDate(Date()) > numberOfDaysInCycle
        {
            cycleStaretDate = cycleStaretDate.dateByAddingDays(numberOfDaysInCycle)
        }
       
        return cycleStaretDate
       
    }()
    
    lazy var masechtot:[Masechet] = {
        
        var masechtot = [Masechet]()
        let requiredData = ["id","name","EnglishName","numberOfPages","firstPageIndex","lastPageSide"]
        
        var nextMasechetfirstPageNumber = 0
        if let queryObjectsInfo = SQLmanager.getData(requiredData, from: "masechtot", where:nil, fromDBFile: "DafYomi.sqlite")
        {
            for queryObject in queryObjectsInfo
            {
                let maschet = Masechet(dictionary: queryObject)
                maschet.firstPageNumber = nextMasechetfirstPageNumber
                nextMasechetfirstPageNumber += maschet.numberOfPages
                
                self.checkForSavedLessonsOnMasehchet(maschet)
                
               self.checkForSavedPagesOnMasehchet(maschet)
                
                masechtot.append(maschet)
            }
        }
        
        return masechtot
    }()
    
    lazy var avalibleDisplayTypes:[TalmudDisplayType] = {
        
        return  [.Vagshal, .Text, .TextWithScore, .Chavruta, .Steinsaltz, .EN]
    }()
    
    func getUserSettingByKey(_ key:String) -> SetableItem?
    {
        if self.userSettings != nil
        {
            for settaleItem in self.userSettings!
            {
                if settaleItem.key == key
                {
                    return settaleItem
                }
            }
        }
      
        return nil
    }
    
    func getAppSettingByKey(_ key:String) -> SetableItem?
    {
        if self.appSettings != nil
        {
            for settaleItem in self.appSettings!
            {
                if settaleItem.key == key
                {
                    return settaleItem
                }
            }
        }
        
        return nil
    }
    
    func getAppSettingValueByKey(_ key:String) -> Any?
    {
        if let requiredSetting = self.getAppSettingByKey(key)
        {
            return requiredSetting.value
        }
        return nil
    }
    
    func checkForSavedLessonsOnMasehchet(_ maschet:Masechet)
    {
        maschet.hasSavedLessons = false
        
        let array = ["maschet"]
        let query = "maschet='\(maschet.name!)'"
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            maschet.hasSavedLessons = true
        }
    }
    
    func getMessechtotWithSavedPages() -> [Masechet]
    {
        var messechtotWithSavedPages =  [Masechet]()
        
        let array = ["maschet"]
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedPages", where: nil, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            for masechet in self.masechtot
            {
                for objectInfo in queryObjectsInfo
                {
                    if let savedMasechetName = objectInfo["maschet"] as? String
                    {
                        if masechet.name == savedMasechetName
                        {
                            messechtotWithSavedPages.append(masechet)
                            
                            break
                        }
                    }
                }
            }
        }
        
        return messechtotWithSavedPages
    }
    
    func checkForSavedPagesOnMasehchet(_ maschet:Masechet)
    {
        let array = ["maschet","page"]
        let query = "maschet='\(maschet.name!)'"
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedPages", where: query, fromDBFile: "DafYomi.sqlite")
            ,queryObjectsInfo.count > 0
        {
            maschet.hasSavedPages = true
            
            for page in maschet.pages
            {
                for objectsInfo in queryObjectsInfo
                {
                    if let pageSymnbol = objectsInfo["page"] as? String
                    , page.symbol! == pageSymnbol
                    {
                        page.hasSavedPages = true
                        break
                    }
                }
            }
        }
    }
    
    var masechtotWithSavedLessons:[Masechet]!{
        get{
            var masechtotWithSavedLessons = [Masechet]()
            for masechet in self.masechtot
            {
                if masechet.hasSavedLessons
                {
                    masechtotWithSavedLessons.append(masechet)
                }
            }
            return masechtotWithSavedLessons
        }
    }
    
    func setMasechtotWithSavedLessons()
    {
        for masechet in self.masechtot
        {
            self.checkForSavedLessonsOnMasehchet(masechet)
        }
    }
    
    lazy var maggidShiurs:[MaggidShiur] = {
        
        if let savedLessonsInfo = FileManager.readFromFile("lessons", ofType: "xml")
        {
            do {
                let xmlDoc = try AEXMLDocument(xmlData: savedLessonsInfo.data(using: .utf8)!)
                if let lessons = GetLessonsProcess.parseLessonsFromDictoinary(["xmlDoc":xmlDoc])
                {
                    let maggidShiours = HadafHayomiManager.sharedManager.extrectMaggidShioursFromLessons(lessons)
                    
                    return maggidShiours

                }
                
            } catch _ {
            }
        }
        return [MaggidShiur]()
    }()
    
    func sortMaggidShiursArray(maggidShiursArray:[MaggidShiur]) -> [MaggidShiur]{
                   
           var sortedMaggisShiurs = maggidShiursArray
           
           if let lastPlayedMaggidShiurs = UserDefaults.standard.object(forKey: "lastPlayedMaggidShiurs") as? [String] {
               
               for maggidShiurId in lastPlayedMaggidShiurs {
                   if let maggidShiur = sortedMaggisShiurs.first(where: { $0.id == maggidShiurId }) {
                       sortedMaggisShiurs.remove(maggidShiur)
                       sortedMaggisShiurs.insert(maggidShiur, at: 0)
                   }
               }
           }
           return sortedMaggisShiurs
       }
    
    lazy var todaysMaschet:Masechet? = {
        
        let st = Date().stringWithFormat("yyyy-MM-dd") + " 00:00"
        let startDayDate = Date.dateFromString(st, withFormat:"yyyy-MM-dd HH:mm")
        
       
        return self.maschetForDate(startDayDate!)
    }()
        
    lazy var todaysPage:Page? = {
        
        let st = Date().stringWithFormat("yyyy-MM-dd") + " 00:00"
        let startDayDate = Date.dateFromString(st, withFormat:"yyyy-MM-dd HH:mm")
        
        return self.pageForDate(startDayDate!, addOnePage:true)
    }()
    
    lazy var talmudNumberOfPages:Int! = {
        
        let lastMasceht =  self.masechtot.last!
        return lastMasceht.lastPageIndex
    }()
    
    lazy var lessonVenues:[LessonVenue] = {
       
        let lessonVenues = [LessonVenue]()
        return lessonVenues
    }()
  
    func todaysPageDisplay() -> String
    {
       
        var todaysPageDisplay = "מסכת"
        todaysPageDisplay += " " + self.getTodaysMasechetName()
        todaysPageDisplay += " " + "דף"
        todaysPageDisplay += " " + self.todaysPage!.symbol
        
        return todaysPageDisplay
    }
    
    func getTodaysMasechetName() -> String
    {
        if let maschet = self.todaysMaschet
        , let page = self.todaysPage
        {
            return self.getMasechetNameforMasechet(maschet, page: page)
        }
        return ""
    }
    
    func todaysPageIndex() -> Int {
        
        var pageIndex = 0
        for masecht in self.masechtot{
            if masecht != self.todaysMaschet{
                pageIndex += masecht.numberOfPages
            }
            else{
                pageIndex += (todaysPage?.index ?? 0)
                break
            }
        }
       return pageIndex
    }
    
    func getMasechetNameforMasechet(_ maschet:Masechet, page:Page) -> String
    {
        var maschetName = maschet.name
        
        if maschetName == "מעילה"
        {
            if page.index >= 21
                && page.index <= 24
            {
                maschetName = "קנים"
            }
                
            else if page.index >= 25
                && page.index <= 32
            {
                maschetName = "תמיד"
            }
                
            else if page.index >= 33
                && page.index <= 36
            {
                maschetName = "מידות"
            }
        }
        
        return maschetName!
    }
    
    func maschetForDate(_ date:Date) -> Masechet?
    {
        let pageNumber = self.pageNumberForDate(date)
        
        var pageSum = 0

        for maschet in self.masechtot
        {
            pageSum = pageSum + maschet.numberOfPages
            
            if pageSum > pageNumber
            {
                return maschet
            }
        }
        return nil
    }
    
    func pageForDate(_ date:Date, addOnePage:Bool) -> Page?
    {
        let pageNumber = self.pageNumberForDate(date)
        
        var pageSum = 0
        
        for maschet in self.masechtot
        {
            pageSum = pageSum + maschet.numberOfPages
            
            if pageSum > pageNumber
            {
                var pageIndex = maschet.numberOfPages - (pageSum - pageNumber)
                if addOnePage
                {
                    pageIndex += 1
                }
                let page = Page(index: pageIndex)
                
                return page
            }
        }
        return nil
    }
    
    func pageNumberForDate(_ date:Date) -> Int
    {
        let numberOfPagesInTalmud = 2711

        let daysBetweenDates = Date.daysBetweenDates(firstDate: self.cycleStaretDate, secondDate: date)
        
        if daysBetweenDates >= 0
        {
            let pageNumber = daysBetweenDates % numberOfPagesInTalmud
            return pageNumber
        }
        else{
            
            let pageNumber = numberOfPagesInTalmud - ((-1 * daysBetweenDates) % numberOfPagesInTalmud)
            return pageNumber
        }
    }
    
    func dateForPageNumber(_ requiredPageNumber:Int) -> Date? //The date for the curreny machzor
    {
        var minDate = self.cycleStaretDate
        var maxDate = Date()
        
        var days =  Date.daysBetweenDates(firstDate: minDate, secondDate: maxDate)/2
        while days > 0
        {
            let rangeDate = minDate.dateByAddingDays(days)
            
            let pageNumber = self.pageNumberForDate(rangeDate)
            
            if  requiredPageNumber < pageNumber
            {
                maxDate = rangeDate
                days =  Date.daysBetweenDates(firstDate: minDate, secondDate: maxDate)/2
            }
            else if requiredPageNumber > pageNumber
            {
                minDate = rangeDate
                days =  Date.daysBetweenDates(firstDate: minDate, secondDate: maxDate)/2
            }
            else{
                return rangeDate
            }
        }
        return Date()
    }
    
    class func dispalyTitleForMaschet(_ maschet:Masechet, page:Page, pageSide:Int) -> String
    {
        var titleText = ""
        //titleText += "מסכת"
        titleText += " " + maschet.name
       // titleText += " " + "דף"
        titleText += " " + page.symbol
        titleText += " " + "ע״"
        if pageSide == 0 || pageSide == 1
        {
            titleText += "א"
        }
        else if pageSide == 2
        {
            titleText += "ב"
        }
        
        return titleText
    }
    
    class func dispalyEnglishTitleForMaschet(_ maschet:Masechet, page:Page, pageSide:Int) -> String
    {
        var titleText = ""
        titleText += " " + (maschet.englishName ?? "")
        titleText += " " + ("\(page.index! + 1)")
        if pageSide == 0 || pageSide == 1
        {
            titleText += "a"
        }
        else if pageSide == 2
        {
            titleText += "b"
        }
        
        return titleText
    }
    
    class func pageInfoForIndexInTalmud(_ index:Int) -> [String:Any]
    {
        var pageInfo = [String:Any]()
        for maschet in HadafHayomiManager.sharedManager.masechtot
        {
            if maschet.lastPageIndex >= index
            {
                pageInfo["maschet"] = maschet
                
                let mumerOfPageInMaschet = index - maschet.firstPageIndex + 1
                
                let  pageNumber = mumerOfPageInMaschet/2 +  mumerOfPageInMaschet%2
                
                let page = Page(index: pageNumber)
                pageInfo["page"] = page
                
                let pageSide = mumerOfPageInMaschet%2 == 0 ? 2 : 1
                pageInfo["pageSide"] = pageSide
                
                return pageInfo
            }
        }
        
        return pageInfo
    }
    
    func getMasechetById(_ id:String) -> Masechet?
    {
        for masechet in self.masechtot
        {
            if masechet.id == id
            {
                return masechet
            }
        }
        return nil
    }
    
    func pageIndexFor(_ maschet:Masechet, page:Page, pageSide:Int) -> Int?
    {
        var pageIndex = (maschet.firstPageIndex! + ((page.index - 1) * 2))
        pageIndex += pageSide
        
        if pageIndex <= maschet.lastPageIndex
        {
            return pageIndex
        }
        else{
            return nil
        }
    }
    
    func getMasechetForPageIndex(_ index:Int) -> Masechet?
    {
        for masecht in self.masechtot
        {
            if index <= masecht.lastPageIndex
            {
                return masecht
            }
        }
        return nil
    }
    
    func getPageForPageIndex(_ index:Int) -> Page?
    {
        if let masecht = self.getMasechetForPageIndex(index)
        {
            let pageIndexInMasechet = ((index - masecht.firstPageIndex)/2)
            
            if pageIndexInMasechet < masecht.pages.count
            {
                return masecht.pages[pageIndexInMasechet]
            }
        }
        return nil
    }
    
    func getPageSideForPageIndex(_ index:Int) -> Int?
    {
        if let masecht = self.getMasechetForPageIndex(index)
        {
            return (index - masecht.firstPageIndex)%2 == 0 ? 1 : 2
        }
        return nil
    }
    
    //Up date information for saved pages that wore not reaint to the SQL data base
    class func updateOldSavedPages()
    {
        Util.showDefaultLoadingView()
        
        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let pdfFiles = directoryContents.filter{ $0.pathExtension == "pdf" }
            print("pdfFiles urls:",pdfFiles)
            let pdfFileNames = pdfFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("pdfFiles list:", pdfFileNames)
            
            for savedPageId in pdfFileNames
            {
                if let pageIndex = Int(savedPageId)
                {
                     HadafHayomiManager.sharedManager.savePageByPageIndex(pageIndex)
                }
            }
            
            for masechet in HadafHayomiManager.sharedManager.masechtot
            {
                HadafHayomiManager.sharedManager.checkForSavedPagesOnMasehchet(masechet)
            }
            
            Util.hideDefaultLoadingView()
            
        } catch {
            print(error.localizedDescription)
            
            Util.hideDefaultLoadingView()
        }
    }
    
    func savePageByPageIndex(_ pageIndex:Int)
    {
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex)
        
        if let masechet = pageInfo["maschet"] as? Masechet
            , let page = pageInfo["page"] as? Page
            , let pageSide =  pageInfo["pageSide"] as? Int
        {
            let pageInfo:[String:String] = ["number":("\(pageIndex)"),
                                            "maschet":masechet.name,
                                            "page":page.symbol,
                                            "pageside": ("\(pageSide)")]
            
            SQLmanager.insertOrReplaceData(dataDictionary: pageInfo, toTable: "savedPages", toDBFile: "DafYomi.sqlite")
        }
    }
    
    func numberOfDaysToCycleComplition() -> Int
    {
        let currentDate = Date()
        
        var nextCycleDate = self.cycleStaretDate
        
        while currentDate.isLessThanDate(nextCycleDate) == false
        {
            var dateComponent = DateComponents()
            dateComponent.day = 2711
            nextCycleDate = Calendar.current.date(byAdding: dateComponent, to: nextCycleDate)!
        }
        
        let numberOfDaysToCycleComplition = currentDate.numberOfDaysToDate(nextCycleDate)
        
       return numberOfDaysToCycleComplition
    }
    
    func extrectMaggidShioursFromLessons(_ lessons:[Lesson]) -> [MaggidShiur]
    {
        var maggidShiours = [MaggidShiur]()
        var maggidShiourIds = [String]()
        
        for lesson in lessons
        {
            //If new MaggidShiur, add it to the maggidShiours array
            if maggidShiourIds.contains(lesson.maggidShiur.id) == false
            {
                maggidShiourIds.append(lesson.maggidShiur.id)
                maggidShiours.append(lesson.maggidShiur)
            }
        }
        
        return maggidShiours
    }
    
    lazy var homeMenuItems:[MenuItem] = {
        
        let menuItem_Contents = MenuItem(dictionary:["name":"Contents","title":"Contents","imageName":"tchanim_icon.png"])
        
        let menuItem_AudioLessons = MenuItem(dictionary:["name":"AudioLessons","title":"Audio Lessons","imageName":"shema_icon.png"])
        
        let menuItem_VideoLesson = MenuItem(dictionary:["name":"VideoLesson","title":"Video Lesson","imageName":"live_icon.png"])
        
        let menuItem_Talmud = MenuItem(dictionary:["name":"Talmud","title":"Talmud","imageName":"talmus_icon.png"])
        
        let menuItem_AramicDictoianry = MenuItem(dictionary:["name":"AramicDictoianry","title":"Aramic Dictoianry","imageName":"milon_icon.png"])
        
        let menuItem_BriefPage = MenuItem(dictionary:["name":"BriefPage","title":"Brief Page","imageName":"hadaf_icon.png"])
        
        let menuItem_Calendar = MenuItem(dictionary:["name":"Calendar","title":"Calendar","imageName":"Calender_icon_empty.png"])
        
        let menuItem_Forum = MenuItem(dictionary:["name":"Forum","title":"Forum","imageName":"forum_icon.png"])
        
        let menuItem_Search = MenuItem(dictionary:["name":"Search","title":"Search In Talmud","imageName":"hipusShas_icon.png"])
        
        let menuItem_Chavrusa = MenuItem(dictionary:["name":"Chavrusa","title":"Chavrusa","imageName":"havruta_icon.png"])
        
        let menuItem_LessonMap = MenuItem(dictionary:["name":"LessonMap","title":"Lesson Map","imageName":"map_icon.png"])
        
        let menuItem_Accessories = MenuItem(dictionary:["name":"Accessories","title":"Accessories","imageName":"azarim_icon.png"])
        
        let menuItem_About = MenuItem(dictionary:["name":"About","title":"About","imageName":"about_icon.png"])
        
        let menuItem_TheDafYomiProject = MenuItem(dictionary:["name":"TheDafYomiProject","title":"The_Daf_Yomi_Project","imageName":"mifal_hdaf_icon"])
        
        let menuItem_PagesSummary = MenuItem(dictionary:["name":"PagesSummary","title":"Page Summary","imageName":"hadaf_icon.png"])
        
        let menuItem_ContactUs = MenuItem(dictionary:["name":"ContactUs","title":"ContactUs","imageName":"ContactUs_icon.png"])
        
        let menuItem_Surveys = MenuItem(dictionary:["name":"Surveys","title":"Surveys","imageName":"seker_icon.png"])
        
        let menuItem_Siyum = MenuItem(dictionary:["name":"Maschet_Complition","title":"Maschet Complition","imageName":"sium_icon.png"])
        
        let menuItem_QandA = MenuItem(dictionary:["name":"Q&A","title":"Q&A","imageName":"questions_icon.png"])
        
        let menuItem_Forums = MenuItem(dictionary:["name":"Forums","title":"Forums","imageName":"forum_icon.png"])
        
        
        let menuItems = [menuItem_Talmud,
                         menuItem_AudioLessons,
                         menuItem_Contents,
                         menuItem_Forums,
                         menuItem_Calendar,
                         menuItem_PagesSummary,
                         menuItem_AramicDictoianry,
                         menuItem_Accessories,
                         menuItem_LessonMap,
                         menuItem_Chavrusa,
                         menuItem_Search,
                         menuItem_Siyum,
                         menuItem_Surveys,
                         menuItem_QandA,
                         menuItem_TheDafYomiProject,
                         menuItem_About,
                         ]
        return menuItems
    }()
    
    lazy var bottomBarItems:[MenuItem] = {
        
        var menuItems = [MenuItem]()
        menuItems.append(MenuItem(dictionary:["name":"Home","title":"Home","imageName":"Home icon_ios.png"]))
        menuItems.append(contentsOf: self.homeMenuItems)
        
        /*
        var menuItems = [MenuItem]()
        
        menuItems.append(MenuItem(dictionary:["name":"Talmud","title":"Talmud","imageName":"talmus_icon.png"]))
        
        menuItems.append(MenuItem(dictionary:["name":"AudioLessons","title":"Audio Lessons","imageName":"shema_icon.png"]))
        menuItems.append(MenuItem(dictionary:["name":"Search","title":"Search","imageName":"hipusShas_icon.png"]))
        menuItems.append(MenuItem(dictionary:["name":"Q&A","title":"qus","imageName":"questions_icon.png"]))
        menuItems.append(MenuItem(dictionary:["name":"Contents","title":"Contents","imageName":"tchanim_icon.png"]))
        menuItems.append(MenuItem(dictionary:["name":"Calendar","title":"Calendar","imageName":"Calender_icon_empty.png"]))
        
        menuItems.append(MenuItem(dictionary:["name":"AramicDictoianry","title":"Aramic Dictoianry","imageName":"milon_icon.png"]))
        menuItems.append(MenuItem(dictionary:["name":"Accessories","title":"Accessories","imageName":"azarim_icon.png"]))
        menuItems.append(MenuItem(dictionary:["name":"About","title":"About","imageName":"about_icon.png"]))
        */
        return menuItems
    }()
    
    func saveNote(_ note:Note)
    {
        //Check and remove old notes on page
        self.removeNote(note)
        
        var notesList = [[String:Any]]()
        
        if let savedNotes = UserDefaults.standard.object(forKey:"savedNotes") as? [[String:Any]]
        {
            notesList = savedNotes
        }
        
        if let noteContent = note.content
            ,noteContent.count > 1
        {
            notesList.append(note.deserializeDictioanry())
            
            UserDefaults.standard.set(notesList, forKey: "savedNotes")
            UserDefaults.standard.synchronize()
            
            self.savedNotes.append(note)
        }
    }
    
    func removeNote(_ note:Note)
    {
        var notesList = [[String:Any]]()
        
        if let savedNotes = UserDefaults.standard.object(forKey:"savedNotes") as? [[String:Any]]
        {
            notesList = savedNotes
            
            //Remove old notes on page
            var oldNoteIndex = [Int]()
            for index in 0 ..< notesList.count
            {
                let noteInfo = notesList[index]
                
                if let savedNotseId = noteInfo["id"] as? String
                    ,savedNotseId == note.id
                {
                    oldNoteIndex.append(index)
                }
            }
            notesList.remove(at: oldNoteIndex)
            
            self.savedNotes.remove(note)
            
        }
        
        UserDefaults.standard.set(notesList, forKey: "savedNotes")
        UserDefaults.standard.synchronize()
        
    }
    
    func getNoteByPageIndex(_ pageId:String) -> Note
    {
        for note in self.savedNotes
        {
           if note.id == "pageNote_\(pageId)"
           {
            return note
            }
        }
        
        let note = Note()
        note.id = "pageNote_\(pageId)"
        return note
    }
    
    func hasNoteOnPage(pageId:String) -> Bool
    {
        for note in self.savedNotes
        {
            if note.id ==  "pageNote_\(pageId)"
            {
                return true
            }
        }
        return false
    }
    
    func savedPageFilePath(pageIndex:Int, type:TalmudDisplayType!) -> String? {
        
        //Check if page is saved in documnets
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

        if type == TalmudDisplayType.Vagshal {
            path += "/\(pageIndex).pdf"
        }
        else{
            path += "/\(pageIndex)_\(type.rawValue).pdf"
        }
        
        if FileManager.default.fileExists(atPath: path){
            return path
        }
        else{
            return nil
        }
    }
}
