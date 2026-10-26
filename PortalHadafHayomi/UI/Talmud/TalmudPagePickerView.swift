//
//  TalmudPagePickerView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 21/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol TalmudPagePickerViewDelegate: class
{
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didChangeComponent component:Int)
    
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didHide:Bool)
    
    /// The user tapped a page in the list (the selection is already set)
    @objc optional func talmudPagePickerViewDidSelectPage(_ talmudPagePickerView:TalmudPagePickerView)
    /// "לדף היומי" was tapped at the top of the list
    @objc optional func talmudPagePickerViewDidSelectTodaysPage(_ talmudPagePickerView:TalmudPagePickerView)
}


class TalmudPagePickerView:UIView, UIPickerViewDelegate,UIPickerViewDataSource
{
    var dispalyedMasechtot:[Masechet]?
    {
        didSet{
            // The picker wheel stays hidden: the page list is shown instead (it still holds the selection)
            self.pagesPickerView.isHidden = true
            // The floating save button is replaced by the icon on the side of each amud
            self.saveOrRemovePageButton?.isHidden = true
            if dispalyedMasechtot?.count == 0
            {
                self.pageListView.isHidden = true
                self.noPagesLabel?.isHidden = false
            }
            else{
                self.pageListView.isHidden = false
                self.noPagesLabel?.isHidden = true
            }
            self.pageListView.masechtot = dispalyedMasechtot ?? []
        }
    }
    var displayedPages:[Page]?
    var displayedPageSides:[Int]?
    
    var displayType:TalmudDisplayType = .Vagshal {
        didSet {
            self.titleLabel?.text = "st_display_Type_\(displayType.rawValue)".localize()
            self.updatePagePickerLayout()
            self.pageListView.reload()
        }
    }
    
    var shouldHighlightSavedPages = false
    
    weak var delegate:TalmudPagePickerViewDelegate?
    
    @IBOutlet weak var pagePickerContentView:UIView?
    var pagesPickerView:UIPickerView!//TablePickerView!
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var toggleButton:UIButton?
    @IBOutlet weak var toggleButtonTopConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var saveOrRemovePageButton:UIButton?
    
    @IBOutlet weak var showAllPagesButton:UIButton?
    @IBOutlet weak var showSavedPagesButton:UIButton?
    
    @IBOutlet weak var noPagesLabel:UILabel?
    
    var savePagesInProgress = [Int:Float]()//The page index and the progress amount
    
    var highlightSavedPages = false{
        didSet{
            self.pagesPickerView.reloadAllComponents()
            self.pageListView.reload()
        }
    }
    
    /// The new page list (masechtot -> daf cards). Replaces the picker wheel on screen.
    lazy var pageListView: TalmudPageListView = {
        let listView = TalmudPageListView()
        
        listView.dafimProvider = { [weak self] masechet in
            guard let self = self else { return [] }
            if self.showSavedPagesButton?.isSelected ?? false {
                return masechet.savedPages(forDisplayType: self.displayType).map {
                    TalmudListDaf(page: $0, sides: masechet.getSavedPageSidesForPage($0, displayType: self.displayType))
                }
            }
            return masechet.pages.map { page in
                TalmudListDaf(page: page, sides: [0, 1].filter {
                    HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: $0) != nil
                })
            }
        }
        
