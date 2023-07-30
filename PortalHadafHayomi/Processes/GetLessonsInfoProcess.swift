//
//  GetLessonsInfoProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/05/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetLessonsInfoProcess: MSBaseProcess
{
    var request:MSRequest?
    
    open override func executeWithObj(_ obj:Any?)
    {
        let lesson = obj as! Lesson
        
        //http://app.daf-yomi.com/AjaxHandler.ashx?medialist=1&pagesize=15&page=1&massechet=284&medaf=80&addaf=80&safa=&maggid=&chofshi=&sort=massechet&dir=1
             
        var params = [String:String]()
        
        params["massechet"] = "\(lesson.masechet.index)"
        
        params["maggid"] = lesson.maggidShiur != nil ? "\(lesson.maggidShiur.id ?? "")" :  ""
        
        if let page = lesson.page {
            
            let pageIndex = (page.index ?? 1) + 1
            params["medaf"] = "\(pageIndex)"
            params["addaf"] = "\(pageIndex)"
          
        }
        else{
            params["medaf"] = "2"
            params["addaf"] = "\(lesson.masechet.numberOfPages ?? 0)"
        }
        
        params["medialist"] = "1"
        params["pagesize"] = "200"
        params["page"] = "1"
        params["dir"] = "1"
        
        let request = MSRequest()
        request.baseUrl = "http://daf-yomi.com"
        request.serviceName = "AjaxHandler.ashx"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        
        request.params = params
        
        self.runWebServiceWithRequest(request)
    }
    
     func runWebServiceWithRequest(_ request:MSRequest)
        {
            if let url = request.url
            {
                let request = URLRequest(url: url)
                let session = URLSession.shared
                
                session.dataTask(with: request) {data, response, error in
                    if error != nil {
                        
                        print(error!.localizedDescription)
                        DispatchQueue.main.async {
                            self.onFaile?(request.url?.absoluteString, error! as NSError)
                        }
                        return
                    }
                    
                    if data != nil
                    {
                        if String(data: data!, encoding: String.Encoding.utf8) != nil
                        {
                            if let responseArray = MSWebService.serializeData(jsonData:data!) as? [[String:Any]]
                            {
                                var mediaLessons = [MediaLesson]()
                                for info in responseArray{
                                    let mediaLesson = MediaLesson(dictionary: info)
                                    mediaLessons.append(mediaLesson)
                                }
                                DispatchQueue.main.async {
                                    self.onComplete?(mediaLessons)
                                }
                                
                            }
                        }
                    }
                    else{
                        let errorCode = -999
                        let userInfo = ["Description": "serverError".localize()]
                        let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
                        
                        DispatchQueue.main.async {
                            self.onFaile?(request.url?.absoluteString, error as NSError)
                        }
                    }
                }.resume()
            }
            else{
                
                let errorCode = -999
                let userInfo = ["Description": "serverError".localize()]
                let error = NSError(domain: "PortalDomain", code: errorCode, userInfo: userInfo)
                
                DispatchQueue.main.async {
                    self.onFaile?(request.url?.absoluteString, error as NSError)
                }
            }
        }
        
        override open func cancel()
        {
            super.cancel()
            
            if self.request != nil
            {
                NetworkingManager.sharedManager.cancelRequest(self.request!)
            }
        }
    }
