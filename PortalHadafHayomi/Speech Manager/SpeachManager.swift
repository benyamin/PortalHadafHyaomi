//
//  SpeachManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/08/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechMock:NSObject
{
    static public var speeches:[String]! = {
        
        var mockSpeeches = [String]()
        
         mockSpeeches.append("שלום פורטל בבקשה נגן את השיעור של הרב דוד קלופר על מסכת בבא קמא דף ק יוד")
         mockSpeeches.append("כן")
        mockSpeeches.append("דוד קלפר")
         mockSpeeches.append("כן")
        /*
         mockSpeeches.append("שלום פורטל נגן שיעור")
         mockSpeeches.append("שלום פורטל")
        mockSpeeches.append("כן")
        mockSpeeches.append("בבא מצע")
        mockSpeeches.append("כן")
        mockSpeeches.append("קיודד")
        mockSpeeches.append("כן")
        mockSpeeches.append("דוד קלפר")
        mockSpeeches.append("כן")
         mockSpeeches.append("כן")
 */
        
        return mockSpeeches
    }()
}


public class SpeechManager: NSObject
{
    static public let sharedManager =  SpeechManager()
     
    
    let lettersBrakeDown:[String:String] = {
        
        var lettersBrakeDown = [String:String]()
        lettersBrakeDown["א"] = "אלף"
        lettersBrakeDown["ב"] = "בית"
        lettersBrakeDown["ג"] = "גימל"
        lettersBrakeDown["ד"] = "דלד"
        lettersBrakeDown["ה"] = "היי"
        lettersBrakeDown["ו"] = "וו"
        lettersBrakeDown["ז"] = "זין"
        lettersBrakeDown["ח"] = "חת"
        lettersBrakeDown["ט"] = "טת"
        lettersBrakeDown["י"] = "יוד"
        lettersBrakeDown["כ"] = "חפ"
        lettersBrakeDown["ל"] = "למד"
        lettersBrakeDown["מ"] = "מם"
        lettersBrakeDown["נ"] = "נון"
        lettersBrakeDown["ס"] = "שמח"
        lettersBrakeDown["ע"] = "עין"
        lettersBrakeDown["פ"] = "פיי"
        lettersBrakeDown["צ"] = "צדיק"
        lettersBrakeDown["ק"] = "קוף"
        lettersBrakeDown["ר"] = "ריש"
        lettersBrakeDown["ש"] = "שין"
        lettersBrakeDown["ת"] = "תף"
        
        return lettersBrakeDown
    }()
    
    func brakeDownPageSymbols(_ pageSymbol:String) -> [String]
    {
        var numberOfOptions = 0
        for i in 0 ..< pageSymbol.count
        {
            numberOfOptions += Int(pow(Double(2),Double(i)))
        }
        
        var brakeDownPageSymbols = [String]()
        for number in 1 ... numberOfOptions
        {
            var binaryNumber = String(number, radix: 2)
            binaryNumber = pad(string: binaryNumber, toSize: pageSymbol.count)
            
            let characters = pageSymbol.map { String($0) }
            let numCharacters = binaryNumber.map { String($0) }
            
            var pageString = ""
            for numIndex in 0 ..< numCharacters.count
            {
                let numChar = numCharacters[numIndex]
                
                let char = characters[numIndex]
                if numChar == "0"
                {
                    pageString += char
                }
                else{
                    
                    pageString +=  self.lettersBrakeDown[char]!
                }
            }
            print (pageString)
            brakeDownPageSymbols.append(pageString)
        }
       return brakeDownPageSymbols
    }
    
    //MARK: IBActions and Cancel
    
    var speechSynthesizer = BTSpeechSynthesizer()
    
    var shouldWelcomeOnLoad:Bool!
    {
        get{
            if let appOpenSpeechNotificatoin = UserDefaults.standard.object(forKey: "setableItem_AppOpenSpeechNotificatoin") as? Bool
                ,appOpenSpeechNotificatoin == true
            {
                return true
            }
            else{
                return false
            }
        }
    }
    
