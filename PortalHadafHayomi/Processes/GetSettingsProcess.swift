//
//  GetSettingsProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 30/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

class GetSettingsProcess: MSBaseProcess
{
    lazy var setableItemsInfo:[[String:String]] = {
        
        var setableItemsInfo = [[String:String]]()
            
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
        
        setableItemsInfo.append(["key":"CounterDisplay",
                                 "title":"Counter_Display",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"SpeechActivatoin",
                                 "title":"Speech_Activatoin",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"SaveLastDisplayPage",
                                 "title":"save_last_displayed_page",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"saveLastLesson",
                                 "title":"save_last_lesson",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"saveLastSelectedPageInArticles",
                                 "title":"save_last_selected_page_in_articles",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"saveLasteSlectedPageInPageSummary",
                                 "title":"save_last_selected_page_in_page_summary",
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
