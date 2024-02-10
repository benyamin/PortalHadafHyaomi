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
}


class TalmudPagePickerView:UIView, UIPickerViewDelegate,UIPickerViewDataSource
{
    var dispalyedMasechtot:[Masechet]?
    {
        didSet{
            if dispalyedMasechtot?.count == 0
            {
                self.pagesPickerView.isHidden = true
                self.noPagesLabel?.isHidden = false
                self.saveOrRemovePageButton?.isHidden = true
            }
            else{
                self.pagesPickerView.isHidden = false
                self.noPagesLabel?.isHidden = true
                
                if displayType == .Vagshal || displayType == .Chavruta {
                    self.saveOrRemovePageButton?.isHidden = false
                }
            }
        }
    }
    var displayedPages:[Page]?
    var displayedPageSides:[Int]?
    
    var displayType:TalmudDisplayType = .Vagshal {
        didSet {
            if displayType == .Vagshal || displayType == .Chavruta {
                self.saveOrRemovePageButton?.isHidden = false
            }
            else{
                self.saveOrRemovePageButton?.isHidden = true
            }
        }
    }
    
    var shouldHighlightSavedPages = false
    
    weak var delegate:TalmudPagePickerViewDelegate?
    
    @IBOutlet weak var pagePickerContentView:UIView?
    var pagesPickerView:UIPickerView!//TablePickerView!
    
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
        }
    }
        
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
                self.displayedPages = selectedMasechet?.savedPages
                
                self.pagesPickerView.reloadComponent(1)//pages

                if let selectedPage = self.selectedPage
                {
                    self.displayedPageSides = selectedMasechet?.getSavedPageSidesForPage(selectedPage)
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
        
        self.addPicker()
        
        self.noPagesLabel?.text = "st_no_saved_pages_message_label".localize()
        
        self.showAllPagesButton?.setTitle("st_show_all_pages".localize(), for: .normal)
          self.showSavedPagesButton?.setTitle("st_show_saved_pages".localize(), for: .normal)
        
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
        
        self.dispalyedMasechtot = HadafHayomiManager.sharedManager.getMessechtotWithSavedPages()
        self.pagesPickerView.reloadComponent(2)//Masechtot
        
        if let indexOfSelectedMasechet = dispalyedMasechtot?.index(of: self.selectedMasechet!)
        {
            self.pagesPickerView.selectRow(indexOfSelectedMasechet, inComponent: 2, animated: false)
        }
       
        if self.dispalyedMasechtot != nil && self.dispalyedMasechtot!.count > 0
        {
            self.selectedMasechet = self.dispalyedMasechtot?[self.pagesPickerView.selectedRow(inComponent: 2)]
        }
        
        self.pagesPickerView.reloadComponent(1)//pages
        
        if let selectedPage = self.selectedPage
        {
            self.displayedPageSides = selectedMasechet?.getSavedPageSidesForPage(selectedPage)
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
                
                let path = LessonsManager.sharedManager.pathForPage(pageIndex: pageIndex)
                
                if self.shouldHighlightSavedPages
                && FileManager.default.fileExists(atPath: path)
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
                textLabel.textColor = (self.shouldHighlightSavedPages && page.hasSavedPages) ?  UIColor.blue : UIColor(HexColor: "781F24")
            }
            
        case 2: //Masechetֿ
            textLabel.textAlignment = .center
            
            if let maschet = self.dispalyedMasechtot?[row]
            {
                textLabel.text = maschet.name
                textLabel.textColor = (self.shouldHighlightSavedPages && maschet.hasSavedPages) ?  UIColor.blue : UIColor(HexColor: "781F24")
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
                self.displayedPageSides = selectedMasechet?.getSavedPageSidesForPage(selectedPage)
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
                
                if displayType == .Vagshal || displayType == .Chavruta {
                    self.saveOrRemovePageButton?.isHidden = false
                    self.progressCircleView?.isHidden = true
                }
                else{
                    self.saveOrRemovePageButton?.isHidden = true
                    self.progressCircleView?.isHidden = true
                }
                
                //Check if page is saved in documnets
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                path += "/\(pageIndex).pdf"
                
                if FileManager.default.fileExists(atPath: path)
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
    
    func setSaveButton()
    {
        self.saveOrRemovePageButton?.setImage(UIImage(named: "save"), for: .normal)
        self.saveOrRemovePageButton?.setImage(UIImage(named: "save_highlighted"), for: .highlighted)
        
        self.saveOrRemovePageButton?.removeTarget(nil, action: nil, for: .allEvents)
        self.saveOrRemovePageButton?.addTarget(self, action:  #selector(saveButtonClicked(_:)), for: .touchUpInside)
    }
    
    func setDeleteButton()
    {
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
        {
            
            let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(selectedMasechet,
                                                                          page: selectedPage,
                                                                          pageSide: selectedPageSide)
            
            if pageIndex == nil{
                return
            }
            
            let pageInfo = (pageIndex:pageIndex, type:self.displayType)
            SavePageProcess().executeWithObject(pageInfo, onStart: { () -> Void in
                
                self.saveOrRemovePageButton?.isHidden = true
                
                if let progressCircleView = self.progressCircleView
                {
                    self.saveOrRemovePageButton?.superview?.addSubview(progressCircleView)
                    self.progressCircleView?.isHidden = false
                }
                
                self.savePagesInProgress[pageIndex!] = 0.0
                self.updatePagePickerLayout()
                
            }, onProgress: { (object) -> Void in
                
                let savePageProcess = object as! SavePageProcess
                self.savePagesInProgress[savePageProcess.pageInfo.pageIndex] = savePageProcess.downloadProgress
                
                self.updatePagePickerLayout()
                
            }, onComplete: { (object) -> Void in
                
                let pageIndex = object as! Int
                self.savePagesInProgress.removeValue(forKey: pageIndex)
                
                let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex)
                
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
                    
                    self.pagesPickerView.reloadComponent(2)//Masechtot
                    self.pagesPickerView.reloadComponent(1)//pages
                    self.pagesPickerView.reloadComponent(0)//pageSide
                    
                    self.updatePagePickerLayout()
                }
                
            },onFaile: { (object, error) -> Void in
                
                print ("saveButtonClicked failed")
                let savePageProcess = object as! SavePageProcess
                self.savePagesInProgress.removeValue(forKey: savePageProcess.pageInfo.pageIndex)
                
                self.updatePagePickerLayout()
            })
        }
    }
    
    @IBAction func deleteButtonClicked(_ sender:UIButton)
    {
        if let selectedMasechet = self.selectedMasechet
            , let selectedPage = self.selectedPage
            , let selectedPageSide = self.selectedPageSide
        {
            
            let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(selectedMasechet,
                                                                          page: selectedPage,
                                                                          pageSide: selectedPageSide)
            
            if pageIndex == nil
            {
                return
            }
            
            RemovePageProcess().executeWithObject(pageIndex!, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                let pageIndex = object as! Int
                self.savePagesInProgress.removeValue(forKey: pageIndex)
                
                if self.showAllPagesButton?.isSelected ?? false
                {
                    self.showAllPages()
                }
                else if self.showSavedPagesButton?.isSelected ?? false
                {
                    self.showSavedPages()
                }
                
            },onFaile: { (object, error) -> Void in
                
                print(error)
            })
        }
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
