//
//  SearchTalmudViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/06/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class SearchTalmudViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    var searchResultInfo:SearchResultInfo?
    
    var selectedSearchResult:SearchTalmudResult?
    
    var selectedMasechet:Masechet?
    
    weak var loadingView:BTLoadingView?
    
    var searchTalmudProcess:SearchTalmudProcess?
    
    var savedSearches:[[String:String]]?
    var displyaedSavedSearches:[[String:String]]?
    var searchsuggestoins:[TranslatedWord]?
    
    let selectMasechetDefaultText = "st_all_masechtot".localize()
    let selectPageDefaultText = "st_all".localize()
    
    var searchInOptoins:[String]! = {
       
        var searchInOptoins = [String]()
        searchInOptoins.append("st_all".localize())
        searchInOptoins.append("st_talmud".localize())
        searchInOptoins.append("st_rashi".localize())
        searchInOptoins.append("st_tosafot".localize())
        
        return searchInOptoins
    }()
    
    @IBOutlet weak var searchBoxView:UIView?
    @IBOutlet weak var selectMasechetTextField:UITextField?
    @IBOutlet weak var selectFromPageTextField:UITextField?
    @IBOutlet weak var selectToPageTextField:UITextField?
    @IBOutlet weak var searchTextTextField:UITextField?
    @IBOutlet weak var runSearchButton:UIButton?
    @IBOutlet weak var searchResultsTable:UITableView?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var pagePickerBaseView:UIView?
    @IBOutlet weak var pagePickerView:UIPickerView?
    @IBOutlet weak var pagePickerTitleLabel:UILabel?
    @IBOutlet weak var pagePickerSelectButton:UIButton?
    @IBOutlet weak var pagePickerBaseViewBottomConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var searchInOptoinsTextField:UITextField?
    @IBOutlet weak var matchingSearchCheckBoxButton:UIButton?
    @IBOutlet weak var searchInOptoinsPickerView:UIPickerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topBarTitleLabel?.text = "st_talmud_search".localize()
        
        self.searchBoxView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.searchBoxView?.layer.shadowOpacity = 0.5
        self.searchBoxView?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.searchBoxView?.layer.shadowRadius = 2.0
        
        self.pagePickerBaseView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.pagePickerBaseView?.layer.shadowOpacity = 0.5
        self.pagePickerBaseView?.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.pagePickerBaseView?.layer.shadowRadius = 2.0
        
        self.pagePickerSelectButton?.setTitle((" \("st_hide".localize()) "), for: .normal)
        self.pagePickerSelectButton?.layer.borderWidth = 1.0
        self.pagePickerSelectButton?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
        
        self.runSearchButton?.layer.cornerRadius = 3.0
        
        self.hidePagePicker(animated:false)
        
        let checkBoxOff = UIImage.imageWithTintColor(UIImage(named: "Checkbox_off.png")!, color: UIColor(HexColor: "781F24"))
        
        let checkBoxOn = UIImage.imageWithTintColor(UIImage(named: "Checkbox_on.png")!, color: UIColor(HexColor: "781F24"))
        self.matchingSearchCheckBoxButton?.setImage(checkBoxOff, for: .normal)
        self.matchingSearchCheckBoxButton?.setImage(checkBoxOn, for: .selected)
        self.matchingSearchCheckBoxButton?.isSelected = true
        
        self.selectMasechetTextField?.text = selectMasechetDefaultText
        self.selectFromPageTextField?.text = selectPageDefaultText
        self.selectToPageTextField?.text = selectPageDefaultText
        
        self.searchInOptoinsTextField?.text = "st_all_search_optoins".localize()
        
        self.runSearchButton?.setTitle("st_search".localize(), for: .normal)
        
        self.view.setLocalizatoin()
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        
        if self.searchsuggestoins == nil
        {
            self.searchsuggestoins =  DictionaryManager.sharedManager.aramicWords
            
            self.setSearchSuggestoinsDisplay()
        }
    }
    
    @IBAction func matchingSearchCheckBoxButtonClicked(_ sender:UIButton)
    {
        self.matchingSearchCheckBoxButton?.isSelected = !(self.matchingSearchCheckBoxButton?.isSelected ?? false)
    }
    
    @IBAction func pagePickerSelectButtonClicked(_ sender:UIButton)
    {
        self.hidePagePicker(animated: true)
    }
    
    @IBAction func runSearchButtonClicked(_ sender:AnyObject)
    {
        if let seaerchText = self.searchTextTextField?.text, seaerchText.count < 2
        {
            return
        }
        
        self.searchTextTextField?.resignFirstResponder()
        self.hidePagePicker(animated: true)
        
        self.searchResultInfo = nil
        
        self.loadingView?.removeFromSuperview()
        
        if let loadingView = UIView.viewWithNib("BTLoadingView") as? BTLoadingView
        {
            loadingView.frame = self.searchResultsTable!.frame
            self.loadingView = loadingView

            self.view.addSubview(self.loadingView!)
            
        }
        
        let searchParams = self.getSearchParams()
        
        self.saveSearchParamters(searchParams)
        
        self.runSearchWithParams(searchParams)
    }
    
    func saveSearchParamters(_ searchParams:[String:String])
    {
        var savedSearchesInfo:[[String:String]]
        
        if let searchInfo = UserDefaults.standard.object(forKey: "savedSearchesInfo") as? [[String : String]]
        {
            savedSearchesInfo = searchInfo
        }
        else{
             savedSearchesInfo = [[String:String]]()
        }
        
        savedSearchesInfo.insert(searchParams, at: 0)
        
        if savedSearchesInfo.count > 10
        {
            savedSearchesInfo.removeLast()
        }
        
        UserDefaults.standard.set(savedSearchesInfo, forKey: "savedSearchesInfo")
        UserDefaults.standard.synchronize()
        
        self.savedSearches = savedSearchesInfo
    }
    
    func getSearchParams() -> [String:String]
    {
        var searchParams = [String:String]()
        
        searchParams["text"] = self.searchTextTextField?.text
        
        if let masechetId = self.selectedMasechet?.getWebId()
        {
            searchParams["massechet"] = masechetId
            
            if let seletedFromPageRow = self.pagePickerView?.selectedRow(inComponent: 1)
                ,let seletedToPageRow = self.pagePickerView?.selectedRow(inComponent: 0)
            {
                if seletedFromPageRow == 0
                {
                    searchParams["medaf"] = ""
                    searchParams["addaf"] = ""
                }
                else{
                    searchParams["medaf"] = ("\(seletedFromPageRow*2 + 1)")
                    
                    //Show all pages
                    if seletedToPageRow == 0
                    {
                        searchParams["addaf"] = ""
                    }
                    else{
                        searchParams["addaf"] = ("\(seletedToPageRow*2 + 2)")
                    }
                }
            }
        }
        else{
            searchParams["massechet"] =  ""
            
            searchParams["medaf"] = ""
            searchParams["addaf"] = ""
        }
        
        if let currenyDataPageNumber = self.searchResultInfo?.dataPageNumber
        {
            searchParams["dataPageNumber"] = ("\(currenyDataPageNumber+1)")
        }
        else{
            searchParams["dataPageNumber"] = "1"
        }
        
        searchParams["matching"] = (self.matchingSearchCheckBoxButton?.isSelected ?? false) ? "true" : "false"
        
        searchParams["searchInId"] = ("\(self.searchInOptoinsPickerView?.selectedRow(inComponent: 0) ?? 0)")
        
        return searchParams
    }
    
    func runSearchWithParams(_ searchParams:[String:String])
    {
        self.searchTalmudProcess?.cancel()
        
        self.searchTalmudProcess =  SearchTalmudProcess()
        
        self.searchTalmudProcess?.executeWithObject(searchParams, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.searchTalmudProcess  = nil
            
            self.loadingView?.removeFromSuperview()
            
            let newSearchResultInfo = object as! SearchResultInfo
            
            if self.searchResultInfo == nil
            {
                self.searchResultInfo = object as? SearchResultInfo
            }
            else
            {
                self.searchResultInfo!.searchResults.append(contentsOf: newSearchResultInfo.searchResults)
                
                self.searchResultInfo?.dataPageNumber = newSearchResultInfo.dataPageNumber
            }
            
            self.searchResultsTable?.tag = 0 // Dispaly Search resutls
            self.searchResultsTable?.reloadData()
            
            if let searchResultInfo = self.searchResultInfo, searchResultInfo.searchResults.count == 0
            {
                  let errorTitle = "st_search_value_error_title".localize()
                let errorMessage = "st_search_value_error_message".localize()
                 let okButtonTitle = "st_ok".localize()
                
                BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [okButtonTitle], onComplete:{ (dismissButtonKey) in
                })
            }
            
        },onFaile: { (object, error) -> Void in
            
            self.searchTalmudProcess  = nil
            
            self.loadingView?.removeFromSuperview()
            
            let errorTitle = "st_error".localize()
            let errorMessage = "st_general_system_error".localize()
            let okButtonTitle = "st_ok".localize()
            
            BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [okButtonTitle], onComplete:{ (dismissButtonKey) in
            })
        })
    }
    
    func cancelSearchProcess()
    {
        self.searchTalmudProcess?.cancel()
    }
    
    // MARK: - TableView Methods:
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1
        {
            return 2
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView.tag == 1
            && self.tableView(tableView, numberOfRowsInSection: section) > 0
        {
            return 44
            
        }
        else{
           
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView.tag == 1
            && self.tableView(tableView, numberOfRowsInSection: section) > 0
        {
            if section == 0
            {
                 let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "SearchTalmudLastSearchesHeader") as! MSTableHeaderTitleCell
                
                sectionHeader.titleLabel?.text = "st_last_searches".localize()
                 return sectionHeader
            }
            
            else if section == 1
            {
                let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "SearchTalmudWordsListHeader") as! MSTableHeaderTitleCell
                
                sectionHeader.titleLabel?.text = "st_words_list".localize()
                
                return sectionHeader
            }
            else{
                return nil
            }
        }
        else{
            return nil
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.tag == 1
        {
            if section == 0 //Saved Searches
            {
                return self.displyaedSavedSearches?.count ?? 0
            }
            else//Suggest searches
            {
               return self.searchsuggestoins?.count ?? 0
            }
        }
        else{
            
            if let searchResultInfo = self.searchResultInfo, searchResultInfo.searchResults.count > 0
            {
                //Did load all relevent seach data
                if searchResultInfo.dataPageNumber == searchResultInfo.numberOfDataPages
                    || searchResultInfo.numberOfDataPages == nil //Only one page result
                {
                    return searchResultInfo.searchResults.count
                }
                else{
                    return searchResultInfo.searchResults.count + 1
                }
            }
            else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = MSBaseTableViewCell()
        
        if tableView.tag == 1
        {
            if indexPath.section == 0 //Saved Searches
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "SavedSearchTableCell", for:indexPath) as! MSBaseTableViewCell
                
                if let savedSearchInfo = self.displyaedSavedSearches?[indexPath.row]
                {
                    cell.reloadWithObject(savedSearchInfo)
                }
            }
            else//Suggest searches
            {
               cell = tableView.dequeueReusableCell(withIdentifier: "SearchSuggestionTableCell", for:indexPath) as! MSBaseTableViewCell
                
                if let aramicWord = self.searchsuggestoins?[indexPath.row]
                {
                    cell.reloadWithObject(aramicWord)
                }
            }
        }
        else
        {
            //If lastIndex
            if indexPath.row == self.searchResultInfo!.searchResults.count
                && searchResultInfo!.dataPageNumber != searchResultInfo!.numberOfDataPages
            {
               cell = tableView.dequeueReusableCell(withIdentifier: "LoadingDataTableCell", for:indexPath) as! MSBaseTableViewCell
                
                cell.reloadData()
            }
            else
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableCell", for:indexPath) as! MSBaseTableViewCell
                
                cell.reloadWithObject(self.searchResultInfo!.searchResults[indexPath.row])

            }
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
       
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView.tag == 1
        {
        }
        else{
            //If last row
            if indexPath.row == self.searchResultInfo!.searchResults.count-1
            {
                if let dataPageNumber = self.searchResultInfo?.dataPageNumber
                    , let numberOfDataPages = self.searchResultInfo?.numberOfDataPages
                    ,dataPageNumber < numberOfDataPages
                {
                    let searchParams = self.getSearchParams()
                    self.runSearchWithParams(searchParams)
                }
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 1
        {
            if indexPath.section == 0 //Saved Searches
            {
                if let savedSearchInfo = self.displyaedSavedSearches?[indexPath.row]
                {
                    self.fillSearchInfoWithParams(savedSearchInfo)
                }
            }
            else //suggested text
            {
                if let word = self.searchsuggestoins?[indexPath.row]
                {
                    self.searchTextTextField?.text = word.key
                }
            }
        }
        else{
            let searchResult = self.searchResultInfo!.searchResults[indexPath.row]
            
            self.showPageForSearchResult(searchResult)
        }
        
    }
    
    func fillSearchInfoWithParams(_ searchParams:[String:String])
    {
         self.searchTextTextField?.text = searchParams["text"]
        
        self.selectMasechetTextField?.text = selectMasechetDefaultText
        self.selectFromPageTextField?.text = selectPageDefaultText
        self.selectToPageTextField?.text = selectPageDefaultText
        
        if let masechet = HadafHayomiManager.sharedManager.getMasechetById(searchParams["massechet"]!)
        {
            self.selectedMasechet = masechet
            self.selectMasechetTextField?.text = self.selectedMasechet?.name
            
            if let fromPage = searchParams["medaf"], fromPage != ""
            {
                if let page =  masechet.getPageByIndex(fromPage)
                {
                    self.selectFromPageTextField?.text = page.symbol
                }
            }
            
            if let toPage = searchParams["addaf"] , toPage != ""
            {
                if let page =  masechet.getPageByIndex(toPage)
                {
                    self.selectToPageTextField?.text = page.symbol
                }
            }
        }
    }
    
    func showsSearchResultsPager()
    {
        let searchResultsPagerViewController =  UIViewController.withName("SearchResultsPagerViewController", storyBoardIdentifier: "SearchTalmudStoryboard") as! SearchResultsPagerViewController
        
        searchResultsPagerViewController.reloadWithObject(self.searchResultInfo!.searchResults)
        self.navigationController?.pushViewController(searchResultsPagerViewController, animated: true)
    }
    
    func showPageForSearchResult(_ searchResult:Any)
    {
        self.selectedSearchResult = searchResult as? SearchTalmudResult
        
        if let link = self.selectedSearchResult?.link
        {
            let mobileLink = "https://app.daf-yomi.com/" + link + "&mobile=1"
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            webViewController.delegate = self
            
            webViewController.loadUrl(mobileLink, title: (self.selectedSearchResult?.page ?? ""))
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if let mainViewController = UIApplication.shared.keyWindow?.mainViewController()
                {
                    mainViewController.presentViewController(webViewController, onContainer: mainViewController.mainContainerView)
                }
            }
            else{
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    
    //MARK: - WebView DelegateMethods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        if let text = self.selectedSearchResult?.searchText
        {
           self.webView(webView, markSelectedText: text)
        }
    }
    
    
    @objc func webView(_ webView:WKWebView, markSelectedText text:String)
    {
        if let text = self.selectedSearchResult?.searchText
        {
           let js = ("var newHtml = document.getElementById(\"oContent\").innerHTML.replace(new RegExp('\(text)', 'g'),'<b style=\"background-color:#6A2423;color:#FAF2DD\">' + '\(text)' + '</b>');   document.getElementsByClassName('clsContainer')[0].innerHTML = newHtml;")
            
            webView.evaluateJavaScript(js) { (result, error) in
                if error != nil {
                }
            }
        }
    }
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.selectMasechetTextField
        || textField == self.selectFromPageTextField
        || textField == self.selectToPageTextField
        {
            self.searchTextTextField?.resignFirstResponder()
            
            self.showPicker(self.pagePickerView!, animated:true)
            
            return false
        }
        else if textField == self.searchInOptoinsTextField
        {
             self.searchTextTextField?.resignFirstResponder()
            
            self.showPicker(self.searchInOptoinsPickerView!, animated:true)
            
            return false
        }
        else{
            self.hidePagePicker(animated: true)
             return true
        }
    }
    
    func showPicker(_ picker:UIPickerView, animated:Bool)
    {
        self.pagePickerView?.isHidden = true
         self.searchInOptoinsPickerView?.isHidden = true
        
        picker.isHidden = false
        
        self.pagePickerBaseViewBottomConstraint?.constant = 0
        
        self.tableViewBottomConstraint?.constant = self.pagePickerBaseView?.frame.size.height ?? 0
        
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
        
    }
    
    
    func hidePagePicker(animated:Bool)
    {
        self.pagePickerBaseViewBottomConstraint?.constant = -1*(self.pagePickerBaseView!.frame.size.height)
        
        self.tableViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
        
    }
    //MARK: - UIPickerView Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        if pickerView == self.searchInOptoinsPickerView
        {
             return 1
        }
            
        else if pickerView == self.pagePickerView
        {
             return 3
        }
        else{
             return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView == self.searchInOptoinsPickerView
        {
            return self.searchInOptoins.count
        }
            
        else if pickerView == self.pagePickerView
        {
            
            switch component
            {
            case 0://To page
                
                if let selectedMasechet = self.selectedMasechet
                {
                    let selectedFromPageIndex = pickerView.selectedRow(inComponent: 1)
                    
                    if selectedFromPageIndex == 0
                    {
                        return 1
                    }
                    else{
                        return selectedMasechet.pages.count + 1
                    }
                    
                }
                else{
                    return 1
                }
            case 1://From page
                
                if let selectedMasechet = self.selectedMasechet
                {
                    return selectedMasechet.pages.count + 1
                }
                else{
                    return 1
                }
                
            case 2://Masechet
                return HadafHayomiManager.sharedManager.masechtot.count + 1
                
            default:
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        if pickerView == self.searchInOptoinsPickerView
        {
            return pickerView.frame.size.width
        }
        
        else if pickerView == self.pagePickerView
        {
            switch component
            {
            case 0, 1://Page
                return pickerView.frame.size.width/4
                
            case 2://Maschet
                return pickerView.frame.size.width/2
                
            default:
                return pickerView.frame.size.width/2
            }
        }
        else{
            return 0
        }
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
        
        if pickerView == self.searchInOptoinsPickerView
        {
            pikerLabel.text = self.searchInOptoins[row]
        }
        else  if pickerView == self.pagePickerView
        {
            switch component
            {
            case 0, 1: //Page
                
                if row == 0
                {
                    pikerLabel.text = "st_all_pages".localize()
                }
                else if let page = selectedMasechet?.pages[row-1]
                {
                    if component == 0 // לדף
                    {
                        pikerLabel.text = "לדף " + page.symbol
                        
                        if let seletedFromPageRow =  self.pagePickerView?.selectedRow(inComponent: 1)
                        {
                            if row < seletedFromPageRow
                            {
                                pikerLabel.alpha = 0.3
                            }
                            else{
                                pikerLabel.alpha = 1.0
                            }
                        }
                    }
                    else if component == 1 // מדף
                    {
                        pikerLabel.text = "מדף " + page.symbol
                    }
                }
                
                break
                
            case 2://masechet
                
                if row == 0
                {
                    pikerLabel.text = selectMasechetDefaultText
                }
                else{
                    let masecht = HadafHayomiManager.sharedManager.masechtot[row-1]
                    pikerLabel.text = masecht.name
                }
                
                break
                
            default:
                break
            }
        }
        
        return pikerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == self.searchInOptoinsPickerView
        {
            if row == 0
            {
                self.searchInOptoinsTextField?.text =  "st_all_search_optoins".localize()
            }
            else{
                self.searchInOptoinsTextField?.text = self.searchInOptoins[row]
            }
        }
        else  if pickerView == self.pagePickerView
        {
            if component == 2 // Did select Masechet
            {
                if row == 0
                {
                    self.didSelectMasechet(nil)
                }
                else
                {
                    let masehcet = HadafHayomiManager.sharedManager.masechtot[row-1]
                    self.didSelectMasechet(masehcet)
                }
            }
                
            else  if component == 1 // From page
            {
                let seletedFromPageRow = pickerView.selectedRow(inComponent: component)
                self.didSelectFromPageIndex(seletedFromPageRow)
            }
                
            else  if component == 0 // To page
            {
                let seletedToPageRow = pickerView.selectedRow(inComponent: component)
                self.didSelectToPageIndex(seletedToPageRow)
            }
        }
    }
    
    func didSelectMasechet(_ masechet:Masechet?)
    {
        if masechet != nil
        {
            self.selectedMasechet = masechet
            self.selectMasechetTextField?.text = self.selectedMasechet?.name
        }
        else
        {
            self.selectedMasechet = nil
            self.selectMasechetTextField?.text = selectMasechetDefaultText
        }
        self.pagePickerView?.reloadComponent(1)// From page
        
        if let seletedFromPageRow = self.pagePickerView?.selectedRow(inComponent: 1)
        {
             self.pickerView( self.pagePickerView!, didSelectRow: seletedFromPageRow, inComponent: 1)
        }
    }
    
    func didSelectFromPageIndex(_ pageIndex:Int)
    {
        let selectedFromPageIndex = pageIndex
        
        if selectedFromPageIndex == 0
        {
            self.selectFromPageTextField?.text = selectPageDefaultText
        }
        else
        {
            if let page = selectedMasechet?.pages[selectedFromPageIndex-1]
            {
                self.selectFromPageTextField?.text =  page.symbol
            }
        }
        self.pagePickerView?.reloadComponent(0)// To page
        
        var seletedToPageRow = self.pagePickerView!.selectedRow(inComponent: 0)
        
        if seletedToPageRow != 0 && seletedToPageRow < selectedFromPageIndex
        {
            seletedToPageRow = selectedFromPageIndex
        }
        self.pagePickerView?.selectRow(seletedToPageRow, inComponent: 0, animated: true)
        self.pickerView(self.pagePickerView!, didSelectRow: seletedToPageRow, inComponent: 0)
    }
    
    func didSelectToPageIndex(_ pageIndex:Int)
    {
        let seletedFromPageRow =  self.pagePickerView!.selectedRow(inComponent: 1)

        var seletedToPageRow = pageIndex
        
        if seletedToPageRow != 0 && seletedToPageRow < seletedFromPageRow
        {
            seletedToPageRow = seletedFromPageRow
            
            self.pagePickerView?.selectRow(seletedToPageRow, inComponent: 0, animated: true)
            self.pickerView(self.pagePickerView!, didSelectRow: seletedToPageRow, inComponent: 0)
            return
        }
        
        if seletedToPageRow == 0 // From page
        {
            self.selectToPageTextField?.text = selectPageDefaultText
        }
        else
        {
            if let page = selectedMasechet?.pages[seletedToPageRow-1]
            {
                self.selectToPageTextField?.text =  page.symbol
            }
        }
    }
    
   // MARK: - TextField Methods
    @IBAction func textFieldEditintChanged(_ textField:UITextField)
    {
        if textField == self.searchTextTextField
        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getSearchsuggestoins), object: nil)
            self.perform(#selector(getSearchsuggestoins), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func getSearchsuggestoins()
    {
        self.searchsuggestoins = [TranslatedWord]()
        
        for word in DictionaryManager.sharedManager.aramicWords
        {
            if word.key.hasPrefix(self.searchTextTextField!.text!)
            {
                self.searchsuggestoins?.append(word)
            }
        }
        
        self.setSearchSuggestoinsDisplay()
    }
    
    func setSearchSuggestoinsDisplay()
    {
        self.searchResultsTable?.tag = 1
        
        if self.savedSearches == nil
        {
            self.savedSearches =  UserDefaults.standard.object(forKey: "savedSearchesInfo") as? [[String : String]]
        }
        
        self.setDispalyedSearches()
        self.searchResultsTable?.reloadData()
    }
    
    func setDispalyedSearches()
    {
        self.displyaedSavedSearches = [[String:String]]()
        
        if let searchText = self.searchTextTextField?.text
        {
            if searchText == ""
            {
                self.displyaedSavedSearches = self.savedSearches
            }
            else if self.savedSearches != nil
            {
                for savedSearcheInfo in self.savedSearches!
                {
                    if let saveSearchText = savedSearcheInfo["text"]
                    {
                        if saveSearchText.hasPrefix(searchText)
                        {
                            self.displyaedSavedSearches?.append(savedSearcheInfo)
                        }
                    }
                }
            }
        }
        else{
             self.displyaedSavedSearches = self.savedSearches
        }
    }
}
