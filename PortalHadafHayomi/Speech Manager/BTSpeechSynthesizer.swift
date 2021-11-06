//
//  BTSpeechSynthesizer.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/09/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Speech

class BTSpeechSynthesizer:NSObject, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate
{
    let runMock = false
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var speechRequest:SFSpeechAudioBufferRecognitionRequest?
    
    var audioPlayer:AVAudioPlayer?
    
    var onComplete:(() -> Void)?
    var onCompleteRecording:((_ speech:String) -> Void)?
    
    var isRecording = false
    var speachEndedTimer:Timer?
    var audioEngine:AVAudioEngine?
    var recognitionTask: SFSpeechRecognitionTask?
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "he-IL"))
    
    deinit {
        print ("deinit BTSpeechSynthesizer")
    }
 
    class func checkSpeechAuthorization() -> Bool
    {
        if SFSpeechRecognizer.authorizationStatus() == .notDetermined
        {
            let alertTitle = "st_speech_recognizer_authorzatoin_alert_title".localize()
            let alertMessage = "st_speech_recognizer_authorzatoin_alert_message".localize()
            
            let okButtonTitle = "st_ok".localize()
            let cancelButtonTitle = "st_cancel".localize()
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [okButtonTitle,cancelButtonTitle], onComplete:{ (dismissButtonKey) in
                
                if dismissButtonKey == okButtonTitle
                {
                   self.requireSpeechtAuthorization()
                }
            })
            return false
        }
        else if SFSpeechRecognizer.authorizationStatus() == .authorized
        {
            return true
        }
        else{
            let alertTitle = "st_speech_recognizer_authorzatoin_denied_alert_title".localize()
            let alertMessage = "st_speech_recognizer_authorzatoin_denied_alert_message".localize()
            
            let okButtonTitle = "st_ok".localize()
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [okButtonTitle], onComplete:{ (dismissButtonKey) in
             
            })
            
            return false
        }
        
    }
    
    class func requireSpeechtAuthorization()
    {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // The authorization status results in changes to the
            // app’s interface, so process the results on the app’s
            // main queue.
             DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    UserDefaults.standard.set(true, forKey: "setableItem_SpeechActivatoin")
                    UserDefaults.standard.synchronize()
                    
                    BTSpeechSynthesizer.downloadSpeechAudioFiles()
                    
                    break
                    
                case .denied:
                    UserDefaults.standard.set(false, forKey: "setableItem_SpeechActivatoin")
                    UserDefaults.standard.synchronize()
                  break
                    
                case .restricted:
                    UserDefaults.standard.set(false, forKey: "setableItem_SpeechActivatoin")
                    UserDefaults.standard.synchronize()
                  break
                    
                case .notDetermined:
                    UserDefaults.standard.set(false, forKey: "setableItem_SpeechActivatoin")
                    UserDefaults.standard.synchronize()
            break
                }
            }
        }
    }
    
    class func downloadSpeechAudioFiles()
    {
        if let loadingView = UIView.viewWithNib("BTLoadingViewWithMessage") as? BTLoadingViewWithMessage
        {
            let popupview = BTPopUpView.show(view: loadingView, onComplete:{ })
            
            let downloadSiriInstructions = DownloadSiriInstructions()
            downloadSiriInstructions.executeWithObject(nil, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                downloadSiriInstructions.onComplete = nil
                downloadSiriInstructions.onFaile = nil
                
                popupview?.dismiss()
                UserDefaults.standard.set(true, forKey: "DownloadSiriInstructions_completed")
                UserDefaults.standard.synchronize()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SpeechActivatoinComplete"), object: nil)
                
                SpeechManager.sharedManager.listen()
                
            },onFaile: { (object, error) -> Void in
                             
                 popupview?.dismiss()
                
                let alertTitle = "st_error".localize()
                let alertMessage = "\("st_the_system_incurred_a_problem_while_downloading".localize())\n\("st_please_try_again_later".localize())"
                let okButtonTitle = "st_ok".localize()
                
                BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [okButtonTitle], onComplete:{ (dismissButtonKey) in
                })
            })
        }
    }
    
 
    open func listen(onComplete:@escaping (_ speech:String) -> Void)
    {
        self.onCompleteRecording = onComplete
        
        if runMock
        {
            self.getMockSpeech()
        }
        else{
             self.startRecording()
        }
    }
    
    func stopListening()
    {
        self.cancelRecording()
    }
    
    func getMockSpeech()
    {
        if let speech = SpeechMock.speeches.first
        {
            SpeechMock.speeches.removeFirst()
            
            self.onCompleteRecording?(speech)
        }
    }
    
    func startRecording() {
        
        if isRecording == true {
            self.cancelRecording()
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            //  startButton.backgroundColor = UIColor.red
        }
    }
    
    func cancelRecording()
    {
        self.speechRequest?.endAudio()
        self.speechRequest = nil
        
        self.audioEngine?.inputNode.removeTap(onBus: 0)
        self.audioEngine?.inputNode.reset()
        
        self.audioEngine?.stop()
        self.audioEngine = nil
        
        recognitionTask?.finish()
        recognitionTask?.cancel()
        recognitionTask = nil
        self.isRecording = false
        self.speachEndedTimer = nil
        
    }
    
    //MARK: - Recognize Speech

    func recordAndRecognizeSpeech() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            // handle errors
        }
        
        self.audioEngine = AVAudioEngine()
       // self.audioEngine?.stop()
       // self.audioEngine?.reset()
        
        let node = audioEngine?.inputNode
        if node == nil{
            return
        }
        
        let recordingFormat = node!.outputFormat(forBus: 0)
        
        self.speechRequest?.endAudio()
       self.speechRequest = SFSpeechAudioBufferRecognitionRequest()
        
        node!.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.speechRequest?.append(buffer)
        }
        self.audioEngine?.prepare()
        do {
            try self.audioEngine?.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        
        if self.speechRequest != nil
        {
            recognitionTask = speechRecognizer?.recognitionTask(with: self.speechRequest!, resultHandler: { result, error in
                if  result != nil {
                    
                    let speach = result!.bestTranscription.formattedString
                    
                    DispatchQueue.main.safeAsync{
                        self.speachEndedTimer?.invalidate()
                        
                        self.speachEndedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
                            
                            
                            print ("speach:\(speach)")
                            
                            self.cancelRecording()
                            
                            self.speachEndedTimer?.invalidate()
                            
                            self.onCompleteRecording?(speach)
                            
                            self.onCompleteRecording = nil
                        })
                    }
                    
                } else if let error = error {
                    self.sendAlert(message: "There has been a speech recognition error.")
                    print(error)
                }
            })
        }
    }
    
    //MARK: - Alert
    
    func sendAlert(message: String) {
        
        print ("Speech Error:\(message)")
    }
    
    open func play(_ audioFileName:String, onComplete:@escaping () -> Void)
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            
        }
        
        self.onComplete = onComplete
        
        //Check if page is saved in documnets
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        path += "/siri_instructions/\(audioFileName).mp3"
        
        if FileManager.default.fileExists(atPath: path)
        {
            let audioFileURL =  URL(fileURLWithPath: path)
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioFileURL)
            } catch let error {
                print(error.localizedDescription)
            }
            
            audioPlayer?.delegate = self
            audioPlayer?.play()
        }
        else{
            print("Audio file is missing: \(audioFileName)")
        }
    }
    
    //AVPlayer delegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        self.onComplete?()
    }
}
