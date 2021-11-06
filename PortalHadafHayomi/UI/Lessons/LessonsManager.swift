//
//  LessonsManager.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 12/08/2016.
//
//

import Foundation

class LessonsManager
{
    static let sharedManager =  LessonsManager()
    
    var playingLesson:Lesson?
    
    var lessons = [Lesson](){
        didSet{
            //Parse relevent maggid shiours for each masechet
            self.setMasechetotWithMagidShiours()
            
            //Parse all maggidShiours from lessons
            let maggidShiours = HadafHayomiManager.sharedManager.extrectMaggidShioursFromLessons(lessons)
            HadafHayomiManager.sharedManager.maggidShiurs = maggidShiours

            
            //Parse relevent masechtot for each maggidShiour
            self.setMaggidShioursMasechtot()
        }
    }
    
    func setMasechetotWithMagidShiours()
    {
        //Remove old maggid shoiors for all masehctot
        for masceht in HadafHayomiManager.sharedManager.masechtot
        {
            masceht.maggidShiurs.removeAll()
        }
        for lesson in lessons
        {
            if let masechet = lesson.masechet
            {
                masechet.maggidShiurs.append(lesson.maggidShiur)
            }
        }
    }
    
  
    
    func setMaggidShioursMasechtot()
    {
        for maggidShiour in HadafHayomiManager.sharedManager.maggidShiurs
        {
            maggidShiour.maschtot = [Masechet]()
            for lesson in lessons
            {
                if lesson.masechet != nil && lesson.maggidShiur.id == maggidShiour.id
                {
                    if maggidShiour.maschtot.contains(lesson.masechet) == false
                    {
                        maggidShiour.maschtot.append(lesson.masechet)
                    }
                }
            }
        }
    }
    
    func maggidShiur(maggidShiur:MaggidShiur, hasSavedLesonsOnMaschet maschet:Masechet, andPage page:Page) -> Bool
    {
        let array = ["maggidShiur"]
        
        if let pageSymbol = page.symbol
        , let maschetName = maschet.name
        , let maggidShiourName = maggidShiur.name
        {
            let query = "page='\(pageSymbol)' AND maschet='\(maschetName)' AND maggidShiur='\(maggidShiourName)'"
            
            if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
                ,queryObjectsInfo.count > 0
            {
                return true
            }
        }
     
        return false
    }
    
    func pathForLesson(_ lesson:Lesson) -> String
    {
        var lessonPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        lessonPath += ("/\(lesson.maggidShiur.name!)\(lesson.masechet.name!)\(lesson.page!.symbol!).mp3")
        
        return lessonPath
    }
    
    func pathForPage(pageIndex:Int) -> String
    {
        var pagePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
         pagePath += "/\(pageIndex).pdf"
        
        print ("filePath:\(pagePath)")
        
        return pagePath
    }
    
    func isSavedLesson(_ lesson:Lesson) -> Bool
    {
        //Check if page is saved in documnets
        
        let lessonPath = self.pathForLesson(lesson)
        let lessonFileExists = FileManager.default.fileExists(atPath: lessonPath)
        return lessonFileExists
    }
    
    func pagesSymbolesWithSavedLessonsOnMaschet(masechet:Masechet?, forMagidShiour maggidShiur:MaggidShiur?) -> [String]
    {
        
        if masechet == nil
        {
            return  [String]()
        }
        
        let array = ["page"]
        
        var query = "maschet='\(masechet!.name!)'"
        
        if maggidShiur != nil
        {
            query += " AND magidShiur='\(maggidShiur!.name!)'"
        }
        
        var savedPagesSymbols = [String]()
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
            
        {
            for dictionary in queryObjectsInfo
            {
                let pageSymbol = dictionary["page"] as! String
                
                if savedPagesSymbols.contains(pageSymbol) == false
                {
                    savedPagesSymbols.append(pageSymbol)
                }
            }
        }
        
        return savedPagesSymbols
    }
    
    
    func pagesWithSavedLessonsOnMaschet(mschet:Masechet?, forMagidShiour maggidShiur:MaggidShiur?) -> [Page]
    {
        if mschet == nil
        {
            return  [Page]()
        }
        let array = ["page"]
        
        var query = ""
        
        if mschet != nil
        {
            query += "maschet='\(mschet!.name!)'"
        }
        
        if maggidShiur != nil
        {
            query += " AND magidShiur='\(maggidShiur!.name!)'"
        }
        
        var savedPagesSymbols = [String]()

         if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
        
         {
            for dictionary in queryObjectsInfo
            {
                let pageSymbol = dictionary["page"] as! String
                
                if savedPagesSymbols.contains(pageSymbol) == false
                {
                    savedPagesSymbols.append(pageSymbol)
                }
            }
        }
        
        var savedPages = [Page]()
        for pageSymbol in savedPagesSymbols
        {
            let page = Page()
            page.symbol = pageSymbol
            savedPages.append(page)
        }
        return savedPages
    }
    
