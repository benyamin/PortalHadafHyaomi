//
//  SavePageProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 24/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class SavePageProcess: MSBaseProcess, URLSessionTaskDelegate, URLSessionDownloadDelegate
{
    var pageInfo:(pageIndex:Int, type:TalmudDisplayType)!
    var downloadProgress:Float = 0.0
    
    open override func executeWithObj(_ obj:Any?)
    {
        if let pageInfo = obj as? (pageIndex:Int, type:TalmudDisplayType) {
            
            self.pageInfo = pageInfo
            self.savePage(pageInfo)
        }
    }
    
    func savePage(_ pageInfo:(pageIndex:Int, type:TalmudDisplayType))
    {
        var pageUrlPath = ("https://www.daf-yomi.com/Data/UploadedFiles/DY_Page/\(pageInfo.pageIndex).pdf")
        
        if pageInfo.type == .Chavruta {
            pageUrlPath = "http://files.daf-yomi.com/app/chavruta/\(pageInfo.pageIndex).pdf"
        }
        
        if let pageUrl = URL(string: pageUrlPath)
        {
           // let config = URLSessionConfiguration.background(withIdentifier: "\(self.pagepageIndex!)")
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
           let task = session.downloadTask(with: pageUrl)
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
                self.onProgress?(self)
            })
        }
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        debugPrint("Download finished: \(location)")
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                
                let errorCode = (downloadTask.response as? HTTPURLResponse)?.statusCode
                let userInfo = ["Description": "serverError".localize()]
                let error = NSError(domain: "PortalDomain", code: errorCode!, userInfo: userInfo)
                
                self.onFailWithError(error)
                
                return
        }
        
        do {
            
            var fileNamed = ("\(self.pageInfo.pageIndex)")
            if self.pageInfo.type != .Vagshal{
                fileNamed += "_\(self.pageInfo.type.rawValue)"
            }
            let filePath = FileManager.filePathFor(fileNamed: fileNamed, ofType: "pdf")
            
            print ("filePath:\(filePath)")
            // after downloading your file you need to move it to your destination url
            try FileManager.default.moveItem(at: location, to: filePath)
            
            OperationQueue.main.addOperation {
                self.onDidSavePage(self.pageInfo)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            
            OperationQueue.main.addOperation {
                self.onFailWithError(error)
            }
        }
    }
    
    func onDidSavePage(_ pageInfo:(pageIndex:Int, type:TalmudDisplayType))
    {
        if pageInfo.type == .Vagshal {
            let pageData = HadafHayomiManager.pageInfoForIndexInTalmud(pageInfo.pageIndex)
            
            if let masechet = pageData["maschet"] as? Masechet
               , let page = pageData["page"] as? Page
               , let pageSide =  pageData["pageSide"] as? Int
            {
                let pageDictoinary:[String:String] = ["number":("\(pageInfo.pageIndex)"),
                                                "maschet":masechet.name,
                                                "page":page.symbol,
                                                "pageside": ("\(pageSide)")]
                
                SQLmanager.insertOrReplaceData(dataDictionary: pageDictoinary, toTable: "savedPages", toDBFile: "DafYomi.sqlite")
                
            }
        }
        self.onComplete?(pageInfo.pageIndex)
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
       // debugPrint("Task completed: \(task), error: \(String(describing: error))")
        
        if error != nil
        {
            OperationQueue.main.addOperation {
                self.onFailWithError(error)
            }
        }
    }
    
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        OperationQueue.main.addOperation {
            self.onFailWithError(error)
        }
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
            self.onFaile?(self, error! as NSError)
        })
    }
    
}
