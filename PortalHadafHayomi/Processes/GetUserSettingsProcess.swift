//
//  GetUserSettingsProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 7 Adar II 5779.
//  Copyright © 5779 Binyamin Trachtman. All rights reserved.
//

import Foundation

class GetUserSettingsProcess: MSBaseProcess
{
    lazy var setableItemsInfo:[[String:String]] = {
        
        var setableItemsInfo = [[String:String]]()
        
        
        setableItemsInfo.append(["key":"Languages",
                                      "title":"Languages",
                                      "type":"Selection"])
        
        setableItemsInfo.append(["key":"TalmudDisplayType",
                                 "title":"Default_Page_Type",
                                 "type":"Selection"])
        
        if HadafHayomiManager.sharedManager.maggidShiurs.count > 0
        {
            setableItemsInfo.append(["key":"DefaultMagidShiour",
                                     "title":"Default_Magid_Shiour",
                                     "type":"Selection"])
        }
        
        setableItemsInfo.append(["key":"SavedPages",
                                 "title":"Saved_Pages",
                                 "type":"Selection"])
        
        setableItemsInfo.append(["key":"SavedLessons",
                                 "title":"Saved_Lessons",
                                 "type":"Selection"])
        
        setableItemsInfo.append(["key":"DefaultMenuItem",
                                 "title":"Default_MenuItem",
                                 "type":"Selection"])
        
        
        setableItemsInfo.append(["key":"DailyReminder",
                                 "title":"Daily_Reminder",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"AutoLock",
                                 "title":"Auto_Lock",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"LessonSkipInterval",
                                 "title":"Lesson_Skip_Interval",
                                 "type":"Selection"])
        
        setableItemsInfo.append(["key":"DefaultMenuItem",
                                 "title":"Default_MenuItem",
                                 "type":"Selection"])
        
        
        setableItemsInfo.append(["key":"EnablesAutomaticPlaying",
                                 "title":"Enables_Automatic_Lesson_Playing",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"PlayLessonsInSequence",
                                 "title":"Play_Lessons_In_Sequence",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"Donation",
                                 "title":"Donation",
                                 "type":"Selection"])
        
        setableItemsInfo.append(["key":"SpeechActivatoin",
                                 "title":"Speech_Activation",
                                 "type":"Bool",
                                 "infoUrlPath":"https://files.daf-yomi.com/files/app/siri/hebrew/siri-hesber.pdf"])
        
        setableItemsInfo.append(["key":"AppOpenSpeechNotificatoin",
                                 "title":"App_Open_Speech_Notificatoin",
                                 "type":"Bool"])
        
       // setableItemsInfo.append(["key":"MyPages",
       //                          "title":"My_Pages",
       //                          "type":"Selection"])
       
        
        return setableItemsInfo
    }()
    
    open override func executeWithObj(_ obj:Any?)
    {
        var setableItems = [SetableItem]()
        for setableItemInfo in self.setableItemsInfo
        {
            let setableItem = SetableItem(dictionary: setableItemInfo)
            
            setableItems.append(setableItem)
        }
        
        self.onComplete?(setableItems)
    }
}

