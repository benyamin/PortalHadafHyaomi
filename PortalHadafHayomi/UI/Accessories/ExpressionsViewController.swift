//
//  ExpressionsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 28/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ExpressionsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate, ExpressionsTableCellDelegate
{
    var accessory:Accessory?
    var displayedExpressions = [Expression]()
    
    @IBOutlet weak var topBarSubTitleLabel:UILabel!
    @IBOutlet weak var loadingMessageLabel:UILabel!
    @IBOutlet weak var expressionsTableView:UITableView!
    @IBOutlet weak var tableViewBottomConstrains:NSLayoutConstraint!
    @IBOutlet weak var searchBar:UISearchBar!
    
    lazy var webViewController:BTWebViewController = {
       
        let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        return webViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.accessory != nil
        {
            self.topBarTitleLabel?.text = self.accessory!.title.localize()

            self.setTopBarSubTitle()
        }
        else{
             self.topBarTitleLabel?.text = ""
        }
        
          self.loadingMessageLabel?.text = "st_system_loading_messgae".localize()
        
        self.searchBar.layer.borderWidth = 1.0
        self.searchBar.layer.borderColor = UIColor(HexColor:"791F23").cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove the accessory expresoins to clear cash space
        self.accessory?.expressions = nil
    }
    
    func setLoadingLayout()
    {
        if self.expressionsTableView != nil
        {
            self.loadingMessageLabel.isHidden = false
            self.expressionsTableView.isHidden = true
        }
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.accessory = object as? Accessory
        
        self.displayedExpressions = (self.accessory?.expressions)!
        
        if expressionsTableView != nil
        {
            self.loadingMessageLabel.isHidden = true
            self.expressionsTableView.isHidden = false
           
            expressionsTableView.reloadData()
            self.topBarTitleLabel?.text = self.accessory!.title.localize()
            
           self.setTopBarSubTitle()
        }
    }
    
    func setTopBarSubTitle()
    {
        self.topBarSubTitleLabel.isHidden = true
        
        //עבור אוצר לעזי רשי הצג קרדיט
        if self.accessory?.id == "LR"
        {
            self.topBarSubTitleLabel.isHidden = false
            self.topBarSubTitleLabel.text = "by_moshe_katan".localize()
        }
    }
    
    //MARK: - Keyboard notifications
    @objc override func keyboardWillAppear(_ notification: Notification)
    {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.tableViewBottomConstrains.constant = keyboardSize.height
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    self.view.setNeedsLayout()
                    
            }, completion: {_ in
            })
            
        }
    }
    
    @objc override func keyboardWillDisappear(_ notification: Notification)
    {
        self.tableViewBottomConstrains.constant = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.setNeedsLayout()
                
        }, completion: {_ in
        })
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.displayedExpressions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpressionsTableCell", for:indexPath) as! ExpressionsTableCell
        cell.delegate = self
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.reloadWithObject(self.displayedExpressions[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    //Mark: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
        searchBar.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            self.displayedExpressions = (self.accessory?.expressions)!
            self.expressionsTableView.reloadData()
            return
        }
        var filterdExpressoins = [Expression]()
        
        var searchTextWithOutGershim = searchText.replacingOccurrences(of: "\"", with: "")
        searchTextWithOutGershim = searchText.replacingOccurrences(of: "״", with: "")
        searchTextWithOutGershim = searchText.replacingOccurrences(of: "”", with: "")
        
        
        for expressoin in (self.accessory?.expressions)!
        {
            var expressoinKey = "\(expressoin.key!)"
            expressoinKey = expressoinKey.replacingOccurrences(of: "\"", with: "")
            
            if expressoinKey.contains(searchTextWithOutGershim)
            {
                 filterdExpressoins.append(expressoin)
            }
        }
        
        self.displayedExpressions = filterdExpressoins
        self.expressionsTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        self.displayedExpressions = self.accessory?.expressions ?? [Expression]()
        self.expressionsTableView.reloadData()
    }
    
    //MARK ExpressionsWebTableCell Delegate methods
    func expressionsTableCell(_ expressionsTableCell:ExpressionsTableCell, shouldStartLoadURL url:URL)
    {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                ,rootViewController is Main_IPadViewController
            {
                let mainViewController = rootViewController as! Main_IPadViewController
                
                mainViewController.presentViewController(self.webViewController, onContainer: mainViewController.mainContainerView)
            }
        }
        else{
            self.navigationController?.pushViewController(self.webViewController, animated: true)

        }
        
        self.webViewController.loadUrl(url.absoluteString, title: self.topBarTitleLabel?.text)
    }
}
