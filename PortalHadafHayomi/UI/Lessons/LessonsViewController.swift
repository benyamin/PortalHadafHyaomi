//
//  LessonsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 15/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import MediaPlayer

class LessonsViewController: MSBaseViewController, BTPlayerViewDelegate, LessonsPickerViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource
{
   
    @IBOutlet weak var palyerPlaceHolderView:UIView!
    
    @IBOutlet weak var todaysPageButton:UIButton?
    
    @IBOutlet weak var sortSegmenterController:UISegmentedControl!
    @IBOutlet weak var lessonsFilterSegmentedController:UISegmentedControl!
    @IBOutlet weak var mediaTypeSegmentedController:UISegmentedControl!
    
    @IBOutlet weak var noSavedLessonsFoundView:UIView!
    
    @IBOutlet weak var lessonsPickerView:LessonsPickerView!
    
    @IBOutlet weak var saveLessonButton:UIButton!
    @IBOutlet weak var deleteLessonButton:UIButton!
    
    @IBOutlet weak var noSavedLessonsMessageLable:UILabel?
    @IBOutlet weak var showAllLessonsButton:UIButton?
    
    @IBOutlet weak var playPauseButton:UIButton!
    
    @IBOutlet weak var durationLabel:UILabel?
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var searchBarTopConstrinatToTopBar:NSLayoutConstraint?
    
    @IBOutlet weak var lastPlayedLessonsTableView:UITableView?
    
    @IBOutlet weak var todaysPageLabel:UILabel?
    
    @IBOutlet weak var displayPageButton:UIButton!
    
    var firstAppearacne = true
    
    var changeLessonAlert:BTAlertView?
    
    var getLessonsInfoProcess:GetLessonsInfoProcess?

    var mediaLessons = [MediaLesson]()

    var lastPlayedLessons:[Lesson]?
    
    var selectedLesson:Lesson?{
        get{
            return lessonsPickerView.selectedLesson
        }
        set(value)
        {
            lessonsPickerView.selectedLesson = value
        }
    }
    var savinglessonsActiveProcess = [String:SaveLessonProcess]()
    
