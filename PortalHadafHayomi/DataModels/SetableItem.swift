//
//  SetableItem.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 30/01/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation


class SetableItem: DataObject {
    
    open var key:String?
    open var title:String?
    open var type:String?
    open var options:[String]?
    open var value:Any?
    open var infoUrlPath:String?
    
    var itemKey:String!{
        get{
            if let key = self.key
            {
               return "setableItem_" + key
            }
            else{
                return ""
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    override init(dictionary:[String:Any]) {
        super.init()
        
        self.key = dictionary["key"] as? String
        self.title = dictionary["title"] as? String
        self.type = dictionary["type"] as? String
        self.options = dictionary["options"] as? [String]
        self.infoUrlPath = dictionary["infoUrlPath"] as? String
        
        if let savedValue = UserDefaults.standard.object(forKey: self.itemKey)
        {
            self.value = savedValue
        }
        else{
            
            if self.key == "PlayLessonsInSequence"
            || self.key == "EnablesAutomaticPlaying"
            || self.key == "SpeechActivatoin"
            || self.key == "AppOpenSpeechNotificatoin"
            {
                self.setValue(false)
            }
            else if self.type == "Bool"
            {
                self.setValue(true)
            }
            else if self.type == "Selection"
            {
                if let options = self.options
                , options.count > 0
                {
                    self.value = options.first
                }
            }
        }
    }
    
    func setValue(_ value:Any)
    {
        self.value = value
        UserDefaults.standard.set(value, forKey: self.itemKey)
        UserDefaults.standard.synchronize()
        
        if self.key == "SpeechActivatoin"
        {
                if (value as! Bool) == true
                {
                    if BTSpeechSynthesizer.checkSpeechAuthorization() == true
                    {
                        if let didDownloadSiriInsturctions = UserDefaults.standard.object(forKey: "DownloadSiriInstructions_completed") as? Bool
                            ,didDownloadSiriInsturctions == true
                        {
                            SpeechManager.sharedManager.listen()
                        }
                        else{
                            
                            //Only after speach audio files are downaloded the speach can will be  atcivated trow the "SpeechActivatoinComplete" notificatoin
                            self.setValue(false)
                            
                            BTSpeechSynthesizer.downloadSpeechAudioFiles()
                        }
                    }
                    else{
                         self.setValue(false)
                    }
                   
                }
                else{
                    SpeechManager.sharedManager.stopListening()
                }
            }
        
        NotificationCenter.default.post(name: Notification.Name("settingsValueChanged"), object: nil, userInfo:["value":self])
    }
}
