//
//  MaggidShiur.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class  MaggidShiur:DataObject
{
    var id:String!
    var name:String!
    var language:String!
    var mediaType:MediaType = .All
    var localizedName:String!
    var hasSubtitles:Bool = false
    
    var isFavorite:Bool = false {
        didSet{
            if isFavorite {
                if var favoriteMagidiShiourIds = UserDefaults.standard.object(forKey:"favoriteMagidiShiour") as? [String] {
                    if favoriteMagidiShiourIds.contains(self.id) == false {
                        favoriteMagidiShiourIds.append(self.id)
                        UserDefaults.standard.setValue(favoriteMagidiShiourIds, forKey:"favoriteMagidiShiour")
                    }
                }
                else{
                    return UserDefaults.standard.setValue([self.id], forKey:"favoriteMagidiShiour")
                }
            }
            else{
                if var favoriteMagidiShiourIds = UserDefaults.standard.object(forKey:"favoriteMagidiShiour") as? [String] {
                    if let index = favoriteMagidiShiourIds.index(of: self.id){
                        favoriteMagidiShiourIds.remove(at: index)
                        UserDefaults.standard.setValue(favoriteMagidiShiourIds, forKey:"favoriteMagidiShiour")
                    }
                }
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var maschtot = [Masechet]()
    
    var hasSavedLessons:Bool = false
        
    override init()
    {
        super.init()
    }
    
    init(id:String, name:String, language:String, mediaType:MediaType, subtitles:Bool) {
        
        super.init()
        
        self.id = mediaType != .Video ? id : "\(id)_V"
        self.name = name
        self.language = language
        self.mediaType = mediaType
        self.hasSubtitles = subtitles
        
        if self.id != nil
        {
            self.localizedName = "st_maggid_\(id)".localize()
        }
        else{
            self.localizedName = self.name
        }
        
        if let favoriteMagidiShiourIds = UserDefaults.standard.object(forKey:"favoriteMagidiShiour") as? [String]
            ,favoriteMagidiShiourIds.contains(self.id) {
            self.isFavorite =  true
        }
        else{
            self.isFavorite =  false
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