        listView.saveState = { [weak self] masechet, page, side in
            guard let self = self, self.displayType.supportsOfflineSave,
                  let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: side) else { return .unavailable }
            if self.isDownloadingPage(pageIndex: pageIndex) { return .downloading }
            if HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: self.displayType) != nil { return .saved }
            return .notSaved
        }
        
        listView.onDownload = { [weak self] masechet, page, side in
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: side) {
                self?.savePage(pageIndex: pageIndex)
            }
        }
        
        listView.onDelete = { [weak self] masechet, page, side in
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: side) {
                self?.deletePage(pageIndex: pageIndex)
            }
        }
        
        listView.onTodaysPage = { [weak self] in
            guard let self = self else { return }
            self.delegate?.talmudPagePickerViewDidSelectTodaysPage?(self)
        }
        
        listView.onSelect = { [weak self] masechet, page, side in
            guard let self = self else { return }
            self.selectInPicker(masechet, page: page, side: side)
            // Screens that react to every change (e.g. the iPad screen) get the usual callback
            self.delegate?.talmudPagePickerView(self, didChangeComponent: 0)
            self.delegate?.talmudPagePickerViewDidSelectPage?(self)
        }
        return listView
    }()
        
    lazy var progressCircleView:BTProgressCircleView? = {
        
        if saveOrRemovePageButton != nil
        {
            var  progressCircleView =  BTProgressCircleView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
            progressCircleView.center = self.saveOrRemovePageButton!.center
            
            return progressCircleView
        }
        return nil
        
    }()
    
    var isDisplyed:Bool = false
    
    var selectedMasechet:Masechet?
    {
        didSet{
            
           if self.showSavedPagesButton?.isSelected ?? false
            {
                self.displayedPages = selectedMasechet?.savedPages(forDisplayType: self.displayType)
                
                self.pagesPickerView.reloadComponent(1)//pages

                if let selectedPage = self.selectedPage
                {
                    self.displayedPageSides = selectedMasechet?.getSavedPageSidesForPage(selectedPage, displayType: self.displayType)
                }
            }
            else 
            {
                self.displayedPages = selectedMasechet?.pages
                self.pagesPickerView.reloadComponent(1)//pages
                
                self.displayedPageSides = [0,1]
            }
            self.pagesPickerView.reloadComponent(0)//page sides

        }
    }
    
    var selectedPage:Page?{
        get{
            let selectedPageIndex = self.pagesPickerView.selectedRow(inComponent: 1)
            
            if selectedPageIndex < (self.displayedPages?.count ?? 0) {
                 return self.displayedPages?[selectedPageIndex]
            }
            else{
                return self.displayedPages?.last
            }
          
        }
    }
    var selectedPageSide:Int?{
        get{
            let selectedRow = self.pagesPickerView.selectedRow(inComponent: 0)
            
            if let displayedPageSides = self.displayedPageSides
            ,displayedPageSides.count > selectedRow
            {
                return self.displayedPageSides?[selectedRow]
            }
            else{
                return nil
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
    }
    
    func setupUI(){
        
        self.addPicker()
        
        self.noPagesLabel?.text = "st_no_saved_pages_message_label".localize()
        
        self.showAllPagesButton?.setTitle("st_show_all_pages".localize(), for: .normal)
          self.showSavedPagesButton?.setTitle("st_show_saved_pages".localize(), for: .normal)
        
        self.titleLabel?.font = UIFont(name:"BroshMF", size: 20)!
        self.titleLabel?.textColor = UIColor(HexColor: "781F24")
        
        self.titleLabel?.text = "st_display_Type_\(displayType.rawValue)".localize()

    }
    
    func reloadData() {
        self.pagesPickerView.reloadAllComponents()
    }
    
    func addPicker()
    {
        self.pagesPickerView = UIPickerView()
        let view = pagesPickerView.view
        pagesPickerView.delegate = self
        pagesPickerView.dataSource = self
        
        //If view xib has contentView add the picker to the contentview, if not add the picker to the main view
        let contentView = self.pagePickerContentView ?? self
        
        self.pagesPickerView.frame = contentView.bounds
        contentView.addSubview(pagesPickerView)
        
        pagesPickerView.addSidedConstraints()
        self.sendSubviewToBack(pagesPickerView)
        
        // The new page list, in the same place as the picker
        self.pageListView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.pageListView)
        NSLayoutConstraint.activate([
            self.pageListView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.pageListView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.pageListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.pageListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        if let saveButton = self.saveOrRemovePageButton {
            saveButton.superview?.bringSubviewToFront(saveButton)
        }
        
        self.showAllPages()
        
        self.pagesPickerView.semanticContentAttribute = .forceLeftToRight

    }
    
    @IBAction func toggleButtonClicked(_ sender:UIButton)
    {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.isDisplyed ? self.hide() : self.show()
                self.layoutIfNeeded()
                
        }, completion: {_ in
            
        })
        
    }
    
    @IBAction func showAllPagesButtonClicked(_ sender:UIButton)
    {
        self.showAllPages()
    }
    
    func showAllPages()
    {
        self.showAllPagesButton?.isSelected = true
        self.showAllPagesButton?.alpha = 1.0
        
         self.showSavedPagesButton?.isSelected = false
        self.showSavedPagesButton?.alpha = 0.5
        
        self.dispalyedMasechtot = HadafHayomiManager.sharedManager.masechtot
        self.pagesPickerView.reloadComponent(2)//Masechtot
        
        if let selectedMasechet = self.selectedMasechet
        ,let indexOfSelectedMasechet = dispalyedMasechtot?.index(of: selectedMasechet)
        {
            self.pagesPickerView.selectRow(indexOfSelectedMasechet, inComponent: 2, animated: false)
        }
        
        self.selectedMasechet = self.dispalyedMasechtot?[self.pagesPickerView.selectedRow(inComponent: 2)]
        
        self.pagesPickerView.reloadComponent(1)//pages
        self.pagesPickerView.selectRow(0, inComponent: 1, animated: false)
        
         self.displayedPageSides = [0,1]
        self.pagesPickerView.reloadComponent(0)//pageSide
        
        self.updatePagePickerLayout()
    }
    
    @IBAction func showSavedPagesClicked(_ sender:UIButton)
    {
        self.showSavedPages()
    }
    
    func showSavedPages()
    {
        self.showAllPagesButton?.isSelected = false
        self.showAllPagesButton?.alpha = 0.5
        
        self.showSavedPagesButton?.isSelected = true
        self.showSavedPagesButton?.alpha = 1.0
        
        self.dispalyedMasechtot = HadafHayomiManager.sharedManager.getMessechtotWithSavedPages(forDisplayType: self.displayType)
        self.pagesPickerView.reloadComponent(2)//Masechtot
        
        if let indexOfSelectedMasechet = dispalyedMasechtot?.index(of: self.selectedMasechet!)
        {
            self.pagesPickerView.selectRow(indexOfSelectedMasechet, inComponent: 2, animated: false)
        }
       
        if let masechtot = self.dispalyedMasechtot, !masechtot.isEmpty
        {
            let selectedRow = self.pagesPickerView.selectedRow(inComponent: 2)
            if selectedRow < masechtot.count {
                self.selectedMasechet = masechtot[selectedRow]
            } else {
                self.selectedMasechet = masechtot[0]
                self.pagesPickerView.selectRow(0, inComponent: 2, animated: false)
            }
        }
        
        self.pagesPickerView.reloadComponent(1)//pages
        
        if let selectedPage = self.selectedPage
        {
            self.displayedPageSides = selectedMasechet?.getSavedPageSidesForPage(selectedPage, displayType: self.displayType)
        }
        self.pagesPickerView.reloadComponent(0)//pageSide
        
         self.updatePagePickerLayout()
    }
    
    func show()
    {
        self.isDisplyed = true
        self.frame.origin.y += self.pagesPickerView.frame.size.height
        self.toggleButton?.setImage(UIImage(named: "V_1ArowUp.png"), for: .normal)
        toggleButtonTopConstraint?.constant = -22.5
    }
    
    func hide()
    {
        self.isDisplyed = false
        self.frame.origin.y -= self.pagesPickerView.frame.size.height
        self.toggleButton?.setImage(UIImage(named: "V_1ArowDown.png"), for: .normal)
        toggleButtonTopConstraint?.constant = 0
        
        self.delegate?.talmudPagePickerView(self, didHide: true)
    }
    
    func scrollToMasechet(_ masechet:Masechet, page:Page, pageSide:Int, animated:Bool)
    {
        if pagesPickerView == nil
        {
            return
        }
        
        if let mascehtIndex = dispalyedMasechtot?.index(of: masechet)
        {
            //Scroll to Masceht
            self.selectedMasechet = masechet
            self.pagesPickerView.selectRow(mascehtIndex, inComponent: 2, animated: animated)
        }
        
        //Reload pages
        self.pagesPickerView.reloadComponent(1)
        
        //Scroll to page
        self.pagesPickerView.selectRow(page.index-1, inComponent: 1, animated: animated)
        
        //Reload page side
        self.pagesPickerView.reloadComponent(0)
        
        //Scroll to page side
        var row = pageSide-1
        if row < 0{
            row = 0
        }
        self.pagesPickerView.selectRow(row, inComponent: 0, animated: animated)
        
        // Open the masechet in the list and show the current page
        self.pageListView.showCurrent(masechet: masechet, page: page, side: row)
    }
    
    /// Puts the picker (which holds selectedMasechet / selectedPage / selectedPageSide) on the tapped page.
    func selectInPicker(_ masechet:Masechet, page:Page, side:Int)
    {
        if let masechetIndex = dispalyedMasechtot?.firstIndex(where: { $0 === masechet })
        {
            self.selectedMasechet = masechet
            self.pagesPickerView.selectRow(masechetIndex, inComponent: 2, animated: false)
        }
        
        if let pageRow = self.displayedPages?.firstIndex(where: { $0.index == page.index })
        {
            self.pagesPickerView.selectRow(pageRow, inComponent: 1, animated: false)
        }
        
        if self.showSavedPagesButton?.isSelected ?? false
        {
            self.displayedPageSides = masechet.getSavedPageSidesForPage(page, displayType: self.displayType)
        }
        else
        {
            self.displayedPageSides = [0,1]
        }
        self.pagesPickerView.reloadComponent(0)
        self.pagesPickerView.selectRow(self.displayedPageSides?.firstIndex(of: side) ?? 0, inComponent: 0, animated: false)
        
        self.updatePagePickerLayout()
    }
    
    //MARK: UIPickerViewDelegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        switch component {
        case 0: //Page side
            /*
             //If last page selected
             if self.selectedPage?.index == self.displayedPages?.count ?? 0
             {
             if self.selectedMasechet?.lastPageSide == "א"
             {
             return 1
             }
             }
             return 2
             */
            return self.displayedPageSides?.count ?? 0
        case 1: //number of Pages for selected Maschet
            return self.displayedPages?.count ?? 0
        case 2: //maschetot
            return dispalyedMasechtot?.count ?? 0
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        
        switch component {
        case 0: //Page side
            return  150
        case 1: //Page
            return self.pagesPickerView.frame.size.width * 0.55 - 150
        case 2: //Masechet
            return self.pagesPickerView.frame.size.width * 0.45
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let componentWidth = self.pickerView(pickerView, widthForComponent: component)
        
        var reusableView:UIView!
        var textLabel:UILabel!
        
        if view != nil
        {
            print ("reusable")
            reusableView = view
            textLabel = reusableView.viewWithTag(333) as? UILabel
            
        }
        else{
            
            reusableView = UIView(frame: CGRect(x: 0, y: 0, width: componentWidth, height: 44))
            reusableView.backgroundColor = UIColor(HexColor: "F9F3DB")
            
            textLabel = UILabel(frame: reusableView.bounds)
            textLabel.font = UIFont(name:"BroshMF", size: 20)!
            textLabel.textColor = UIColor(HexColor: "781F24")
            textLabel.backgroundColor = UIColor.clear
            textLabel.textAlignment = .center
            textLabel.adjustsFontSizeToFitWidth = true;
            
            textLabel.tag = 333
            reusableView.addSubview(textLabel)
        }
        
        
        
        /*
         var reusableView:PickerRawDefaultview!
         
         if  view is PickerRawDefaultview
         {
         reusableView = view as! PickerRawDefaultview
         }
         else{
         reusableView = UIView.viewWithNib("PickerRawDefaultview", bundle: nil) as! PickerRawDefaultview
         }
         */
        
        reusableView.frame.size.width = self.pickerView(pickerView, widthForComponent: component)
        
        switch component {
        case 0: //Page side
            textLabel.textAlignment = .right
            textLabel.frame.size.width = componentWidth - 8
            
            if let pageSideId = self.displayedPageSides?[row]
            {
                if pageSideId == 0{
                    textLabel.text = "א"
                }
                else if pageSideId == 1 {
                    textLabel.text = "ב"
                }
            }
            
            if let masechet = self.selectedMasechet
                ,let page = self.selectedPage
                ,let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet,
                                                                              page: page,
                                                                              pageSide: row)
            {
                if let _ = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: self.displayType)
                {
                    textLabel.textColor = UIColor.blue
                }
            }
            
            break
            
        case 1: //Page
            textLabel.textAlignment = .right
            textLabel.frame.size.width = componentWidth - 8
            
            if let page = self.displayedPages?[row]
            {
                textLabel.text = page.symbol
                
                var pageSaved = false
                if self.shouldHighlightSavedPages, let masechet = self.selectedMasechet {
                    for side in 0...1 {
                        if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: side),
                           let _ = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: self.displayType) {
                            pageSaved = true
                            break
                        }
                    }
                }
                textLabel.textColor = pageSaved ? UIColor.blue : UIColor(HexColor: "781F24")
            }
            
        case 2: //Masechetֿ
            textLabel.textAlignment = .center
            
            if let maschet = self.dispalyedMasechtot?[row]
            {
                textLabel.text = maschet.name
                
                var masechetSaved = false
                if self.shouldHighlightSavedPages {
                    for page in maschet.pages {
                        for side in 0...1 {
                            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(maschet, page: page, pageSide: side),
                               let _ = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: self.displayType) {
                                masechetSaved = true
                                break
                            }
                        }
                        if masechetSaved { break }
                    }
                }
                textLabel.textColor = masechetSaved ? UIColor.blue : UIColor(HexColor: "781F24")
            }
            
            break
        default:
            break
        }
        
        return reusableView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: //Page side
            break
        case 1: //Page
            
            if self.showSavedPagesButton?.isSelected ?? false
            ,let selectedPage = self.selectedPage
            {
                self.displayedPageSides = selectedMasechet?.getSavedPageSidesForPage(selectedPage, displayType: self.displayType)
            }
            self.pagesPickerView.reloadComponent(0)//page side
            
            break
        case 2: //Masechet
            self.selectedMasechet = self.dispalyedMasechtot?[row]
            
            var selectedPageIndex = self.selectedPage?.index ?? 0
            if selectedPageIndex >= self.selectedMasechet?.pages.count ?? 0
            {
                selectedPageIndex = (self.selectedMasechet?.pages.count ?? 1) - 1
            }
            self.pagesPickerView.selectRow(selectedPageIndex, inComponent: 1, animated: false)

            break
            
        default:
            break
        }
        
        self.updatePagePickerLayout()
        
        self.delegate?.talmudPagePickerView(self, didChangeComponent: component)
    }
    
    func updatePagePickerLayout()
    {
        if let masechet = self.selectedMasechet
            ,let page = self.selectedPage
            ,let pageSide = self.selectedPageSide
            ,let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet,
                                                                          page: page,
                                                                          pageSide: pageSide)
            {
            
            if self.isDownloadingPage(pageIndex:pageIndex)
            {
                self.saveOrRemovePageButton?.isHidden = true
                
                self.progressCircleView?.isHidden = false
                
                if let downloadProgressPercentage = self.savePagesInProgress[pageIndex]
                {
                    self.progressCircleView?.updatePrecnetage(precentage: downloadProgressPercentage)
                }
            }
            else{
                
                // Show save/delete button only for display types that support offline saving
                self.saveOrRemovePageButton?.isHidden = !displayType.supportsOfflineSave
                self.progressCircleView?.isHidden = true
                
                if displayType.supportsOfflineSave {
                    //Check if page is saved in documents for current display type
                    if let _ = HadafHayomiManager.sharedManager.savedPageFilePath(pageIndex: pageIndex, type: displayType)
                    {
                        setDeleteButton()
                    }
                    else //page is not saved
                    {
                        self.setSaveButton()
                    }
                }
            }
        }
    }
    
    func setSaveButton()
    {
        // The floating button is no longer shown (see the icons in the page list)
        self.saveOrRemovePageButton?.isHidden = true
        self.progressCircleView?.isHidden = true
        self.saveOrRemovePageButton?.setImage(UIImage(named: "downloadIcon"), for: .normal)
        self.saveOrRemovePageButton?.setImage(UIImage(named: "downloadIcon"), for: .highlighted)
        
        self.saveOrRemovePageButton?.removeTarget(nil, action: nil, for: .allEvents)
        self.saveOrRemovePageButton?.addTarget(self, action:  #selector(saveButtonClicked(_:)), for: .touchUpInside)
    }
    
    func setDeleteButton()
    {
        self.saveOrRemovePageButton?.isHidden = true
        self.progressCircleView?.isHidden = true
        self.saveOrRemovePageButton?.setImage(UIImage(named: "delete"), for: .normal)
        self.saveOrRemovePageButton?.setImage(UIImage(named: "delete_highlighted"), for: .highlighted)
        
        self.saveOrRemovePageButton?.removeTarget(nil, action: nil, for: .allEvents)
        self.saveOrRemovePageButton?.addTarget(self, action:  #selector(deleteButtonClicked(_:)), for: .touchUpInside)
    }
    
    @IBAction func saveButtonClicked(_ sender:UIButton)
    {
        if let selectedMasechet = self.selectedMasechet
            , let selectedPage = self.selectedPage
            , let selectedPageSide = self.selectedPageSide
            , let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(selectedMasechet, page: selectedPage, pageSide: selectedPageSide)
        {
            self.savePage(pageIndex: pageIndex)
        }
    }
    
    /// Downloads one amud for the current display type (the icon on its side shows the progress)
    func savePage(pageIndex:Int)
    {
        if self.isDownloadingPage(pageIndex: pageIndex) { return }
        
        let pageInfo = (pageIndex:pageIndex, type:self.displayType)
        SavePageProcess().executeWithObject(pageInfo, onStart: { () -> Void in
            
            self.savePagesInProgress[pageIndex] = 0.0
            self.pageListView.reloadVisibleRows()
            
        }, onProgress: { (object) -> Void in
            
            let savePageProcess = object as! SavePageProcess
            self.savePagesInProgress[savePageProcess.pageInfo.pageIndex] = savePageProcess.downloadProgress
            
        }, onComplete: { (object) -> Void in
            
            let savedPageIndex = object as! Int
            self.savePagesInProgress.removeValue(forKey: savedPageIndex)
            
            let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(savedPageIndex)
            
            if let masechet = pageInfo["maschet"] as? Masechet
                , let page = pageInfo["page"] as? Page
            {
                masechet.hasSavedPages = true
                
                for masechetPage in masechet.pages
                {
                    if masechetPage.index == page.index
                    {
                        masechetPage.hasSavedPages = true
                        break
                    }
                }
                
                self.pagesPickerView.reloadAllComponents()
            }
            self.pageListView.reloadVisibleRows()
            self.updatePagePickerLayout()
            
        },onFaile: { (object, error) -> Void in
            
            print ("savePage failed")
            self.savePagesInProgress.removeValue(forKey: pageIndex)
            self.pageListView.reloadVisibleRows()
            self.updatePagePickerLayout()
        })
    }
    
    @IBAction func deleteButtonClicked(_ sender:UIButton)
    {
        if let selectedMasechet = self.selectedMasechet
            , let selectedPage = self.selectedPage
            , let selectedPageSide = self.selectedPageSide
            , let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(selectedMasechet, page: selectedPage, pageSide: selectedPageSide)
        {
            self.deletePage(pageIndex: pageIndex)
        }
    }
    
    /// Deletes one saved amud of the current display type
    func deletePage(pageIndex:Int)
    {
        let removePageInfo = (pageIndex:pageIndex, type:self.displayType)
        RemovePageProcess().executeWithObject(removePageInfo, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            let removedPageIndex = object as! Int
            self.savePagesInProgress.removeValue(forKey: removedPageIndex)
            
            if self.showSavedPagesButton?.isSelected ?? false
            {
                // In "saved pages" the amud disappears from the list
                self.showSavedPages()
            }
            else
            {
                self.pageListView.reloadVisibleRows()
            }
            
            self.updatePagePickerLayout()
            
        },onFaile: { (object, error) -> Void in
            
            print(error)
        })
    }
    
    func onDidRemovePage(pageIndex:Int)
    {
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex)
        
        if let masechet = pageInfo["maschet"] as? Masechet
            , let page = pageInfo["page"] as? Page
        {
            var noSavedPagesOnPage = false
            
            let array = ["maschet"]
            let query = "maschet='\(masechet.name!)'"
            
            if let queryObjectsInfo = SQLmanager.getData(array, from: "savedPages", where: query, fromDBFile: "DafYomi.sqlite")
                ,queryObjectsInfo.count > 0
            {
                masechet.hasSavedPages = true
                
                let pageQuery = "maschet='\(masechet.name!)' AND page='\(page.symbol!)'"
                if let queryObjectsInfo = SQLmanager.getData(array, from: "savedPages", where: pageQuery, fromDBFile: "DafYomi.sqlite")
                    ,queryObjectsInfo.count > 0
                {
                    noSavedPagesOnPage = false
                }
                else{
                    noSavedPagesOnPage = true
                }
            }
            else{
                masechet.hasSavedPages = false
                noSavedPagesOnPage = true
            }
            
            if noSavedPagesOnPage
            {
                for masechetPage in masechet.pages
                {
                    if masechetPage.index == page.index
                    {
                        masechetPage.hasSavedPages = false
                        break
                    }
                }
            }
        }
    }
    
    func isDownloadingPage(pageIndex:Int) -> Bool
    {
        if let _ =  self.savePagesInProgress[pageIndex]
        {
            return true
        }
        return false
    }
}
