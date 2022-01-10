//
//  PageSummaryViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class PageSummaryViewController:MSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    var pageSummaries:[PageSummary]?
    
    let masechtot = HadafHayomiManager.sharedManager.masechtot;

    var selectedMaseceht:Masechet?
        
    @IBOutlet weak var searchPageButton:UIButton?
    @IBOutlet weak var selectTodaysPageButton:UIButton?
    
    @IBOutlet weak var pageSummaryCollectoinView:UICollectionView?
    
    @IBOutlet weak var pagePickerBaseView:UIView?
    @IBOutlet weak var pagePickerView:UIPickerView?
    @IBOutlet weak var pagePickerTitleLabel:UILabel?
    @IBOutlet weak var pagePickerSelectButton:UIButton?
    @IBOutlet weak var pagePickerBaseViewBottomConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        //self.pageSummaryCollectoinView?.semanticContentAttribute = .forceRightToLeft
        
        self.pagePickerView?.semanticContentAttribute = .forceRightToLeft
        
        self.topBarTitleLabel?.text = "st_page_summary".localize()
                
        self.pagePickerSelectButton?.setTitle(("  \("st_hide".localize())  "), for: .normal)
        self.pagePickerSelectButton?.layer.borderWidth = 1.0
        self.pagePickerSelectButton?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
        
        self.searchPageButton?.setTitle((" \("st_select_page".localize()) "), for: .normal)
     
        self.selectTodaysPageButton?.setTitle(("st_todays_page").localize(), for: .normal)
        
        self.hidePagePicker(animated:false)
        
       self.getPageSummaries()
    }
    
    func getPageSummaries()
    {
        self.pageSummaries = [PageSummary]()
        
        var pageIndex = 0
        for masecht in self.masechtot
        {
            for page in masecht.pages{
                
               let pageSummary = PageSummary()
                pageSummary.maseceht = masecht
                pageSummary.pageIndex = page.index
                pageSummary.key = "\(masecht.name ?? "") דף \(page.symbol ?? "")"
                self.pageSummaries?.append(pageSummary)
                
                pageIndex += 1
            }
        }
          
        self.reloadData()
    }
        
    override func reloadData() {
        
        self.selectedMaseceht = HadafHayomiManager.sharedManager.todaysMaschet
        
        self.pageSummaryCollectoinView?.reloadData()
        
        self.pagePickerView?.reloadAllComponents()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dispalyLastPageViewed = UserDefaults.standard.object(forKey: "setableItem_SaveLasteSlectedPageInPageSummary") as? Bool ?? true
        
        if dispalyLastPageViewed
            ,let lastViewdPageSummary = UserDefaults.standard.object(forKey: "lastViewdPageSummary") as? [String:Int]
            ,let selectedMasechetIndex = lastViewdPageSummary["selectedMasechetIndex"]
            ,let selectedPageIndex =  lastViewdPageSummary["selectedPageIndex"]
        {
            if  selectedMasechetIndex < self.masechtot.count {
                self.selectedMaseceht = self.masechtot[selectedMasechetIndex]
                           self.pagePickerView?.selectRow(selectedMasechetIndex, inComponent: 0, animated: false)
                           self.pagePickerView?.selectRow(selectedPageIndex, inComponent: 1, animated: false)
                           
                           self.scrollToSelectedPage()
            }
            else{
                 self.scrollToTodaysPage()
            }
           
        }
        else
        {
            self.scrollToTodaysPage()
        }
    }
    
    func selectPage(pageSummary:PageSummary){
        
        if let index = self.pageSummaries?.index(of:pageSummary) {
            let selectedIndexPath = IndexPath(row:index, section: 0)
            
            self.pageSummaryCollectoinView?.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    @IBAction func pagePickerSelectButtonClicked(_ sender:UIButton)
    {
        self.hidePagePicker(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sender:UIButton)
    {
        self.showPagePicker(animated: true)
    }
    
    @IBAction func showTodaysPageButtonClicked(_ sender:UIButton)
    {
        self.scrollToTodaysPage()
    }
    
    //MARK: - UICollectoinView Delegate methods:
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.pageSummaries?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageSummaryCollectionCell", for: indexPath) as! PageSummaryCollectionCell
        
        if let pageSummary = self.pageSummaries?[indexPath.row] {
            
            cell.reloadWithObject(pageSummary)
            cell.getPageSummary()
        }
        
        return cell
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
        self.pageSummaryCollectoinView?.scrollToNearestVisibleCell()
        
        if let selectedpageSummaryIndex = self.pageSummaryCollectoinView?.centerRowIndex()
            ,let pageSummary = self.pageSummaries?[selectedpageSummaryIndex]
            ,let masechet =  pageSummary.maseceht{
            self.saveViewedPage(selectedPageIndex: pageSummary.pageIndex, masechet: masechet)
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.showPagePicker(animated:true)
        
        return false
    }
    
    func showPagePicker(animated:Bool)
    {
        self.pagePickerBaseViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
               self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })

    }
    
    func hidePagePicker(animated:Bool)
    {
        self.pagePickerBaseViewBottomConstraint?.constant = self.pagePickerBaseView!.frame.size.height
                
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
 
    }
    
    //MARK: - UIPickerView Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch component {
        case 0: //Masechtot
            return self.masechtot.count
            
        case 1: //Masechtot
            return self.selectedMaseceht?.pages.count ?? 0
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        return pickerView.frame.size.width/2
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pikerLabel = view as? UILabel ?? UILabel()
        pikerLabel.textAlignment = .center

        pikerLabel.font = UIFont(name:"BroshMF", size: 20)!
        pikerLabel.textColor = UIColor(HexColor: "781F24")
        pikerLabel.text = ""
        
        switch component
        {
        case 0://masechet
            
            let masechet = self.masechtot[row]
            pikerLabel.text = masechet.name
            break
          
            
        case 1://page
            
            if let count = selectedMaseceht?.pages.count
                ,row < count
            {
                if let page = self.selectedMaseceht?.pages[row]
                {
                    pikerLabel.text = "דף " + page.symbol
                }
            }
           
            break

        default:
            break
        }
        
        return pikerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 // Did select Masechet
        {
            self.selectedMaseceht = self.masechtot[row]
            pickerView.reloadComponent(1)
        }
        
        self.scrollToSelectedPage()
    }
    
    func scrollToSelectedPage()
    {
        let selectedMasechet = self.masechtot[self.pagePickerView?.selectedRow(inComponent: 0) ?? 0]
        let selectedPageIndex = self.pagePickerView?.selectedRow(inComponent: 1) ?? 0
        
        var pageIndex = 0
        for masecht in self.masechtot{
            if masecht != selectedMasechet{
                pageIndex += masecht.numberOfPages
            }
            else{
                pageIndex += selectedPageIndex
                break
            }
        }
                
        if let pageSummary = self.pageSummaries?[pageIndex] {
                 
                 self.selectPage(pageSummary: pageSummary)
        }
    
        self.saveViewedPage(selectedPageIndex: selectedPageIndex, masechet: selectedMasechet)
    }
    
    func saveViewedPage(selectedPageIndex:Int, masechet:Masechet){
        
          UserDefaults.standard.set(
              ["selectedMasechetIndex":(self.masechtot.index(of: masechet) ?? 0),
               "selectedPageIndex":selectedPageIndex]
              , forKey: "lastViewdPageSummary")
          UserDefaults.standard.synchronize()
    }

    func scrollToTodaysPage()
    {
        if let todyasPageSummary = self.pageSummaries?[HadafHayomiManager.sharedManager.todaysPageIndex()-1] {
            
            self.selectPage(pageSummary: todyasPageSummary)
            
            UserDefaults.standard.removeObject(forKey: "lastViewdPageSummary")
            UserDefaults.standard.synchronize()
        }
    }
}
