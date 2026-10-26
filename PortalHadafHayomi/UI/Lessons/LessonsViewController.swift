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
    
    @IBOutlet weak var sortByLabel:UILabel?
    @IBOutlet weak var durationLabel:UILabel?
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var searchBarTopConstrinatToTopBar:NSLayoutConstraint?
    @IBOutlet weak var searchBarTrailingConstraintToView:NSLayoutConstraint?
    
    @IBOutlet weak var lastPlayedLessonsTableView:UITableView?
    
    @IBOutlet weak var todaysPageLabel:UILabel?
    
    @IBOutlet weak var displayPageButton:UIButton!
    
    @IBOutlet weak var noFavoriteMaggidShioursContentView:UIView!
    @IBOutlet weak var noFavoriteMaggidShioursMessageLabel:UILabel!
    
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
    
    lazy var maggidiShiourTableView:MaggidiShiourTableView? =
    {
        if let maggidiShiourTableView = MaggidiShiourTableView.create(){
            
            maggidiShiourTableView.frame = CGRect(x: 0, y: palyerPlaceHolderView.bottom(), width: self.view.bounds.width, height: self.view.bounds.height - palyerPlaceHolderView.bottom())
            
            maggidiShiourTableView.onDismiss = { [weak self]  in
                maggidiShiourTableView.removeFromSuperview()
                self?.lessonsPickerView.reloadData()
                self?.setFavoriteMaggidShioursLayout()
            }
            return maggidiShiourTableView}
        else{
            return nil
        }
    }()
    
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
        
        self.sortSegmenterController.setTitle( "st_sort_masechtot".localize(), forSegmentAt: 0)
        self.sortSegmenterController.setTitle("st_sort_magid_shiour".localize(), forSegmentAt: 1)
        self.sortSegmenterController.setTitle("st_sort_selected_magid_shiour".localize(), forSegmentAt: 2)
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

        self.sortByLabel?.text = "st_sort_by".localize()
        
        self.todaysPageButton?.setTitle("st_move_to_todays_page".localize(), for: .normal)
       
        self.noSavedLessonsMessageLable?.text = "st_saved_lessons_not_found".localize()
        self.showAllLessonsButton?.setTitle("st_show_all_lessons".localize(), for: .normal)
        
        self.addBorderToView(self.todaysPageButton)
        self.addBorderToView(self.sortSegmenterController)
        self.addBorderToView(self.lessonsFilterSegmentedController)
        self.addBorderToView(self.mediaTypeSegmentedController)
        
        self.displayPageButton.setImageTintColor(UIColor(HexColor: "781F24"))
        
        self.noFavoriteMaggidShioursContentView.layer.borderColor = (UIColor(HexColor: "781F24")).cgColor
        self.noFavoriteMaggidShioursContentView.layer.borderWidth = 1
        self.noFavoriteMaggidShioursContentView.layer.cornerRadius = 3
        self.noFavoriteMaggidShioursMessageLabel?.text = "st_add_Favorite_maggid_shiour_message".localize()
        
        self.noFavoriteMaggidShioursContentView.isHidden = true
        
        self.setupNewLessonsLayout()
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
        palyerPlaceHolderView.addBottomShadow()
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
            
            // New lessons list: starts with all masechtot closed
            self.lessonsBrowser.rebuildRoot(force: true)

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
        if sortSegmenterController.selectedSegmentIndex == 0{//Sort by Masechtot
            self.lessonsPickerView.lessonsSortOption = .Maschtot
            self.setDefaultLayout()
        }
        else if sortSegmenterController.selectedSegmentIndex == 1 {//Sort by MaggidShiours
             self.lessonsPickerView.lessonsSortOption = .AllMagidiShiurs
            self.setDefaultLayout()
        }
        else if sortSegmenterController.selectedSegmentIndex == 2 {//Sort by Favorite MaggidShiours
            self.lessonsPickerView.lessonsSortOption = .FavoirteMagidiShiour
            self.setFavoriteMaggidShioursLayout()
        }
    }
    
    @IBAction func lessonsFilterSegmentedControllerValueChanged(_ sedner:AnyObject)
    {
        
        if lessonsFilterSegmentedController.selectedSegmentIndex == 0//Show All Lessons
        {
            self.lessonsPickerView.lessonsFilterOption = .All
            self.setDefaultLayout()
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
            self.setDefaultLayout()
            
            self.lastPlayedLessons = LessonsManager.sharedManager.getLastPlayedLessons()
            self.lastPlayedLessonsTableView?.reloadData()
            self.lastPlayedLessonsTableView?.isHidden = false
            self.searchBar?.isHidden = true
            self.todaysPageButton?.isHidden = true        }
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
        
        if self.audioPlayer?.lockButton.isSelected ?? false {
            self.audioPlayer?.displayLockAlert()
            return
        }
        
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
    
    @IBAction func favoriteMaggidShioursButtonClicked(_ sedner:AnyObject)
    {
        if self.maggidiShiourTableView != nil {
            
            self.view.addSubview(self.maggidiShiourTableView!)
        }
    }
    
    @IBAction func settingsButtonClicked(_ sender:UIButton){
        
        GetLessonsSettingsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let lessonsSettings = object as? [SetableItem] {
                                
                let settingsViewController = SettingsViewController.createWith(settings: lessonsSettings)
                let navController = UINavigationController(rootViewController: settingsViewController)
                navController.setNavigationBarHidden(true, animated: false)
                
                if self.navigationController != nil
                {
                    self.navigationController?.present(navController, animated: true, completion: nil)
                }
                else{
                    self.view.superview?.parentViewController?.present(navController, animated: true, completion: nil)
                }
            }
            
        },onFaile: { (object, error) -> Void in
        })
    }
    
    func setSearchLayout(visible:Bool) {
                              
        searchBar.showsCancelButton = visible

        if self.lessonsFilterSegmentedController.selectedSegmentIndex == 2 { //Last payed lessons
            self.lessonsFilterSegmentedController.selectedSegmentIndex = 0
            self.lessonsFilterSegmentedControllerValueChanged(self.lessonsFilterSegmentedController)
        }
        
        self.searchBarTopConstrinatToTopBar?.priority = UILayoutPriority(rawValue: visible ? 900 : 500)
        self.searchBarTrailingConstraintToView?.priority = UILayoutPriority(rawValue: visible ? 900 : 500)
        
        if !visible {
            self.searchBar.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
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
        self.todaysPageButton?.isHidden = false
        self.noFavoriteMaggidShioursContentView.isHidden = true
        
        if self.lessonsPickerView.lessonsFilterOption == .Saved
        && self.lessonsPickerView.displayedMasechetot.count == 0 {
            self.setNoLessonsLayout()
        }
    }
    
    func setNoLessonsLayout()
    {
         self.noSavedLessonsFoundView.isHidden = false
        self.lessonsPickerView.isHidden = true
    }
    
    func setFavoriteMaggidShioursLayout()
    {
        let favoritMaggidShiours = HadafHayomiManager.sharedManager.maggidShiurs.filter{ $0.isFavorite == true }
        if favoritMaggidShiours.count == 0 {
            
            self.lastPlayedLessonsTableView?.isHidden = true
            self.noSavedLessonsFoundView.isHidden = true
            self.lessonsPickerView.isHidden = true
            self.searchBar?.isHidden = true
            self.todaysPageButton?.isHidden = true
            self.noFavoriteMaggidShioursContentView.isHidden = false
        }
        else{
            self.setDefaultLayout()

            if self.lessonsPickerView.lessonsFilterOption == .Saved
            && self.lessonsPickerView.displayedMasechetot.count == 0 {
                self.setNoLessonsLayout()
            }
        }
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
        
        NotificationCenter.default.post(name: Notification.Name("didSelectLessonNotification"), object: nil, userInfo: ["lesson":lesson])
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
        defer { self.lessonsBrowserIfLoaded?.reloadVisible() }
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
            
            if let masechet = pickerView.selectedMaschet
                ,let page = pickerView.selectedPage {
                
                let lesson = Lesson()
                lesson.masechet = masechet
                lesson.page = page
                self.getInfoForLesson(lesson)
            }
            break
            
        case .AllMagidiShiurs, .FavoirteMagidiShiour:
            
            if let masechet = pickerView.selectedMaschet
                ,let maggidShiur = pickerView.selectedMaggidShiur {
                
                let lesson = Lesson()
                lesson.masechet = masechet
                lesson.maggidShiur = maggidShiur
                self.getInfoForLesson(lesson)
            }
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
        self.lessonsBrowserIfLoaded?.reloadVisible()
        
        if let tableView  = self.lastPlayedLessonsTableView
           ,let visibleCellsIndexes = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleCellsIndexes, with: .none)
        }
    }
    
    func didPlay(player:BTPlayerView){
        self.playPauseButton.isSelected = true
        
        LessonsManager.sharedManager.isPlaying = true
        self.lessonsBrowserIfLoaded?.reloadVisible()
        
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

// MARK: - New lessons layout: compact filters + masechet → daf → maggid shiur

extension LessonsViewController: LessonsBrowserDataSource
{
    private static var browserKey = 0
    private static var filterViewsKey = 0
    
    private final class FilterViews {
        let container = UIView()
        let stack = UIStackView()
        let filterButton = UIButton(type: .system)
        let summaryLabel = UILabel()
        let todayButton = UIButton(type: .system)
        let panel = UIStackView()
        var sort = UISegmentedControl()
        var which = UISegmentedControl()
        var media = UISegmentedControl()
    }
    
    private var filterViews:FilterViews {
        if let views = objc_getAssociatedObject(self, &LessonsViewController.filterViewsKey) as? FilterViews { return views }
        let views = FilterViews()
        objc_setAssociatedObject(self, &LessonsViewController.filterViewsKey, views, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return views
    }
    
    var lessonsBrowserIfLoaded:LessonsBrowser? {
        return objc_getAssociatedObject(self, &LessonsViewController.browserKey) as? LessonsBrowser
    }
    
    var lessonsBrowser:LessonsBrowser {
        if let browser = self.lessonsBrowserIfLoaded { return browser }
        let browser = LessonsBrowser(source: self)
        objc_setAssociatedObject(self, &LessonsViewController.browserKey, browser, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return browser
    }
    
    // MARK: Layout
    
    func setupNewLessonsLayout()
    {
        let v = self.filterViews
        let burgundy = LessonsBrowserStyle.burgundy
        
        // Everything under the player: filter row, (filter panel), lessons list.
        // It covers the old pickers / segments / search bar (they stay hidden underneath).
        v.container.backgroundColor = LessonsBrowserStyle.parchment
        v.container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(v.container)
        NSLayoutConstraint.activate([
            v.container.topAnchor.constraint(equalTo: self.palyerPlaceHolderView.bottomAnchor),
            v.container.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            v.container.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            v.container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.searchBar?.isHidden = true
        
        // Filter row: [סינון ▾ (n)]  summary  [לדף היומי]
        let row = UIView()
        row.semanticContentAttribute = .forceRightToLeft
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        v.filterButton.setTitle(" סינון", for: .normal)
        v.filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        v.filterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        v.filterButton.tintColor = burgundy
        v.filterButton.setTitleColor(burgundy, for: .normal)
        v.filterButton.backgroundColor = .white
        v.filterButton.layer.borderWidth = 1
        v.filterButton.layer.borderColor = LessonsBrowserStyle.border.cgColor
        v.filterButton.layer.cornerRadius = 3
        v.filterButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        v.filterButton.semanticContentAttribute = .forceRightToLeft
        v.filterButton.addTarget(self, action: #selector(newFilterButtonTapped), for: .touchUpInside)
        v.filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        v.summaryLabel.font = UIFont.systemFont(ofSize: 12)
        v.summaryLabel.textColor = LessonsBrowserStyle.secondaryText
        v.summaryLabel.textAlignment = .right
        v.summaryLabel.lineBreakMode = .byTruncatingTail
        v.summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        v.todayButton.setTitle("st_go_to_todays_page".localize(), for: .normal)
        v.todayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        v.todayButton.setTitleColor(burgundy, for: .normal)
        v.todayButton.backgroundColor = .white
        v.todayButton.layer.borderWidth = 1
        v.todayButton.layer.borderColor = burgundy.cgColor
        v.todayButton.layer.cornerRadius = 3
        v.todayButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        v.todayButton.addTarget(self, action: #selector(newTodaysPageTapped), for: .touchUpInside)
        v.todayButton.translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.backgroundColor = LessonsBrowserStyle.line
        line.translatesAutoresizingMaskIntoConstraints = false
        
        // "לדף היומי" was removed from this row; the summary takes its place
        row.addSubview(v.filterButton)
        row.addSubview(v.summaryLabel)
        row.addSubview(line)
        NSLayoutConstraint.activate([
            v.filterButton.rightAnchor.constraint(equalTo: row.rightAnchor, constant: -12),
            v.filterButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.filterButton.heightAnchor.constraint(equalToConstant: 34),
            v.summaryLabel.rightAnchor.constraint(equalTo: v.filterButton.leftAnchor, constant: -8),
            v.summaryLabel.leftAnchor.constraint(equalTo: row.leftAnchor, constant: 12),
            v.summaryLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            line.leftAnchor.constraint(equalTo: row.leftAnchor),
            line.rightAnchor.constraint(equalTo: row.rightAnchor),
            line.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Filter panel (closed until "סינון" is tapped) – same choices as before
        func copySegments(_ old:UISegmentedControl?, action:Selector) -> UISegmentedControl {
            var titles = [String]()
            for i in 0 ..< (old?.numberOfSegments ?? 0) { titles.append(old?.titleForSegment(at: i) ?? "") }
            let control = UISegmentedControl(items: titles)
            control.selectedSegmentIndex = old?.selectedSegmentIndex ?? 0
            control.selectedSegmentTintColor = .white
            control.backgroundColor = UIColor(HexColor: "EBE2C4")
            control.setTitleTextAttributes([.foregroundColor: burgundy, .font: UIFont.boldSystemFont(ofSize: 13)], for: .selected)
            control.setTitleTextAttributes([.foregroundColor: UIColor(HexColor: "3D332B"), .font: UIFont.systemFont(ofSize: 13)], for: .normal)
            control.semanticContentAttribute = .forceRightToLeft
            control.addTarget(self, action: action, for: .valueChanged)
            return control
        }
        v.sort = copySegments(self.sortSegmenterController, action: #selector(newSortChanged(_:)))
        v.which = copySegments(self.lessonsFilterSegmentedController, action: #selector(newWhichChanged(_:)))
        v.media = copySegments(self.mediaTypeSegmentedController, action: #selector(newMediaChanged(_:)))
        
        func caption(_ text:String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textColor = LessonsBrowserStyle.secondaryText
            label.textAlignment = .right
            return label
        }
        for view in [caption("st_sort_by".localize()), v.sort, caption("שיעורים"), v.which, caption("סוג"), v.media] as [UIView] {
            v.panel.addArrangedSubview(view)
        }
        v.panel.axis = .vertical
        v.panel.spacing = 6
        v.panel.isLayoutMarginsRelativeArrangement = true
        v.panel.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 12, right: 12)
        v.panel.backgroundColor = LessonsBrowserStyle.openBackground
        v.panel.isHidden = true
        
        // The lessons list: its own navigation controller (daf → maggidei shiur slides in)
        let nav = self.lessonsBrowser.navigationController
        self.addChild(nav)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        
        v.stack.axis = .vertical
        v.stack.translatesAutoresizingMaskIntoConstraints = false
        v.stack.addArrangedSubview(row)
        v.stack.addArrangedSubview(v.panel)
        v.stack.addArrangedSubview(nav.view)
        v.container.addSubview(v.stack)
        NSLayoutConstraint.activate([
            v.stack.topAnchor.constraint(equalTo: v.container.topAnchor),
            v.stack.leftAnchor.constraint(equalTo: v.container.leftAnchor),
            v.stack.rightAnchor.constraint(equalTo: v.container.rightAnchor),
            v.stack.bottomAnchor.constraint(equalTo: v.container.bottomAnchor)
        ])
        nav.didMove(toParent: self)
        
        self.updateFilterSummary()
    }
    
    private func setFilterPanel(open:Bool)
    {
        let v = self.filterViews
        v.filterButton.layer.borderColor = (open ? LessonsBrowserStyle.burgundy : LessonsBrowserStyle.border).cgColor
        v.filterButton.backgroundColor = open ? LessonsBrowserStyle.openBackground : .white
        UIView.animate(withDuration: 0.25) {
            v.panel.isHidden = !open
            v.stack.layoutIfNeeded()
        }
    }
    
    @objc func newFilterButtonTapped()
    {
        self.setFilterPanel(open: self.filterViews.panel.isHidden)
    }
    
    @objc func newTodaysPageTapped()
    {
        self.scrollToTodaysPage(selectDefaultMaggidShiour: false)
        if self.browserSortOption != .Maschtot || self.browserShowsHistory {
            // today's lessons are shown in the masechet list
            self.filterViews.sort.selectedSegmentIndex = 0
            self.newSortChanged(self.filterViews.sort)
            if self.browserShowsHistory {
                self.filterViews.which.selectedSegmentIndex = 0
                self.newWhichChanged(self.filterViews.which)
            }
        }
        self.lessonsBrowser.showTodaysPage()
    }
    
    @objc func newSortChanged(_ sender:UISegmentedControl)
    {
        self.sortSegmenterController.selectedSegmentIndex = sender.selectedSegmentIndex
        self.sortSegmentedControlloerValueChanged(self.sortSegmenterController)
        self.filtersDidChange()
    }
    
    @objc func newWhichChanged(_ sender:UISegmentedControl)
    {
        self.lessonsFilterSegmentedController.selectedSegmentIndex = sender.selectedSegmentIndex
        self.lessonsFilterSegmentedControllerValueChanged(self.lessonsFilterSegmentedController)
        self.filtersDidChange()
    }
    
    @objc func newMediaChanged(_ sender:UISegmentedControl)
    {
        self.mediaTypeSegmentedController.selectedSegmentIndex = sender.selectedSegmentIndex
        self.mediaTypeSegmentedControllerValueChanged(self.mediaTypeSegmentedController)
        self.filtersDidChange()
    }
    
    private func filtersDidChange()
    {
        self.updateFilterSummary()
        self.lessonsBrowser.rebuildRoot(force: true)
    }
    
    private func updateFilterSummary()
    {
        let v = self.filterViews
        var parts = [String]()
        var active = 0
        for control in [v.sort, v.which, v.media] {
            let index = control.selectedSegmentIndex
            if index > 0 { active += 1 }
            if index >= 0, let title = control.titleForSegment(at: index) { parts.append(title) }
        }
        v.summaryLabel.text = parts.joined(separator: " · ")
        v.filterButton.setTitle(active > 0 ? " סינון (\(active))" : " סינון", for: .normal)
    }
    
    // MARK: LessonsBrowserDataSource
    
    var browserSortOption:LessonsSortOption { return self.lessonsPickerView.lessonsSortOption }
    var browserFilterOption:LessonsFilterOption { return self.lessonsPickerView.lessonsFilterOption }
    var browserMediaOption:LessonsMediaTypeOption { return self.lessonsPickerView.lessonsMediaTypeOption }
    var browserShowsHistory:Bool { return self.lessonsFilterSegmentedController.selectedSegmentIndex == 2 }
    var browserMaggidShiurs:[MaggidShiur] { return self.lessonsPickerView.displayedMaggidShiours }
    var browserCurrentLesson:Lesson? { return self.selectedLesson }
    var browserIsPlaying:Bool { return self.audioPlayer?.isPlaying ?? false }
    
    func browserPlay(_ lesson:Lesson)
    {
        if self.audioPlayer?.lockButton.isSelected ?? false {
            self.audioPlayer?.displayLockAlert()
            return
        }
        let isCurrent = self.selectedLesson?.identifier != nil && self.selectedLesson?.identifier == lesson.identifier
        
        // Tapping the playing lesson pauses it
        if isCurrent, self.audioPlayer?.isPlaying == true {
            self.audioPlayer?.pause()
            self.playPauseButton.isSelected = false
            self.lessonsBrowser.reloadVisible()
            return
        }
        
        // Keep the (hidden) picker on this lesson: the player's next / previous use it
        self.setPlayingLesson(lesson)
        self.updateLastPlayedMaggidShiurs(selectedMaggidShiur: lesson.maggidShiur)
        
        if isCurrent {
            self.audioPlayer?.play()
        } else {
            self.selectLesson(lesson, andStartAutomatically: true)
        }
        self.playPauseButton.isSelected = true
        if let selected = self.selectedLesson, let player = self.audioPlayer {
            LessonsManager.sharedManager.savePlayingLassonInfo(selected, duratoinInSeconds: player.timeNow())
        }
        self.lessonsBrowser.reloadVisible()
    }
    
    func browserIsSaving(_ lesson:Lesson) -> Bool { return self.isSavingLessonInProgress(lesson: lesson) }
    func browserDownloadProgress(_ lesson:Lesson) -> Float { return self.lessonDownloadPrecnetage(lesson: lesson) }
    
    func browserSave(_ lesson:Lesson)
    {
        guard let masechetName = lesson.masechet?.name, let maggidName = lesson.maggidShiur?.name, let pageSymbol = lesson.page?.symbol else { return }
        let processKey = "\(masechetName)\(maggidName)\(pageSymbol)"
        if self.savinglessonsActiveProcess[processKey] != nil { return }
        
        let saveLessonProcess = SaveLessonProcess()
        self.savinglessonsActiveProcess[processKey] = saveLessonProcess
        self.lessonsBrowser.reloadVisible()
        
        saveLessonProcess.executeWithObject(lesson, onStart: { () -> Void in
        }, onProgress: { (object) -> Void in
            self.lessonsBrowser.reloadVisible()
        }, onComplete: { (object) -> Void in
            self.savinglessonsActiveProcess.removeValue(forKey: processKey)
            lesson.masechet.hasSavedLessons = true
            lesson.maggidShiur.hasSavedLessons = true
            self.lessonsPickerView.reloadData()
            self.lessonsBrowser.reloadVisible()
        }, onFaile: { (object, error) -> Void in
            self.savinglessonsActiveProcess.removeValue(forKey: processKey)
            self.lessonsPickerView.reloadData()
            self.lessonsBrowser.reloadVisible()
            self.presentErrorAlertWithError(error)
        })
    }
    
    func browserDelete(_ lesson:Lesson)
    {
        guard LessonsManager.sharedManager.isSavedLesson(lesson) else { return }
        let alertTitle = "st_delete_lesson_alert_title".localize()
        let alertMessage = String(format: "st_delete_lesson_alert_message".localize(), arguments: [lesson.maggidShiur.name ?? "", lesson.masechet.name ?? "", lesson.page?.symbol ?? ""])
        let deleteTitle = "st_delete".localize()
        let cancelTitle = "st_cancel".localize()
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [deleteTitle, cancelTitle], onComplete:{ (dismissButtonKey) in
            guard dismissButtonKey == deleteTitle else { return }
            RemoveLessonProcess().executeWithObject(lesson, onStart: { () -> Void in
            }, onComplete: { (object) -> Void in
                self.lessonsPickerView.reloadData()
                self.lessonsBrowser.rebuildRoot(force: self.browserFilterOption == .Saved)
                self.lessonsBrowser.reloadVisible()
            }, onFaile: { (object, error) -> Void in
                self.lessonsPickerView.reloadData()
                self.lessonsBrowser.reloadVisible()
            })
        })
    }
}