    func savedMaggidShiursOnMaschet(_ masceht: Masechet?, page:Page?) -> [MaggidShiur]
    {
        var maggidShiurs = [MaggidShiur]()
        
        let magidShiurNamesWithSavedLessons = self.magidShiurNamesWithSavedLessonsForMaschet(mascht: masceht, onPage: page)
        
        if masceht != nil
        {
            for magidShiur in masceht!.maggidShiurs
            {
                if magidShiurNamesWithSavedLessons.contains(magidShiur.name)
                {
                    maggidShiurs.append(magidShiur)
                }
            }
        }
        return maggidShiurs
    }
    
    func magidShiurNamesWithSavedLessonsForMaschet(mascht: Masechet?, onPage page:Page?) -> [String]
    {
        let array = ["magidShiur"]
        
        var query = ""
        
        if mascht != nil
        {
            query += "maschet='\(mascht!.name!)'"
        }
        
        if page != nil
        {
            query += " AND page='\(page!.symbol!)'"
        }
        
        var savedMagidShiurNames = [String]()
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
        {
            for dictionary in queryObjectsInfo
            {
                let magidShiurName = dictionary["magidShiur"] as! String
                
                if savedMagidShiurNames.contains(magidShiurName) == false
                {
                    savedMagidShiurNames.append(magidShiurName)
                }
            }
        }
        
        return savedMagidShiurNames
    }
    
    func magidShiurNamesWithSavedLessons() -> [String]
    {
        let array = ["maggidShiur"]
        
        var savedMagidShiurNames = [String]()
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: nil, fromDBFile: "DafYomi.sqlite")
        {
            for dictionary in queryObjectsInfo
            {
                let magidShiurName = dictionary["maggidShiur"] as! String
                
                if savedMagidShiurNames.contains(magidShiurName) == false
                {
                    savedMagidShiurNames.append(magidShiurName)
                }
            }
        }
        
