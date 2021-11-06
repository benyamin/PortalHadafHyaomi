//
//  SaveLessonProcess.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 09/08/2016.
//
//

import Foundation

class SaveLessonProcess: MSBaseProcess, URLSessionTaskDelegate, URLSessionDownloadDelegate
{
    var lesson:Lesson!
    var downloadProgress:Float = 0.0

    open override func executeWithObj(_ obj:Any?)
    {
        self.lesson = obj as? Lesson
        
        self.saveLesson(lesson)
    }
    
    func saveLesson(_ lesson:Lesson)
    {
        if let lessonUrl = lesson.getUrl()
        {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            let task = session.downloadTask(with: lessonUrl)
            task.resume()
        }
        else{
             self.onFailWithError(nil)
        }
    }
    
    //MARK: - session delegate methods
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            self.downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            DispatchQueue.main.async(execute: {() -> Void in
                  self.onProgress?(self.lesson)
            })
        }
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        debugPrint("Download finished: \(location)")
       
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                
                if let errorCode = (downloadTask.response as? HTTPURLResponse)?.statusCode{
                    
                    let userInfo = ["Description": "serverError".localize()]
                    let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
                    
                    self.onFailWithError(error)
                }
                else{
                     self.onFailWithError(nil)
                }
                
              
                return
        }
        
        do {
            
            let fileNamed = self.fileNamedForLesson(self.lesson)
            
            let filePath = FileManager.filePathFor(fileNamed: fileNamed, ofType: "mp3")
            
            print ("filePath:\(filePath)")
            // after downloading your file you need to move it to your destination url
            try FileManager.default.moveItem(at: location, to: filePath)
            
            DispatchQueue.main.async(execute: {() -> Void in
               self.onDidSaveLesson(self.lesson)
            })
            
        } catch let error as NSError {
            print(error.localizedDescription)
            
           self.onFailWithError(error)
           
        }
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // debugPrint("Task completed: \(task), error: \(String(describing: error))")
        
        if error != nil
        {
            self.onFailWithError(error)
        }
    }
    
    func onDidSaveLesson(_ lesson:Lesson)
    {
        let lesonDictionary:[String:String] = ["magidShior":lesson.maggidShiur.name,
                                               "maschet":lesson.masechet.name,
                                               "page":lesson.page!.symbol]
        
        SQLmanager.insertOrReplaceData(dataDictionary: lesonDictionary, toTable: "savedLessons", toDBFile: "DafYomi.sqlite")
        
         self.onComplete?(self.lesson)
        
        self.lesson = nil
    }
    
    func fileNamedForLesson(_ lesson:Lesson) -> String
    {
         let fileNamed = ("\(self.lesson.maggidShiur.name!)\(self.lesson.masechet.name!)\(self.lesson.page!.symbol!)")
        
        return fileNamed
    }
    
    func onFailWithError(_ error:Error?)
    {
        var error = error
        
        if error == nil
        {
            let userInfo = ["Description": "serverError".localize()]
            error = NSError(domain: "PortalDomain", code: -1, userInfo: userInfo)
        }
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.onFaile?(self.lesson, error! as NSError)
        })
    }
}

