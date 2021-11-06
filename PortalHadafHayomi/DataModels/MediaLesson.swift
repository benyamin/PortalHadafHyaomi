//
//  MediaLesson.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 31/05/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

class MediaLesson:DataObject
{
    var path:String?
    var maggidShiurName:String?
    var title:String?
    var duration:Int?
    var info: String?
    var mediaType:String?
    var mediaTypeDesctiption:String?
    var pageSymmbol:String?
    var pageNumber:Int?
    var masechetHebrewName:String?
    var masechetEnglishName:String?
    var language:String?
    var durationDisplay:String?
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.path = dictionary["k"] as? String
        self.maggidShiurName = dictionary["ma"] as? String
        self.title = dictionary["sd"] as? String
        self.duration = dictionary["dur"] as? Int
        self.info = dictionary["tsd"] as? String
        self.mediaType = dictionary["e"] as? String
        self.mediaTypeDesctiption = dictionary["ss"] as? String
        self.pageSymmbol = dictionary["d"] as? String
        self.pageNumber = dictionary["sk"] as? Int
        self.masechetHebrewName = dictionary["m"] as? String
        self.masechetEnglishName = dictionary["me"] as? String
        self.language = dictionary["s"] as? String
        
        if self.duration != nil{
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional

            self.durationDisplay = formatter.string(from: TimeInterval(self.duration!))!
        }
    }
    
}
