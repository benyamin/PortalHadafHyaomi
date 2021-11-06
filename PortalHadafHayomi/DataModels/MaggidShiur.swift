//
//  MaggidShiur.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

class  MaggidShiur:DataObject
{
    var id:String!
    var name:String!
    var language:String!
    var mediaType:MediaType = .All
    var localizedName:String!
    
    var maschtot = [Masechet]()
    
    var hasSavedLessons:Bool = false
        
    override init()
    {
        super.init()
    }
    
    init(id:String, name:String, language:String, mediaType:MediaType) {
        
        super.init()
        
        self.id = mediaType != .Video ? id : "\(id)_V"
        self.name = name
        self.language = language
        self.mediaType = mediaType
        
        if self.id != nil
        {
            self.localizedName = "st_maggid_\(id)".localize()
        }
        else{
            self.localizedName = self.name
        }
    }
    
    func hasSavedLessonForMasechet(_ masechet:Masechet?, andPage page:Page?) -> Bool
    {
       
        let array = ["magidShior"]
        
        var query = "magidShior='\(self.name!)'"
        
        if masechet != nil
        {
            query += " And maschet='\(masechet!.name!)'"
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
}
