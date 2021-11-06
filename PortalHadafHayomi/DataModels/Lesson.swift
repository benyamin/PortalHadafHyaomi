//
//  Lesson.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

public enum MediaType:String {
    case All = "all"
    case Audio = "audio"
    case Video = "video"
}

class Lesson:DataObject
{
    var masechet:Masechet!
    var page:Page?
    var maggidShiur:MaggidShiur!
    var audioBaseUrl:String?
    var language:String?
    var mediaType:MediaType?
    var additionlSuffix:String!
    var durration:Int?
    var durationDisplay:String?
    var lastDuration:Int?
    
    var isSelected:Bool = false
        
    override init() {
        super.init()
    }
    
    var identifier:String?{
        get{
            if let masecehtName =  self.masechet?.name
                ,let maggidShiurName = self.maggidShiur?.name
                ,let pageSymbol = self.page?.symbol
            {
                var identifier = ("\(masecehtName)_\(maggidShiurName)_\(pageSymbol)")
                if let mediaType = mediaType?.rawValue {
                    identifier += "_\(mediaType)"
                }
                return identifier
            }
            else{
                return ""
            }
        }
    }
    
    init(maschet:Masechet, page:Page, andMaggidShiur maggidShiur:MaggidShiur)
    {
        super.init()
        
        self.masechet = maschet
        self.page = page
        self.maggidShiur = maggidShiur
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.mediaType = (dictionary["type"] as? String ?? "audio") == "audio" ? .Audio : .Video
        self.additionlSuffix = dictionary["additionlSuffix"] as? String
        self.language = dictionary["language"] as? String
        
        if let baseUrl = dictionary["audioBaseUrl"] as? String
        {
            self.audioBaseUrl = baseUrl.withReplacedCharacters(" ", by: "")
        }
        
        if let pageIndex = dictionary["pageIndex"] as? Int
        {
            self.page = Page(index: pageIndex)
        }
        
        if let masechtId = dictionary["masechtId"] as? String
        {
            if let masechet = HadafHayomiManager.sharedManager.getMasechetById(masechtId)
            {
                self.masechet = masechet
            }
            else{
            }
        }
        
        self.durationDisplay = dictionary["durationDisplay"] as? String
        self.lastDuration = dictionary["lastDuration"] as? Int
        
        if let magidShiorId = dictionary["magidShiorId"] as? String
           ,let magidShiorName = dictionary["magidShior"] as? String
           ,let language =  dictionary["language"] as? String {
            
            self.maggidShiur = MaggidShiur(  id: magidShiorId, name: magidShiorName, language:language, mediaType:mediaType ?? .All)
        }
    }
    
    override func copy() -> Any
    {
        let copyLesson = Lesson()
        
        copyLesson.masechet = self.masechet
        copyLesson.page = self.page
        copyLesson.maggidShiur = self.maggidShiur
        copyLesson.audioBaseUrl = self.audioBaseUrl
        copyLesson.language = self.language
        copyLesson.mediaType = self.mediaType
        copyLesson.additionlSuffix = self.additionlSuffix
        
        return copyLesson
    }
    
    func deserializeDictioanry() -> [String:Any]
    {
        var deserializeDictioanry = [String:Any]()
        
        if self.mediaType == nil {
            return deserializeDictioanry
        }
        
        deserializeDictioanry["type"] = self.mediaType?.rawValue ?? "all"
        deserializeDictioanry["additionlSuffix"] = self.additionlSuffix
        deserializeDictioanry["audioBaseUrl"] = self.audioBaseUrl ?? ""
        deserializeDictioanry["language"] = self.language ?? ""
        deserializeDictioanry["masechtId"] = self.masechet.id!
        deserializeDictioanry["magidShiorId"] = self.maggidShiur.id
        deserializeDictioanry["magidShior"] = self.maggidShiur.name
        deserializeDictioanry["pageIndex"] = self.page?.index ?? 0
        deserializeDictioanry["durationDisplay"] = self.durationDisplay ?? ""
        
        
        return deserializeDictioanry
    }
    
    func getUrl() -> URL?
    {
        if LessonsManager.sharedManager.isSavedLesson(self)
        {
            let lessonPath = LessonsManager.sharedManager.pathForLesson(self)
            let lessonUrl = URL(fileURLWithPath: lessonPath)
            
            return lessonUrl
            
        }
        else if let lessonUrlPath = self.urlPath()
            ,let lessonUrl = URL(string: lessonUrlPath) {
            return lessonUrl
        }
        else{
            return nil
        }
    }
    
    func urlPath() -> String? {
        var additionlSuffix = ""
        
        let pageNumber=(self.page!.index+1);
        
        if(pageNumber < 10)
        {
            if self.additionlSuffix == "00"
            {
                additionlSuffix = "00"
            }
            else if self.additionlSuffix == "0"
            {
                additionlSuffix = "0"
            }
        }
        else if(pageNumber < 100)
        {
            if self.additionlSuffix == "00"
            {
                additionlSuffix = "0"
            }
        }
        if var lessonUrlPath = self.audioBaseUrl {
            
            lessonUrlPath += additionlSuffix
            lessonUrlPath += ("\(self.page!.index! + 1)")
            lessonUrlPath += "."
            lessonUrlPath += self.mediaType! == .Video ? "mp4" : "mp3"
            
            lessonUrlPath = lessonUrlPath.replacingOccurrences(of: " ", with: "%20")
            
            return lessonUrlPath
           
        }
        else {
            return nil
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let comparedLesson = object as? Lesson{
            
            if self.masechet.id == comparedLesson.masechet.id
                ,self.page?.index == comparedLesson.page?.index
                ,self.maggidShiur.id == comparedLesson.maggidShiur.id {
                
                return true
            }
        }
        return false
    }
}
