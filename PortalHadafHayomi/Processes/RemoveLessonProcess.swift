//
//  RemoveLessonProcess.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 10/08/2016.
//
//

import Foundation

class RemoveLessonProcess: MSBaseProcess//, LessonDownLoaderDelegate, UIAlertViewDelegate
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let lesson = obj as? Lesson
        {
          self.removeLesson(lesson)
        }
        else if let lessons = obj as? [Lesson]
        {
            self.removeLessons(lessons)
        }
    }
    
    func removeLesson(_ lesson:Lesson)
    {
        let path = LessonsManager.sharedManager.pathForLesson(lesson)
        
        if FileManager.default.fileExists(atPath: path)
        {
            do{
                try FileManager.default.removeItem(atPath:path)
                
                if lesson.maggidShiur.hasSubtitles{
                    let subtitlesFilePath = path.replacingOccurrences(of: "mp4", with: "srt")
                    
                    try FileManager.default.removeItem(atPath:subtitlesFilePath)
                }
                
                let lesonDictionary:[String:String] = ["magidShior":lesson.maggidShiur.name,
                                                       "maschet":lesson.masechet.name,
                                                       "page":lesson.page!.symbol]
                
                SQLmanager.deleteData(dataDictionary: lesonDictionary, fromTable: "savedLessons", inDBFile:"DafYomi.sqlite" )
                
                 self.onComplete?(lesson)
                
            }catch{
                print(error)
                
                self.onFaile!(lesson, error as NSError)
            }
        }
    }
    func removeLessons(_ lessons:[Lesson])
    {
        var lessonsInfo = [[String:String]]()
        for lesson in lessons
        {
            let path = LessonsManager.sharedManager.pathForLesson(lesson)
            
            if FileManager.default.fileExists(atPath: path)
            {
                do{
                    try FileManager.default.removeItem(atPath:path)
                    
                    let lesonDictionary:[String:String] = ["magidShior":lesson.maggidShiur.name,
                                                           "maschet":lesson.masechet.name,
                                                           "page":lesson.page!.symbol]
                    
                    lessonsInfo.append(lesonDictionary)
                    
                }catch{
                    print(error)
                }
            }
        }
        
          SQLmanager.deleteData(dataArray: lessonsInfo, fromTable: "savedLessons", inDBFile: "DafYomi.sqlite")
        
        self.onComplete?(lessons)

    }
}
