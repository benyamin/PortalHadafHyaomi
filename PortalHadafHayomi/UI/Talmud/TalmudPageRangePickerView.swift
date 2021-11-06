//
//  TalmudPageRangePickerView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 07/10/2021.
//  Copyright © 2021 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class TalmudPageRangePickerView:UIView, UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate
{
    let masechtot = HadafHayomiManager.sharedManager.masechtot;
    var selectedMaseceht:Masechet?
    
    var fromPageIndex:Int?
    var toPageIndex:Int?
    
    let maxPagesToDownlaod = 10
    
    var savePageProcess:SavePageProcess?
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var fromPageLabel:UILabel!
    @IBOutlet weak var fromPageTextField:UITextField?
    @IBOutlet weak var toPageLabel:UILabel!
    @IBOutlet weak var toPageTextField:UITextField!
    @IBOutlet weak var pagePickerView:UIPickerView?
    @IBOutlet weak var downloadButton:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.downloadButton.setTitle("st_download".localize(), for: .normal)
        self.titleLabel.text = "\("st_Max_Pages_Per_Downlaod".localize()): \(maxPagesToDownlaod)"
        self.fromPageLabel.text = "st_from_page".localize()
        self.toPageLabel.text = "st_to_page".localize()
        self.fromPageTextField?.becomeFirstResponder()
        
        self.reloadData()
    }
    
    func reloadWithObject(_ object:Any?) {
        self.fromPageIndex = object as? Int
        
        self.reloadData()
    }
    
    func reloadData() {
        
        if let pageIndex = self.fromPageIndex {
            self.scrollToPage(pageIndex)
            
            if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(pageIndex)
                ,let page = HadafHayomiManager.sharedManager.getPageForPageIndex(pageIndex) {
                self.fromPageTextField?.text = "\(masechet.name ?? "") דף \(page.symbol ?? "")"
            }
        }
    }
        
    func scrollToPage(_ pageIndex:Int) {
        
        if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(pageIndex)
        ,let page = HadafHayomiManager.sharedManager.getPageForPageIndex(pageIndex)
        {
            self.selectedMaseceht = masechet
            
            self.toPageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: 1)
                        
            if let masechetIndex = self.masechtot.index(where: { $0.id == masechet.id }) {
                self.pagePickerView?.selectRow(masechetIndex, inComponent: 0, animated: true)
                self.pagePickerView?.reloadComponent(1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.pagePickerView?.selectRow(page.index-1, inComponent: 1, animated: true)
                }
            }
        }
    }
    
    @IBAction func downloadButtonClicked(_ sender:UIButton) {
        if self.fromPageIndex != nil && self.toPageIndex != nil {
                        
            downloadPage(fromPageIndex!)
            
            func downloadPage(_ pageIndex:Int) {
                
                let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(pageIndex)
                let page = HadafHayomiManager.sharedManager.getPageForPageIndex(pageIndex)

              
                let pageInfo = (pageIndex:pageIndex, type:TalmudDisplayType.Vagshal)

                SavePageProcess().executeWithObject(pageInfo, onStart: { () -> Void in
                    
                    let pageSide = HadafHayomiManager.sharedManager.getPageSideForPageIndex(pageIndex) ?? 1
                    self.titleLabel.text = "\("מוריד") \(masechet?.name ?? "") דף \(page?.symbol ?? "") עמ׳ \(pageSide == 1 ? "א" : "ב")"
                    
                }, onProgress: { (object) -> Void in
                    
                }, onComplete: { (object) -> Void in
                    
                    masechet?.hasSavedPages = true
                    page?.hasSavedPages = true
                    
                    self.savePageProcess = nil
                    
                    if pageIndex < self.toPageIndex! {
                        downloadPage(pageIndex+1)
                    }
                    else{
                        self.downloadComplete()
                    }
                    
                },onFaile: { (object, error) -> Void in
                   
                    self.savePageProcess = nil
                    
                    // If page is alredy saved
                    if error.code == 516 {
                        if pageIndex < self.toPageIndex! {
                            downloadPage(pageIndex+1)
                        }
                        else{
                            self.downloadComplete()
                        }
                    }
                })
            }
        }
    }
    
    func downloadComplete() {
        
        self.titleLabel.text = "\("st_Max_Pages_Per_Downlaod".localize()): \(maxPagesToDownlaod)"
        
        self.selectedMaseceht?.hasSavedPages = true
        self.pagePickerView?.reloadAllComponents()
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
            if masechet.hasSavedPages {
                pikerLabel.textColor = .systemBlue
            }
            else{
                pikerLabel.textColor = UIColor(HexColor: "781F24")
            }
            
            pikerLabel.text = masechet.name
            break
          
            
        case 1://page
            
            if let count = selectedMaseceht?.pages.count
                ,row < count
            {
                if let page = self.selectedMaseceht?.pages[row]
                {
                    pikerLabel.text = "דף " + page.symbol
                    
                    pikerLabel.textColor = UIColor(HexColor: "781F24")
                    
                    if let masechet = self.selectedMaseceht
                        ,let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet,
                                                                                       page: page,
                                                                                       pageSide: 0)
                    {
                        if FileManager.default.fileExists(atPath: LessonsManager.sharedManager.pathForPage(pageIndex: pageIndex))
                            && FileManager.default.fileExists(atPath: LessonsManager.sharedManager.pathForPage(pageIndex: pageIndex+1))
                        {
                            pikerLabel.textColor = .systemBlue
                        }
                    }
                }
            }
           
            break

        default:
            break
        }
        
        return pikerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var pickerMasechet:Masechet?
        var pickerPage:Page?
        
        if component == 0 // Did select Masechet
        {
            pickerMasechet = self.masechtot[row]
            
            self.selectedMaseceht = pickerMasechet
            
            pickerView.reloadComponent(1)
            
            let selectedPageIndex = pickerView.selectedRow(inComponent: 1)
            
            if selectedPageIndex < pickerMasechet?.pages.count ?? 0  {
                pickerPage = pickerMasechet?.pages[selectedPageIndex]
            }
            else{
                pickerPage = pickerMasechet?.pages.last
            }
        }
        else{
            pickerMasechet = self.selectedMaseceht
            pickerPage = pickerMasechet?.pages[row]
        }
        
        if pickerMasechet == nil || pickerPage == nil {
            return
        }
        
        let selectedPageTextDisplay = "\(pickerMasechet?.name ?? "") דף \(pickerPage?.symbol ?? "")"
        
        if self.fromPageTextField?.isFirstResponder ?? false {
            
            self.fromPageIndex = HadafHayomiManager.sharedManager.pageIndexFor(pickerMasechet!, page: pickerPage!, pageSide: 0)
            self.fromPageTextField?.text = selectedPageTextDisplay
            
            let maxPageIndexToSelect = ((self.fromPageIndex
                                         ?? 0) + maxPagesToDownlaod*2)
            
            if (self.fromPageIndex != nil && self.toPageIndex != nil)
                && (self.toPageIndex! > maxPageIndexToSelect || self.toPageIndex! < self.fromPageIndex!) {
                
                self.setMaxPage(shouldScrollToPage:false)
            }
        }
        else if self.toPageTextField.isFirstResponder {
            
            let selectedPageIndex = HadafHayomiManager.sharedManager.pageIndexFor(pickerMasechet!, page: pickerPage!, pageSide: 1)
            
            let maxPageIndexToSelect = ((self.fromPageIndex
                                         ?? 0) + maxPagesToDownlaod*2)
            
            if self.fromPageIndex != nil && selectedPageIndex != nil
                && selectedPageIndex! <= maxPageIndexToSelect
                && selectedPageIndex! > self.fromPageIndex! {
                
                self.toPageIndex = selectedPageIndex
                self.toPageTextField.text = selectedPageTextDisplay
            }
            else {
                self.setMaxPage(shouldScrollToPage:true)
            }
        }
    }
    
    func setMaxPage(shouldScrollToPage:Bool) {
        
        let maxPageIndexToSelect = ((self.fromPageIndex
                                     ?? 0) + maxPagesToDownlaod*2)
        
        if let masechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(maxPageIndexToSelect)
        ,let page = HadafHayomiManager.sharedManager.getPageForPageIndex(maxPageIndexToSelect)
        {
            
            self.toPageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: 1)
            
            self.toPageTextField.text = "\(masechet.name ?? "") דף \(page.symbol ?? "")"
            
            if shouldScrollToPage {
                
                if let masechetIndex = self.masechtot.index(where: { $0.id == masechet.id }) {
                    self.pagePickerView?.selectRow(masechetIndex, inComponent: 0, animated: true)
                    self.pagePickerView?.reloadComponent(1)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.pagePickerView?.selectRow(page.index-1, inComponent: 1, animated: true)
                    }
                }
            }
        }
    }
    
    //MARK: - TextField Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.inputView == nil {
            textField.inputView = UIView.init(frame: CGRect.zero)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
  
}
