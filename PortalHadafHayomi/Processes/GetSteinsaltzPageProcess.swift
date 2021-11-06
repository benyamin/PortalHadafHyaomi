//
//  GetSteinsaltzPageProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/01/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetSteinsaltzPageProcess: MSBaseProcess
{
    var dataTask: URLSessionDataTask?
    
    lazy var englsihMasechtot:[String:String] = {
    
        var englsihMasechtot = [String:String]()
        englsihMasechtot["01"] = "Berakhot"
        englsihMasechtot["02"] = "Shabbat"
        englsihMasechtot["03"] = "Eruvin"
        englsihMasechtot["04"] = "Pesachim"
        englsihMasechtot["05"] = "Jerusalem_Talmud_Shekalim"
        englsihMasechtot["06"] = "Yoma"
        englsihMasechtot["07"] = "Sukkah"
        englsihMasechtot["08"] = "Beitzah"
        englsihMasechtot["09"] = "Rosh_Hashanah"
        englsihMasechtot["10"] = "Taanit"
        englsihMasechtot["11"] = "Megillah"
        englsihMasechtot["12"] = "Moed_Katan"
        englsihMasechtot["13"] = "Chagigah"
        englsihMasechtot["14"] = "Yevamot"
        englsihMasechtot["15"] = "Ketubot"
        englsihMasechtot["16"] = "Nedarim"
        englsihMasechtot["17"] = "Nazir"
        englsihMasechtot["18"] = "Sotah"
        englsihMasechtot["19"] = "Gittin"
        englsihMasechtot["20"] = "Kiddushin"
        englsihMasechtot["21"] = "Bava_Kamma"
        englsihMasechtot["22"] = "Bava_Metzia"
        englsihMasechtot["23"] = "Bava_Batra"
        englsihMasechtot["24"] = "Sanhedrin"
        englsihMasechtot["25"] = "Makkot"
        englsihMasechtot["26"] = "Shevuot"
        englsihMasechtot["27"] = "Avodah_Zarah"
        englsihMasechtot["28"] = "Horayot"
        englsihMasechtot["29"] = "Zevachim"
        englsihMasechtot["30"] = "Menachot"
        englsihMasechtot["31"] = "Chullin"
        englsihMasechtot["32"] = "Bekhorot"
        englsihMasechtot["33"] = "Arakhin"
        englsihMasechtot["34"] = "Temurah"
        englsihMasechtot["35"] = "Keritot"
        englsihMasechtot["36"] = "Meilah"
        englsihMasechtot["40"] = "Niddah"
        
        return englsihMasechtot
    }()
    
    open override func executeWithObj(_ obj:Any?)
    {
        let pageIndex = obj as! Int
        
       self.getPageByIndex(pageIndex)
    }
    
    func getPageByIndex(_ pageIndex:Int)
    {
        if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(pageIndex)
            ,let englishName = self.englsihMasechtot[masechet.id!]
            ,let page = HadafHayomiManager.sharedManager.getPageForPageIndex(pageIndex)
            ,let pageSide = HadafHayomiManager.sharedManager.getPageSideForPageIndex(pageIndex)
        {
            var params = [String:String]()
            
            //https://www.sefaria.org.il/api/texts/Steinsaltz_on_Berakhot.2a.4?commentary=0&context=1&pad=0&wrapLinks=1&multiple=0
          
        
            
           var baseUrl = "https://www.sefaria.org.il/api/texts/Steinsaltz_on_"
            baseUrl += englishName
            baseUrl += (".\(page.index!+1)")
            baseUrl += pageSide == 1 ? "a" : "b"
         
            dataTask?.cancel()
            
            if var urlComponents = URLComponents(string: baseUrl) {
                urlComponents.query = "commentary=0&context=1&pad=0&wrapLinks=0&multiple=0"
                
                guard let url = urlComponents.url else {
                    self.didFaile(error: nil)
                    return
                }
                
                let defaultSession = URLSession(configuration: .default)
                dataTask = defaultSession.dataTask(with: url) { data, response, error in
                    defer { self.dataTask = nil }
                    
                    if let error = error
                    {
                        self.didFaile(error: error)
                        
                    } else if let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200 {
                        
                        var fullText = "<br>"
                        
                        do {
                            
                            if let dictionary = try JSONSerialization.jsonObject(with: (data), options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]
                            {
                                
                                if let title = dictionary["heRef"] as? String
                                {
                                    fullText += "<font color=\"rgb(46,56,86)\">\(title)</font>"
                                    fullText += "<br><br>"
                                }
                                
                              
                                if let data = dictionary["he"]
                                {
                                    fullText += self.buildTextDispalyFromData(data)
                                }
                            }
                            
                            // 6
                            DispatchQueue.main.async {
                                
                              fullText =  "<!DOCTYPE html> <html dir=\"rtl\"> <head> <style> p.padding {padding-left: 1cm; padding-right: 1cm; padding-bottom: 0.5cm;} p.padding2 { padding-left: 50%; } </style> </head> <body> <p class=\"padding\">\(fullText)</p> </body> </html>"
                                
                             self.onComplete?(fullText)
                            }
                            
                        } catch {
                            self.didFaile(error: error)
                            
                        }
                        
                        
                    }
                }
                // 7
                dataTask?.resume()
            }
        }
        else{
            self.didFaile(error:nil)
        }
    }
    
    func buildTextDispalyFromData(_ data:Any) -> String {
        
        var fullText = ""
        
        if data is [String] {
            for text in (data as! [String])
            {
                fullText += text
                
                fullText += "<br><br>"
            }
        }
        else if data is [Any] {
            
            for element in (data as! [Any]) {
                fullText += self.buildTextDispalyFromData(element)
            }
        }
        return fullText
    }
    
    func didFaile(error:Error?)
    {
        if error == nil
        {
            let userInfo = ["Description": "serverError".localize()]
            let defaultError = NSError(domain: "PortalDomain", code: -1, userInfo: userInfo)
            
            self.onFaile?(self, defaultError as NSError)
        }
        else
        {
            self.onFaile?(self, error! as NSError)
        }
    }
    
    override open func cancel()
    {
       self.dataTask?.cancel()
        super.cancel()
    }
}
