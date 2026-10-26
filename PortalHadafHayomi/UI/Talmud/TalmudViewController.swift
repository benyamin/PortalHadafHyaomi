//
//  TalmudViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 31/05/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

class TalmudViewController: MSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TalmudPagePickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate
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
            
    @IBOutlet weak var nikodButton:UIButton?
                
    @IBOutlet weak var increaseTextSizeButton:UIButton!
    @IBOutlet weak var dicreaseTextSizeButton:UIButton!
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var searchBarTrailingConstraintToView:NSLayoutConstraint!
    
    @IBOutlet weak var nextPageButton:UIButton?
    @IBOutlet weak var prePageButton:UIButton?
    
    @IBOutlet weak var menuButton:UIButton!
    
    var displyedPicker:UIView?{
        didSet{
            
            if displyedPicker != nil
            {
                if self.blockView.superview != self.pagesCollectionView {
                    self.pagesCollectionView.addSubview(self.blockView)
                }
                self.blockView .frame = self.pagesCollectionView.bounds
                self.blockView.isHidden = false
                self.pagesCollectionView.bringSubviewToFront(self.blockView)
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
    
    var selectedDisplayType:TalmudDisplayType = .Vagshal{
        didSet{
            if self.pagesCollectionView != nil {
                self.pagesCollectionView.reloadData()
            }
            
            switch selectedDisplayType {
            case .Vagshal, .Meorot, .Chavruta:
                self.increaseTextSizeButton.isHidden = true
                self.dicreaseTextSizeButton.isHidden = true
                break
            case .Steinsaltz, .EN, .Text, .TextWithScore, .TextWithCommentators:
                self.increaseTextSizeButton.isHidden = false
                self.dicreaseTextSizeButton.isHidden = false
                break 
            }
            
            if selectedDisplayType == .Text {
                self.nikodButton?.isHidden = false
                self.nikodButton?.isSelected = false
            }
            else if selectedDisplayType == .TextWithScore {
                self.nikodButton?.isHidden = false
                self.nikodButton?.isSelected = true
            }
            else{
                self.nikodButton?.isHidden = true
            }
            
            // The ביאור is remembered separately; the normal display stays the one the user chose
            if !self.isBiurMode {
                UserDefaults.standard.set(selectedDisplayType.rawValue, forKey: "TalmudSelectedDisplayType")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    var talmudNumberOfPages:Int
    {
        get{
            return HadafHayomiManager.sharedManager.talmudNumberOfPages
        }
    }
    
    lazy var audioPlayer:BTPlayerView? = {
      return BTPlayerManager.sharedManager.sharedPlayerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setDefaultTalmudDisplay()
        
        self.setupSearchRowConstraints()
        self.setupPageToolbar()
        
        self.talmudPagePickerView.shouldHighlightSavedPages = true

        self.pagesCollectionView.isHidden = true
        
        self.pagesCollectionView.semanticContentAttribute = .forceRightToLeft
     
        self.topBarView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.topBarView?.layer.shadowOpacity = 0.5
        self.topBarView?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.topBarView?.layer.shadowRadius = 2.0
        
        self.talmudPagePickerView.delegate = self
        
        self.view.bringSubviewToFront(self.topBarView!)
        
        self.showPlayerButton?.layer.shadowColor = UIColor.darkGray.cgColor
        self.showPlayerButton?.layer.shadowOpacity = 0.5
        self.showPlayerButton?.layer.shadowOffset = CGSize(width: -1.0, height: -1.0)
        self.showPlayerButton?.layer.shadowRadius = 1.0
        self.showPlayerButton?.imageView?.contentMode = .scaleAspectFit
        
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
        
        self.selectLessonButton?.titleLabel?.numberOfLines = 2
         self.selectPageButton?.titleLabel?.numberOfLines = 2
         self.selectTodaysPageButton?.titleLabel?.numberOfLines = 2
         self.selectDisplayTypeButton?.titleLabel?.numberOfLines = 2
      
        // This button is now "ביאור" (today's page moved into "בחר דף")
        self.selectTodaysPageButton?.setTitle(("st_biur").localize(), for: .normal)
        self.selectPageButton?.setTitle(("st_select_page").localize(), for: .normal)
        self.selectDisplayTypeButton?.setTitle(("st_page_display").localize(), for: .normal)
        //self.selectDisplayTypeButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.selectLessonButton?.setTitle(("st_select_lesson").localize(), for: .normal)
    
        self.creaditView.isHidden = true
        self.pagesCollectionBottomConstraint?.constant = 0
        
        if let currentLanguage = Locale.current.languageCode
            ,currentLanguage.hasSuffix("he")
        {
            self.increaseTextSizeButton.setImage(UIImage(named: "AH+_icon"), for: .normal)
            self.dicreaseTextSizeButton.setImage(UIImage(named: "AH-_icon"), for: .normal)
        }
        else{
            self.increaseTextSizeButton.setImage(UIImage(named: "A+_icon"), for: .normal)
            self.dicreaseTextSizeButton.setImage(UIImage(named: "A-_icon"), for: .normal)
        }
    }
    
    func setDefaultTalmudDisplay()
    {
        selectedDisplayType =  TalmudDisplayType(rawValue:(UserDefaults.standard.object(forKey: "TalmudSelectedDisplayType") as? String ?? "Vagshal")) ?? .Vagshal
        self.talmudPagePickerView.displayType = self.selectedDisplayType
        /*
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
        */
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        TalmudViewController.shared = self
        TalmudViewController.updateSupportedOrientations()
        
        if self.firstAppearance == true
        {
            self.firstAppearance = false
            
            self.pagesCollectionView.reloadData()
            
            if let playingLesson = LessonsManager.sharedManager.playingLesson
                ,LessonsManager.sharedManager.isPlaying
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
                    ,LessonsManager.sharedManager.isPlaying
        {
            self.talmudPagePickerView.scrollToMasechet(playingLesson.masechet, page: playingLesson.page!, pageSide: 1, animated: false)
            
            self.scrollToMaschet(playingLesson.masechet, page: playingLesson.page!, pageSide:0,  animated: false)
        }
        
        if let audioPlayerView = self.audioPlayer
        {
            self.audioPlayer?.startAutomatically = false
            
            self.view.addSubview(audioPlayerView)
            
            let playerOrigenY = self.showPlayerButton!.frame.origin.y + self.showPlayerButton!.frame.size.height
            audioPlayerView.frame = CGRect(x: 0.0, y: playerOrigenY, width: self.view.frame.size.width, height: 170.0)
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
    
    private func toggleBookMarkDisplay(){
        
        var isDisplayingBookMark =  UserDefaults.standard.bool(forKey: "displayDafBookMark")
        isDisplayingBookMark = !isDisplayingBookMark
        for cell in self.pagesCollectionView.visibleCells {
            (cell as? TalmudPageCell)?.bookmarkView?.isHidden = !isDisplayingBookMark
            UserDefaults.standard.setValue(isDisplayingBookMark, forKey:"displayDafBookMark")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func saveMultiplePages() {
        
        //let timePickerview = UIView.viewWithNib("BTTimePickerview") as? BTTimePickerview
        
        if let pageRangePickerView = UIView.viewWithNib("TalmudPageRangePickerView") as? TalmudPageRangePickerView {
           
            let arrowHight = CGFloat(15)
            let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: arrowHight))
            arrow.image = UIImage.imageWithTintColor(UIImage(named: "Triangle.png")!, color: UIColor(HexColor: "791F23"))
            
            let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 260, height: pageRangePickerView.frame.size.height + arrowHight))
            popUpView.addSubview(arrow)
            popUpView.layer.cornerRadius = 3.0
            arrow.center = CGPoint(x: menuButton.frame.origin.x, y:  arrow.center.y)
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
            popover.show(popUpView, fromView: menuButton, inView: self.view)
            
            pageRangePickerView.reloadWithObject(self.currentPageIndex)
        }
    }
    
    @IBAction func togglePagePickerViewButtonClicked(_ sender:UIButton)
    {
       self.togglePagePickerViewDisplay()
    }
   
    private func saveOrRemoveCurrentPage() {
        
        if let pageIndex = self.currentPageIndex
        {
            if HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:pageIndex, type: self.selectedDisplayType) == nil
            {
                let pageInfo = (pageIndex:pageIndex, type:self.selectedDisplayType)
                SavePageProcess().executeWithObject(pageInfo, onStart: { () -> Void in
                    
                }, onProgress: { (object) -> Void in
                    
                }, onComplete: { (object) -> Void in
                    //self.saveOrDeletePageButton?.isUserInteractionEnabled = true
                    
                },onFaile: { (object, error) -> Void in
                })
            }
            else{
                RemovePageProcess().executeWithObject(pageIndex, onStart: { () -> Void in
                    
                }, onComplete: { (object) -> Void in
                   // self.saveOrDeletePageButton?.isSelected = false
                    //self.saveOrDeletePageButton?.isUserInteractionEnabled = true
                    
                },onFaile: { (object, error) -> Void in
                    
                    print(error)
                })
            }
        }
    }

    @IBAction func lockRotationButtonClicked(_ sender:UIButton)
    {
        self.lockRotationButton.isSelected = !self.lockRotationButton.isSelected
        
        // Lock to the orientation the screen is in right now
        switch self.view.window?.windowScene?.interfaceOrientation {
        case .landscapeLeft?: self.lockedOrientationMask = .landscapeLeft
        case .landscapeRight?: self.lockedOrientationMask = .landscapeRight
        default: self.lockedOrientationMask = .portrait
        }
        TalmudViewController.updateSupportedOrientations()
        
        //If should rotate
        if self.lockRotationButton.isSelected == false
        {
            self.rotated()
        }
    }
    
    @IBAction func showPlayerButtonClicked(_ sender:UIButton)
    {
        self.showPlayerButton?.isSelected = !self.showPlayerButton!.isSelected
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
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
    
    private func addNote()
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
    
    /// The page in the middle of the screen. (indexPathsForVisibleItems.first is not in order:
    /// it was sometimes the neighbour page, so "back" seemed not to work.)
    private func centeredPageRow() -> Int
    {
        let row = self.pagesCollectionView.centerRowIndex()
        if row >= 0 && row < self.pagesCollectionView.numberOfItems(inSection: 0) {
            return row
        }
        return self.currentPageIndexPath().row
    }
    
    @IBAction func nextPageButtonClicked(_ sender:UIButton){
        let nextIndexPath = IndexPath(item: self.centeredPageRow() + 1, section: 0)
        if nextIndexPath.item < self.pagesCollectionView.numberOfItems(inSection: 0) {
            self.pagesCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    @IBAction func prePageButtonClicked(_ sender:UIButton){
        let preIndexPath = IndexPath(item: self.centeredPageRow() - 1, section: 0)
        if preIndexPath.item >= 0 {
            self.pagesCollectionView.scrollToItem(at: preIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    private func isCurrentPageSaved() -> Bool {
        guard let pageIndex = self.currentPageIndex else {return false}
        return HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex:pageIndex, type: self.selectedDisplayType) == nil
    }
    
    @IBAction func menuButtonClicked(_ sender:UIButton){
      
        var actions = [ActionItem]()
        actions.append(
            ActionItem(
                key: "save/remove",
                title: self.isCurrentPageSaved() ? "st_save".localize() : "st_delete".localize(),
                image: self.isCurrentPageSaved() ? UIImage(named: "saveIcon") : UIImage(named: "trachIcon"),
                onTap:{
                    self.saveOrRemoveCurrentPage()
                })
        )
        
        actions.append(
            ActionItem(
                key: "addNote",
                title: "st_add_note".localize(),
                image: self.addNoteImageIconImage(),
                onTap:{
                    self.addNote()
                })
        )
       
        if self.canShareCurrentPage() {
            actions.append(
                ActionItem(
                    key: "share",
                    title: "st_share_page".localize(),
                    image: UIImage(named: "shareIcon"),
                    onTap:{
                        self.shareCurrentPage()
                    })
            )
        }
        
        actions.append(
            ActionItem(
                key: "addBookmark",
                title: UserDefaults.standard.bool(forKey: "displayDafBookMark")
                    ? "st_remove_bookmark".localize()
                    : "st_add_bookmark".localize() ,
                image: UserDefaults.standard.bool(forKey: "displayDafBookMark")
                    ? UIImage(named:"removeBookmark")
                    : UIImage(named:"addBookmark"),
                onTap:{
                    self.toggleBookMarkDisplay()
                })
        )
        
        actions.append(
            ActionItem(
                key: "DownloadPages",
                title: "st_download_pages".localize(),
                image: UIImage(named: "MultiplePageDownload"),
                onTap:{
                    self.saveMultiplePages()
                })
        )
      
             
          /*
            ActionItem(key: "options", title: "Options", image: UIImage(named: "MultiplePageDownload.png"), subActions: [
                    ActionItem(key: "a1", title: "Sub Action 1") { print("Sub 1") },
                    ActionItem(key: "a2", title: "Sub Action 2") { print("Sub 2") }
                ]),
                   ActionItem(key: "delete", title: "Delete", image: UIImage(named: "saveIcon.png")) { print("Delete") }
               ]*/
               
               let dropdown = ActionDropdownView(actions: actions)
               dropdown.show(relativeTo: sender)
    }
    
    private func canShareCurrentPage() -> Bool {
        if let pageIndex = self.currentPageIndex
            ,let pageLink = HadafHayomiManager.sharedManager.UrlPathForPage(pageIndex: pageIndex, displayType: self.selectedDisplayType){
            return true
        }
        else{
           return false
        }
    }
    /*
    private func currentPageSave(){
        if let pageIndex = currentPageIndex
           ,HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: self.selectedDisplayType) != nil {
          //  self.saveOrDeletePageButton?.isSelected = true
        }
        else{
           // self.saveOrDeletePageButton?.isSelected = false
        }
    }*/
    
    
    @objc func blockViewTap(_ sender: UITapGestureRecognizer) {
        
        if self.displyedPicker != nil
        {
             self.closPicker(self.displyedPicker!, animated:true)
        }
    }
    
    /// "בחר דף" while the page picker is closed, "סגור" while it is open
    func updateSelectPageButtonTitle(isPickerOpen:Bool)
    {
        let key = isPickerOpen ? "st_close" : "st_select_page"
        self.selectPageButton?.setTitle(key.localize(), for: .normal)
    }
    
    // MARK: - Page toolbar (44pt under the tabs): search · display / ביאור ▾ · arrows
    
    let biurTypes:[TalmudDisplayType] = [.Chavruta, .Steinsaltz, .EN]
    var isBiurMode = false
    private var displayTypeBeforeBiur:TalmudDisplayType = .Vagshal
    
    let pageToolbarHeight:CGFloat = 44
    private let tabsRowHeight:CGFloat = 35
    
    /// The last ביאור the user chose (default: חברותא)
    var biurDisplayType:TalmudDisplayType {
        get {
            let raw = UserDefaults.standard.string(forKey: "TalmudBiurDisplayType") ?? TalmudDisplayType.Chavruta.rawValue
            let type = TalmudDisplayType(rawValue: raw) ?? .Chavruta
            return self.biurTypes.contains(type) ? type : .Chavruta
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "TalmudBiurDisplayType")
        }
    }
    
    /// All page displays except the ביאור ones (those are under "ביאור")
    var pageDisplayTypes:[TalmudDisplayType] {
        return self.avalibleDisplayTypes.filter { !self.biurTypes.contains($0) }
    }
    
    private func toolbarTitle(for type:TalmudDisplayType) -> String {
        return type == .EN ? "Steinsaltz (English)" : type.localizedString()
    }
    
    private func makeToolbarIconButton(_ systemName:String, label:String, action:Selector, bordered:Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        button.tintColor = UIColor(HexColor: "781F24")
        if bordered {
            button.backgroundColor = .white
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(HexColor: "DCCFAE").cgColor
            button.layer.cornerRadius = 3
        }
        button.accessibilityLabel = label
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    lazy var toolbarSearchButton:UIButton = self.makeToolbarIconButton("magnifyingglass", label: "חיפוש בדף", action: #selector(toolbarSearchTapped), bordered: false)
    lazy var toolbarPrevButton:UIButton = self.makeToolbarIconButton("chevron.right", label: "העמוד הקודם", action: #selector(toolbarPrevTapped), bordered: true)
    lazy var toolbarNextButton:UIButton = self.makeToolbarIconButton("chevron.left", label: "העמוד הבא", action: #selector(toolbarNextTapped), bordered: true)
    
    lazy var toolbarMenuButton:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor(HexColor: "781F24"), for: .normal)
        button.tintColor = UIColor(HexColor: "781F24")
        button.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        // chevron on the left of the text
        button.semanticContentAttribute = .forceLeftToRight
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 12)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(HexColor: "DCCFAE").cgColor
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(toolbarMenuTappedLegacy), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var pageToolbar:UIView = {
        let bar = UIView()
        bar.backgroundColor = UIColor(HexColor: "F3E9CC")
        bar.semanticContentAttribute = .forceRightToLeft
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.backgroundColor = UIColor(HexColor: "DCCFAE")
        line.translatesAutoresizingMaskIntoConstraints = false
        
        for v in [self.toolbarSearchButton, self.toolbarMenuButton, self.toolbarPrevButton, self.toolbarNextButton, line] {
            bar.addSubview(v)
        }
        NSLayoutConstraint.activate([
            // search on the right
            self.toolbarSearchButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 6),
            self.toolbarSearchButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            self.toolbarSearchButton.widthAnchor.constraint(equalToConstant: 36),
            self.toolbarSearchButton.heightAnchor.constraint(equalToConstant: 34),
            // current display / ביאור in the middle
            self.toolbarMenuButton.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            self.toolbarMenuButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            self.toolbarMenuButton.heightAnchor.constraint(equalToConstant: 34),
            // arrows on the left: previous (→) then next (←)
            self.toolbarNextButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -8),
            self.toolbarNextButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            self.toolbarNextButton.widthAnchor.constraint(equalToConstant: 36),
            self.toolbarNextButton.heightAnchor.constraint(equalToConstant: 34),
            self.toolbarPrevButton.trailingAnchor.constraint(equalTo: self.toolbarNextButton.leadingAnchor, constant: -4),
            self.toolbarPrevButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            self.toolbarPrevButton.widthAnchor.constraint(equalToConstant: 36),
            self.toolbarPrevButton.heightAnchor.constraint(equalToConstant: 34),
            line.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            line.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return bar
    }()
    
    private var pageToolbarAdded = false
    
    func setupPageToolbar()
    {
        guard !self.pageToolbarAdded, let topBar = self.topBarView else { return }
        self.pageToolbarAdded = true
        
        self.view.addSubview(self.pageToolbar)
        NSLayoutConstraint.activate([
            self.pageToolbar.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: self.tabsRowHeight),
            self.pageToolbar.heightAnchor.constraint(equalToConstant: self.pageToolbarHeight),
            self.pageToolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pageToolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // The old search row (search bar, arrows, nikod) is replaced by the toolbar.
        // The search bar opens over the toolbar when the search icon is tapped.
        for c in self.searchRowTopConstraints {
            if c.firstItem === self.searchBar {
                c.constant = self.tabsRowHeight
            } else {
                (c.firstItem as? UIView)?.isHidden = true
            }
        }
        self.searchBar?.isHidden = true
        
        self.updatePageToolbar()
    }
    
    func updatePageToolbar()
    {
        self.setupPageToolbar()
        
        let current = self.isBiurMode ? self.biurDisplayType : self.selectedDisplayType
        self.toolbarMenuButton.setTitle(self.toolbarTitle(for: current), for: .normal)
        self.toolbarMenuButton.accessibilityLabel = (self.isBiurMode ? "st_biur" : "st_page_display").localize() + ": " + self.toolbarTitle(for: current)
        self.rebuildToolbarMenu()
        
        // Displays are chosen from the toolbar now; the nikod button is not needed
        self.nikodButton?.isHidden = true
        
        // No swiping between pages inside the ביאור (the arrows still work)
        self.pagesCollectionView?.isScrollEnabled = !self.isBiurMode && !self.isInLandscapeLayout
        
        // The active tab looks pressed (darker), no system highlight
        let normal = UIColor(red: 0.553, green: 0.267, blue: 0.263, alpha: 1)
        let pressed = UIColor(HexColor: "5A1520")
        self.selectTodaysPageButton?.backgroundColor = self.isBiurMode ? pressed : normal
        self.selectDisplayTypeButton?.backgroundColor = self.isBiurMode ? normal : pressed
        
        if self.searchBar?.isHidden == false {
            self.view.bringSubviewToFront(self.pageToolbar)
            self.view.bringSubviewToFront(self.searchBar)
        } else {
            self.view.bringSubviewToFront(self.pageToolbar)
        }
    }
    
    // MARK: Drop-down list under the toolbar (display / ביאור options)
    
    private var isToolbarDropdownOpen = false
    private var toolbarDropdownHeight:NSLayoutConstraint?
    
    private lazy var toolbarDropdownDim:UIControl = {
        let dim = UIControl()
        dim.backgroundColor = UIColor(white: 0.12, alpha: 0.35)
        dim.alpha = 0
        dim.isHidden = true
        dim.translatesAutoresizingMaskIntoConstraints = false
        dim.addTarget(self, action: #selector(closeToolbarDropdownTapped), for: .touchUpInside)
        dim.accessibilityLabel = "st_close".localize()
        return dim
    }()
    
    private lazy var toolbarDropdown:UIView = {
        let panel = UIView()
        panel.backgroundColor = .white
        panel.clipsToBounds = true
        panel.isHidden = true
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.semanticContentAttribute = .forceRightToLeft
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.tag = 7001
        panel.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panel.topAnchor),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor)
        ])
        return panel
    }()
    
    private var toolbarDropdownAdded = false
    
    private func addToolbarDropdownIfNeeded()
    {
        guard !self.toolbarDropdownAdded else { return }
        self.setupPageToolbar()
        self.toolbarDropdownAdded = true
        self.view.addSubview(self.toolbarDropdownDim)
        self.view.addSubview(self.toolbarDropdown)
        let height = self.toolbarDropdown.heightAnchor.constraint(equalToConstant: 0)
        self.toolbarDropdownHeight = height
        NSLayoutConstraint.activate([
            self.toolbarDropdownDim.topAnchor.constraint(equalTo: self.pageToolbar.bottomAnchor),
            self.toolbarDropdownDim.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.toolbarDropdownDim.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.toolbarDropdownDim.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.toolbarDropdown.topAnchor.constraint(equalTo: self.pageToolbar.bottomAnchor),
            self.toolbarDropdown.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.toolbarDropdown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            height
        ])
    }
    
    private func rebuildToolbarMenu()
    {
        // The options open as a drop-down under the toolbar (not a floating menu)
        self.updateToolbarChevron()
    }
    
    private func updateToolbarChevron()
    {
        let name = self.isToolbarDropdownOpen ? "chevron.up" : "chevron.down"
        self.toolbarMenuButton.setImage(UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        self.toolbarMenuButton.layer.borderColor = UIColor(HexColor: self.isToolbarDropdownOpen ? "781F24" : "DCCFAE").cgColor
        self.toolbarMenuButton.accessibilityValue = self.isToolbarDropdownOpen ? "פתוח" : nil
    }
    
    private func fillToolbarDropdown() -> CGFloat
    {
        guard let stack = self.toolbarDropdown.viewWithTag(7001) as? UIStackView else { return 0 }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let types = self.isBiurMode ? self.biurTypes : self.pageDisplayTypes
        let current = self.isBiurMode ? self.biurDisplayType : self.selectedDisplayType
        let burgundy = UIColor(HexColor: "781F24")
        let rowHeight:CGFloat = 48
        
        for (index, type) in types.enumerated() {
            let selected = type == current
            let row = UIButton(type: .custom)
            row.tag = index
            row.backgroundColor = selected ? UIColor(HexColor: "FFF6E0") : .white
            row.setTitle(self.toolbarTitle(for: type), for: .normal)
            row.setTitleColor(selected ? burgundy : UIColor(HexColor: "1F1A17"), for: .normal)
            row.titleLabel?.font = selected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
            row.contentHorizontalAlignment = .right
            row.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 44)
            row.addTarget(self, action: #selector(toolbarDropdownRowTapped(_:)), for: .touchUpInside)
            row.accessibilityTraits = selected ? [.button, .selected] : .button
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
            
            if selected {
                let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)))
                check.tintColor = burgundy
                check.translatesAutoresizingMaskIntoConstraints = false
                row.addSubview(check)
                NSLayoutConstraint.activate([
                    check.rightAnchor.constraint(equalTo: row.rightAnchor, constant: -16),
                    check.centerYAnchor.constraint(equalTo: row.centerYAnchor)
                ])
            }
            
            let line = UIView()
            line.backgroundColor = UIColor(HexColor: "EFE6CC")
            line.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(line)
            NSLayoutConstraint.activate([
                line.leftAnchor.constraint(equalTo: row.leftAnchor),
                line.rightAnchor.constraint(equalTo: row.rightAnchor),
                line.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                line.heightAnchor.constraint(equalToConstant: 1)
            ])
            stack.addArrangedSubview(row)
        }
        return CGFloat(types.count) * rowHeight
    }
    
    @objc func toolbarMenuTappedLegacy()
    {
        if self.isToolbarDropdownOpen {
            self.closeToolbarDropdown(animated: true)
        } else {
            self.openToolbarDropdown()
        }
    }
    
    private func openToolbarDropdown()
    {
        self.addToolbarDropdownIfNeeded()
        self.searchBar?.resignFirstResponder()
        let height = self.fillToolbarDropdown()
        self.isToolbarDropdownOpen = true
        self.updateToolbarChevron()
        
        self.toolbarDropdownDim.isHidden = false
        self.toolbarDropdown.isHidden = false
        self.view.bringSubviewToFront(self.toolbarDropdownDim)
        self.view.bringSubviewToFront(self.toolbarDropdown)
        self.view.bringSubviewToFront(self.pageToolbar)
        self.view.layoutIfNeeded()
        
        // slides down from under the toolbar
        self.toolbarDropdownHeight?.constant = height
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.toolbarDropdownDim.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func closeToolbarDropdown(animated:Bool)
    {
        guard self.isToolbarDropdownOpen else { return }
        self.isToolbarDropdownOpen = false
        self.updateToolbarChevron()
        self.toolbarDropdownHeight?.constant = 0
        
        let finish = {
            self.toolbarDropdownDim.isHidden = true
            self.toolbarDropdown.isHidden = true
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.toolbarDropdownDim.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { _ in finish() })
        } else {
            self.toolbarDropdownDim.alpha = 0
            self.view.layoutIfNeeded()
            finish()
        }
    }
    
    @objc private func closeToolbarDropdownTapped()
    {
        self.closeToolbarDropdown(animated: true)
    }
    
    @objc private func toolbarDropdownRowTapped(_ sender:UIButton)
    {
        let types = self.isBiurMode ? self.biurTypes : self.pageDisplayTypes
        guard sender.tag < types.count else { return }
        self.closeToolbarDropdown(animated: true)
        self.selectToolbarOption(types[sender.tag])
    }
    
    private func selectToolbarOption(_ type:TalmudDisplayType)
    {
        if self.isBiurMode {
            self.biurDisplayType = type          // remembered for next time
        }
        self.applyDisplayType(type)
        self.updatePageToolbar()
    }
    
    @objc func toolbarSearchTapped()
    {
        guard let searchBar = self.searchBar else { return }
        searchBar.isHidden = false
        searchBar.showsCancelButton = true
        self.view.bringSubviewToFront(searchBar)
        searchBar.becomeFirstResponder()
    }
    
    private func hideSearchBar()
    {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.isHidden = true
    }
    
    @objc func toolbarPrevTapped() { self.prePageButtonClicked(self.toolbarPrevButton) }
    @objc func toolbarNextTapped() { self.nextPageButtonClicked(self.toolbarNextButton) }
    
    /// "ביאור" tab: opens the last chosen ביאור on the current page (tapping it again keeps it open)
    @IBAction func biurButtonClicked(_ sender:UIButton)
    {
        self.closeToolbarDropdown(animated: false)
        self.closPicker(self.displayTypePickerView, animated:false)
        self.closPicker(self.lessonsPickerView, animated:false)
        self.closPicker(self.talmudPagePickerView, animated:false)
        
        if !self.isBiurMode {
            self.enterBiurMode()
        }
        self.view.layoutIfNeeded()
    }
    
    func enterBiurMode()
    {
        if !self.biurTypes.contains(self.selectedDisplayType) {
            self.displayTypeBeforeBiur = self.selectedDisplayType
        }
        self.isBiurMode = true
        self.applyDisplayType(self.biurDisplayType)
        self.updatePageToolbar()
    }
    
    func exitBiurMode()
    {
        self.isBiurMode = false
        self.applyDisplayType(self.displayTypeBeforeBiur)
        self.updatePageToolbar()
    }
    
    // MARK: - Search row stays at the top while the page picker is open
    
    private var searchRowTopConstraints:[NSLayoutConstraint] = []
    private let searchRowTopWhenClosed:CGFloat = 39
    
    /// The page picker opens right under the buttons row ("לדף היומי" / "סגור"), over the search row
    var pagePickerOpenTopOffset:CGFloat {
        return self.selectPageButton?.frame.size.height ?? 35
    }
    
    /// The picker stretches from under the search row down to the bottom bar (credit / player button)
    func updatePagePickerHeightForOpen()
    {
        guard let picker = self.talmudPagePickerView, let container = picker.superview, let topBar = self.topBarView else { return }
        container.layoutIfNeeded()
        
        // Full size: down to the bottom of the screen area (above the app's tab bar)
        let bottomY = container.bounds.height - container.safeAreaInsets.bottom
        let topY = topBar.frame.maxY + self.pagePickerOpenTopOffset
        let height = max(200, bottomY - topY)
        
        if let heightConstraint = picker.constraints.first(where: { $0.firstItem === picker && $0.firstAttribute == .height && $0.secondItem == nil }) {
            heightConstraint.constant = height
        }
        container.layoutIfNeeded()
    }
    
    var isPagePickerOpen:Bool {
        return self.talmudPagePickerViewTopConstraint.constant >= 0
    }
    
    func setupSearchRowConstraints()
    {
        guard let topBar = self.topBarView, let searchBar = self.searchBar, let container = searchBar.superview else { return }
        
        // The search bar was attached under the "today's page" button, so it moved down with the page picker.
        // Attach it to the top bar instead, like the arrows row.
        for c in container.constraints where c.firstItem === searchBar && c.firstAttribute == .top {
            c.isActive = false
        }
        let searchTop = searchBar.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: self.searchRowTopWhenClosed)
        searchTop.isActive = true
        self.searchRowTopConstraints = [searchTop]
        
        // The arrows row and the nikod button are already attached to the top bar (+39)
        for c in container.constraints where c.isActive && c !== searchTop
            && c.firstAttribute == .top && c.secondItem === topBar && c.secondAttribute == .bottom
            && c.constant == self.searchRowTopWhenClosed {
            self.searchRowTopConstraints.append(c)
        }
    }
    
    func setSearchRowForPagePicker(open:Bool)
    {
        // The picker covers the search row and the bottom bar;
        // "לדף היומי", "בחר דף / סגור" and the top bar stay above it
        if open, let picker = self.talmudPagePickerView {
            picker.superview?.bringSubviewToFront(picker)
        }
        if !open {
            self.view.bringSubviewToFront(self.pageToolbar)
            if self.searchBar?.isHidden == false {
                self.view.bringSubviewToFront(self.searchBar)
            }
        }
        // "תצוגת הדף", "ביאור" and "בחר שיעור" are disabled while the page picker is open
        for b in [self.selectDisplayTypeButton, self.selectLessonButton, self.selectTodaysPageButton] {
            let disabled = open
            b?.isEnabled = !disabled
            b?.alpha = disabled ? 0.3 : 1.0
        }
        
        for v in [self.selectTodaysPageButton as UIView?, self.selectPageButton as UIView?] {
            if let v = v { v.superview?.bringSubviewToFront(v) }
        }
        if let topBar = self.topBarView { topBar.superview?.bringSubviewToFront(topBar) }
    }
    
    func closPicker(_ picker:UIView, animated:Bool)
    {
        //If is open hide talmudPagePicker
        if picker == talmudPagePickerView && self.isPagePickerOpen {
            self.talmudPagePickerViewTopConstraint.constant = -1 * self.talmudPagePickerView.frame.size.height
            self.setSearchRowForPagePicker(open: false)
            self.updateSelectPageButtonTitle(isPickerOpen: false)
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
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
                {
                    self.view.layoutIfNeeded()
                    
            }, completion: {_ in
            })
        }
    }
    
    func setSelectedDisplayType()
    {
        self.applyDisplayType(self.avalibleDisplayTypes[displayTypePickerView.selectedRow(inComponent: 0)])
    }
    
    func applyDisplayType(_ displayType:TalmudDisplayType)
    {
        self.pagesCollectionView.semanticContentAttribute = .forceRightToLeft
        
        self.vagshalLogoImageView.isHidden = true
        self.creaditView.isHidden = true
        self.nikodButton?.isHidden = true
        
         self.pagesCollectionBottomConstraint?.constant = 0
        
        self.selectedDisplayType = displayType
        
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
        /*
        if self.selectedDisplayType == .Vagshal
            || self.selectedDisplayType == .Chavruta {
            saveOrDeletePageButton?.isHidden = false
        }
        else{
            saveOrDeletePageButton?.isHidden = true
        }*/
        
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
    }
    
    func addNoteImageIconImage() -> UIImage?
    {
        if self.displyedMasceht == nil || self.displyedPage == nil || self.displyedPageSide == nil
        {
            return UIImage(named: "Icons_notes_off.png")
        }
        
        if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor( self.displyedMasceht!, page: self.displyedPage!, pageSide :self.displyedPageSide)
        {
            if HadafHayomiManager.sharedManager.hasNoteOnPage(pageId:"\(pageIndex)")
            {
                return UIImage(named: "Icons_notes_on.png")
            }
            else{
                return UIImage(named: "Icons_notes_off.png")
            }
        }
        else{
            return UIImage(named: "Icons_notes_off.png")
        }
    }
    
    func togglePagePickerViewDisplay()
    {
        self.closeToolbarDropdown(animated: false)
        self.closPicker(self.displayTypePickerView, animated:false)
        self.closPicker(self.lessonsPickerView, animated:false)
        
        var pickerIsDisplayed = false
        //If is open hide talmudPagePicker
        if self.isPagePickerOpen
        {
            if let selectedMasehchet = talmudPagePickerView.selectedMasechet
            , let selectedPage = talmudPagePickerView.selectedPage
            , let selectedPageSide = talmudPagePickerView.selectedPageSide
            {
                self.scrollToMaschet(selectedMasehchet, page: selectedPage, pageSide:selectedPageSide, animated: false)
                
                self.talmudPagePickerViewTopConstraint.constant = -1 * self.talmudPagePickerView.frame.size.height
                self.setSearchRowForPagePicker(open: false)
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
            
            self.updatePagePickerHeightForOpen()
            self.talmudPagePickerViewTopConstraint.constant = self.pagePickerOpenTopOffset
            self.setSearchRowForPagePicker(open: true)
            
        }
        
        self.updateSelectPageButtonTitle(isPickerOpen: pickerIsDisplayed)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
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
        self.closeToolbarDropdown(animated: false)
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
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
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
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                 self.pagesCollectionView.isUserInteractionEnabled = true
                self.pagesCollectionView.alpha = 1.0
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    /// "תצוגת הדף" tab: back to the page from the ביאור (the display is chosen in the toolbar)
    @IBAction func toggleDisplyTypeButtonClicked(_ sender:UIButton)
    {
        self.closeToolbarDropdown(animated: false)
        self.closPicker(self.lessonsPickerView, animated:false)
        self.closPicker(self.talmudPagePickerView, animated:false)
        self.closPicker(self.displayTypePickerView, animated:false)
        
        if self.isBiurMode {
            self.exitBiurMode()
        }
        self.view.layoutIfNeeded()
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
        
        if self.pagesCollectionView != nil {
            
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(maschet, page: page, pageSide: pageSide)
            {
                //Reduce by 1 becuse the collectoin view index starts from 0
                let indexPath = IndexPath(row:pageIndex-1, section: 0)
                
                self.pagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            }
            self.onDidSelectPage()
        }
        
        self.saveSelectedPage()
        DispatchQueue.main.async { self.updateLandscapeBiurPage() }
    }
    
    // MARK: - Rotation
    // Landscape uses a real iOS interface rotation (not a CGAffineTransform),
    // because PDFKit only renders the visible area sharply when the view is not transformed.
    
    /// The instance AppDelegate asks for the allowed orientations.
    static weak var shared: TalmudViewController?
    
    private var isInLandscapeLayout = false
    private var lockedOrientationMask: UIInterfaceOrientationMask = .portrait
    private var originalLockRotationFrame: CGRect?
    
    /// Orientations the app may use while this screen is visible.
    var allowedOrientations: UIInterfaceOrientationMask {
        guard isViewLoaded, view.window != nil else { return .portrait }
        if lockRotationButton?.isSelected == true { return lockedOrientationMask }
        return .allButUpsideDown
    }
    
    /// Tell iOS to re-read the allowed orientations.
    static func updateSupportedOrientations() {
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController
        if #available(iOS 16.0, *) {
            rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateLayoutForInterfaceOrientation()
        self.layoutLandscapeViews()
    }
    
    @objc func rotated()
    {
        let orientation = UIDevice.current.orientation
        
        // Ignore faceUp, faceDown, and unknown orientations
        guard orientation == .landscapeLeft || orientation == .landscapeRight || orientation == .portrait || orientation == .portraitUpsideDown else {
            return
        }
        
        if self.lockRotationButton.isSelected
        {
            self.lockRotationArrowImageView.rotateAnimation(duration: 0.6, repeatCount:2.0)
            return
        }
        
        // iOS rotates the screen itself. The layout is updated in viewDidLayoutSubviews.
        self.updateLayoutForInterfaceOrientation()
    }
    
    private func updateLayoutForInterfaceOrientation()
    {
        guard let window = self.view.window else { return }
        let isLandscape = window.bounds.width > window.bounds.height
        // The rotation lock is only useful in landscape (to stay there); hide it in portrait
        self.lockRotationContentView?.isHidden = !isLandscape
        if isLandscape == self.isInLandscapeLayout { return }
        self.isInLandscapeLayout = isLandscape
        
        if isLandscape {
            self.setLandscapeLayout()
        } else {
            self.setProtraitLayout()
        }
    }
    
    private func currentPageIndexPath() -> IndexPath
    {
        // Use the page we know is displayed. The visible cells are not reliable here:
        // while rotating, the collection view is already resized, so 2 pages are partly visible
        // and taking the first one sometimes jumped to the neighbour page.
        if let masechet = self.displyedMasceht, let page = self.displyedPage, let side = self.displyedPageSide,
           let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: side),
           pageIndex > 0 {
            return IndexPath(row: pageIndex - 1, section: 0)
        }
        if let first = self.pagesCollectionView.indexPathsForVisibleItems.sorted().first {
            return first
        }
        return IndexPath(row: 0, section: 0)
    }
    
    private func scrollBackTo(_ indexPath: IndexPath)
    {
        let scroll = { [weak self] in
            guard let self = self else { return }
            self.pagesCollectionView.collectionViewLayout.invalidateLayout()
            self.pagesCollectionView.layoutIfNeeded()
            if indexPath.row < self.pagesCollectionView.numberOfItems(inSection: 0) {
                self.pagesCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
        scroll()
        // The rotation may resize the page area once more after this; scroll again when it is done
        DispatchQueue.main.async(execute: scroll)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: scroll)
    }
    
    func setLandscapeLayout()
    {
        guard let rootView = self.view.window?.rootViewController?.view else { return }
        let currentIndex = self.currentPageIndexPath()
        
        self.pagesCollectionView.translatesAutoresizingMaskIntoConstraints = true
        self.lockRotationContentView.translatesAutoresizingMaskIntoConstraints = true
        
        if self.originalLockRotationFrame == nil {
            self.originalLockRotationFrame = self.lockRotationContentView.frame
        }
        
        // Full screen page, no transform
        self.pagesCollectionView.transform = .identity
        rootView.addSubview(self.pagesCollectionView)
        self.pagesCollectionView.autoresizingMask = []
        
        // Side bar (44pt) with the lock, ביאור and page arrows
        self.setupLandscapeSideBar()
        rootView.addSubview(self.landscapeBiurView)
        rootView.addSubview(self.landscapeSideBar)
        self.lockRotationContentView.transform = .identity
        self.lockRotationContentView.autoresizingMask = []
        self.landscapeSideBar.addSubview(self.lockRotationContentView)
        
        // In landscape pages move only with the side bar arrows (no swiping)
        self.pagesCollectionView.isScrollEnabled = false
        
        rootView.addSubview(self.landscapeSplitHandle)
        self.lastLandscapeLayoutKey = nil
        self.layoutLandscapeViews()
        self.updateLandscapeBiurPage()
        
        self.scrollBackTo(currentIndex)
    }
    
    func setProtraitLayout()
    {
        let currentIndex = self.currentPageIndexPath()
        
        // No side bar and no ביאור half in portrait
        self.landscapeSideBar.removeFromSuperview()
        self.landscapeBiurView.removeFromSuperview()
        self.landscapeSplitHandle.removeFromSuperview()
        self.landscapeBiurView.stop()
        
        // Swiping back in portrait (not inside the ביאור tab)
        self.pagesCollectionView.isScrollEnabled = !self.isBiurMode
        
        let topButtonsHeight:CGFloat = 35.0 + self.pageToolbarHeight   // tabs row + page toolbar
        let collectionY = self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height + topButtonsHeight
        let collectionHeight = self.view.bounds.size.height - collectionY
        
        self.pagesCollectionView.transform = .identity
        self.view.addSubview(self.pagesCollectionView)
        self.pagesCollectionView.autoresizingMask = []
        self.pagesCollectionView.frame = CGRect(x: 0, y: collectionY, width: self.view.bounds.size.width, height: collectionHeight)
        self.view.sendSubviewToBack(self.pagesCollectionView)
        
        self.lockRotationContentView.transform = .identity
        self.topBarView!.addSubview(self.lockRotationContentView)
        self.lockRotationContentView.autoresizingMask = []
        if let originalFrame = self.originalLockRotationFrame {
            self.lockRotationContentView.frame = originalFrame
        }
        
        self.scrollBackTo(currentIndex)
    }
    
    // MARK: - Landscape side bar + ביאור side by side (like the iPad)
    
    let landscapeSideBarWidth:CGFloat = 44
    /// The ביאור shown next to the page in landscape (nil = page only)
    var landscapeBiurType:TalmudDisplayType?
    private var lastLandscapeLayoutKey:String?
    
    lazy var landscapeBiurView:TalmudBiurSideView = TalmudBiurSideView()
    
    lazy var landscapeBiurButton:UIButton = self.makeSideBarButton("lightbulb", label: "st_select_explanation".localize(), action: #selector(landscapeBiurTapped))
    lazy var landscapePrevButton:UIButton = self.makeSideBarButton("chevron.right", label: "העמוד הקודם", action: #selector(toolbarPrevTapped))
    lazy var landscapeNextButton:UIButton = self.makeSideBarButton("chevron.left", label: "העמוד הבא", action: #selector(toolbarNextTapped))
    
    private func makeSideBarButton(_ systemName:String, label:String, action:Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)), for: .normal)
        button.tintColor = UIColor(HexColor: "781F24")
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(HexColor: "DCCFAE").cgColor
        button.layer.cornerRadius = 3
        button.accessibilityLabel = label
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    lazy var landscapeSideBar:UIView = {
        let bar = UIView()
        bar.backgroundColor = UIColor(HexColor: "F3E9CC")
        let line = UIView()
        line.backgroundColor = UIColor(HexColor: "DCCFAE")
        line.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(line)
        
        let lower = UIStackView(arrangedSubviews: [self.landscapeBiurButton, self.landscapePrevButton, self.landscapeNextButton])
        lower.axis = .vertical
        lower.spacing = 10
        lower.translatesAutoresizingMaskIntoConstraints = false
        lower.tag = 7101
        bar.addSubview(lower)
        
        NSLayoutConstraint.activate([
            line.leftAnchor.constraint(equalTo: bar.leftAnchor),
            line.topAnchor.constraint(equalTo: bar.topAnchor),
            line.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            line.widthAnchor.constraint(equalToConstant: 1),
            // at the bottom, away from the camera area (in landscape it is in the middle of the side)
            lower.bottomAnchor.constraint(equalTo: bar.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            self.landscapeBiurButton.widthAnchor.constraint(equalToConstant: 36),
            self.landscapeBiurButton.heightAnchor.constraint(equalToConstant: 36),
            self.landscapePrevButton.widthAnchor.constraint(equalToConstant: 36),
            self.landscapePrevButton.heightAnchor.constraint(equalToConstant: 36),
            self.landscapeNextButton.widthAnchor.constraint(equalToConstant: 36),
            self.landscapeNextButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        return bar
    }()
    
    private var landscapeStackCenterX:NSLayoutConstraint?
    
    private func setupLandscapeSideBar()
    {
        guard self.landscapeStackCenterX == nil, let stack = self.landscapeSideBar.viewWithTag(7101) else { return }
        let centerX = stack.centerXAnchor.constraint(equalTo: self.landscapeSideBar.centerXAnchor)
        centerX.isActive = true
        self.landscapeStackCenterX = centerX
    }
    
    /// Frames for the landscape views: [ביאור half][page][side bar]
    func layoutLandscapeViews()
    {
        guard self.isInLandscapeLayout, let rootView = self.landscapeSideBar.superview else { return }
        let bounds = rootView.bounds
        let rightInset = rootView.safeAreaInsets.right
        // as wide as the lock button + 16 on each side
        let lockWidth = self.lockRotationContentView.bounds.width > 0 ? self.lockRotationContentView.bounds.width : self.landscapeSideBarWidth
        let barWidth = lockWidth + 32
        let contentWidth = bounds.width - barWidth
        let split = self.landscapeBiurType != nil
        
        let key = "\(bounds.size)-\(rightInset)-\(split)-\(self.landscapeSplitRatio)"
        if key == self.lastLandscapeLayoutKey { return }
        let pageChangedWidth = self.lastLandscapeLayoutKey != nil
        self.lastLandscapeLayoutKey = key
        let currentIndex = self.currentPageIndexPath()
        
        self.landscapeSideBar.frame = CGRect(x: contentWidth, y: 0, width: barWidth, height: bounds.height)
        
        // lock button at the top of the side bar
        let lockSize = self.lockRotationContentView.bounds.size
        self.lockRotationContentView.frame = CGRect(x: 16,
                                                    y: max(12, rootView.safeAreaInsets.top + 8),
                                                    width: lockSize.width, height: lockSize.height)
        self.lockRotationContentView.isHidden = false
        
        self.applyLandscapeSplitFrames(contentWidth: contentWidth, height: bounds.height, split: split)
        
        self.landscapeBiurButton.backgroundColor = split ? UIColor(HexColor: "781F24") : .white
        self.landscapeBiurButton.tintColor = split ? .white : UIColor(HexColor: "781F24")
        
        if pageChangedWidth {
            self.scrollBackTo(currentIndex)
        }
    }
    
    // MARK: Resize page / ביאור by dragging the middle
    
    /// Width of the ביאור part (0.3 ... 0.7 of the content width)
    var landscapeSplitRatio:CGFloat {
        get {
            let value = UserDefaults.standard.object(forKey: "TalmudLandscapeSplitRatio") as? Double ?? 0.5
            return CGFloat(min(0.7, max(0.3, value)))
        }
        set {
            UserDefaults.standard.set(Double(min(0.7, max(0.3, newValue))), forKey: "TalmudLandscapeSplitRatio")
        }
    }
    
    private var landscapeContentWidth:CGFloat = 0
    private var splitDragRow:Int = 0
    
    lazy var landscapeSplitHandle:UIView = {
        let handle = UIView()
        handle.backgroundColor = .clear
        // Size first: the subviews below use autoresizing, which needs a real starting size
        // (with a zero size the middle marks were pushed off screen)
        handle.frame = CGRect(x: 0, y: 0, width: 34, height: 104)
        
        // A 20pt-wide rail along the divider: a light band with a line on each side
        // of the center line, so it reads as something that can be moved
        let rail = UIView()
        rail.backgroundColor = UIColor(HexColor: "F3E9CC").withAlphaComponent(0.85)
        rail.frame = CGRect(x: 7, y: 0, width: 20, height: 104)
        rail.autoresizingMask = [.flexibleHeight]
        handle.addSubview(rail)
        for x in [CGFloat(7), CGFloat(26)] {
            let side = UIView()
            side.backgroundColor = UIColor(HexColor: "DCCFAE")
            side.frame = CGRect(x: x, y: 0, width: 1, height: 104)
            side.autoresizingMask = [.flexibleHeight]
            handle.addSubview(side)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(HexColor: "B58B3A")
        line.frame = CGRect(x: 16, y: 0, width: 2, height: 104)
        line.autoresizingMask = [.flexibleHeight]
        handle.addSubview(line)
        
        // Grip marks in the middle: a 30pt line on each side of the center line,
        // 2pt away from it, in the same color
        for x in [CGFloat(16 - 2 - 2), CGFloat(18 + 2)] {
            let mark = UIView()
            mark.backgroundColor = UIColor(HexColor: "B58B3A")
            mark.frame = CGRect(x: x, y: (104 - 30) / 2, width: 2, height: 30)
            mark.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            mark.tag = 7201
            handle.addSubview(mark)
        }
        
        handle.frame = CGRect(x: 0, y: 0, width: 34, height: 104)
        handle.isAccessibilityElement = true
        handle.accessibilityLabel = "גרור לשינוי הגודל"
        handle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(splitHandleDragged(_:))))
        handle.isHidden = true
        return handle
    }()
    
    private func applyLandscapeSplitFrames(contentWidth:CGFloat, height:CGFloat, split:Bool)
    {
        self.landscapeContentWidth = contentWidth
        if split {
            // ביאור on the left, page on the right
            let biurWidth = floor(contentWidth * self.landscapeSplitRatio)
            self.landscapeBiurView.isHidden = false
            self.landscapeBiurView.frame = CGRect(x: 0, y: 0, width: biurWidth, height: height)
            self.pagesCollectionView.frame = CGRect(x: biurWidth, y: 0, width: contentWidth - biurWidth, height: height)
            self.landscapeSplitHandle.isHidden = false
            self.landscapeSplitHandle.frame = CGRect(x: biurWidth - 17, y: 0, width: 34, height: height)
            // keep the grip marks in the vertical middle
            for part in self.landscapeSplitHandle.subviews {
                if part.tag == 7201 {
                    part.frame.origin.y = (height - part.frame.height) / 2
                } else {
                    // rail and lines: full height, no gap at the bottom
                    part.frame.origin.y = 0
                    part.frame.size.height = height
                }
            }
            self.landscapeSplitHandle.superview?.bringSubviewToFront(self.landscapeSplitHandle)
        } else {
            self.landscapeBiurView.isHidden = true
            self.landscapeSplitHandle.isHidden = true
            self.pagesCollectionView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: height)
        }
    }
    
    @objc private func splitHandleDragged(_ pan:UIPanGestureRecognizer)
    {
        guard let rootView = self.landscapeSplitHandle.superview, self.landscapeContentWidth > 0 else { return }
        switch pan.state {
        case .began:
            self.splitDragRow = self.currentPageIndexPath().row
        case .changed:
            let x = pan.location(in: rootView).x
            let ratio = min(0.7, max(0.3, x / self.landscapeContentWidth))
            self.landscapeSplitRatio = ratio
            self.applyLandscapeSplitFrames(contentWidth: self.landscapeContentWidth, height: rootView.bounds.height, split: true)
            // keep the same page while the page area gets wider / narrower
            self.pagesCollectionView.collectionViewLayout.invalidateLayout()
            self.pagesCollectionView.layoutIfNeeded()
            if self.splitDragRow < self.pagesCollectionView.numberOfItems(inSection: 0) {
                self.pagesCollectionView.scrollToItem(at: IndexPath(row: self.splitDragRow, section: 0), at: .centeredHorizontally, animated: false)
            }
        case .ended, .cancelled:
            self.lastLandscapeLayoutKey = nil
            self.layoutLandscapeViews()
            self.scrollBackTo(IndexPath(row: self.splitDragRow, section: 0))
        default:
            break
        }
    }
    
    /// Load the ביאור of the page that is shown now
    func updateLandscapeBiurPage()
    {
        guard self.isInLandscapeLayout, let type = self.landscapeBiurType else { return }
        let row = self.currentPageIndexPath().row
        self.landscapeBiurView.show(type: type, pageIndex: row + 1)
    }
    
    // ביאור options (like the iPad: חברותא / שטיינזלץ / Steinsaltz, and "hide")
    @objc func landscapeBiurTapped()
    {
        // Already showing a ביאור: tapping again hides it (page only)
        if self.landscapeBiurType != nil {
            self.selectLandscapeBiur("hide")
            return
        }
        
        let options = ["חברותא", "שטיינזלץ", "Steinsaltz"]
        var titles = options
        if self.landscapeBiurType != nil {
            titles.append("st_hide_explanation".localize())
        }
        let selected:String? = {
            switch self.landscapeBiurType {
            case .some(.Chavruta): return "חברותא"
            case .some(.Steinsaltz): return "שטיינזלץ"
            case .some(.EN): return "Steinsaltz"
            default: return nil
            }
        }()
        
        let sheet = UIAlertController(title: "st_select_explanation".localize(), message: nil, preferredStyle: .actionSheet)
        for title in titles {
            let isSelected = (title == selected)
            sheet.addAction(UIAlertAction(title: (isSelected ? "✓ " : "") + title, style: .default) { [weak self] _ in
                self?.selectLandscapeBiur(title)
            })
        }
        sheet.addAction(UIAlertAction(title: "st_close".localize(), style: .cancel, handler: nil))
        sheet.popoverPresentationController?.sourceView = self.landscapeBiurButton
        sheet.popoverPresentationController?.sourceRect = self.landscapeBiurButton.bounds
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func selectLandscapeBiur(_ option:String)
    {
        switch option {
        case "חברותא": self.landscapeBiurType = .Chavruta
        case "שטיינזלץ": self.landscapeBiurType = .Steinsaltz
        case "Steinsaltz": self.landscapeBiurType = .EN
        default: self.landscapeBiurType = nil
        }
        if self.landscapeBiurType == nil {
            self.landscapeBiurView.stop()
        }
        self.layoutLandscapeViews()
        self.updateLandscapeBiurPage()
    }
    
    @IBAction func dicreaseTextSizeButtonClicked(_ sender:UIButton) {
          
        let textSizeKey = HadafHayomiManager.sharedManager.textSizeKeyForDisplayType(selectedDisplayType)
        let textSize = UserDefaults.standard.object(forKey: textSizeKey) as? Int ?? 0
        UserDefaults.standard.set( (textSize-2 > -80) ? textSize-2 : -80 , forKey: textSizeKey)
        UserDefaults.standard.synchronize()
     
        for cell in self.pagesCollectionView.visibleCells{
            (cell as? TalmudPageCell)?.reloadData()
        }
    }
    
    @IBAction func increaseTextSizeButtonClicked(_ sender:UIButton) {
        
        let textSizeKey = HadafHayomiManager.sharedManager.textSizeKeyForDisplayType(selectedDisplayType)
        let textSize = UserDefaults.standard.object(forKey: textSizeKey) as? Int ?? 0
        UserDefaults.standard.set( (textSize+2 < 80) ? textSize+2 : 80 , forKey: textSizeKey)
        UserDefaults.standard.synchronize()
     
        for cell in self.pagesCollectionView.visibleCells{
            (cell as? TalmudPageCell)?.reloadData()
        }
    }
    
    func shareCurrentPage(){
        
        let text = self.topBarTitleLabel?.text ?? ""
        if let image = UIImage(named: "Icon-App-60x60@2x.png")
            , let pageIndex = self.currentPageIndex
            ,let pageLink = HadafHayomiManager.sharedManager.UrlPathForPage(pageIndex: pageIndex, displayType: self.selectedDisplayType) {
            
            let shareAll = [text ,image , pageLink] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - CollectionView Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.talmudNumberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalmudPageCell", for: indexPath) as! TalmudPageCell
                    
        cell.reloadWithObject((self.selectedDisplayType, indexPath.row+1))
        
        if let searchText = self.searchBar.text
            ,!searchText.isEmpty {
            cell.highlightText(searchText)
        }
        
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
        self.updateLandscapeBiurPage()
    }
    
    /// After the arrows scroll the pages (animated), update the shown page
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === self.pagesCollectionView else { return }
        let pageIndex = self.pagesCollectionView.centerRowIndex()
        guard pageIndex >= 0 else { return }
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex + 1)
        self.displyedMasceht = pageInfo["maschet"] as? Masechet
        self.displyedPage = pageInfo["page"] as? Page
        self.displyedPageSide = pageInfo["pageSide"] as? Int
        self.onDidSelectPage()
        self.saveSelectedPage()
        self.updateLandscapeBiurPage()
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
    
    /// "לדף היומי" at the top of the page list
    func talmudPagePickerViewDidSelectTodaysPage(_ talmudPagePickerView: TalmudPagePickerView) {
        self.showTodaysPageButtonClicked(self.selectPageButton ?? UIButton())
    }
    
    /// A page was tapped in the page list: go to it and close the picker
    func talmudPagePickerViewDidSelectPage(_ talmudPagePickerView: TalmudPagePickerView) {
        if self.isPagePickerOpen {
            self.togglePagePickerViewDisplay()
        }
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
                
            case .TextWithCommentators:
                pikerLabel.text = "טקסט הדף ומפרשים"
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
                let lessonType = "(\("st_\(maggidShiourLessonType)".localize()))"
                
                lessonPickerText += " \(lessonType)"
                
                pikerLabel.attributedText = lessonPickerText.addAttribute(["name":NSAttributedString.Key.font.rawValue,"value": UIFont.boldSystemFont(ofSize: 12)], ToSubString: lessonType, ignoreCase: true)
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
    
    //MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBarTrailingConstraintToView?.priority = UILayoutPriority(900)
        self.searchBar.searchBarStyle = .default
        
        // The open search bar goes over the next / previous page arrows
        self.searchBar.superview?.bringSubviewToFront(self.searchBar)
        
        // A "סגור" button above the keyboard to dismiss it
        if self.searchBar.searchTextField.inputAccessoryView == nil {
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
            let closeButton = UIBarButtonItem(title: "st_close".localize(), style: .done, target: self, action: #selector(dismissSearchKeyboard))
            toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), closeButton]
            toolbar.sizeToFit()
            self.searchBar.searchTextField.inputAccessoryView = toolbar
            self.searchBar.searchTextField.reloadInputViews()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Empty search: back to the toolbar
        if (searchBar.text ?? "").isEmpty {
            searchBar.isHidden = true
        }
        self.searchBarTrailingConstraintToView?.priority = UILayoutPriority(500)
        self.searchBar.searchBarStyle = .minimal
        
        // Arrows back on top when the search bar is small again
        if let prePageButton = self.prePageButton { prePageButton.superview?.bringSubviewToFront(prePageButton) }
        if let nextPageButton = self.nextPageButton { nextPageButton.superview?.bringSubviewToFront(nextPageButton) }
    }
    
    @objc func dismissSearchKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        for cell in self.pagesCollectionView.visibleCells{
            (cell as? TalmudPageCell)?.highlightText(searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        self.searchBar(searchBar, textDidChange: "")
        self.hideSearchBar()
    }
}

// MARK: - The ביאור half next to the page (iPhone landscape)

final class TalmudBiurSideView: UIView
{
    private let pdfView = PDFView()
    private let webView = WKWebView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var process:MSBaseProcess?
    private var dataTask:URLSessionDataTask?
    private var shown:(type:TalmudDisplayType, pageIndex:Int)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        pdfView.autoScales = true
        pdfView.backgroundColor = .white
        for v in [pdfView, webView] as [UIView] {
            v.frame = bounds
            v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(v)
        }
        spinner.hidesWhenStopped = true
        spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        addSubview(spinner)
        
        let line = UIView(frame: CGRect(x: bounds.width - 1, y: 0, width: 1, height: bounds.height))
        line.backgroundColor = UIColor(HexColor: "B58B3A")
        line.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        addSubview(line)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func stop() {
        process?.cancel()
        dataTask?.cancel()
        shown = nil
    }
    
    func show(type:TalmudDisplayType, pageIndex:Int)
    {
        if let shown = shown, shown.type == type, shown.pageIndex == pageIndex { return }
        stop()
        shown = (type, pageIndex)
        spinner.startAnimating()
        bringSubviewToFront(spinner)
        
        if type == .Chavruta {
            pdfView.isHidden = false
            webView.isHidden = true
            pdfView.document = nil
            if let saved = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: .Chavruta),
               let document = PDFDocument(url: URL(fileURLWithPath: saved)) {
                pdfView.document = document
                spinner.stopAnimating()
                return
            }
            guard let url = URL(string: "http://files.daf-yomi.com/files/app/chavruta/\(pageIndex).pdf") else { return }
            dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                DispatchQueue.main.async {
                    guard let self = self, self.shown?.pageIndex == pageIndex, self.shown?.type == type else { return }
                    self.spinner.stopAnimating()
                    if let data = data { self.pdfView.document = PDFDocument(data: data) }
                }
            }
            dataTask?.resume()
            return
        }
        
        // Steinsaltz (Hebrew) / English: HTML
        pdfView.isHidden = true
        webView.isHidden = false
        webView.loadHTMLString("", baseURL: nil)
        
        let fileNamed = "\(pageIndex)_\(type.rawValue)"
        let filePath = FileManager.filePathFor(fileNamed: fileNamed, ofType: "html")
        if FileManager.default.fileExists(atPath: filePath.path),
           let savedText = try? String(contentsOf: filePath, encoding: .utf8) {
            webView.loadHTMLString(type == .Steinsaltz ? "<font size=\"25\">\(savedText)</font>" : savedText, baseURL: nil)
            spinner.stopAnimating()
            return
        }
        
        let newProcess:MSBaseProcess = (type == .EN) ? GetENPageProcess() : GetSteinsaltzPageProcess()
        process = newProcess
        newProcess.executeWithObject(pageIndex, onStart: { }, onComplete: { [weak self] object in
            guard let self = self, self.shown?.pageIndex == pageIndex, self.shown?.type == type else { return }
            self.spinner.stopAnimating()
            if let pageText = object as? String {
                self.webView.loadHTMLString("<font size=\"25\">\(pageText)</font>", baseURL: nil)
            } else if let pageURL = object as? URL {
                self.webView.load(URLRequest(url: pageURL))
            }
        }, onFaile: { [weak self] _, _ in
            self?.spinner.stopAnimating()
        })
    }
}