    var shouldListen:Bool!
    {
        get{
            if let speechActivatoin = UserDefaults.standard.object(forKey: "setableItem_SpeechActivatoin") as? Bool
                ,speechActivatoin == true
            {
                return true
            }
            else{
                return false
            }
        }
    }
    
    func welcome()
    {
        self.speechSynthesizer.play("siri_instruction_Welcome",
                                    onComplete:{
                                        
                                        if SpeechManager.sharedManager.shouldListen
                                        {
                                            SpeechManager.sharedManager.listen()
                                        }
        })
    }
    
    func pad(string : String, toSize: Int) -> String {
        var padded = string
        if toSize - string.count > 0
        {
            for _ in 0..<(toSize - string.count) {
                padded = "0" + padded
            }
        }
        
        return padded
    }
    
    func listen()
    {
        if LessonsManager.sharedManager.lessons.count == 0
        {
            GetLessonsProcess().executeWithObject(nil, onStart: { () -> Void in
                
            }, onProgress: { (object) -> Void in
                LessonsManager.sharedManager.lessons = object as! [Lesson]
                
            }, onComplete: { (object) -> Void in
                LessonsManager.sharedManager.lessons = object as! [Lesson]
                self.listen()
                
            },onFaile: { (object, error) -> Void in })
            
            return
        }
        
        BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
            
            print ("speech:\(speech)")
                        
            var activationSpeeches = [String]()
            activationSpeeches.append("שלום פורטל")
            activationSpeeches.append("שלום פורטל הדף היומי")
            activationSpeeches.append("היי פורטל")
            activationSpeeches.append("שלום הדף היומי")
            activationSpeeches.append("היי הדף היומי")
            
      
            for activationSpeech in activationSpeeches
            {
                if speech.contains(activationSpeech)
                {
                    if speech.contains("דף")
                        && speech.contains("יומי")
                        && (speech.contains("נגן") || speech.contains("נגד"))
                    {
                        self.playTodaysPage()
                        return
                    }
                    else if (speech.contains("המשך")
                    && speech.contains("שיעור"))||(speech.contains("נגן")
                    && speech.contains("שיעור")
                     && speech.contains("אחרון"))
                    {
                         self.continueLastLesson()
                        return
                    }
                    
                    else if speech.contains("מסכת")
                        && speech.contains("דף")
                        
                    {
                        self.extractLessonFromSpeech(speech)
                        return
                    }
                        
                    else if (speech.contains("נגן")
                        || speech.contains("בחר")
                       || speech.contains("הפעל"))
                       && speech.contains("שיעור")
                        
                    {
                        self.runLessonSelectionDialog()
                        return
                    }
                }
            }
            
            for activationSpeech in activationSpeeches
            {
                let score = speech.levenshteinDistanceScore(to: activationSpeech, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
                
                if score > 0.8
                {
                    self.startLessonDialog()
                    return
                }
            }
            
            self.listen()
            
            
            print ("Did liston")
        })
    }
    
    func extractLessonFromSpeech(_ speech:String)
    {
        //If speech recoginzed spacificly the maseceht page and maggid shiour
        if let massechtName = speech.slice(from: "מסכת", to: "דף")
            ,let masechet = self.getMasechetFrom(massechtName)
            ,let pageName = speech.slice(from: "דף", to: nil)
            ,let page =  self.getPageFrom(pageName, pages: masechet.pages)
        {
            if speech.range(of: "שיעור") != nil
                ,let maggidShiourName = speech.slice(from: "שיעור", to: "מסכת")
                , let maggidShiour = self.getMaggidShiourFrom(maggidShiourName)
            {
                if let lesson = self.getLessonForMasechet(masechet, page: page, andMaggidShiour: maggidShiour)
                {
                    self.playLesson(lesson)
                }
            }
            else{
                
                if let lesson = self.defaultLessonForMasecht(masechet, page: page)
                {
                    self.playLesson(lesson)
                }
                else{
                    self.selectMaggidShiourOnMasechet(masechet, page: page)
                }
            }
        }
        else{
            if let massechtName = speech.slice(from: "מסכת", to: "דף")
                ,let recommendedMasechet = self.getRecommendedMasechetFrom(massechtName)
                ,let pageName = speech.slice(from: "דף", to: nil)
                ,let recommendedPage =  self.getRecommendedPagetFrom(pageName, pages: recommendedMasechet.pages)
            {
                    if speech.range(of: "שיעור") != nil
                        ,let maggidShiourName = speech.slice(from: "שיעור", to: "מסכת")
                        , let recommendedMaggidShiour = self.getRecommendedMaggidShiourFrom(maggidShiourName)
                    {
                        self.playDidYouMeanMasechet(recommendedMasechet, page: recommendedPage, andMaggiShiour:recommendedMaggidShiour)
                    }
                    else{
                        self.playDidYouMeanMasechet(recommendedMasechet, andPage: recommendedPage)
                    }
            }
        }
    }
        
    
    func playDidYouMeanMasechet(_ masechet:Masechet, page:Page, andMaggiShiour maggidShiour:MaggidShiur)
    {
        self.speechSynthesizer.play("siri_hahim_itkavanta_le", onComplete:{
            
            self.speechSynthesizer.play("siri_magid_hashiur", onComplete:{
                self.speechSynthesizer.play("siri_magid_\(maggidShiour.id!)", onComplete:{
                    self.speechSynthesizer.play("siri_masechet", onComplete:{
                        self.speechSynthesizer.play("siri_masechet_\(masechet.id!)", onComplete:{
                            self.speechSynthesizer.play("siri_page", onComplete:{
                                self.speechSynthesizer.play("siri_page_\(page.index!+1)", onComplete:{
                                    
                                    BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                                        if speech.hasSuffix("לא")
                                        {
                                            self.runLessonSelectionDialog()
                                        }
                                        else{
                                            if let lesson = self.getLessonForMasechet(masechet, page: page, andMaggidShiour: maggidShiour)
                                            {
                                                self.playLesson(lesson)
                                            }
                                        }
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
    
    func playDidYouMeanMasechet(_ masechet:Masechet, andPage page:Page)
    {
        self.speechSynthesizer.play("siri_hahim_itkavanta_le", onComplete:{
            self.speechSynthesizer.play("siri_masechet", onComplete:{
                self.speechSynthesizer.play("siri_masechet_\(masechet.id!)", onComplete:{
                    self.speechSynthesizer.play("siri_page", onComplete:{
                        self.speechSynthesizer.play("siri_page_\(page.index!+1)", onComplete:{
                            
                            BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                                if speech.hasSuffix("לא")
                                {
                                    self.runLessonSelectionDialog()
                                }
                                else{
                                    self.selectMaggidShiourOnMasechet(masechet, page: page)
                                }
                            })
                        })
                    })
                })
            })
        })
    }
    
    func defaultLessonForMasecht(_ masechet:Masechet, page:Page) -> Lesson?
    {
        if let defaultMagidShiourId =  UserDefaults.standard.object(forKey: "DefaultMagidShiour") as? String
        {
            for maggidShior in masechet.maggidShiurs
            {
                if maggidShior.id == defaultMagidShiourId
                {
                    if let lesson = LessonsManager.sharedManager.getLessonForMasechet(masechet, andMaggidShiour: maggidShior)?.copy() as? Lesson
                    {
                        lesson.page = page
                       return lesson
                    }
                }
            }
        }
        return nil
    }
    
    func playTodaysPage()
    {
        if LessonsManager.sharedManager.lessons.count == 0
        {
            GetLessonsProcess().executeWithObject(nil, onStart: { () -> Void in
                
            }, onProgress: { (object) -> Void in
                LessonsManager.sharedManager.lessons = object as! [Lesson]
                
            }, onComplete: { (object) -> Void in
                LessonsManager.sharedManager.lessons = object as! [Lesson]
                
                self.playTodaysPage()
                
            },onFaile: { (object, error) -> Void in })
        }
        else{
            
            if let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet
                ,let todaysPage = HadafHayomiManager.sharedManager.todaysPage
            {
                if let defaultMagidShiourId =  UserDefaults.standard.object(forKey: "DefaultMagidShiour") as? String
                {
                    for maggidShior in todaysMaschet.maggidShiurs
                    {
                        if maggidShior.id == defaultMagidShiourId
                        {
                            if let lesson = LessonsManager.sharedManager.getLessonForMasechet(todaysMaschet, andMaggidShiour: maggidShior)?.copy() as? Lesson
                            {
                                lesson.page = todaysPage
                                self.playLesson(lesson)
                                
                            }
                            else{
                                self.listen()
                            }
                            
                            return
                        }
                    }
                }
                else{
                    self.selectMaggidShiourOnMasechet(todaysMaschet, page: todaysPage)
                }
            }
            
        }
    }
    
    func continueLastLesson()
    {
        if let lesson = LessonsManager.sharedManager.lastPlayedLasson()
        {
             self.playLesson(lesson)
        }
        else{
            self.speechSynthesizer.play("siri_instruction_TheSystemNotFoundTheReqShiur", onComplete:{
                self.listen()
            })
        }
    }
    
    func startLessonDialog()
    {
        self.speechSynthesizer.play("siri_instruction_HelloAreYouInterstedHearingAShiur", onComplete:{
            
            BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                
                if speech.hasSuffix("כן")
                {
                    self.runLessonSelectionDialog()
                }
                else{
                    self.listen()
                }
            })
        })
    }
        
    func stopListening()
    {
         print ("stopListening")
    }
    
    func runLessonSelectionDialog()
    {
        if LessonsManager.sharedManager.lessons.count == 0
        {
            GetLessonsProcess().executeWithObject(nil, onStart: { () -> Void in
                
            }, onProgress: { (object) -> Void in
                LessonsManager.sharedManager.lessons = object as! [Lesson]
                
                 self.runLessonSelectionDialog()
                
            }, onComplete: { (object) -> Void in
                
                 LessonsManager.sharedManager.lessons = object as! [Lesson]
                
            },onFaile: { (object, error) -> Void in })
        }
        else{
            
            self.speechSynthesizer.play("siri_instruction_ChooseMasehet", onComplete:{
                
                self.selectMasechet()
            })
        }
    
    }
    
    func selectMasechet()
    {
        
        BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
            
            let speechForMasechet = speech
            if let masechet = self.getMasechetFrom(speechForMasechet)
            {
                self.selectPageForMasechet(masechet)
            }
            else if let recommendedMasechet = self.getRecommendedMasechetFrom(speech)
            {
                self.speechSynthesizer.play("siri_instruction_DidYouMeanToMasechet", onComplete:{
                    
                    self.speechSynthesizer.play("siri_masechet_\(recommendedMasechet.id!)", onComplete:{
                        
                        BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                            
                            if speech.hasSuffix("לא")
                            {
                                self.runLessonSelectionDialog()
                            }
                            else{
                                
                                self.saveRecommendedSpeech(speech: speechForMasechet, recommendedString: recommendedMasechet.name)
                                
                                self.selectPageForMasechet(recommendedMasechet)
                            }
                        })
                    })
                })
            }
        })
    }
    
  
    func saveRecommendedSpeech(speech:String, recommendedString:String)
    {
            if var recommendedSpeeches = UserDefaults.standard.object(forKey: "recommendedSpeeches") as? [String:Any]
            {
                recommendedSpeeches[speech] = recommendedString
                UserDefaults.standard.set(recommendedSpeeches, forKey:"recommendedSpeeches")
                UserDefaults.standard.synchronize()
            }
            else{
                var recommendedSpeeches = [String:Any]()
                
                recommendedSpeeches[speech] = recommendedString
                
                UserDefaults.standard.set(recommendedSpeeches, forKey:"recommendedSpeeches")
                UserDefaults.standard.synchronize()
            }
    }
    
    func setSpeechIterations(speech:String)
    {
        if var speechIterationNumber =  UserDefaults.standard.object(forKey: "speechIterationNumber") as? [String:Int]
        {
            let iteratoins = speechIterationNumber[speech] ?? 0
            
            speechIterationNumber[speech] = iteratoins + 1
            
            UserDefaults.standard.set(speechIterationNumber, forKey: "speechIterationNumber")
            UserDefaults.standard.synchronize()
        }
        else{
            var speechIterationNumber = [String:Int]()
            
            speechIterationNumber[speech] = 1
            UserDefaults.standard.set(speechIterationNumber, forKey: "speechIterationNumber")
            UserDefaults.standard.synchronize()
        }
    }
    
    func getSpeechIterations(_ speech:String) -> Int
    {
        if let speechIterationNumber =  UserDefaults.standard.object(forKey: "speechIterationNumber") as? [String:Int]
        {
            return speechIterationNumber[speech] ?? 0
        }
        else{
            return 0
        }
    }
    
    func selectPageForMasechet(_ masechet:Masechet)
    {
        self.speechSynthesizer.play("siri_instruction_ChooswDaf", onComplete:{
            
            BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                
                print ("page:\(speech)")
                
                let speechForPage = speech.trimmeSpaces()

                if let page = self.getPageFrom(speechForPage, pages: masechet.pages)
                {
                    self.selectMaggidShiourOnMasechet(masechet, page:page)
                }
                else if let recommendedPage = self.getRecommendedPagetFrom(speech.trimmeSpaces(), pages: masechet.pages)
                {
                    self.speechSynthesizer.play("siri_instruction_DidYouMeanPage", onComplete:{
                        
                        self.speechSynthesizer.play("siri_page_\(recommendedPage.index!+1)", onComplete:{
                            
                            BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                                
                                if speech.hasSuffix("לא")
                                {
                                    self.selectPageForMasechet(masechet)
                                }
                                else{
                                     self.saveRecommendedSpeech(speech: speechForPage, recommendedString: recommendedPage.symbol)
                                    
                                    self.selectMaggidShiourOnMasechet(masechet, page: recommendedPage)
                                }
                            })
                        })
                    })
                }
            })
        })
    }
    
    func selectMaggidShiourOnMasechet(_ masechet:Masechet, page:Page)
    {
        self.speechSynthesizer.play("siri_instruction_ChooseMagidShiur", onComplete:{
            
            BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                
                print ("maggidShiour:\(speech)")
                
                let speechForMaggidShiour = speech
                if let maggidShiour = self.getMaggidShiourFrom(speechForMaggidShiour)
                {
                    if let lesson = self.getLessonForMasechet(masechet, page: page, andMaggidShiour: maggidShiour)
                    {
                         self.playLesson(lesson)
                    }
                }
                else if let recommendedMaggidShiour = self.getRecommendedMaggidShiourFrom(speech)
                {
                    /*
                    let maggidShiourNameAudioPath = "siri_magid_\(recommendedMaggidShiour.id!)"
                    guard Bundle.main.path(forResource: maggidShiourNameAudioPath, ofType: "mp3") != nil else {
                        print ("nononoonoo")
                        return
                    }
 */
                    
                    self.speechSynthesizer.play("siri_instruction_DidYouMeanToMagidShiur", onComplete:{
                       
                        print ("recommended maggid shiour: \(recommendedMaggidShiour.localizedName!) id:\(recommendedMaggidShiour.id!)")
                            self.speechSynthesizer.play("siri_magid_\(recommendedMaggidShiour.id!)", onComplete:{
                            
                            BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                                
                                if speech.hasSuffix("לא")
                                {
                                    self.selectMaggidShiourOnMasechet(masechet, page: page)
                                }
                                else{
                                    
                                    self.saveRecommendedSpeech(speech: speechForMaggidShiour, recommendedString: recommendedMaggidShiour.name)
                                    
                                    if let lesson = self.getLessonForMasechet(masechet, page: page, andMaggidShiour: recommendedMaggidShiour)
                                    {
                                        self.playLesson(lesson)
                                    }
                                }
                            })
                        })
                    })
                }
            })
        })
    }
    
    func getLessonForMasechet(_ masechet:Masechet, page:Page, andMaggidShiour maggidShiour:MaggidShiur) -> Lesson?
    {
        
        for masehcetMaggidShiour in masechet.maggidShiurs
        {
            if masehcetMaggidShiour.id == maggidShiour.id
            {
                if let lesson = LessonsManager.sharedManager.getLessonForMasechet(masechet, andMaggidShiour: maggidShiour)?.copy() as? Lesson
                {
                    lesson.page = page
                    
                   return lesson
                }
            }
        }
        
        //If Selected Maggid shiour has no lessons on selected masechet
        self.speechSynthesizer.play("siri_instruction_NotFoundShiurimOf", onComplete:{
            self.speechSynthesizer.play("siri_magid_\(maggidShiour.id!)", onComplete:{
                self.speechSynthesizer.play("siri_instruction_OnMasehet", onComplete:{
                    self.speechSynthesizer.play("siri_masechet_\(masechet.id!)", onComplete:{
                        self.listen()
                    })
                })
            })
            
        })
        return nil
    }
    
    
    func playLesson(_ lesson:Lesson)
    {
      //  let audioOperatoins = OperationQueue()
       // audioOperatoins.cancelAllOperations()
        self.speechSynthesizer.play("siri_instruction_TheSystemLoadindTheReqShiur", onComplete:{
            
            LessonsManager.sharedManager.playingLesson = lesson
            
            let playerView = BTPlayerManager.sharedManager.sharedPlayerView
            playerView?.title = "מסכת \(lesson.masechet.name!) דף \(lesson.page!.symbol!)"
            playerView?.subTitle = lesson.maggidShiur.name
            
            self.isLoading = true
            
            self.perform(#selector(self.playLoadingBeep), with: nil, afterDelay: 2.0)
         
           // playerView?.setPlayerUrl(lesson.getUrl(),durration: lesson.durration ?? 0)
            playerView?.playerUrl = nil
            playerView?.setPlayerUrl(lesson.getUrl(),durration: lesson.durration ?? 0
            ,onReadyToPlay:{
                
                playerView?.onReadyToPlay = nil
                playerView?.onLessonNotFound = nil
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.playLoadingBeep), object: nil)
                
                self.isLoading = false
                
                playerView?.play()
                playerView?.setIsPlayingLayout()
                playerView?.setDuration(lesson.durration ?? 0)
                
                 NotificationCenter.default.post(name: Notification.Name("speechManagerDidLoadLesson"), object: nil, userInfo:["value":self])
                
            },onLessonNotFound:{
                
                playerView?.onReadyToPlay = nil
                playerView?.onLessonNotFound = nil
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.playLoadingBeep), object: nil)
                
                    self.isLoading = false
                self.speechSynthesizer.play("siri_instruction_TheSystemNotFoundTheReqShiur", onComplete:{
                    self.speechSynthesizer.play("siri_instruction_try_agin", onComplete:{
                        
                        BTSpeechSynthesizer().listen(onComplete:{(speech) -> Void in
                            
                            if speech.hasSuffix("כן")
                            {
                                self.playLesson(lesson)
                            }
                            else{
                                self.listen()
                            }
                        })
                    })
                  })
            }, onPlayerDidStop:{
                
            })

        })
    }
    
    var isLoading = false
    @objc func playLoadingBeep()
    {
        let beep = "siri_instruction_TheSystemLoadindTheReqShiur"
        //let beep = "ShortBeep"
        self.speechSynthesizer.play(beep, onComplete:{
            
            if self.isLoading
            {
                 self.perform(#selector(self.playLoadingBeep), with: nil, afterDelay: 2.0)
            }
        })
    }
    
    
    func getMasechetFrom(_ speach:String) -> Masechet?
    {
        print (speach)
        
        for masecht in HadafHayomiManager.sharedManager.masechtot
        {
            if speach.contains(masecht.name)
            {
                SpeechMock.speeches.removeFirst()
                
                return masecht
            }
        }
        
        if let recommendedSpeech = self.recommendedSpeechForSpeech(speach)
        {
             return self.getMasechetFrom(recommendedSpeech)
        }
       
        return nil
    }
    
    func getRecommendedMasechetFrom(_ speach:String) -> Masechet?
    {
        // var masecototScors = [String:Double]()
        var highScore = 0.0
        var matchedMasechet:Masechet?
        
        for masecht in HadafHayomiManager.sharedManager.masechtot
        {
            let score = masecht.name.levenshteinDistanceScore(to: speach, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
            
            if score > highScore
            {
                highScore = score
                matchedMasechet = masecht
            }
            
            // masecototScors[masecht.name] = score
        }
        return matchedMasechet
    }
    
    func getPageFrom(_ speach:String, pages:[Page]) -> Page?
    {
        for page in pages
        {
            if speach == page.symbol
            {
                SpeechMock.speeches.removeFirst()
                return page
            }
        }
        
        if let recommendedSpeech = self.recommendedSpeechForSpeech(speach)
        {
            return self.getPageFrom(recommendedSpeech, pages: pages)
        }
        
        return nil
    }
    
    func getRecommendedPagetFrom(_ speach:String, pages:[Page]) -> Page?
    {
        // var masecototScors = [String:Double]()
        var highScore = 0.0
        
        var matchedPage:Page?
        
        for page in pages
        {
            let score = page.symbol.levenshteinDistanceScore(to: speach, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
            print ("score:\(score): page:\(page.symbol!)")

            if score > highScore
            {
                highScore = score
                matchedPage = page
                 print ("*highScore:\(highScore)")
            }
            
            
            let pageSymbolBrakeDowns = self.brakeDownPageSymbols(page.symbol)
            
            for pageSymbolBrakeDown in pageSymbolBrakeDowns
            {
                let pageSymbolBrakeDownScore = pageSymbolBrakeDown.levenshteinDistanceScore(to: speach, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
                
                if pageSymbolBrakeDownScore > highScore
                {
                    highScore = pageSymbolBrakeDownScore
                    matchedPage = page
                    
                    print ("_highScore:\(highScore)")
                }
            }
        }
        return matchedPage
    }
    
    func getMaggidShiourFrom(_ speach:String) -> MaggidShiur?
    {
        print ("MaggidShiour:\(speach)")
        
        for maggidShiour in HadafHayomiManager.sharedManager.maggidShiurs
        {
            if speach.contains(maggidShiour.localizedName)
            {
                SpeechMock.speeches.removeFirst()
                return maggidShiour
            }
        }
        
        if let recommendedSpeech = self.recommendedSpeechForSpeech(speach)
        {
            return self.getMaggidShiourFrom(recommendedSpeech)
        }
        
        return nil
    }
    
    func getRecommendedMaggidShiourFrom(_ speach:String) -> MaggidShiur?
    {
        // var masecototScors = [String:Double]()
        var highScore = 0.0
        
        var matchedMaggidShiour:MaggidShiur?
        
        for maggidShiour in HadafHayomiManager.sharedManager.maggidShiurs
        {
            let score = maggidShiour.localizedName.levenshteinDistanceScore(to: speach, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
            
            if score > highScore
            {
                highScore = score
                matchedMaggidShiour = maggidShiour
            }
        }
        return matchedMaggidShiour
    }
    
    func recommendedSpeechForSpeech(_ speech:String) -> String?
    {
        if let recommendedSpeeches = UserDefaults.standard.object(forKey: "recommendedSpeeches") as? [String:Any]
        {
            for recommendedSpeech in recommendedSpeeches.keys
            {
                if recommendedSpeech == speech
                {
                    return recommendedSpeeches[recommendedSpeech] as? String
                }
            }
        }
        return nil
    }
    

}