        return savedMagidShiurNames
    }
    
    func maschtotWithSavedLessonsForMaggidShiur(magidShiour:MaggidShiur?) -> [String]
    {
        let array = ["maschet"]
        let query = magidShiour == nil ? "" : "maggidShiur='\(magidShiour!.name!)'"
        
        var savedMaschtotNames = [String]()
        
        if let queryObjectsInfo = SQLmanager.getData(array, from: "savedLessons", where: query, fromDBFile: "DafYomi.sqlite")
        {
            for dictionary in queryObjectsInfo
            {
                let maschetName = dictionary["maschet"] as! String
                
                if savedMaschtotNames.contains(maschetName) == false
                {
                    savedMaschtotNames.append(maschetName)
                }
            }
        }
        
        return savedMaschtotNames
    }
    
    func savedMaggidShiursFromList(maggidShiurs:[MaggidShiur]) -> [MaggidShiur]
    {
        let savedMaggidShiursNames = self.magidShiurNamesWithSavedLessonsForMaschet(mascht: nil, onPage: nil)
        
        var savedMaggidShiurs = [MaggidShiur]()
        
        for maggidShiur in maggidShiurs
        {
            if savedMaggidShiursNames.contains(maggidShiur.name)
            {
                savedMaggidShiurs.append(maggidShiur)
            }
        }
        
        return savedMaggidShiurs
    }
    
    func savedMaggidShiursOnMaschet(_ maschet:Masechet) -> [MaggidShiur]
    {
        let savedMaggidShiursNames = self.magidShiurNamesWithSavedLessonsForMaschet(mascht: maschet, onPage: nil)
        
        var savedMaggidShiurs = [MaggidShiur]()
        
        for maggidShiur in maschet.maggidShiurs
        {
            if savedMaggidShiursNames.contains(maggidShiur.name)
            {
                savedMaggidShiurs.append(maggidShiur )
            }
        }
        
        return savedMaggidShiurs
    }
    
    func savedMaschtotFromList(maschtot:[Masechet], forMagidShiour magidShiour:MaggidShiur?) -> [Masechet]
    {
        let savedMaschtotNames = self.maschtotWithSavedLessonsForMaggidShiur(magidShiour: magidShiour)
        
        var savedMaschtot = [Masechet]()
        
        for maschet in maschtot
        {
            if savedMaschtotNames.contains(maschet.name)
            {
                savedMaschtot.append(maschet)
            }
        }
        
        return savedMaschtot
    }

    func savedPagesFromList(pages:[Page], forMagidShiour magidShiour:MaggidShiur?, andMaschet maschet:Masechet?) -> [Page]
    {
        return [Page]()
        /*
        let savedPages = self.pagesWithSavedLessonsOnMaschet(mschet: maschet, forMagidShiour: magidShiour)
        
        var savedPagesFromList = [Page]()
        
        for page in pages
        {
            /*
            if savedPagesSymbols.contains(page.symbol)
            {
                savedPagesFromList.append(page)
            }
 */
        }
        
        return savedPagesFromList
 */
    }
    
    func savedMaschtotCount() -> Int
    {
        let savedMaschtotNames = self.maschtotWithSavedLessonsForMaggidShiur(magidShiour: nil)
        
        return savedMaschtotNames.count
    }
    
    func getLessonForMasechet(_ maschet:Masechet, andMaggidShiour maggidShiour:MaggidShiur) -> Lesson?
    {
        for lesson in self.lessons
        {
            if lesson.masechet == nil || lesson.maggidShiur == nil{
                continue
            }
            
            if lesson.masechet.id == maschet.id && lesson.maggidShiur.id == maggidShiour.id
            {
                return lesson
            }
        }
        return nil
    }
    
    func savePlayingLassonInfo(_ lesson:Lesson, duratoinInSeconds seconds:Int)
    {
        let lastPlayedLassonDictionary:[String : Any] = ["duration":seconds,
                                                         "lesson":lesson.deserializeDictioanry()]
        
        UserDefaults.standard.set(lastPlayedLassonDictionary, forKey: "lastPlayedLasson")
        UserDefaults.standard.set(Date(), forKey: "savedLessonDate")
        UserDefaults.standard.synchronize()
        
        //Save lesson status evry 5 seconds
        if seconds%5 == 0 {
            self.saveLessonStatus(lesson: lesson, duration: seconds)
        }
    }
    
    func lastPlayedLasson() -> Lesson?
    {
        if let lastPlayedLassonInfo = UserDefaults.standard.object(forKey: "lastPlayedLasson") as? [String:Any]
        {
           //Check if lesson saved is from a old app version, if true remove it
            if lastPlayedLassonInfo["Pageindex"] != nil
            {
                UserDefaults.standard.removeObject(forKey:"lastPlayedLasson")
                UserDefaults.standard.removeObject(forKey:"savedLessonDate")
                UserDefaults.standard.synchronize()
                
                return nil
            }
            else{
                if let lessonInfo = lastPlayedLassonInfo["lesson"] as? [String : Any]
                    , lessonInfo.count > 0
                {
                    let lesson = Lesson(dictionary:lessonInfo)
                    lesson.durration = lastPlayedLassonInfo["duration"] as? Int
                    return lesson
                }
                else{
                     return nil
                }
            }
          
        }
        return nil
    }
    
    func lastPlayedLessonDuration() -> Int?
    {
        if let lastPlayedLassonInfo = UserDefaults.standard.object(forKey: "lastPlayedLasson") as? [String:Any]
        {
            if let duration = lastPlayedLassonInfo["duration"] as? Int
            {
                return duration
            }
        }
       
        return nil
    }
    
    func saveLessonStatus(lesson:Lesson, duration:Int) {
        
        var lessonDeserilizedInfo = lesson.deserializeDictioanry()
        lessonDeserilizedInfo["lastDuration"] = duration > 3 ?  duration-3 : duration
        
        if var lastPlayedLessonsInfo = UserDefaults.standard.object(forKey: "lastPlayedLessonsInfo") as? [[String:Any]] {
          
            //Check if lesson is in the lastPlayedLessonsInfo and remove it before re adding it
            for index in 0 ..< lastPlayedLessonsInfo.count {
                
                let lessonInfo = lastPlayedLessonsInfo[index]
                if lessonInfo["masechtId"] == nil {
                    continue
                }
                let savedLesson = Lesson(dictionary: lessonInfo)
                
                if lesson.identifier == savedLesson.identifier{
                    lastPlayedLessonsInfo.remove(at:index)
                    break
                }
            }
            lastPlayedLessonsInfo.insert(lessonDeserilizedInfo, at: 0)
            
            if lastPlayedLessonsInfo.count > 50{
                lastPlayedLessonsInfo.removeLast()
            }
            UserDefaults.standard.setValue(lastPlayedLessonsInfo, forKey: "lastPlayedLessonsInfo")
        }
        else{
            var lastPlayedLessonsInfo = [[String:Any]]()
            lastPlayedLessonsInfo.append(lessonDeserilizedInfo)
            UserDefaults.standard.setValue(lastPlayedLessonsInfo, forKey: "lastPlayedLessonsInfo")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func getLastPlayedLessons() -> [Lesson] {
        
        var lessons = [Lesson]()
        
        if let lastPlayedLessonsInfo = UserDefaults.standard.object(forKey: "lastPlayedLessonsInfo") as? [[String:Any]]
        {
            for lessonInfo in lastPlayedLessonsInfo {
                let lesson = Lesson(dictionary: lessonInfo)
                lessons.append(lesson)
            }
        }
        
        return lessons
    }
}
