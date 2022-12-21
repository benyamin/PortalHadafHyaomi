//
//  FindChavrusaViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/08/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class FindChavrusaViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, ChavrusaInfoTableCellDelegate, BTTablePopUpViewDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var chavrusasTableView:UITableView?
    
    @IBOutlet weak var regionTextField:UITextField?
    @IBOutlet weak var cityTextField:UITextField?
    @IBOutlet weak var freeTextTextField:UITextField?
    @IBOutlet weak var searchButton:UIButton?
    
    var chavrusas:[Chavrusa]?
    
    var sholdLoadMoreChavrusas = true
    
    var currentChavrusasPage = 0
    
    var regions = [Region](){
        
        didSet{
            
            if regions.count > 0
            {
               self.selectedRegion = self.regions.first
            }
        }
    }
    
    var selectedRegion:Region?
    {
        didSet{
            
            self.regionTextField?.text = self.selectedRegion?.sRegionName
            
            if let cities = self.selectedRegion?.cities, cities.count > 0
            {
                self.selectedCity = nil
                
                self.cityTextField?.text =  "st_all_locations".localize()
            }
        }
    }
    
    var selectedCity:City?{
        
        didSet{
             if selectedCity == nil
             {
                 self.cityTextField?.text =  "st_all_locations".localize()
            }
             else{
                 self.cityTextField?.text = selectedCity?.sCityName
            }
        }
    }
    
    var popupview:BTPopUpView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setLocalizatoin()
        
        self.searchButton?.setTitle("st_search".localize(), for: .normal)
        
        searchButton?.layer.cornerRadius = 3.0
        
        self.topBarTitleLabel?.text = "st_find_chavrusa".localize()
        
        self.getRegions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.getChavrusas()
    }
    
    @IBAction func searchButtonClicked()
    {
        Util.showDefaultLoadingView()
        
        self.chavrusas = nil
        self.chavrusasTableView?.reloadData()
        
        self.currentChavrusasPage = 0
        
        self.freeTextTextField?.resignFirstResponder()

        self.getChavrusas()
    }
    
    func getChavrusas()
    {
        let numberOfResults = 10
        
        self.currentChavrusasPage += 1
        
        var params = [String:String]()
       
        params["page"] = ("\(self.currentChavrusasPage)")
        params["pagesize"] = ("\(numberOfResults)")
        
        if let id = self.selectedRegion?.ID, id != -1 // -1 = כל האזורים
        {
            params["ezor"] = ("\(id)")
        }
        else{
            params["ezor"] = ""
        }
        
        if let id = self.selectedCity?.ID
        {
            params["city"] = ("\(id)")
        }
        else{
            params["city"] = ""
        }
        
        params["chofshi"] = self.freeTextTextField?.text ?? ""
        
        GetChavrusasProcess().executeWithObject(params, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            
            if self.chavrusas == nil
            {
                self.chavrusas = [Chavrusa]()
            }
            
            let newChavrusas = object as! [Chavrusa]
            self.chavrusas?.append(contentsOf:newChavrusas)
            
            if self.chavrusas?.count == 0
            {
                 self.setNoAvalibleChavrusalayout()
                return
            }
            
            //If the number of the chavrusas recived are same as the numberOfResults required, this indicates that thare are more chavrusts to request
            if newChavrusas.count == numberOfResults
            {
                self.sholdLoadMoreChavrusas = true
            }
            else{
                self.sholdLoadMoreChavrusas = false
            }
            
            self.chavrusasTableView?.reloadData()
            
            Util.hideDefaultLoadingView()

            
        },onFaile: { (object, error) -> Void in
            
            //If request for perst page chavrusas failed
            if self.chavrusas?.count == 0
            {
                self.setNoAvalibleChavrusalayout()
            }
        })
    }
    
    func setNoAvalibleChavrusalayout()
    {
         Util.hideDefaultLoadingView()
        
        self.chavrusas = nil
        self.chavrusasTableView?.reloadData()
        
        let alertTitle = "st_error".localize()
        let alertMessage = "st_search_no_results_message".localize()
        
        let alertTryAgionButtonTitle = "st_try_again".localize()
        let alertCancelButtonTitle = "st_return_to_search_page".localize()
        
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertTryAgionButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == alertTryAgionButtonTitle
            {
                self.searchButtonClicked()
            }
        })
        
    }
    
    func getRegions()
    {
        if let regions = HadafHayomiManager.sharedManager.regions
            , regions.count > 0
        {
            self.regions =  regions
            
            return
        }
        
        Util.showDefaultLoadingView()
        
        GetRegionsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            Util.hideDefaultLoadingView()
            
            HadafHayomiManager.sharedManager.regions = object as? [Region]
            
            self.regions =  HadafHayomiManager.sharedManager.regions!
            
            self.getChavrusas()
            
        },onFaile: { (object, error) -> Void in
            
            Util.hideDefaultLoadingView()
            
            let alertTitle = ""
            let alertMessage = "st_loading_data_error".localize()
            let alertTryAgionButtonTitle = "st_try_again".localize()
            let alertCancelButtonTitle = "st_return_to_previous_page".localize()
            
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertTryAgionButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
                
                if dismissButtonKey == alertTryAgionButtonTitle
                {
                    self.getRegions()
                }
                else if dismissButtonKey == alertCancelButtonTitle
                {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
        })
    }
    
    //Mark TextField Delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == self.regionTextField
        {
            self.showRegionOptions()
            
            return false
        }
        else if textField == self.cityTextField
        {
            self.showCitiesOptions()
            
            return false
        }
        
        return true
    }
    
    
    func showRegionOptions()
    {
        self.resignFirstResponder()
        
        let tablePopUpView = UIView.loadFromNibNamed("BTTablePopUpView") as! BTTablePopUpView
        tablePopUpView.delegate = self
        
        tablePopUpView.identifier = "regions"
        
        var regionNames = [String]()
        for region in self.regions
        {
            regionNames.append(region.sRegionName)
        }
        
        let selectedOption = self.selectedRegion?.sRegionName ?? regionNames.first!
        
        let popupTitle = "st_select_country".localize()
        tablePopUpView.reloadWithOptions(regionNames, title:popupTitle, selectedOption: selectedOption)
        
        self.popupview = BTPopUpView.show(view: tablePopUpView, onComplete:{ })
    }
    
    func showCitiesOptions()
    {
        self.resignFirstResponder()
        
        
        if let selectedRegion = self.selectedRegion
        {
            let tablePopUpView = UIView.loadFromNibNamed("BTTablePopUpView") as! BTTablePopUpView
            tablePopUpView.delegate = self
            
            tablePopUpView.identifier = "cities"
            
            var cityNames = [String]()
            
            cityNames.append("st_all_locations".localize())
            
            for city in selectedRegion.cities
            {
                cityNames.append(city.sCityName)
            }
            
            let selectedOption = self.selectedCity?.sCityName ?? cityNames.first!
            
            let popupTitle = "st_select_city".localize()
            tablePopUpView.reloadWithOptions(cityNames, title:popupTitle, selectedOption: selectedOption)
            
            self.popupview = BTPopUpView.show(view: tablePopUpView, onComplete:{ })
        }
    }
    
    //MARK: BTTablePopUpView delegate methods
    func tablePopUpView(_ tablePopUpView: BTTablePopUpView, didSelectOption option: String!)
    {
        if tablePopUpView.identifier == "regions"
        {
            for region in self.regions
            {
                if region.sRegionName == option
                {
                    self.selectedRegion = region
                    
                    break
                }
            }
        }
        else if tablePopUpView.identifier == "cities"
        {
            self.selectedCity = nil
            
            for city in self.selectedRegion!.cities
            {
                if city.sCityName == option
                {
                    self.selectedCity = city
                    
                    break
                }
            }
        }
        
        self.popupview?.dismiss()
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRows = 0
        if self.chavrusas != nil
        {
            numberOfRows = self.chavrusas!.count
            
            if sholdLoadMoreChavrusas
            {
                numberOfRows += 1
            }
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // If show show loading view for last row
        if indexPath.row == self.chavrusas?.count
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingDataTableCell", for:indexPath) as! MSBaseTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.reloadData()
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChavrusaInfoTableCell", for:indexPath) as! ChavrusaInfoTableCell
            
            cell.reloadWithObject(self.chavrusas![indexPath.row])
            
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //If last row
        if indexPath.row == self.chavrusas!.count
        {
           self.getChavrusas()
        }
    }
    
    // MARK ChavrusaInfoTableCell Delegate methods
    
    func chavrusaInfoTableCell(_ chavrusaInfoTableCell:ChavrusaInfoTableCell, onContactChavrusa chavrusa:Chavrusa?)
    {
        if let chavrusaId = chavrusa?.Id
        {
            let contactUrl = ("https://daf-yomi.com/ContactBoard.aspx?id=\(chavrusaId)")
            
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            webViewController.scalesPageToFit = false
            
            webViewController.loadUrl(contactUrl, title: "st_find_chavrusa".localize())
            webViewController.shareButtonDisabled = true
            
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    @IBAction func addNewChahvortaRequestButtonClicked(_ sender:UIButton) {
        
        let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        webViewController.shareButtonDisabled = true
        
        let title = "st_chavrusa".localize()
        webViewController.loadUrl("https://daf-yomi.com/BoardAdd.aspx", title: title)
        
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
}
