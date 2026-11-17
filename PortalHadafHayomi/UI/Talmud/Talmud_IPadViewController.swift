//
//  Talmud_IPadViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 31/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class Talmud_IPadViewController: MSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TalmudPagePickerViewControllerDelegate, BTTablePopUpViewDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var pagesCollectionView:UICollectionView!
    @IBOutlet weak var showTodaysPageButton:UIButton!
    
    @IBOutlet weak var displayTranslationButton:UIButton!
    @IBOutlet weak var bookmarkButton:UIButton!
    @IBOutlet weak var selectPageButton:UIButton!
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var screenDivisionDisplayBaseView:UIView?
    @IBOutlet weak var centerScreensButton:UIButton?
    @IBOutlet weak var pushLeftScreensButton:UIButton?
    @IBOutlet weak var pushRightScreensButton:UIButton?
    
     @IBOutlet weak var displayExplantionButton:UIButton!
    
    var popover:Popover?
    
    var firstAppearance = true
    
     let explantionOptoins = ["חברותא", "שטיינזלץ", "שפה ברורה"]
    
     var secondaryPageDisplayType:TalmudDisplayType?
    
    var selectedMaschet:Masechet?
    var selectedPage:Page?
    
    var talmudPagePickerViewController:TalmudPagePickerViewController!{
        didSet{
             self.perform( #selector(setTalmudPagePickerViewControllerDelegate), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func setTalmudPagePickerViewControllerDelegate()
    {
        self.talmudPagePickerViewController.delegate = self
    }
    
    var talmudNumberOfPages:Int
    {
        get{
            return HadafHayomiManager.sharedManager.talmudNumberOfPages
        }
    }
    
    // Pages run right to left, like a book: the first amud is the LAST row (far right), so the
    // next amud is on the left. The collection view stays left to right; only the order is reversed.
    func row(forPageIndex pageIndex:Int) -> Int { return self.talmudNumberOfPages - pageIndex }
    func pageIndex(forRow row:Int) -> Int { return self.talmudNumberOfPages - row }
    
    // MARK: - Previous / next page arrows, on the left side of the title
    
    lazy var prevPageArrowButton:UIButton = self.makePageArrowButton("chevron.right", label: "העמוד הקודם", action: #selector(prevPageArrowTapped))
    lazy var nextPageArrowButton:UIButton = self.makePageArrowButton("chevron.left", label: "העמוד הבא", action: #selector(nextPageArrowTapped))
    
    private func makePageArrowButton(_ systemName:String, label:String, action:Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        button.tintColor = UIColor(HexColor: "781F24")
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(HexColor: "781F24").cgColor
        button.layer.cornerRadius = 3
        button.accessibilityLabel = label
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func addPageArrows()
    {
        guard let title = self.topBarTitleLabel, let bar = title.superview else { return }
        bar.addSubview(self.prevPageArrowButton)
        bar.addSubview(self.nextPageArrowButton)
        NSLayoutConstraint.activate([
            // right to left: title · › previous · ‹ next
            self.prevPageArrowButton.rightAnchor.constraint(equalTo: title.leftAnchor, constant: -16),
            self.prevPageArrowButton.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -15),
            self.prevPageArrowButton.widthAnchor.constraint(equalToConstant: 33),
            self.prevPageArrowButton.heightAnchor.constraint(equalToConstant: 33),
            self.nextPageArrowButton.rightAnchor.constraint(equalTo: self.prevPageArrowButton.leftAnchor, constant: -8),
            self.nextPageArrowButton.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -15),
            self.nextPageArrowButton.widthAnchor.constraint(equalToConstant: 33),
            self.nextPageArrowButton.heightAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    @objc func prevPageArrowTapped() { self.movePage(by: -1) }
    @objc func nextPageArrowTapped() { self.movePage(by: 1) }
    
    /// One amud back / forward (rows are the amudim of the whole Talmud in order)
    private func movePage(by step:Int)
    {
        guard let collectionView = self.pagesCollectionView else { return }
        // next amud = one row to the left (rows are in reverse order)
        let row = collectionView.centerRowIndex() - step
        guard row >= 0, row < collectionView.numberOfItems(inSection: 0) else { return }
        collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    /// The arrows scroll with an animation: update the title and the picker when it ends
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView === self.pagesCollectionView {
            self.updateDisplay(shouldUpdateTalmudPagePicker: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addPageArrows()
        
        showTodaysPageButton.layer.borderWidth = 1.0
        showTodaysPageButton.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        showTodaysPageButton.layer.cornerRadius = 3.0
    
        self.screenDivisionDisplayBaseView?.isHidden = true
        
        showTodaysPageButton.setTitle("st_todays_page".localize(), for: .normal)
        
        self.searchBar.isHidden = true
      
        self.searchBarTopConstraint.constant = -1*(self.searchBar.frame.size.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.firstAppearance == true
        {
            self.firstAppearance = false
            
            if AppLayout.restorePageAfterSwitch {
                AppLayout.restorePageAfterSwitch = false
                self.perform( #selector(self.scrollToSavedPage), with: nil, afterDelay: 0.4)
            } else {
                self.perform( #selector(self.scrollToTodaysPage), with: nil, afterDelay: 0.4)
            }
        }
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectLessonNotification(notification:)), name: Notification.Name("didSelectLessonNotification"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didSelectLessonNotification(notification: Notification){
        
        if let lesson = notification.userInfo?["lesson"] as? Lesson
            ,let maschet = lesson.masechet
            ,let page = lesson.page
            ,page.index != (self.selectedPage?.index ?? -1)
            ,maschet.id != (self.selectedMaschet?.id ?? ""){
            
            BTAlertView.show(title: "".localize(), message: "st_should_move_to_selected_lesson_page".localize(), buttonKeys: ["st_yes".localize(),"st_no".localize()]) { dismissButtonKey in
                if dismissButtonKey == "st_yes".localize() {
                    self.scrollToMaschet(maschet, page:page, pageSide:0, animated:false)
                }
            }
        }
    }
    
    @IBAction func showTodaysPageButtonClicked(_ sender:UIButton)
    {
        self.scrollToTodaysPage()
    }
    
    @IBAction func searchButtonClicked(_ sender:UIButton){
        self.searchBarTopConstraint.constant = self.searchBarTopConstraint.constant == 0 ? -1*(self.searchBar.frame.size.height) : 0
    }
    
    @IBAction func bookmarkButtonButtonClicked(_ sender:UIButton){
        self.bookmarkButton.isSelected = !self.bookmarkButton.isSelected
        
        for cell in self.pagesCollectionView.visibleCells {
            (cell as? TalmudDoublePageCell)?.bookmarkView.isHidden = !(self.bookmarkButton.isSelected)
            UserDefaults.standard.setValue(self.bookmarkButton.isSelected, forKey:"displayDafBookMark")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// The page picker opened from selectPageButton (portrait – the side menu with the picker is hidden)
    private weak var pagePickerPopover:TalmudPagePickerViewController?
    
    /// Opens the daf picker (with "לדף היומי" on top) in a popover, on the daf shown now
    @IBAction func selectPageButtonClicked(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
        guard let picker = storyboard.instantiateViewController(withIdentifier: "TalmudPagePickerViewController") as? TalmudPagePickerViewController else { return }
        picker.delegate = self
        if let masechet = self.selectedMaschet, let page = self.selectedPage {
            picker.initialPage = (masechet, page, 0)
        }
        picker.modalPresentationStyle = .popover
        picker.preferredContentSize = CGSize(width: 380, height: min(680, self.view.bounds.height - 160))
        if let popover = picker.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = [.up, .down]
            popover.delegate = self
        }
        self.pagePickerPopover = picker
        self.present(picker, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none   // stay a popover
    }
    
    /// selectPageButton only in portrait (in landscape the side menu has the picker)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let screen = self.view.window?.bounds.size ?? UIScreen.main.bounds.size
        let isPortrait = screen.height > screen.width
        self.selectPageButton?.isHidden = !isPortrait
        if !isPortrait, let popover = self.pagePickerPopover, popover.presentingViewController != nil {
            popover.dismiss(animated: false, completion: nil)
        }
    }
    
    
    @IBAction func displayTranslationButtonClicked(_ sender:UIButton)
    {
        self.displayExplantionButton.isSelected = false
        
        self.displayTranslationButton.isSelected = !self.displayTranslationButton.isSelected
        
        if self.displayTranslationButton.isSelected
        {
            self.secondaryPageDisplayType = .EN
        }
        else{
            self.secondaryPageDisplayType = nil
        }

        self.setDoublePageDisplay()
    }
    
    @IBAction func displayExplantionButtonClicked(_ sender:UIButton)
    {
        self.showExplantionsOptions()
    }
    
    func showExplantionsOptions()
    {
        self.resignFirstResponder()
        
        let tablePopUpView = UIView.loadFromNibNamed("BTTablePopUpView") as! BTTablePopUpView
       tablePopUpView.delegate = self
        
        tablePopUpView.identifier = "regions"
        
        let popupTitle = "st_select_explanation".localize()
        
        var tableOptions = [String]()
        tableOptions.append(contentsOf: self.explantionOptoins)
        
        if self.displayExplantionButton.isSelected
        {
            tableOptions.append("st_hide_explanation".localize())
        }
        
        var selectedOption:String? = nil
        if  self.secondaryPageDisplayType == .Steinsaltz
        {
            selectedOption = "שטיינזלץ"
        }
        if  self.secondaryPageDisplayType == .Chavruta
        {
            selectedOption = "חברותא"
        }
        if  self.secondaryPageDisplayType == .SafaBrura
        {
            selectedOption = "שפה ברורה"
        }
        tablePopUpView.reloadWithOptions(tableOptions, title:popupTitle, selectedOption: selectedOption)
        
        let arrowHight = CGFloat(15)
        let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: arrowHight))
         arrow.image = UIImage.imageWithTintColor(UIImage(named: "Triangle.png")!, color: UIColor(HexColor: "791F23"))
        
        let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: tablePopUpView.frame.size.height + arrowHight))
        popUpView.addSubview(arrow)
        popUpView.layer.cornerRadius = 3.0
        arrow.center = CGPoint(x: popUpView.frame.size.width/2, y:  arrow.center.y)
        tablePopUpView.layer.borderColor = UIColor(HexColor:"791F23").cgColor
        
        tablePopUpView.layer.borderWidth = 2.0
        tablePopUpView.layer.cornerRadius = 3.0
        tablePopUpView.frame.origin.y = arrowHight
        tablePopUpView.frame.size.width = popUpView.frame.size.width
        popUpView.addSubview(tablePopUpView)
        let options = [
            .type(.down)
            ] as [PopoverOption]
        
        self.popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover?.show(popUpView, fromView: displayExplantionButton, inView: self.view)

    }
    
    func setDoublePageDisplay()
    {
        self.centerScreensButton?.isSelected = false
        self.pushLeftScreensButton?.isSelected = false
        self.pushRightScreensButton?.isSelected = false
        
        if  self.displayTranslationButton.isSelected || self.displayExplantionButton.isSelected
        {
            self.screenDivisionDisplayBaseView?.isHidden = false
            self.centerScreensButton?.isSelected = true
        }
        else
        {
            self.screenDivisionDisplayBaseView?.isHidden = true
        }
        
        self.pagesCollectionView.reloadData()
    }
    
    @IBAction func setLayoutButtonClicked(_ sender:UIButton)
    {
        self.centerScreensButton?.isSelected = false
        self.pushLeftScreensButton?.isSelected = false
        self.pushRightScreensButton?.isSelected = false
        
        sender.isSelected = true
        
        self.pagesCollectionView.reloadData()
    }
    
    @objc func scrollToTodaysPage()
    {
        let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet!
        let todaysPage = HadafHayomiManager.sharedManager.todaysPage!
        
        self.scrollToMaschet(todaysMaschet, page: todaysPage, pageSide:0,  animated: false)
    }
    
    /// Opens the page that was open before the fold / unfold switch
    @objc func scrollToSavedPage()
    {
        guard let info = UserDefaults.standard.object(forKey: "selectedPageInfo") as? [String:Any]
            , let maschetId = info["maschetId"] as? String
            , let pageIndex = info["pageIndex"] as? Int
            , let pageSide = info["pageSide"] as? Int
            , let masechet = HadafHayomiManager.sharedManager.getMasechetById(maschetId)
        else {
            self.scrollToTodaysPage()
            return
        }
        let page = Page(index: pageIndex)
        self.scrollToMaschet(masechet, page: page, pageSide: pageSide, animated: false)
        self.talmudPagePickerViewController?.talmudPagePickerView.scrollToMasechet(masechet, page: page, pageSide: pageSide, animated: false)
    }
    
    func scrollToMaschet(_ maschet:Masechet, page:Page, pageSide:Int, animated:Bool)
    {
        if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(maschet, page: page, pageSide: pageSide)
        {
            //Reduce by 1 becuse the collectoin view index starts from 0
            
            self.selectedMaschet = maschet
            self.selectedPage = page
            
            var selectedPageInfo = [String:Any]()
            selectedPageInfo["maschetId"] = maschet.id
            selectedPageInfo["pageIndex"] = page.index
            selectedPageInfo["pageSide"] = pageSide
            
            UserDefaults.standard.set(selectedPageInfo, forKey: "selectedPageInfo")
            UserDefaults.standard.synchronize()
            
            let indexPath = IndexPath(row: self.row(forPageIndex: pageIndex), section: 0)
            
            if self.pagesCollectionView != nil {
                self.pagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            }
        }
        
        self.topBarTitleLabel?.text = HadafHayomiManager.dispalyTitleForMaschet(maschet, page: page, pageSide: pageSide)
    }
    
    
    
    //MARK: - CollectionView Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.talmudNumberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalmudDoublePageCell", for: indexPath) as! TalmudDoublePageCell
        
        
        if self.pushLeftScreensButton?.isSelected ?? false
        {
            cell.displayLayout(layout:"secondaryPage")
        }
        else if self.pushRightScreensButton?.isSelected ?? false
        {
            cell.displayLayout(layout:"mainPage")
        }
        else if self.centerScreensButton?.isSelected ?? false
        {
            cell.displayLayout(layout:"centerPages")
        }
        else{
            cell.displayLayout(layout:"mainPage")
        }
        
        if self.secondaryPageDisplayType != nil
        {
            cell.secondaryPageDisplayType = self.secondaryPageDisplayType!

        }
        
        cell.reloadWithObject(self.pageIndex(forRow: indexPath.row))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return collectionView.bounds.size
    }
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging == false
        && scrollView.isDecelerating == false
        {
           self.updateDisplay(shouldUpdateTalmudPagePicker:false)
        }
    }
 */
    
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
        
        self.updateDisplay(shouldUpdateTalmudPagePicker:true)
     
    }
    
    func updateDisplay(shouldUpdateTalmudPagePicker:Bool)
    {
        let centerRow = self.pagesCollectionView.centerRowIndex()
        if centerRow < 0 { return }
        
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(self.pageIndex(forRow: centerRow))
        
        let maschet = pageInfo["maschet"] as! Masechet
        let page = pageInfo["page"] as! Page
        let pageSide =  pageInfo["pageSide"] as! Int
        
        self.topBarTitleLabel?.text = HadafHayomiManager.dispalyTitleForMaschet(maschet, page: page, pageSide: pageSide )
        
        // Remember the page, so folding the phone opens the same page in the iPhone layout
        var selectedPageInfo = [String:Any]()
        selectedPageInfo["maschetId"] = maschet.id
        selectedPageInfo["pageIndex"] = page.index
        selectedPageInfo["pageSide"] = pageSide
        UserDefaults.standard.set(selectedPageInfo, forKey: "selectedPageInfo")
        
        if shouldUpdateTalmudPagePicker && self.talmudPagePickerViewController != nil
        {
            self.talmudPagePickerViewController.delegate = nil
            self.talmudPagePickerViewController.talmudPagePickerView.scrollToMasechet(maschet, page: page, pageSide:pageSide, animated: false)
             self.talmudPagePickerViewController.delegate = self
        }
    }
    
    //MARK: TalmudPagePickerViewController Delegate methods
        func talmudPagePickerViewControllerDidChange(_ talmudPagePickerViewController:TalmudPagePickerViewController, component:Int)
    {
        if let masechet = talmudPagePickerViewController.selectedMasechet
            , let page =  talmudPagePickerViewController.selectedPage
            , let pageSide = talmudPagePickerViewController.selectedPageSide
        {
           self.scrollToMaschet(masechet, page: page, pageSide: pageSide, animated: true)
        }
        // chosen in the popover: close it
        if talmudPagePickerViewController === self.pagePickerPopover {
            talmudPagePickerViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: BTTablePopUpView delegate methods
    func tablePopUpView(_ tablePopUpView:BTTablePopUpView, didSelectOption option:String!)
    {
        self.displayTranslationButton.isSelected = false
        if option == "חברותא"
        {
            self.displayExplantionButton.isSelected = true
            self.secondaryPageDisplayType = .Chavruta
        }
        else if option == "שפה ברורה"
        {
            self.displayExplantionButton.isSelected = true
            self.secondaryPageDisplayType = .SafaBrura
        }
        else if option == "שטיינזלץ"
        {
             self.displayExplantionButton.isSelected = true
             self.secondaryPageDisplayType = .Steinsaltz
        }
        else if option == "st_hide_explanation".localize()
        {
             self.displayExplantionButton.isSelected = false
            
            self.secondaryPageDisplayType = nil
        }
        
        self.popover?.dismiss()
        
         self.setDoublePageDisplay()
    }
}
