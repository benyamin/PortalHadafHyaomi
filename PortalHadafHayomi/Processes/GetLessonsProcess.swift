//
//  GetLessonsProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 05/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetLessonsProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let savedLessonsInfo = FileManager.readFromFile("lessons", ofType: "xml")
        {
            do {
                let xmlDoc = try AEXMLDocument(xmlData: savedLessonsInfo.data(using: .utf8)!)
                if let lessons = GetLessonsProcess.parseLessonsFromDictoinary(["xmlDoc":xmlDoc])
                {
                    self.onProgress!(lessons)
                    
                    //If at least a day past from last lssons request, run new request
                    if let dateModified = FileManager.fileModificationDate("lessons", ofType: "xml")
                    {
                        if true//Date.daysBetweenDates(firstDate: dateModified, secondDate: Date()) > 0
                        {
                            self.getNewLessonsList()
                        }
                        else{
                            self.onComplete!(lessons)
                        }
                    }
                }
                else{
                     self.getNewLessonsList()
                }
                
            } catch _ {
                self.getNewLessonsList()
            }
        }
        else{
            //Get the default lessons from the bundle
            if let defaultLessons = self.getDefaultLessons()
            {
                self.onProgress!(defaultLessons)
            }
            
            self.getNewLessonsList()
        }
    }
    
    func getDefaultLessons() -> [Lesson]?
    {
        if let filepath = Bundle.main.path(forResource: "lessons", ofType: "xml") {
            do {
                let defaultLessonsInfo = try String(contentsOfFile: filepath)
                let xmlDoc = try AEXMLDocument(xmlData: defaultLessonsInfo.data(using: .utf8)!)
                if let lessons = GetLessonsProcess.parseLessonsFromDictoinary(["xmlDoc":xmlDoc])
                {
                    return lessons
                }
               
            } catch {
            }
        }
        
        return nil
    }
    
    func getNewLessonsList()
    {
        let request = MSRequest()
        request.baseUrl = "https://files.daf-yomi.com/files/app"
        request.serviceName = "magid_shiors_android_https.xml"
        request.requiredResponseType = .XML
        request.httpMethod = GET
                
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            if let resposeData = request.responseData
            {
                if FileManager.write(text: resposeData, to: "lessons", ofType: "xml") == false
                {
                    print ("error did not wirte lessons to data base")
                }
            }
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if let lessons = GetLessonsProcess.parseLessonsFromDictoinary(responseDctinoary)
            {
                self.onComplete?(lessons)
            }
            else if error == nil
            {
                self.onComplete?(responseDctinoary)
            }
            else {
                self.onFaile?(responseDctinoary, error!)
            }
            
            
            
        },onFaile: { (object, error) in
            
            self.onFaile!(object, error)
            
        })
    }
    
    class func parseLessonsFromDictoinary(_ dictionary:[String:AnyObject]) -> [Lesson]?
    {
        let xmlDoc = dictionary["xmlDoc"] as! AEXMLDocument
        
        if let lessonsElments = xmlDoc.root["lessons"].all
        {
            var lessons = [Lesson]()
            
            for maachetLessons in lessonsElments
            {
                for lessonNode in maachetLessons.children
                {
                    var lessonInfo = [String:Any]()
                    
                    for lessonAttribute in lessonNode.attributes
                    {
                        lessonInfo[lessonAttribute.key] = lessonAttribute.value
                    }
                    
                    let lesson = Lesson(dictionary: lessonInfo)
                    lessons.append(lesson)
                }
            }
            
            return lessons
        }
        else{
            return nil
        }
    }
}
