//
//  Talmud_IPadViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 31/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class Talmud_IPadViewController: MSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TalmudPagePickerViewControllerDelegate, BTTablePopUpViewDelegate
{
    @IBOutlet weak var pagesCollectionView:UICollectionView!
    @IBOutlet weak var showTodaysPageButton:UIButton!
    
    @IBOutlet weak var displayTranslationButton:UIButton!
    @IBOutlet weak var searchButton:UIButton!
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var screenDivisionDisplayBaseView:UIView?
    @IBOutlet weak var centerScreensButton:UIButton?
    @IBOutlet weak var pushLeftScreensButton:UIButton?
    @IBOutlet weak var pushRightScreensButton:UIButton?
    
     @IBOutlet weak var displayExplantionButton:UIButton!
    
    var popover:Popover?
    
    var firstAppearance = true
    
     let explantionOptoins = ["חברותא", "שטיינזלץ"]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTodaysPageButton.layer.borderWidth = 1.0
        showTodaysPageButton.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        showTodaysPageButton.layer.cornerRadius = 3.0
    
        self.screenDivisionDisplayBaseView?.isHidden = true
        
        showTodaysPageButton.setTitle("st_todays_page".localize(), for: .normal)
        
        self.searchBar.isHidden = true
        self.searchButton.layer.borderWidth = 1.0
        self.searchButton.layer.cornerRadius = 3
        self.searchButton.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        
        self.searchBarTopConstraint.constant = -1*(self.searchBar.frame.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.firstAppearance == true
        {
            self.firstAppearance = false
            
             self.perform( #selector(self.scrollToTodaysPage), with: nil, afterDelay: 0.4)
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
            
            let indexPath = IndexPath(row:pageIndex-1, section: 0)
            
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
        
        cell.reloadWithObject(indexPath.row + 1)
        
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
        let pageIndex = self.pagesCollectionView.centerRowIndex()
        
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex + 1)
        
        let maschet = pageInfo["maschet"] as! Masechet
        let page = pageInfo["page"] as! Page
        let pageSide =  pageInfo["pageSide"] as! Int
        
        self.topBarTitleLabel?.text = HadafHayomiManager.dispalyTitleForMaschet(maschet, page: page, pageSide: pageSide )
        
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
