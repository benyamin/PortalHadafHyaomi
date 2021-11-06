//
//  TalmudViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 31/05/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TalmudViewController: MSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TalmudPagePickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var pagesCollectionView:UICollectionView!
     @IBOutlet weak var pagesCollectionBottomConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var talmudPagePickerView:TalmudPagePickerView!
    @IBOutlet weak var talmudPagePickerViewTopConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var displayTypePickerView:UIPickerView!
    @IBOutlet weak var displayTypePickerViewTopConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var lessonsPickerView:UIPickerView!
    @IBOutlet weak var lessonsPickerViewTopConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var vagshalLogoImageView:UIImageView!
    @IBOutlet weak var creaditView:UIView!
    
    @IBOutlet weak var lockRotationContentView:UIView!
    @IBOutlet weak var lockRotationButton:UIButton!
    @IBOutlet weak var lockRotationArrowImageView:UIImageView!
    
    @IBOutlet weak var showPlayerButton:UIButton?
    @IBOutlet weak var showPlayerButtonBottomConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var selectLessonButton:UIButton?
    @IBOutlet weak var selectPageButton:UIButton?
    @IBOutlet weak var selectTodaysPageButton:UIButton?
    @IBOutlet weak var selectDisplayTypeButton:UIButton?
    
    @IBOutlet weak var saveOrDeletePageButton:UIButton?
    
    @IBOutlet weak var addNoteButton:UIButton?
    
    @IBOutlet weak var nikodButton:UIButton?
    
    
    var displyedPicker:UIView?{
        didSet{
            
            if displyedPicker != nil
            {
                if self.blockView.superview != self.pagesCollectionView {
                    self.pagesCollectionView.addSubview(self.blockView)
                }
                self.blockView.isHidden = false
                self.pagesCollectionView.bringSubview(toFront: self.blockView)
            }
            else{
                self.blockView.isHidden = true
            }
        }
    }
    
    lazy var blockView:UIView = {
        
        var blockView = UIView(frame:self.pagesCollectionView.bounds)
        blockView.backgroundColor = UIColor.lightGray
        blockView.alpha = 0.6
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.blockViewTap(_:)))
        blockView.addGestureRecognizer(tap)
        
        return blockView
    }()
        
    var firstAppearance:Bool = true
    
    var avalibleDisplayTypes = HadafHayomiManager.sharedManager.avalibleDisplayTypes

    var displyedMasceht:Masechet?
    
    var displyedPage:Page!{
        didSet{
            //Set audio url only if the audio player is dispalyed
            if self.showPlayerButton?.isSelected ?? false
                &&   self.audioPlayer?.isPaused == false
                && self.audioPlayer?.isPlaying == false
            {
                self.setAudioUrl()
            }
            
            if let pageIndex = currentPageIndex
               ,HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: self.selectedDisplayType) != nil {
                self.saveOrDeletePageButton?.isSelected = true
            }
            else{
                self.saveOrDeletePageButton?.isSelected = false
            }
        }
    }
    
    
    var currentPageIndex:Int?{
        
        if let selectedMasechet = self.displyedMasceht
           , let selectedPage = self.displyedPage
           , let selectedPageSide = self.displyedPageSide
           , let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(selectedMasechet,
                                                                           page: selectedPage,
                                                                           pageSide: selectedPageSide) {
            return pageIndex
        }
        return nil
    }
    
    var displyedPageSide:Int!
    
    var selectedDisplayType:TalmudDisplayType = .Vagshal
    
    var talmudNumberOfPages:Int
    {
        get{
            return HadafHayomiManager.sharedManager.talmudNumberOfPages
        }
    }
    
    lazy var audioPlayer:BTPlayerView? = {
        
        BTPlayerManager.sharedManager.sharedPlayerView.displayPageButton?.isHidden = true
      return BTPlayerManager.sharedManager.sharedPlayerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setDefaultTalmudDisplay()
        
        self.talmudPagePickerView.shouldHighlightSavedPages = true

        self.pagesCollectionView.isHidden = true
        
        self.pagesCollectionView.semanticContentAttribute = .forceRightToLeft
     
        self.topBarView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.topBarView?.layer.shadowOpacity = 0.5
        self.topBarView?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.topBarView?.layer.shadowRadius = 2.0
        
        self.talmudPagePickerView.delegate = self
        
        self.view.bringSubview(toFront:  self.topBarView!)
        
        self.showPlayerButton?.layer.shadowColor = UIColor.darkGray.cgColor
        self.showPlayerButton?.layer.shadowOpacity = 0.5
        self.showPlayerButton?.layer.shadowOffset = CGSize(width: -1.0, height: -1.0)
        self.showPlayerButton?.layer.shadowRadius = 1.0
        
        self.creaditView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.creaditView?.layer.shadowOpacity = 0.5
        self.creaditView?.layer.shadowOffset = CGSize(width: -1.0, height: -1.0)
        self.creaditView?.layer.shadowRadius = 1.0
        
        self.talmudPagePickerView.highlightSavedPages = true
        
        if UserDefaults.standard.object(forKey: "didUpdateOldSavedPages") == nil
        {
            HadafHayomiManager.updateOldSavedPages()
            self.talmudPagePickerView.reloadInputViews()
            
            UserDefaults.standard.set(true, forKey: "didUpdateOldSavedPages")
        }
        
        let showPlayerButtonTitle = "  " + ("st_display_palyer").localize() + "  "
        self.showPlayerButton?.setTitle(showPlayerButtonTitle, for: .normal)
        
        let hidePlayerButtonTitle = "  " + ("st_hide_palyer").localize() + "  "
        self.showPlayerButton?.setTitle(hidePlayerButtonTitle, for: .selected)
        
        
        self.selectLessonButton?.titleLabel?.numberOfLines = 2
         self.selectPageButton?.titleLabel?.numberOfLines = 2
         self.selectTodaysPageButton?.titleLabel?.numberOfLines = 2
         self.selectDisplayTypeButton?.titleLabel?.numberOfLines = 2
      
        self.selectTodaysPageButton?.setTitle(("st_todays_page").localize(), for: .normal)
        self.selectPageButton?.setTitle(("st_select_page").localize(), for: .normal)
        self.selectDisplayTypeButton?.setTitle(("st_select_display").localize(), for: .normal)
        //self.selectDisplayTypeButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.selectLessonButton?.setTitle(("st_select_lesson").localize(), for: .normal)
    
        self.creaditView.isHidden = true
        self.pagesCollectionBottomConstraint?.constant = 0
    }
    
    func setDefaultTalmudDisplay()
    {
        self.nikodButton?.isHidden = true
        
        if let selectedTalmudDisplayType = UserDefaults.standard.object(forKey: "TalmudDisplayType") as? String
        {
            if selectedTalmudDisplayType == "צורת הדף"
            {
                selectedDisplayType = .Vagshal
            }
            else if selectedTalmudDisplayType == "טקסט הדף"
            {
                selectedDisplayType = .Text
                self.nikodButton?.isHidden = false
                self.nikodButton?.isSelected = false
            }
            else if selectedTalmudDisplayType == "טקסט הדף (מנוקד)"
            {
                selectedDisplayType = .TextWithScore
                 self.nikodButton?.isHidden = false
                self.nikodButton?.isSelected = true
            }
            else if selectedTalmudDisplayType == "Steinsaltz"
            {
                selectedDisplayType = .EN
            }
            else if selectedTalmudDisplayType == "חברותא"
            {
                selectedDisplayType = .Chavruta
            }
            else if selectedTalmudDisplayType == "שטיינזלץ"
            {
                selectedDisplayType = .Steinsaltz
            }
        }
        else{
           selectedDisplayType = .Vagshal
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         self.setAddNoteImageDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
        
        if self.firstAppearance == true
        {
            self.firstAppearance = false
            
            self.pagesCollectionView.reloadData()
            
            if let playingLesson = LessonsManager.sharedManager.playingLesson
            {
                self.talmudPagePickerView.scrollToMasechet(playingLesson.masechet, page: playingLesson.page!, pageSide: 1, animated: false)
                
                self.scrollToMaschet(playingLesson.masechet, page: playingLesson.page!, pageSide:0,  animated: false)
            }
            else if  let selectedPageInfo = UserDefaults.standard.object(forKey: "selectedPageInfo") as? [String:Any]
            {
                self.scrollToSelectedPage(pageInfo: selectedPageInfo)
            }
            else{
                 self.scrollToTodaysPage()
            }
            
            self.pagesCollectionView.isHidden = false
            
            if  LessonsManager.sharedManager.lessons.count == 0
            {
               self.getLessons()
            }
        }
        else if let playingLesson = LessonsManager.sharedManager.playingLesson
        {
            self.talmudPagePickerView.scrollToMasechet(playingLesson.masechet, page: playingLesson.page!, pageSide: 1, animated: false)
            
            self.scrollToMaschet(playingLesson.masechet, page: playingLesson.page!, pageSide:0,  animated: false)
        }
        
        if let audioPlayerView = self.audioPlayer
        {
            self.audioPlayer?.startAutomatically = false
            
            self.view.addSubview(audioPlayerView)
            
            let playerOrigenY = self.showPlayerButton!.frame.origin.y + self.showPlayerButton!.frame.size.height
            audioPlayerView.frame = CGRect(x: 0.0, y: playerOrigenY, width: self.view.frame.size.width, height: 120.0)
        }
    }
    
    func getLessons()
    {
        GetLessonsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onProgress: { (object) -> Void in
            
            //This returns for default lessons (last search)
            LessonsManager.sharedManager.lessons = object as! [Lesson]
            
        }, onComplete: { (object) -> Void in
            
            LessonsManager.sharedManager.lessons = object as! [Lesson]
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    @IBAction func saveMultiplePageButtonClicked(_ sender:UIButton) {
        
        //let timePickerview = UIView.viewWithNib("BTTimePickerview") as? BTTimePickerview
        
        if let pageRangePickerView = UIView.viewWithNib("TalmudPageRangePickerView") as? TalmudPageRangePickerView {
           
            let arrowHight = CGFloat(15)
            let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: arrowHight))
            arrow.image = UIImage.imageWithTintColor(UIImage(named: "Triangle.png")!, color: UIColor(HexColor: "791F23"))
            
            let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 260, height: pageRangePickerView.frame.size.height + arrowHight))
            popUpView.addSubview(arrow)
            popUpView.layer.cornerRadius = 3.0
            arrow.center = CGPoint(x: sender.frame.origin.x, y:  arrow.center.y)
            pageRangePickerView.layer.borderColor = UIColor(HexColor:"791F23").cgColor
            
            pageRangePickerView.layer.borderWidth = 2.0
            pageRangePickerView.layer.cornerRadius = 3.0
            pageRangePickerView.frame.origin.y = arrowHight
            pageRangePickerView.frame.size.width = popUpView.frame.size.width
            popUpView.addSubview(pageRangePickerView)
            let options = [
                .type(.down)
                ] as [PopoverOption]
            
          
            let popover = Popover(options: options, showHandler: nil, dismissHandler: {
                
            })
            popover.show(popUpView, fromView: sender, inView: self.view)
            
            pageRangePickerView.reloadWithObject(self.currentPageIndex)
        }
    }
    
    @IBAction func togglePagePickerViewButtonClicked(_ sender:UIButton)
    {
       self.togglePagePickerViewDisplay()
    }
    
    @IBAction func saveOrDeletePageButtonClicked(_ sender:UIButton) {
        
        self.saveOrDeletePageButton?.isUserInteractionEnabled = false
        if let pageIndex = self.currentPageIndex
        {
            if HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:pageIndex, type: self.selectedDisplayType) == nil
            {
                let pageInfo = (pageIndex:pageIndex, type:self.selectedDisplayType)
                SavePageProcess().executeWithObject(pageInfo, onStart: { () -> Void in
                    
                }, onProgress: { (object) -> Void in
                    
                }, onComplete: { (object) -> Void in
                    self.saveOrDeletePageButton?.isSelected = true
                    self.saveOrDeletePageButton?.isUserInteractionEnabled = true
                    
                },onFaile: { (object, error) -> Void in
                })
            }
            else{
                RemovePageProcess().executeWithObject(pageIndex, onStart: { () -> Void in
                    
                }, onComplete: { (object) -> Void in
                    self.saveOrDeletePageButton?.isSelected = false
                    self.saveOrDeletePageButton?.isUserInteractionEnabled = true
                    
                },onFaile: { (object, error) -> Void in
                    
                    print(error)
                })
            }
        }
    }

    @IBAction func lockRotationButtonClicked(_ sender:UIButton)
    {
        self.lockRotationButton.isSelected = !self.lockRotationButton.isSelected
        
        //If should rotate
        if self.lockRotationButton.isSelected == false
        {
            self.rotated()
        }
    }
    
    @IBAction func showPlayerButtonClicked(_ sender:UIButton)
    {
        self.showPlayerButton?.isSelected = !self.showPlayerButton!.isSelected
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                if self.showPlayerButton!.isSelected
                {
                    self.showPlayerButtonBottomConstraint?.constant = self.audioPlayer!.frame.size.height-1
                    
                    self.audioPlayer?.frame.origin.y = self.view.frame.size.height - self.audioPlayer!.frame.size.height
                    
                    //Set audio url only if an audio lesson is not active
                    if  self.audioPlayer?.isPaused == false
                        && self.audioPlayer?.isPlaying == false
                    {
                        self.setAudioUrl()
                    }
                }
                else{
                    
                    self.showPlayerButtonBottomConstraint?.constant = 0
                    self.audioPlayer?.frame.origin.y = self.view.frame.size.height
                }
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    @IBAction func addNoteButtonClicked(_ sender:UIButton)
    {
           let noteViewController =  UIViewController.withName("NoteViewController", storyBoardIdentifier: "TalmudStoryboard") as! MSBaseViewController
              
        if self.displyedMasceht != nil && self.displyedPage != nil
        {
            let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor( self.displyedMasceht!, page: self.displyedPage!, pageSide :self.displyedPageSide)
            
           let note = HadafHayomiManager.sharedManager.getNoteByPageIndex("\(pageIndex!)")
            
            if note.title == nil
            {
                let pageSideDisplay = self.displyedPageSide == 1 ? "א" : "ב"
                
                var noteTitle = "מסכת " + self.displyedMasceht!.name +  " דף " + self.displyedPage!.symbol
                
                noteTitle += " עמ' " + "\(pageSideDisplay)"
                note.title = noteTitle
            }
            
            noteViewController.reloadWithObject(note)
            self.navigationController?.pushViewController(noteViewController, animated: true)
        }
        
    }
    
    @IBAction func nikodButtonClicked(_ sender:UIButton)
    {
        nikodButton?.isSelected = !sender.isSelected
        
        if nikodButton?.isSelected ?? false
        {
            self.selectedDisplayType = .TextWithScore
        }
        else{
             self.selectedDisplayType = .Text
        }
        
        self.pagesCollectionView.reloadData()
    }
    
    
    @objc func blockViewTap(_ sender: UITapGestureRecognizer) {
        
        if self.displyedPicker != nil
        {
             self.closPicker(self.displyedPicker!, animated:true)
        }
    }
    
    func closPicker(_ picker:UIView, animated:Bool)
    {
        //If is open hide talmudPagePicker
        if picker == talmudPagePickerView && self.talmudPagePickerViewTopConstraint.constant == 0 {
            self.talmudPagePickerViewTopConstraint.constant = -1 * self.talmudPagePickerView.frame.size.height
        }
        
        //If is open hide displayTypePickerView
        if picker == displayTypePickerView && self.displayTypePickerViewTopConstraint.constant == 0
        {
            self.setSelectedDisplayType()
            self.displayTypePickerViewTopConstraint.constant = -1 * self.displayTypePickerView.frame.size.height
        }
        
        //If is open hide displayTypePickerView
        if picker == lessonsPickerView && self.lessonsPickerViewTopConstraint.constant == 0
        {
            self.lessonsPickerViewTopConstraint.constant = -1 * self.lessonsPickerView.frame.size.height
        }
        
        self.displyedPicker = nil
        
        if animated
        {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    self.view.layoutIfNeeded()
                    
            }, completion: {_ in
            })
        }
    }
    
    func setSelectedDisplayType()
    {
        self.pagesCollectionView.semanticContentAttribute = .forceRightToLeft
        
        self.vagshalLogoImageView.isHidden = true
        self.creaditView.isHidden = true
        self.nikodButton?.isHidden = true
        
         self.pagesCollectionBottomConstraint?.constant = 0
        
        self.selectedDisplayType = self.avalibleDisplayTypes[displayTypePickerView.selectedRow(inComponent: 0)]
        
        if self.selectedDisplayType == .Vagshal
        {
           self.vagshalLogoImageView.isHidden = false
        }
        else if self.selectedDisplayType == .EN
        {
            self.creaditView.isHidden = false
            self.pagesCollectionBottomConstraint?.constant = self.creaditView.frame.size.height
            self.pagesCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        else if self.selectedDisplayType == .Steinsaltz
        {
            self.creaditView.isHidden = false
            self.pagesCollectionBottomConstraint?.constant = self.creaditView.frame.size.height
        }
        else if self.selectedDisplayType == .Text
            || self.selectedDisplayType == .TextWithScore
        {
             self.nikodButton?.isHidden = false
            
             if self.selectedDisplayType == .Text
             {
                self.nikodButton?.isSelected = false
            }
            else if self.selectedDisplayType == .TextWithScore
            {
                self.nikodButton?.isSelected = true
            }
        }
        
        if self.selectedDisplayType == .Vagshal
            || self.selectedDisplayType == .Chavruta {
            saveOrDeletePageButton?.isHidden = false
        }
        else{
            saveOrDeletePageButton?.isHidden = true
        }
        
        self.talmudPagePickerView.displayType = self.selectedDisplayType;
        
        self.view.layoutIfNeeded()
        
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.pagesCollectionView.reloadData()
        
        self.scrollToMaschet(self.displyedMasceht!, page: self.displyedPage, pageSide: self.displyedPageSide, animated: false)
        
       self.onDidSelectPage()
    }
    
    func onDidSelectPage()
    {
        if self.selectedDisplayType == .EN
        {
            self.topBarTitleLabel?.text = HadafHayomiManager.dispalyEnglishTitleForMaschet(self.displyedMasceht!, page: self.displyedPage, pageSide:  self.displyedPageSide)
        }
        else{
            self.topBarTitleLabel?.text = HadafHayomiManager.dispalyTitleForMaschet(self.displyedMasceht!, page: self.displyedPage, pageSide:  self.displyedPageSide)
        }
        
        self.setAddNoteImageDisplay()
    }
    
    func setAddNoteImageDisplay()
    {
        if self.displyedMasceht == nil || self.displyedPage == nil || self.displyedPageSide == nil
        {
            let addNoteImgae = UIImage(named: "Icons_notes_off.png")
            self.addNoteButton?.setImage(addNoteImgae, for: .normal)
            
            return
        }
        
        if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor( self.displyedMasceht!, page: self.displyedPage!, pageSide :self.displyedPageSide)
        {
            if HadafHayomiManager.sharedManager.hasNoteOnPage(pageId:"\(pageIndex)")
            {
                let addNoteImgae = UIImage(named: "Icons_notes_on.png")
                self.addNoteButton?.setImage(addNoteImgae, for: .normal)
            }
            else{
                let addNoteImgae = UIImage(named: "Icons_notes_off.png")
                self.addNoteButton?.setImage(addNoteImgae, for: .normal)
            }
        }
        else{
            let addNoteImgae = UIImage(named: "Icons_notes_off.png")
            self.addNoteButton?.setImage(addNoteImgae, for: .normal)
        }
    }
    
    func togglePagePickerViewDisplay()
    {
        self.closPicker(self.displayTypePickerView, animated:false)
        self.closPicker(self.lessonsPickerView, animated:false)
        
        var pickerIsDisplayed = false
        //If is open hide talmudPagePicker
        if self.talmudPagePickerViewTopConstraint.constant == 0
        {
            if let selectedMasehchet = talmudPagePickerView.selectedMasechet
            , let selectedPage = talmudPagePickerView.selectedPage
            , let selectedPageSide = talmudPagePickerView.selectedPageSide
            {
                self.scrollToMaschet(selectedMasehchet, page: selectedPage, pageSide:selectedPageSide, animated: false)
                
                self.talmudPagePickerViewTopConstraint.constant = -1 * self.talmudPagePickerView.frame.size.height
            }
        }
        else//Show picker
        {
            pickerIsDisplayed = true
            
            if  self.talmudPagePickerView.pagesPickerView.frame != self.talmudPagePickerView.bounds
            {
                self.talmudPagePickerView.pagesPickerView.frame = self.talmudPagePickerView.bounds
                self.talmudPagePickerView.pagesPickerView.reloadAllComponents()
            }
            
            self.talmudPagePickerView.scrollToMasechet(self.displyedMasceht!, page: self.displyedPage, pageSide:self.displyedPageSide, animated: false)
            
            self.talmudPagePickerViewTopConstraint.constant = 0
            
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
                if pickerIsDisplayed
                {
                    self.displyedPicker = self.talmudPagePickerView
                }
                else{
                
                    self.displyedPicker = nil
                }
               
                
        }, completion: {_ in
        })
    }
    
    @IBAction func toggleLessonsPickerViewDisplayButtonClicked(_ sender:UIButton)
    {
        self.toggleLessonsPickerViewDisplay()
    }
    
    func toggleLessonsPickerViewDisplay()
    {
        self.lessonsPickerView.reloadAllComponents()
        
        self.closPicker(self.displayTypePickerView, animated:false)
        self.closPicker(self.talmudPagePickerView, animated:false)
        
        //If is open hide lessonsPickerView
        if self.lessonsPickerViewTopConstraint.constant == 0
        {
            self.lessonsPickerViewTopConstraint.constant = -1 * self.lessonsPickerView.frame.size.height
            
            self.displyedPicker = nil
        }
        else//Show picker
        {
            //Scroll to the current playgin maggid shiur
            if let playingLesson = LessonsManager.sharedManager.playingLesson
                ,let maggidShiurs = self.displyedMasceht?.maggidShiurs
            {
                for index in 0 ..< maggidShiurs.count
                {
                    if maggidShiurs[index].id == playingLesson.maggidShiur.id
                    {
                         self.lessonsPickerView.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                }
            }
            
            self.lessonsPickerViewTopConstraint.constant = 0
            
            self.displyedPicker = self.lessonsPickerView
            
            //If the player is hidden
            if self.showPlayerButton?.isSelected == false
            {
                self.showPlayerButtonClicked(self.showPlayerButton!)
            }
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func setAudioUrl()
    {
        let selectedMagidShiourIndex = self.lessonsPickerView.selectedRow(inComponent: 0)
        
        if let maschet = self.displyedMasceht
            ,selectedMagidShiourIndex < maschet.maggidShiurs.count
        {
            var selectedMaggidShior = self.displyedMasceht?.maggidShiurs[selectedMagidShiourIndex]
            
            //Get saved default magidShiour and check if the selected masechet has lessons for this magidShiour
            if let defaultMagidShiourId =  UserDefaults.standard.object(forKey: "DefaultMagidShiour") as? String
            {
                if let maggidShiurs = self.displyedMasceht?.maggidShiurs
                {
                    for maggidShior in maggidShiurs
                    {
                        if maggidShior.id == defaultMagidShiourId
                        {
                            selectedMaggidShior = maggidShior
                            break
                        }
                    }
                }
            }
            
            if selectedMaggidShior == nil
            {
                return
            }
            
            if let lesson = LessonsManager.sharedManager.getLessonForMasechet(maschet, andMaggidShiour: selectedMaggidShior!)?.copy() as? Lesson
            {
                lesson.page = self.displyedPage
                
                self.audioPlayer?.title = "מסכת \(lesson.masechet.name!) דף \(lesson.page!.symbol!)"
                self.audioPlayer?.subTitle = lesson.maggidShiur.name
                
                LessonsManager.sharedManager.playingLesson = lesson
                
                self.audioPlayer?.setPlayerUrl(lesson.getUrl())
            }
        }
    }
    
    @IBAction func showTodaysPageButtonClicked(_ sender:UIButton)
    {
        self.scrollToTodaysPage()
        self.closPicker(self.talmudPagePickerView, animated:false)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                 self.pagesCollectionView.isUserInteractionEnabled = true
                self.pagesCollectionView.alpha = 1.0
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    @IBAction func toggleDisplyTypeButtonClicked(_ sender:UIButton)
    {
        self.closPicker(self.lessonsPickerView, animated:false)
        self.closPicker(self.talmudPagePickerView, animated:false)
        
        //If is open hide displayTypePickerView
        if self.displayTypePickerViewTopConstraint.constant == 0
        {
            self.setSelectedDisplayType()
            self.displayTypePickerViewTopConstraint.constant = -1 * self.displayTypePickerView.frame.size.height
            
            self.displyedPicker = nil
        }
        else//Show picker
        {
            self.displayTypePickerViewTopConstraint.constant = 0
            
            self.displyedPicker = self.displayTypePickerView
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func scrollToSelectedPage(pageInfo:[String:Any])
    {
        if let maschetId =  pageInfo["maschetId"] as? String
        {
            let pageIndex =  pageInfo["pageIndex"] as! Int
            let pageSide =  pageInfo["pageSide"] as! Int
            
            if let masechet = HadafHayomiManager.sharedManager.getMasechetById(maschetId)
            {
                let page = Page(index: pageIndex)
                
                self.scrollToMaschet(masechet, page: page, pageSide:pageSide, animated: false)
            }
        }
    }
    
    func scrollToTodaysPage()
    {
        let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet!
        let todaysPage = HadafHayomiManager.sharedManager.todaysPage!
        
        self.talmudPagePickerView.scrollToMasechet(todaysMaschet, page: todaysPage, pageSide: 1, animated: false)
        
        self.scrollToMaschet(todaysMaschet, page: todaysPage, pageSide:0,  animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func scrollToMaschet(_ maschet:Masechet, page:Page, pageSide:Int, animated:Bool)
    {
        self.displyedMasceht = maschet
        self.displyedPage = page
        self.displyedPageSide =  pageSide
        
        if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(maschet, page: page, pageSide: pageSide)
        {
            //Reduce by 1 becuse the collectoin view index starts from 0
            let indexPath = IndexPath(row:pageIndex-1, section: 0)
            
            self.pagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
        self.onDidSelectPage()
        
        self.saveSelectedPage()
    }
    
    @objc func rotated()
    {
        if self.lockRotationButton.isSelected
        {
            self.lockRotationArrowImageView.rotateAnimation(duration: 0.6, repeatCount:2.0)

            return
        }
        
        self.pagesCollectionView.translatesAutoresizingMaskIntoConstraints = true
        self.lockRotationContentView.translatesAutoresizingMaskIntoConstraints = true
        
        if UIDevice.current.orientation.isLandscape {
            
            self.setLandscapeLayout()
        }
        else {
            
            //Is alredy in protert mode
            if self.pagesCollectionView.superview == self.view
            {
                return
            }
            self.setProtraitLayout()
        }
    }
    
    func setLandscapeLayout()
    {
        var rotationAngle:Double!
        
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.pagesCollectionView.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.pagesCollectionView.indexPathsForVisibleItems.first!
        }
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let colletoinCenterOnRootView = self.view.convert(self.pagesCollectionView.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.pagesCollectionView)
        self.pagesCollectionView.center = colletoinCenterOnRootView
        
        if UIDevice.current.orientation == .landscapeLeft
        {
            rotationAngle = Double.pi/2
        }
        else if UIDevice.current.orientation == .landscapeRight
        {
            rotationAngle = -Double.pi/2
        }
   
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.pagesCollectionView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
                let collectionFrameSize = CGSize(width: rootViewController.view.bounds.size.width, height: rootViewController.view.bounds.size.height)
                let collectionCenter = CGPoint(x: collectionFrameSize.width/2, y: collectionFrameSize.height/2)
                
                self.pagesCollectionView.frame.size = collectionFrameSize
                self.pagesCollectionView.center = collectionCenter
                
                if let flowLayout = self.pagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                self.pagesCollectionView.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
        }, completion: {_ in
            
            let lockRotationCenter = self.view.convert(self.lockRotationContentView.center, to:rootViewController.view)
            rootViewController.view.addSubview(self.lockRotationContentView)
            self.lockRotationContentView.center = lockRotationCenter
            
            self.lockRotationContentView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        })
    }
    
    func setProtraitLayout()
    {
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.pagesCollectionView.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.pagesCollectionView.indexPathsForVisibleItems.first!
        }
        
        let rotationAngle = 0
        
        let collectionHeight = self.view.bounds.size.height - (self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height)
        
        let collectionFrameSize = CGSize(width: self.view.bounds.size.width, height:collectionHeight)
        
        let topButtonsHeight:CGFloat = 35.0
        let collectionCenterY = (self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height + topButtonsHeight) + (collectionHeight/2)
        let collectionCenter = CGPoint(x:  collectionFrameSize.width/2, y: collectionCenterY)
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let lockRotationCenter = rootViewController.view.convert(self.lockRotationContentView.center, to:self.topBarView!)
        self.topBarView!.addSubview(self.lockRotationContentView)
        self.lockRotationContentView.center = lockRotationCenter
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.pagesCollectionView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                self.lockRotationContentView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))

                self.pagesCollectionView.frame.size = collectionFrameSize
                self.pagesCollectionView.center = collectionCenter
                
                if let flowLayout = self.pagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                self.pagesCollectionView.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
        }, completion: {_ in
            
                let colletoinCenter = rootViewController.view.convert(self.pagesCollectionView.center, to:self.view)
                self.view.addSubview(self.pagesCollectionView)
                self.pagesCollectionView.center = colletoinCenter
                self.view.sendSubview(toBack: self.pagesCollectionView)
        })
    }
    
    //MARK: - CollectionView Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.talmudNumberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalmudPageCell", for: indexPath) as! TalmudPageCell
        
        cell.displayType = self.selectedDisplayType
            
        cell.reloadWithObject(indexPath.row + 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStop()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStop()
        }
    }
    
    func scrollViewDidStop()
    {
        self.pagesCollectionView.scrollToNearestVisibleCell()
        
        let pageIndex = self.pagesCollectionView.centerRowIndex()
        
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex + 1)
        
        self.displyedMasceht = pageInfo["maschet"] as? Masechet
        self.displyedPage = pageInfo["page"] as? Page
        self.displyedPageSide =  pageInfo["pageSide"] as? Int
       
        self.onDidSelectPage()
        
        self.saveSelectedPage()
    }
    
    func saveSelectedPage()
    {
        var selectedPageInfo = [String:Any]()
        selectedPageInfo["maschetId"] = self.displyedMasceht?.id
        selectedPageInfo["pageIndex"] = self.displyedPage.index
        selectedPageInfo["pageSide"] = self.displyedPageSide
        
        UserDefaults.standard.set(selectedPageInfo, forKey: "selectedPageInfo")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: = TalmudPagePickerView delegate meothods
     func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didChangeComponent component:Int){
    }
    
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didHide:Bool){
    }
    
    //MARK PickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView == lessonsPickerView
        {
             let numberOfMaggidShiurs = self.displyedMasceht?.maggidShiurs.count
             return numberOfMaggidShiurs ?? 0
        }
        else if pickerView == displayTypePickerView
        {
            return self.avalibleDisplayTypes.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        return pickerView.frame.size.width
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let componentWidth = self.pickerView(pickerView, widthForComponent: component)
        
        let reusableView = UIView(frame: CGRect(x: 0, y: 0, width: componentWidth, height: 44))
        reusableView.backgroundColor = UIColor(HexColor: "F9F3DB")
        
        let pikerLabel = UILabel(frame: reusableView.bounds)
        pikerLabel.font = UIFont(name:"BroshMF", size: 20)!
        pikerLabel.textColor = UIColor(HexColor: "781F24")
        pikerLabel.backgroundColor = UIColor.clear
        pikerLabel.textAlignment = .center
        pikerLabel.adjustsFontSizeToFitWidth = true;
        
        reusableView.addSubview(pikerLabel)
        
       
        if pickerView == displayTypePickerView
        {
            switch (self.avalibleDisplayTypes[row])
            {
            case .Vagshal:
                pikerLabel.text = "צורת הדף"
                break
                
            case .Text:
                pikerLabel.text = "טקסט הדף"
                break
                
            case .TextWithScore:
                pikerLabel.text = "טקסט הדף (מנוקד)"
                break
                
            case .Meorot:
                pikerLabel.text = "טקסט הדף"
                break
                
            case .EN:
                pikerLabel.text = "Steinsaltz"
                break
                
            case .Chavruta:
                pikerLabel.text = "חברותא"
                break
            case .Steinsaltz:
                 pikerLabel.text = "שטיינזלץ"
            }
        }
        else if pickerView == lessonsPickerView
        {
            var lessonPickerText =  self.displyedMasceht?.maggidShiurs[row].name ?? ""
            
            if let maggidShiourLessonType = self.displyedMasceht?.maggidShiurs[row].mediaType.rawValue {
                let lessonType = "(\(maggidShiourLessonType))"
                lessonPickerText += " \(lessonType)"
                
                pikerLabel.attributedText = lessonPickerText.addAttribute(["name":NSAttributedStringKey.font.rawValue,"value": UIFont.boldSystemFont(ofSize: 12)], ToSubString: lessonType, ignoreCase: true)
            }
            else{
                pikerLabel.text = lessonPickerText
            }
        }
        
        return reusableView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == self.lessonsPickerView
        {
            self.setAudioUrl()
        }
    }
}
