//
//  DownloadSiriInstructions.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 12/10/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class DownloadSiriInstructions: MSBaseProcess
{
    var downloadProgress:Float = 0.0
    var operationQueue:OperationQueue?
    var completionOperation:BlockOperation?
    
    open override func executeWithObj(_ obj:Any?)
    {
        self.download()
    }
    
    func download()
    {
       self.createSiriInstructionsFolder()
        
        if let plistPath = Bundle.main.path(forResource: "speechAudioFiles", ofType: "plist")
        ,let speechAudioFiles = NSDictionary(contentsOfFile: plistPath) as? [String: [String]]
        {
            self.operationQueue = OperationQueue()
            self.operationQueue?.maxConcurrentOperationCount = 1
            
            self.completionOperation = BlockOperation {
                print ("complete operatoins")
                self.onComplete?(self)
            }
            
            for audioFolderName in speechAudioFiles.keys
            {
                if let audioFileNames = speechAudioFiles[audioFolderName]
                {
                    for audioFileName in audioFileNames
                    {
                        self.downlaodFile(audioFileName,folderName:audioFolderName, queue: self.operationQueue!, completionOperation: self.completionOperation!)
                    }
                }
            }
            
            OperationQueue.main.addOperation(self.completionOperation!)

        }
    }
    
    func createSiriInstructionsFolder()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get documents folder
        let documentsDirectory: String = paths.first ?? ""
        // Get your folder path
        let dataPath = documentsDirectory + "/siri_instructions"
        if !FileManager.default.fileExists(atPath: dataPath) {
            // Creates that folder if not exists
            try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    func downlaodFile(_ audioFileName:String, folderName:String, queue:OperationQueue, completionOperation:BlockOperation)
    {
        if let url = URL(string:"https://files.daf-yomi.com/files/app/siri/hebrew/\(folderName)/\(audioFileName).mp3")
        {
            let operation = DownloadOperation(session: URLSession.shared, downloadTaskURL: url, completionHandler: { (localURL, response, error) in
                
                if response != nil
                && localURL != nil
                {
                    self.urlaSession(response:response!, didFinishDownloadingTo: localURL!, fileName:audioFileName)
                }
              
                if error == nil
                {
                    print("finished downloading \(url.absoluteString)")
                }
                else{
                    print ("Download error:\(String(describing: error))")
                    self.onFailWithError(error)
                }

            })
            
            completionOperation.addDependency(operation)
            queue.addOperation(operation)
            
        }
    }
    

    open func urlaSession(response:URLResponse , didFinishDownloadingTo location: URL, fileName:String) {
        
        debugPrint("Download finished: \(location)")
        
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                
                let errorCode = (response as? HTTPURLResponse)?.statusCode
                let userInfo = ["Description": "serverError".localize()]
                let error = NSError(domain: "PortalDomain", code: errorCode!, userInfo: userInfo)
                
                self.onFailWithError(error)
                
                return
        }
        
        do {
            let filePath = FileManager.filePathFor(fileNamed: "siri_instructions/\(fileName)", ofType: "mp3")
            
            print ("filePath:\(filePath)")
            // after downloading your file you need to move it to your destination url
            try FileManager.default.moveItem(at: location, to: filePath)
            
            /*
            DispatchQueue.main.async(execute: {() -> Void in
                self.onDidSaveLesson(self.lesson)
            })
 */
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func onFailWithError(_ error:Error?)
    {
        self.completionOperation?.cancel()
        self.operationQueue?.cancelAllOperations()
       
        var error = error
        
        if error == nil
        {
            let userInfo = ["Description": "serverError".localize()]
            error = NSError(domain: "PortalDomain", code: -1, userInfo: userInfo)
        }
        
        DispatchQueue.main.async {
            
         self.onFaile?(self, error! as NSError)
            
        self.onFaile = nil
        self.onComplete = nil
            
        }
    }
}
