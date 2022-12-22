//
//  GetLessonsSettingsProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 22/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation

class GetLessonsSettingsProcess: MSBaseProcess
{
    lazy var setableItemsInfo:[[String:String]] = {
        
        var setableItemsInfo = [[String:String]]()
        
        setableItemsInfo.append(["key":"EnablesAutomaticPlaying",
                                 "title":"Enables_Automatic_Lesson_Playing",
                                 "type":"Bool"])
        
        setableItemsInfo.append(["key":"PlayLessonsInSequence",
                                 "title":"Play_Lessons_In_Sequence",
                                 "type":"Bool"])
        
        if HadafHayomiManager.sharedManager.maggidShiurs.count > 0
        {
            setableItemsInfo.append(["key":"DefaultMagidShiour",
                                     "title":"Default_Magid_Shiour",
                                     "type":"Selection"])
        }
        
        setableItemsInfo.append(["key":"LessonSkipInterval",
                                 "title":"Lesson_Skip_Interval",
                                 "type":"Selection"])
       
        setableItemsInfo.append(["key":"SaveLastLesson",
                                 "title":"save_last_lesson",
                                 "type":"Bool"])
                
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
