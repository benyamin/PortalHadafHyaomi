//
//  SearchArticlesViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/12/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class SearchArticlesViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    var searchResultInfo:SearchResultInfo?
    
    var selectedSearchResult:SearchTalmudResult?
    
    var selectedMasechet:Masechet?
    
    weak var loadingView:BTLoadingView?
    
    var searchArticalesProcess:SearchArticalesProcess?
    
    var selectedTextField:UITextField?
    
    var currentResultsPage = 0
    
    var didGetAllResults = false
    
    let selectMasechetDefaultText = "st_all_masechtot".localize()
    let selectPageDefaultText = "st_all".localize()
    
    @IBOutlet weak var searchBoxView:UIView?
    @IBOutlet weak var selectMasechetTextField:UITextField?
    @IBOutlet weak var selectFromPageTextField:UITextField?
    @IBOutlet weak var selectToPageTextField:UITextField?
    @IBOutlet weak var searchTextTextField:UITextField?
    @IBOutlet weak var searchPublisherTextField:UITextField?
    @IBOutlet weak var searchInOptoinsTextField:UITextField?
    @IBOutlet weak var runSearchButton:UIButton?
    @IBOutlet weak var searchResultsTable:UITableView?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var pagePickerBaseView:UIView?
    @IBOutlet weak var pagePickerView:UIPickerView?
    @IBOutlet weak var pagePickerTitleLabel:UILabel?
    @IBOutlet weak var pagePickerSelectButton:UIButton?
    @IBOutlet weak var pagePickerBaseViewBottomConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var matchingSearchCheckBoxButton:UIButton?
    @IBOutlet weak var searchInOptoinsPickerView:UIPickerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBoxView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.searchBoxView?.layer.shadowOpacity = 0.5
        self.searchBoxView?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.searchBoxView?.layer.shadowRadius = 2.0
                
        self.pagePickerBaseView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.pagePickerBaseView?.layer.shadowOpacity = 0.5
        self.pagePickerBaseView?.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.pagePickerBaseView?.layer.shadowRadius = 2.0
        
        self.pagePickerSelectButton?.setTitle(("\("st_hide".localize())"), for: .normal)
        self.pagePickerSelectButton?.layer.borderWidth = 1.0
        self.pagePickerSelectButton?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
        
        self.runSearchButton?.layer.cornerRadius = 3.0
        
        self.hidePagePicker(animated:false)
        
        let checkBoxOff = UIImage.imageWithTintColor(UIImage(named: "Checkbox_off.png")!, color: UIColor(HexColor: "781F24"))
        
        let checkBoxOn = UIImage.imageWithTintColor(UIImage(named: "Checkbox_on.png")!, color: UIColor(HexColor: "781F24"))
        self.matchingSearchCheckBoxButton?.setImage(checkBoxOff, for: .normal)
        self.matchingSearchCheckBoxButton?.setImage(checkBoxOn, for: .selected)
        self.matchingSearchCheckBoxButton?.isSelected = false
        
        self.selectMasechetTextField?.text = selectMasechetDefaultText
        self.selectFromPageTextField?.text = selectPageDefaultText
        self.selectToPageTextField?.text = selectPageDefaultText
        self.searchInOptoinsTextField?.text =  "st_all_categories".localize()
        
        self.searchBoxView?.setLocalizatoin()
        self.runSearchButton?.setTitle("st_search".localize(), for: .normal)
        
        if ArticlesManager.sharedManager.publishers == nil
        {
             self.getPublishers()
        }
       
    }
    
    func getPublishers()
    {
        GetArticlesPublishers().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
           ArticlesManager.sharedManager.publishers = object as? [Publisher]
            
        },onFaile: { (object, error) -> Void in
         
        })
        
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
        self.runNewSearch()
    }
    
    func runNewSearch()
    {
        self.searchTextTextField?.resignFirstResponder()
        self.hidePagePicker(animated: true)
        
        self.searchResultInfo = nil
        self.currentResultsPage = 0
        self.didGetAllResults = false
        
        self.searchResultsTable?.reloadData()
        
        self.loadingView?.removeFromSuperview()
        
        if let loadingView = UIView.viewWithNib("BTLoadingView") as? BTLoadingView
        {
            loadingView.frame = self.searchResultsTable!.frame
            self.loadingView = loadingView
            
            self.view.addSubview(self.loadingView!)
            
        }
        
        self.runSearch()
    }
    
    func getSearchParams() -> [String:String]
    {
        var searchParams = [String:String]()
        
        searchParams["text"] = self.searchTextTextField?.text
        
        if let masechetId = self.selectedMasechet?.id
        {
            searchParams["massechet"] = masechetId
            
            if let seletedFromPageRow = self.pagePickerView?.selectedRow(inComponent: 1)
                ,let seletedToPageRow = self.pagePickerView?.selectedRow(inComponent: 0)
            {
                if seletedFromPageRow == 0
                {
                    searchParams["medaf"] = "1"
                    
                    if let totalPages = self.selectedMasechet?.numberOfPages
                    {
                        searchParams["addaf"] = ("\(totalPages+1)")
                    }
                }
                else{
                    searchParams["medaf"] = ("\(seletedFromPageRow*2 + 1)")
                    
                    //Show all pages
                    if seletedToPageRow == 0
                    {
                        if let totalPages = self.selectedMasechet?.numberOfPages
                        {
                            searchParams["addaf"] = ("\(totalPages+1)")
                        }
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
      
        searchParams["dataPageNumber"] = ("\(self.currentResultsPage+1)")
        
        searchParams["matching"] = (self.matchingSearchCheckBoxButton?.isSelected ?? false) ? "true" : "false"
        
        searchParams["selectedCategoryId"] = "9" //All Categorys
        for category in ArticlesManager.sharedManager.allArticlesCategoryOptions
        {
            let categoryLocalizedTitle = "st_\(category.title!)".localize()
            
            if self.searchInOptoinsTextField?.text == categoryLocalizedTitle
            {
                 searchParams["selectedCategoryId"] = category.id
                break
            }
        }
        
        if let publishers = ArticlesManager.sharedManager.publishers
        {
            for publisher in publishers
            {
                if self.searchPublisherTextField?.text == publisher.name
                {
                    searchParams["selectedPublisherId"] = publisher.id
                    break
                }
            }
        }
        
        searchParams["titleOnly"] = self.matchingSearchCheckBoxButton!.isSelected ? "1" : "0"
        
        return searchParams
    }
    
    func runSearch()
    {
        self.searchArticalesProcess?.cancel()
        
        let searchParams = self.getSearchParams()
        
        self.searchArticalesProcess =  SearchArticalesProcess()
        
        self.searchArticalesProcess?.executeWithObject(searchParams, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.currentResultsPage += 1
            
            self.searchArticalesProcess  = nil
            
            self.loadingView?.removeFromSuperview()
            
            let newSearchResultInfo = object as! SearchResultInfo
            
            if newSearchResultInfo.searchResults.count > 0
            {
                if self.searchResultInfo == nil
                {
                    self.searchResultInfo = object as? SearchResultInfo
                }
                else
                {
                    self.searchResultInfo!.searchResults.append(contentsOf: newSearchResultInfo.searchResults)
                    
                    self.searchResultInfo?.dataPageNumber = newSearchResultInfo.dataPageNumber
                }
            }
            else{
                self.didGetAllResults = true
            }
            
            self.searchResultsTable?.tag = 0 // Dispaly Search resutls
            self.searchResultsTable?.reloadData()
            
            if let searchResultInfo = self.searchResultInfo, searchResultInfo.searchResults.count == 0
            {
                let errorTitle = "st_value_not_found_title".localize()
                let errorMessage = "st_value_not_found_message".localize()
                let okButtonTitle =  "st_ok".localize()
               
                BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [okButtonTitle], onComplete:{ (dismissButtonKey) in
                })
            }
            
        },onFaile: { (object, error) -> Void in
            
            self.searchArticalesProcess  = nil
            
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
        self.searchArticalesProcess?.cancel()
    }
    
    // MARK: - TableView Methods:
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
       return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
      return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let searchResultInfo = self.searchResultInfo, searchResultInfo.searchResults.count > 0
        {
            if self.didGetAllResults == true
            {
                 return searchResultInfo.searchResults.count
            }
            else //Add onle extra cell for the loader
            {
                return searchResultInfo.searchResults.count + 1
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = MSBaseTableViewCell()
        
        //If lastIndex
        if indexPath.row == self.searchResultInfo!.searchResults.count
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "LoadingDataTableCell", for:indexPath) as! MSBaseTableViewCell
            
            cell.reloadData()
        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "SearchArticleResultTableCell", for:indexPath) as! MSBaseTableViewCell
            
            cell.reloadWithObject(self.searchResultInfo!.searchResults[indexPath.row])
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //If last row and should Load more resutls
        if indexPath.row == self.searchResultInfo!.searchResults.count
        {
            self.runSearch()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let searchResult = self.searchResultInfo!.searchResults[indexPath.row]
        
        self.didSelectSeaerchResult(searchResult as! ArticleSearchResult)
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
    
    func didSelectSeaerchResult(_ searchResult:ArticleSearchResult)
    {
          let webView = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                ,rootViewController is Main_IPadViewController
            {
                let mainViewController = rootViewController as! Main_IPadViewController
                
                mainViewController.presentViewController(webView, onContainer: mainViewController.mainContainerView)
            }
        }
        else{
            self.navigationController?.pushViewController(webView, animated: true)
        }
        
        if let articleLink = searchResult.articleUrlPath
        {
            webView.loadUrl(articleLink, title: searchResult.articleTitle ?? "")
        }
      
    }
    
    func showPageForSearchResult(_ searchResult:Any)
    {
        self.selectedSearchResult = searchResult as? SearchTalmudResult
        
        if let link = self.selectedSearchResult?.link
        {
            let mobileLink = "http://daf-yomi.com/" + link + "&mobile=1"
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
        
        self.selectedTextField = textField
        
        if textField == self.selectMasechetTextField
            || textField == self.selectFromPageTextField
            || textField == self.selectToPageTextField
        {
            self.searchTextTextField?.resignFirstResponder()
            
            self.showPicker(self.pagePickerView!, animated:true)
            
            return false
        }
        else if textField == self.searchInOptoinsTextField
            || textField == self.searchPublisherTextField
        {
            self.searchTextTextField?.resignFirstResponder()
            
            self.searchInOptoinsPickerView?.reloadAllComponents()
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
        
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
        
    }
    
    
    func hidePagePicker(animated:Bool)
    {
        self.pagePickerBaseViewBottomConstraint?.constant = -1*(self.pagePickerBaseView!.frame.size.height)
        
        self.tableViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
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
            if self.selectedTextField === self.searchInOptoinsTextField
            {
                 return ArticlesManager.sharedManager.allArticlesCategoryOptions.count + 1
            }
            else if self.selectedTextField === self.searchPublisherTextField
            {
                return ArticlesManager.sharedManager.publishers?.count ?? 0
            }
            else{
                return 0
            }
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
            if self.selectedTextField === self.searchInOptoinsTextField
            {
                if row == 0
                {
                     pikerLabel.text =  "st_all_categories".localize()
                }
                else{
                    let category = ArticlesManager.sharedManager.allArticlesCategoryOptions[row-1]
                    pikerLabel.text = "st_\(category.title!)".localize()
                }
            }
            else if self.selectedTextField === self.searchPublisherTextField
            {
                let publisher = ArticlesManager.sharedManager.publishers![row]
                pikerLabel.text = publisher.name
            }
            else{
                pikerLabel.text = ""
            }
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
            if self.selectedTextField === self.searchInOptoinsTextField
            {
                if row == 0
                {
                    self.searchInOptoinsTextField?.text = "st_all_categories".localize()
                }
                else{
                    let category = ArticlesManager.sharedManager.allArticlesCategoryOptions[row-1]
                    self.searchInOptoinsTextField?.text = "st_\(category.title!)".localize()
                }
            }
            else if self.selectedTextField === self.searchPublisherTextField
            {
                let publisher = ArticlesManager.sharedManager.publishers![row]
                self.searchPublisherTextField?.text = publisher.name
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
    }

}
