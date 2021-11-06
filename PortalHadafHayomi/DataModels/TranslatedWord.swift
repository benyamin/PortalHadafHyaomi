//
//  TranslatedWord.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 30/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class TranslatedWord:DataObject
{
    var key:String = ""
    var keyDispaly:String = ""
    var translatoin:String = ""
    var translatoin_clean:String = ""
    var sorce:String = ""
    
    lazy var defaultTranslatoin:String = {
        
        var defaultTranslatoin = self.translatoin
        if self.translatoin.range(of:";") != nil
        {
            let words = self.translatoin.components(separatedBy: ";")
            defaultTranslatoin = words.first!
        }
        return defaultTranslatoin
    }()
    
    init(info:[String:String])
    {
        super.init()
        
        self.keyDispaly = info["keyDispaly"] ?? ""
        self.key =  info["key"] ?? ""
        self.translatoin = info["translatoin"] ?? ""
        self.translatoin_clean = info["translatoin_clean"] ?? ""
        self.sorce = info["sorce"] ?? ""
        
    }
}