    lazy var audioPlayer:BTPlayerView? = {
        
        let player = BTPlayerManager.sharedManager.sharedPlayerView
        player?.delegate = self
        
        player?.onPreButtonClicked = {
            
            if let preLesson = self.getPreLesson() {
                
                self.lessonsPickerView.select(maschet: preLesson.masechet, page: preLesson.page!, maggidShior:preLesson.maggidShiur)
                
                self.playSelectedLesson()
                self.playPauseButton.isSelected = true
            }
        }
        
        player?.onNextButtonClicked = {
            
            if let nextLesson = self.getNextLesson() {
                
                self.lessonsPickerView.select(maschet: nextLesson.masechet, page: nextLesson.page!, maggidShior:nextLesson.maggidShiur)
                
                self.playSelectedLesson()
                self.playPauseButton.isSelected = true
            }
        }
        
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.lessonsPickerView.isHidden = true
        
        self.sortSegmenterController.setTitle("st_sort_by_masechtot".localize(), forSegmentAt: 0)
        self.sortSegmenterController.setTitle("st_sort_by_magid_shiour".localize(), forSegmentAt: 1)
        self.sortSegmenterController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(HexColor: "781F24")], for: .selected)
        self.sortSegmenterController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:  UIColor.gray], for: .normal)
        
        self.lessonsFilterSegmentedController.setTitle("st_all_essons".localize(), forSegmentAt: 0)
        self.lessonsFilterSegmentedController.setTitle("st_saved_lessons".localize(), forSegmentAt: 1)
        self.lessonsFilterSegmentedController.setTitle("st_playlist_history".localize(), forSegmentAt: 2)
        self.lessonsFilterSegmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(HexColor: "781F24")], for: .selected)
        self.lessonsFilterSegmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:  UIColor.gray], for: .normal)
        
        self.mediaTypeSegmentedController.setTitle("st_all_media_type".localize(), forSegmentAt: 0)
        self.mediaTypeSegmentedController.setTitle("st_audio_lessons".localize(), forSegmentAt: 1)
        self.mediaTypeSegmentedController.setTitle("st_video_lessons".localize(), forSegmentAt: 2)
        self.mediaTypeSegmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(HexColor: "781F24")], for: .selected)
        self.mediaTypeSegmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:  UIColor.gray], for: .normal)


        
        self.todaysPageButton?.setTitle("st_move_to_todays_page".localize(), for: .normal)
       
        self.noSavedLessonsMessageLable?.text = "st_saved_lessons_not_found".localize()
        self.showAllLessonsButton?.setTitle("st_show_all_lessons".localize(), for: .normal)
        
        self.addBorderToView(self.todaysPageButton)
        self.addBorderToView(self.sortSegmenterController)
        self.addBorderToView(self.lessonsFilterSegmentedController)
        self.addBorderToView(self.mediaTypeSegmentedController)
        
        self.displayPageButton.setImageTintColor(UIColor(HexColor: "781F24"))
    }
    
    func addBorderToView(_ view:UIView?) {
        
        if view == nil {
            return
        }
        
        view!.layer.cornerRadius = 3.0
        view!.layer.borderWidth = 1.0
        view!.layer.borderColor = UIColor(HexColor: "781F24").cgColor
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.palyerPlaceHolderView.addSubview(self.audioPlayer!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.firstAppearacne
        {
            self.lessonsPickerView.delegate = self

            self.firstAppearacne = false
            
            self.lessonsPickerView.pickerView.frame = self.lessonsPickerView.bounds
            self.lessonsPickerView.pickerView.reloadAllComponents()
            
            let saveLastLesson = UserDefaults.standard.object(forKey: "setableItem_SaveLastLesson") as? Bool ?? true
            
            if let playingLesson = LessonsManager.sharedManager.playingLesson
            {
              self.setPlayingLesson(playingLesson)
            }
                
            else if let lastPlayedLasson = LessonsManager.sharedManager.lastPlayedLasson()
                        ,saveLastLesson == true
            {
                if self.lessonsPickerView != nil
                {
                    
                    if let lastPlayedLassonInfo = UserDefaults.standard.object(forKey: "lastPlayedLasson") as? [String:Any]
                        ,let duration = lastPlayedLassonInfo["duration"] as? Int
                        
                    {                        
                        self.lessonsPickerView.select(lesson: lastPlayedLasson)
                        
                        self.audioPlayer?.startAutomatically = false
                        self.setAudioUrlForLesson(lesson: lastPlayedLasson)
                        self.audioPlayer?.setDuration(duration)
                    }
                }
            }
            else{
                self.scrollToTodaysPage(selectDefaultMaggidShiour:true)
            }
            
            self.lessonsPickerView.isHidden = false
            
            self.lessonsPickerView.addConstraint(NSLayoutConstraint(item: lessonsPickerView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: lessonsPickerView.frame.size.height))

        }
        else if let playingLesson = LessonsManager.sharedManager.playingLesson
        {
           self.setPlayingLesson(playingLesson)
        }
        
        self.todaysPageLabel?.text = "הדף היומי\n\(HadafHayomiManager.sharedManager.todaysPageDisplay())"
        
        if UserDefaults.standard.object(forKey: "didShowUpdateAlert") == nil{
            
            let alertTitle = "שינויים בבחירת שיעורים"
            let alertMessage = "על מנת להפעיל שיעור, יש קודם לבחור את השיעור ולאחר מכן ללחוץ על הכפתור נגן בצד ימין של השיעור הנבחר."
           
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: ["st_ok".localize()], onComplete:{ (dismissButtonKey) in
                
                UserDefaults.standard.set(true, forKey: "didShowUpdateAlert")
                 UserDefaults.standard.synchronize()
            })
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
      //  BTPlayerManager.sharedManager.sharedPlayerView.delegate = nil
    }
    
    func setPlayingLesson(_ lesson:Lesson)
    {
        if self.lessonsPickerView != nil
        {
            self.lessonsPickerView.delegate = nil
            
            self.lessonsPickerView.select(lesson: lesson)
            
            self.lessonsPickerView.delegate = self
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.audioPlayer?.frame = self.palyerPlaceHolderView.bounds
    }
    
    @IBAction func scrollToTodaysPageButtonClicked(_ sedner:AnyObject)
    {
        self.scrollToTodaysPage(selectDefaultMaggidShiour:false)
    }
    
    @IBAction func sortSegmentedControlloerValueChanged(_ sedner:AnyObject)
    {
        if sortSegmenterController.selectedSegmentIndex == 0//Sort by Masechtot
        {
            self.lessonsPickerView.lessonsSortOption = .Maschtot
        }
        
        if sortSegmenterController.selectedSegmentIndex == 1//Sort by MaggidShiours
        {
             self.lessonsPickerView.lessonsSortOption = .MagidShiurs
        }
    }
    
    @IBAction func lessonsFilterSegmentedControllerValueChanged(_ sedner:AnyObject)
    {
         self.setDefaultLayout()
        
        if lessonsFilterSegmentedController.selectedSegmentIndex == 0//Show All Lessons
        {
            self.lessonsPickerView.lessonsFilterOption = .All
        }
        
        else if lessonsFilterSegmentedController.selectedSegmentIndex == 1//Show saved Lessons
        {
            self.lessonsPickerView.lessonsFilterOption = .Saved
            
            //If no saved lessons found
            if self.lessonsPickerView.displayedMasechetot.count == 0
            {
                self.setNoLessonsLayout()
            }
        }
        else if lessonsFilterSegmentedController.selectedSegmentIndex == 2//lastPlayedLessons
        {
            self.lastPlayedLessons = LessonsManager.sharedManager.getLastPlayedLessons()
            self.lastPlayedLessonsTableView?.reloadData()
            self.lastPlayedLessonsTableView?.isHidden = false
            self.searchBar?.isHidden = true
        }
    }
    
    @IBAction func mediaTypeSegmentedControllerValueChanged(_ sedner:AnyObject)
    {
        if mediaTypeSegmentedController.selectedSegmentIndex == 0//Show Audio and Video Lessons
        {
            self.lessonsPickerView.lessonsMediaTypeOption = .All
        }
        
        else if mediaTypeSegmentedController.selectedSegmentIndex == 1//Show Audio Lessons
        {
            self.lessonsPickerView.lessonsMediaTypeOption = .Audio
        }
        
        else if mediaTypeSegmentedController.selectedSegmentIndex == 2//Show Video Lessons
        {
            self.lessonsPickerView.lessonsMediaTypeOption = .Video
        }
      
       
    }
    
    @IBAction func showAllLessonsButtonClicked(_ sedner:AnyObject)
    {
        self.lessonsFilterSegmentedController.selectedSegmentIndex = 0
        self.lessonsFilterSegmentedControllerValueChanged(lessonsFilterSegmentedController)
    }
    
    @IBAction func saveLessonButtonClicked(_ sender:AnyObject)
    {
        if let selectedMaschet = self.lessonsPickerView.selectedMaschet
        , let selectedMaggidShiour = self.lessonsPickerView.selectedMaggidShiur
        , let selectedPage = self.lessonsPickerView.selectedPage
        {
        if let lesson = LessonsManager.sharedManager.getLessonForMasechet(selectedMaschet, andMaggidShiour: selectedMaggidShiour)
        {
            let selectedLesson = lesson.copy() as! Lesson
            selectedLesson.page = selectedPage
            
            let processKey = "\(selectedLesson.masechet.name!)\( selectedLesson.maggidShiur.name!)\(selectedLesson.page!.symbol!)"
            
            //If is saving lesson in progress
            if self.savinglessonsActiveProcess[processKey] != nil
            {
                return
            }
            
            let saveLessonProcess = SaveLessonProcess()
            self.savinglessonsActiveProcess[processKey] = saveLessonProcess
            
            saveLessonProcess.executeWithObject(selectedLesson, onStart: { () -> Void in
                
                //Reload component to update saving precentage circale display
               // self.lessonsPickerView.reloadComponent(2)
                
                let currentPickerLesson = Lesson()
                currentPickerLesson.masechet = self.lessonsPickerView.selectedMaschet
                currentPickerLesson.maggidShiur = self.lessonsPickerView.selectedMaggidShiur
                currentPickerLesson.page = self.lessonsPickerView.selectedPage
               
                 if selectedLesson.identifier == currentPickerLesson.identifier
                {
                    self.saveLessonButton.isHidden = true
                    self.deleteLessonButton.isHidden = true
                }
                
            }, onProgress: { (object) -> Void in
                
                 //Reload component to update saving precentage circale display
                self.lessonsPickerView.reloadComponent(0)
                
                
            }, onComplete: { (object) -> Void in
                
                let lesson = object as! Lesson
                let processKey = "\(lesson.masechet.name!)\( lesson.maggidShiur.name!)\(lesson.page!.symbol!)"
                
                self.savinglessonsActiveProcess.removeValue(forKey: processKey)
                
                selectedLesson.masechet.hasSavedLessons = true
                selectedLesson.maggidShiur.hasSavedLessons = true
                
                
                self.lessonsPickerView.reloadComponent(2)
                self.lessonsPickerView.didSelectedMaschet(self.lessonsPickerView.selectedMaschet)
                
            },onFaile: { (object, error) -> Void in
                
                print ("saving lesson failed")
                
                let lesson = object as! Lesson
                let processKey = "\(lesson.masechet.name!)\( lesson.maggidShiur.name!)\(lesson.page!.symbol!)"
                self.savinglessonsActiveProcess.removeValue(forKey: processKey)
                
                 self.lessonsPickerView.reloadData()
                
                 self.presentErrorAlertWithError(error)
            })
        }
        }
    }
    
     @IBAction  func deleteSelectedLessonButtonClicked(_ sender:AnyObject)
    {
        if let lesson = LessonsManager.sharedManager.getLessonForMasechet(self.lessonsPickerView.selectedMaschet!, andMaggidShiour: self.lessonsPickerView.selectedMaggidShiur!)
        {
            let selectedLesson = lesson.copy() as! Lesson
            selectedLesson.page = self.lessonsPickerView.selectedPage
            
            if LessonsManager.sharedManager.isSavedLesson(selectedLesson)
            {
                let alertTitle = "st_delete_lesson_alert_title".localize()
                let alertMessage = String(format: "st_delete_lesson_alert_message".localize(), arguments: [selectedLesson.maggidShiur.name!,selectedLesson.masechet.name!,selectedLesson.page!.symbol!])
        
                
                let alertDeleteButtonTitle = "st_delete".localize()
                let alertCancelButtonTitle = "st_cancel".localize()
                BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertDeleteButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
                    
                    if dismissButtonKey == alertDeleteButtonTitle
                    {
                        self.deleteLesson(lesson: selectedLesson)
                    }
                })
            }
        }
    }
    
    @IBAction func  playPauseButtonClicked (_ sender:UIButton) {
        
        if self.playPauseButton.isSelected == false {
            
            self.playSelectedLesson()
            self.playPauseButton.isSelected = true
        }
        else{
            self.audioPlayer?.pause()
            self.playPauseButton.isSelected = false
        }
        
        self.setSearchLayout(visible: false)
    }
    
    @IBAction func searchButtonClicked(_ sender:UIButton){
        self.setSearchLayout(visible: true)
    }
        
    @IBAction func displayPageButtonClicked(_ sender:UIButton) {
        self.selectTabWithName(tabName:"Talmud")
    }
    
    func setSearchLayout(visible:Bool) {
                              
        searchBar.showsCancelButton = visible

        if self.lessonsFilterSegmentedController.selectedSegmentIndex == 2 { //Last payed lessons
            self.lessonsFilterSegmentedController.selectedSegmentIndex = 0
            self.lessonsFilterSegmentedControllerValueChanged(self.lessonsFilterSegmentedController)
        }
        
        self.searchBarTopConstrinatToTopBar?.priority = UILayoutPriority(rawValue: visible ? 900 : 500)
        
        if !visible {
            self.searchBar.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
            
        })
    }
    
    func deleteLesson(lesson:Lesson)
    {
        RemoveLessonProcess().executeWithObject(lesson, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.lessonsPickerView.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
            self.lessonsPickerView.reloadData()
        })
    }
    
    func presentErrorAlertWithError(_ error:NSError)
    {
        if let errorMessage = error.userInfo["NSLocalizedDescription"]
        {
            let errorTitle = "st_error".localize()
            let errorOkButton = "st_ok".localize()
            BTAlertView.show(title: errorTitle, message: errorMessage as! String, buttonKeys: [errorOkButton], onComplete:{ (dismissButtonKey) in
            })
        }
        else
        {
            let errorTitle = "st_error".localize()
            let errorOkButton = "st_ok".localize()
            let errorMessage = "st_lesson_downlad_error_message".localize()
            BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [errorOkButton], onComplete:{ (dismissButtonKey) in
            })
        }
    }
    
    func setDefaultLayout()
    {
        self.lastPlayedLessonsTableView?.isHidden = true
        self.noSavedLessonsFoundView.isHidden = true
        self.lessonsPickerView.isHidden = false
        self.searchBar?.isHidden = false
    }
    
    func setNoLessonsLayout()
    {
         self.noSavedLessonsFoundView.isHidden = false
        self.lessonsPickerView.isHidden = true
    }
    
    func scrollToTodaysPage(selectDefaultMaggidShiour:Bool)
    {
        let todaysLesson = Lesson()
        todaysLesson.masechet = HadafHayomiManager.sharedManager.todaysMaschet!
        todaysLesson.page = HadafHayomiManager.sharedManager.todaysPage!
        
       todaysLesson.maggidShiur = todaysLesson.masechet.maggidShiurs.first
        
        if selectDefaultMaggidShiour == true
        {
            todaysLesson.maggidShiur = self.defaultMagidShiourForMasechet(todaysLesson.masechet)
        }
                
        if self.lessonsPickerView != nil
        {
            self.lessonsPickerView.select(lesson: todaysLesson)
            
            self.audioPlayer?.startAutomatically = false
            self.setAudioUrlForLesson(lesson: todaysLesson)
        }
    }
    
    func defaultMagidShiourForMasechet(_ masechet:Masechet) -> MaggidShiur?
    {
        if let defaultMagidShiourId =  UserDefaults.standard.object(forKey: "DefaultMagidShiour") as? String
        {
            for maggidShior in masechet.maggidShiurs
            {
                if maggidShior.id == defaultMagidShiourId
                {
                    return maggidShior
                }
            }
        }
        
        return masechet.maggidShiurs.first ?? nil
    }
    
    func setAudioUrlForLesson(lesson:Lesson)
    {
        self.audioPlayer?.title = "מסכת \(lesson.masechet.name!) דף \(lesson.page!.symbol!)"
        self.audioPlayer?.subTitle = lesson.maggidShiur.name
        
        LessonsManager.sharedManager.playingLesson = lesson

        if let lessonIdentifier = lesson.identifier
            ,let lessonInfo = UserDefaults.standard.object(forKey: lessonIdentifier) as? [String:Any]
            ,let duration = lessonInfo["duration"] as? Int {
            
            let alertTitle = "st_Continue_from_where_you_left_off_alert_title".localize()
            let alertMessage = "st_Continue_from_where_you_left_off_alert_message".localize(withArgumetns: [lesson.maggidShiur.name ?? "",lesson.masechet.name ?? "",lesson.page?.symbol ?? ""])
            
            BTAlertView.show(title: alertTitle, message:alertMessage, buttonKeys: ["st_no".localize(),"st_yes".localize()], onComplete:{ (dismissButtonKey) in
                
                if dismissButtonKey == "st_yes".localize(){
                    lesson.durration = duration
                }
                else if dismissButtonKey == "st_no".localize(){
                    lesson.durration = 0
                    UserDefaults.standard.removeObject(forKey: lessonIdentifier)
                    UserDefaults.standard.synchronize()
                }
                
                self.audioPlayer?.setPlayerUrl(lesson.getUrl(), durration:lesson.durration ?? 0)

            })
            
            lesson.durration = duration
        }
        else{
            self.audioPlayer?.setPlayerUrl(lesson.getUrl(), durration:lesson.durration ?? 0)
        }
    }
    
    func isSavingLessonInProgress(lesson:Lesson) -> Bool
    {
        let processKey = "\(lesson.masechet.name!)\( lesson.maggidShiur.name!)\(lesson.page!.symbol!)"
        if self.savinglessonsActiveProcess[processKey] != nil
        {
            return true
        }
        return false
    }
    
    func lessonDownloadPrecnetage(lesson:Lesson) -> Float
    {
        let processKey = "\(lesson.masechet.name!)\( lesson.maggidShiur.name!)\(lesson.page!.symbol!)"
        if let savingProcess = self.savinglessonsActiveProcess[processKey]
        {
            return savingProcess.downloadProgress
        }
        
        return 0
    }
    
    //Mark: LessonsPickerView Delegate Methods
    func lessonsPickerViewDidChangeSelection()
    {
        self.playPauseButton.isSelected = false
        
        if let selectedMaschet = self.lessonsPickerView.selectedMaschet
            , let selectedPage = self.lessonsPickerView.selectedPage
            , let selectedMaggidShiur = self.lessonsPickerView.selectedMaggidShiur
        {
            if let pickerSelectedLesson = LessonsManager.sharedManager.getLessonForMasechet(selectedMaschet, andMaggidShiour: selectedMaggidShiur)
            {
                pickerSelectedLesson.page = selectedPage
                
                if self.selectedLesson?.isEqual(pickerSelectedLesson) ?? false
                {
                    self.playPauseButton.isSelected = self.audioPlayer?.isPlaying ?? false
                }
                else{
                    if self.audioPlayer?.isPlaying == false
                       ,let currentDuration = self.audioPlayer?.currentPlayingDuration()
                       ,currentDuration < 10 {
                       // self.selectLesson(pickerSelectedLesson, andStartAutomatically: false)
                    }
                }
                
                self.setDurationDisplay()
                
                if LessonsManager.sharedManager.isSavedLesson(pickerSelectedLesson){
                    self.saveLessonButton.isHidden = true
                    self.deleteLessonButton.isHidden = false
                }
                else{
                    self.saveLessonButton.isHidden = false
                    self.deleteLessonButton.isHidden = true
                }
                
                if self.isSavingLessonInProgress(lesson: pickerSelectedLesson)
                {
                    self.deleteLessonButton.isHidden = true
                    self.saveLessonButton.isHidden = true
                }
            }
        }
    }
    
    func setDurationDisplay(){
        
        self.durationLabel?.text = "--:--"

        if let selectedMaschet = self.lessonsPickerView.selectedMaschet
            , let selectedPage = self.lessonsPickerView.selectedPage
            , let selectedMaggidShiur = self.lessonsPickerView.selectedMaggidShiur
        {
            if let lesson = LessonsManager.sharedManager.getLessonForMasechet(selectedMaschet, andMaggidShiour: selectedMaggidShiur)
            {
                lesson.page = selectedPage
                
                if var pickerLessonPath = lesson.urlPath()
                {
                    pickerLessonPath = pickerLessonPath.replacingOccurrences(of: "http:", with: "https:")
                    
                    for mediaLesson in self.mediaLessons {
                        
                        if pickerLessonPath == mediaLesson.path {
                            
                            if let durationDisplay = mediaLesson.durationDisplay {
                                self.durationLabel?.text = durationDisplay
                                
                                if self.selectedLesson?.identifier == lesson.identifier {
                                    self.selectedLesson?.durationDisplay = durationDisplay
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func lessonsPickerView(_ pickerView: LessonsPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.lessonsPickerViewDidChangeSelection()
        
        switch pickerView.lessonsSortOption
        {
        case .Maschtot:
            let lesson = Lesson()
            lesson.masechet = pickerView.selectedMaschet
            lesson.page = pickerView.selectedPage
            self.getInfoForLesson(lesson)
            
            break
            
        case .MagidShiurs:
            let lesson = Lesson()
            lesson.masechet = pickerView.selectedMaschet
            lesson.maggidShiur = pickerView.selectedMaggidShiur
            self.getInfoForLesson(lesson)
            
            break
        }
    }
    
    func getInfoForLesson(_ lesson:Lesson){
        
        self.durationLabel?.text = ""
        
         self.getLessonsInfoProcess?.cancel()
         
         self.getLessonsInfoProcess = GetLessonsInfoProcess()
         
         self.getLessonsInfoProcess?.executeWithObject(lesson, onStart: { () -> Void in
             
         }, onComplete: { (object) -> Void in
             
             self.mediaLessons = object as! [MediaLesson]
            self.setDurationDisplay()
             
         },onFaile: { (object, error) -> Void in
             
         })
     }
    
    func playSelectedLesson()
    {
        if let selectedMaschet = self.lessonsPickerView.selectedMaschet
            , let selectedPage = self.lessonsPickerView.selectedPage
            , let selectedMaggidShiur = self.lessonsPickerView.selectedMaggidShiur
        {
            
            self.updateLastPlayedMaggidShiurs(selectedMaggidShiur: selectedMaggidShiur)
            
            if let lesson = LessonsManager.sharedManager.getLessonForMasechet(selectedMaschet, andMaggidShiour: selectedMaggidShiur)
            {
                lesson.page = selectedPage
                
                //If selected  current playing lesson
                if self.selectedLesson != nil
                    && self.selectedLesson?.identifier == lesson.identifier{
                    self.audioPlayer?.play()
                }
                else{
                    self.selectLesson(lesson, andStartAutomatically: true)
                }
            }
        }
        
        LessonsManager.sharedManager.savePlayingLassonInfo(self.selectedLesson!, duratoinInSeconds: self.audioPlayer!.timeNow())
    }
    
    func updateLastPlayedMaggidShiurs(selectedMaggidShiur:MaggidShiur){
        
        if selectedMaggidShiur.id != nil {
            
            var lastPlayedMaggidShiurs = UserDefaults.standard.object(forKey: "lastPlayedMaggidShiurs") as? [String]
            
            if lastPlayedMaggidShiurs == nil {
                lastPlayedMaggidShiurs = [String]()
            }
            
            if lastPlayedMaggidShiurs!.contains(selectedMaggidShiur.id) {
                
                lastPlayedMaggidShiurs!.remove(selectedMaggidShiur.id as AnyObject)
            }
            
            lastPlayedMaggidShiurs!.append(selectedMaggidShiur.id)
            
            UserDefaults.standard.set(lastPlayedMaggidShiurs, forKey: "lastPlayedMaggidShiurs")
            UserDefaults.standard.synchronize()
        }
    }
        
    func selectLesson(_ lesson:Lesson, andStartAutomatically startAutomatically:Bool)
    {
        self.selectedLesson = lesson.copy() as? Lesson
        
        let isSavedLesson = LessonsManager.sharedManager.isSavedLesson(self.selectedLesson!)
        self.deleteLessonButton.isHidden = isSavedLesson ? false : true
        self.saveLessonButton.isHidden = isSavedLesson ? true : false
        
         self.audioPlayer?.startAutomatically = startAutomatically
        self.setAudioUrlForLesson(lesson: self.selectedLesson!)
    }
   
    //MARK : BTPlayerView delegate methods
    func didPause(player:BTPlayerView){
        
        LessonsManager.sharedManager.isPlaying = false
        self.playPauseButton.isSelected = false
        
        if let tableView  = self.lastPlayedLessonsTableView
           ,let visibleCellsIndexes = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleCellsIndexes, with: .none)
        }
    }
    
    func didPlay(player:BTPlayerView){
        self.playPauseButton.isSelected = true
        
        LessonsManager.sharedManager.isPlaying = true
        
        if let tableView  = self.lastPlayedLessonsTableView
           ,let visibleCellsIndexes = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleCellsIndexes, with: .none)
        }
    }
    
    func playerView(_ player:BTPlayerView, didChangeDuration duration:Int){
        
        if self.selectedLesson?.audioBaseUrl != nil && duration%5 == 0
        {
           LessonsManager.sharedManager.savePlayingLassonInfo(self.selectedLesson!, duratoinInSeconds: self.audioPlayer!.timeNow())
        }
    }
    
     func didFinishPlaying(_ player:BTPlayerView)
     {
        if self.selectedLesson?.mediaType == .Video
        {
            return
        }
        
        if let nextLesson = self.getNextLesson()
        {
            if self.lessonsPickerView != nil
            {
                if let playLessonsInSequence = UserDefaults.standard.object(forKey: "setableItem_PlayLessonsInSequence") as? Bool
                , playLessonsInSequence == true
                {
                    self.lessonsPickerView.select(maschet: nextLesson.masechet, page: nextLesson.page!, maggidShior:nextLesson.maggidShiur)
                    
                    self.playSelectedLesson()
                    self.playPauseButton.isSelected = true
                }
                
                else{
                    self.showPlayNextLessonAlert(nextLesson:nextLesson)
                }
            }
        }
    }
    
    func didCancelWithError(_ error:Error?){
        
        self.playPauseButton.isSelected = false
    }
    
    func showPlayNextLessonAlert(nextLesson:Lesson)
    {
        let alertTitle = "st_play_next_lesson_title".localize()
        let alertMessage = String(format: "st_play_next_lesson_message".localize(), arguments: [nextLesson.maggidShiur.name, nextLesson.masechet.name, nextLesson.page?.symbol ?? ""])
        let playButton = "st_play".localize()
        let cancelButton = "st_cancel".localize()
        
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [playButton,cancelButton], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == playButton
            {
                self.lessonsPickerView.select(maschet: nextLesson.masechet, page: nextLesson.page!, maggidShior:nextLesson.maggidShiur)
                
                self.playSelectedLesson()
                self.playPauseButton.isSelected = true
            }
        })
    }
    
    func getNextLesson() -> Lesson? {
        self.jumpToLesson(jump:1)
    }
    
    func getPreLesson() -> Lesson? {
        self.jumpToLesson(jump:-1)
    }
    
    func jumpToLesson(jump:Int) -> Lesson? {
        
        if let masechet = self.selectedLesson?.masechet
        ,let page = self.selectedLesson?.page
        {
            let nextLesson = Lesson()
            nextLesson.maggidShiur = self.selectedLesson?.maggidShiur
            
            if page.index == masechet.numberOfPages
            {
                if let masechtIndex = HadafHayomiManager.sharedManager.masechtot.index(of: masechet)
                {
                    if HadafHayomiManager.sharedManager.masechtot.count > masechtIndex+jump
                    {
                        nextLesson.masechet = HadafHayomiManager.sharedManager.masechtot[masechtIndex+jump]
                       
                    }
                    else{
                         nextLesson.masechet = HadafHayomiManager.sharedManager.masechtot.first
                    }
                    nextLesson.page = Page(index:1)
                }
            }
            else
            {
                nextLesson.masechet = masechet
                nextLesson.page = Page(index: page.index+jump)
                
            }
            return nextLesson
        }
        return nil
    }
    
    override func applicationWillTerminate()
    {
        if self.selectedLesson != nil
            {
                  LessonsManager.sharedManager.savePlayingLassonInfo(self.selectedLesson!, duratoinInSeconds: self.audioPlayer!.timeNow())
            }
    }
    
    //MARK: - search bar delegate methods]
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.setSearchLayout(visible: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.setSearchLayout(visible: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.sortMasechtotBy(searchText)
        self.sortPageShiurBy(searchText)
        self.sortMaggidShiurBy(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.setSearchLayout(visible: false)
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.setSearchLayout(visible: false)
        searchBar.text = ""
    }
    
    func sortMasechtotBy(_ searchText:String)
    {
        var hightScore = 0.0
        var selectedMasechet = lessonsPickerView.displayedMasechetot.first
               
        for masecht in lessonsPickerView.displayedMasechetot
        {
            let score = masecht.name.levenshteinDistanceScore(to: searchText, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
            if score > hightScore {
                hightScore = score
                selectedMasechet = masecht
            }
        }
        
        //Scroll to selected Masecht
        if selectedMasechet != nil {
            if let masechtIndex = lessonsPickerView.displayedMasechetot.index(of: selectedMasechet!)
            {
                lessonsPickerView.pickerView.selectRow(masechtIndex, inComponent: lessonsPickerView.masechtotComponentTag, animated: true)
            }
        }
    }
    
    func sortPageShiurBy(_ searchText:String)
     {
        var hightScore = 0.0
        var selectedPage = lessonsPickerView.displayedPages.first
        
         for page in lessonsPickerView.displayedPages
         {
            let score = page.symbol.levenshteinDistanceScore(to: searchText, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
            if score > hightScore {
                hightScore = score
                selectedPage = page
            }
        }
        
        //Scroll to selected page
        if selectedPage != nil {
            
            if let pageIndex = lessonsPickerView.displayedPages.index(of: selectedPage!)
            {
                lessonsPickerView.pickerView.selectRow(pageIndex, inComponent: lessonsPickerView.pagesComponentTag, animated: true)
            }
        }
    }
    
    func sortMaggidShiurBy(_ searchText:String)
    {
          var hightScore = 0.0
              var selectedMaggidShiur = lessonsPickerView.displayedMaggidShiours.first
                     
              for maggidShiur in lessonsPickerView.displayedMaggidShiours
              {
                  let score = maggidShiur.name.levenshteinDistanceScore(to: searchText, ignoreCase: true, trimWhiteSpacesAndNewLines: true)
                  if score > hightScore {
                      hightScore = score
                      selectedMaggidShiur = maggidShiur
                  }
              }
              
              //Scroll to selected maggidShiur
              if selectedMaggidShiur != nil {
                  if let maggidShiurIndex = lessonsPickerView.displayedMaggidShiours.index(of: selectedMaggidShiur!)
                  {
                    lessonsPickerView.pickerView.selectRow(maggidShiurIndex, inComponent: lessonsPickerView.magidShioursComponentTag, animated: true)
                  }
        }
    }
    
    @objc override func keyboardWillAppear(_ notification: Notification)
    {
    }
    
    @objc override func keyboardWillDisappear(_ notification: Notification)
    {
    }
    
    //MARK: Tableview delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastPlayedLessons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for:indexPath) as! LessonTableViewCell
        
        cell.onPlayLesson = {(lesson) in
            if lesson.identifier == self.selectedLesson?.identifier {
                
                if self.audioPlayer?.isPlaying ?? false {
                    self.audioPlayer?.pause()
                }
                else{
                    self.audioPlayer?.play()
                }
            }
            
            else {
                self.selectLesson(lesson, andStartAutomatically: true)
                self.lessonsPickerView.select(lesson: lesson)
                
                if let lastDuration = lesson.lastDuration {
                    self.audioPlayer?.setDuration(lastDuration)
                }
            }
        }
        
        if let lesson = self.lastPlayedLessons?[indexPath.row] {
            cell.reloadWithObject(lesson)
            
            if lesson.identifier == self.selectedLesson?.identifier
                && self.audioPlayer?.isPlaying ?? false {
                cell.playButton?.isSelected = true
            }
            else {
                cell.playButton?.isSelected = false
            }
        }
                
        return cell
    }
}
