//
//  QuastionsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 27/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class QuastionsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate
{
    var topic:HadafHayomiProjectTopic?
    
    var allExpressions:[Expression]?
    var displayedExpressions = [Expression]()
    
    @IBOutlet weak var loadingMessageLabel:UILabel!
    @IBOutlet weak var QandATableView:UITableView!
    @IBOutlet weak var tableViewBottomConstrains:NSLayoutConstraint!
    
    lazy var webViewController:BTWebViewController = {
        
        let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        return webViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingMessageLabel?.text = "st_system_loading_messgae".localize()
        
        self.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setLoadingLayout()
    {
        if self.QandATableView != nil
        {
            self.loadingMessageLabel.isHidden = false
            self.QandATableView.isHidden = true
            self.topBarTitleLabel?.text = ""
        }
    }
    
    override func reloadWithObject(_ object: Any)
    {
        if object is HadafHayomiProjectTopic
        {
            self.topic = object as? HadafHayomiProjectTopic
            self.reloadData()
        }
        else{
            self.allExpressions = object as? [Expression]
            
            self.displayedExpressions = self.allExpressions ?? [Expression]()
            
            if QandATableView != nil
            {
                self.loadingMessageLabel.isHidden = true
                self.QandATableView.isHidden = false
                
                QandATableView.reloadData()
                
            }
        }
    }
    
    override func reloadData() {
        self.topBarTitleLabel?.text = self.topic?.title
    }
    
    
    //MARK: - Keyboard notifications
    @objc override func keyboardWillAppear(_ notification: Notification)
    {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.tableViewBottomConstrains.constant = keyboardSize.height
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
                {
                    self.view.setNeedsLayout()
                    
            }, completion: {_ in
            })
            
        }
    }
    
    @objc override func keyboardWillDisappear(_ notification: Notification)
    {
        self.tableViewBottomConstrains.constant = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuastionTopicTableCell", for:indexPath) as! QuastionTopicTableCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.reloadWithObject(self.displayedExpressions[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedQustionTopic = self.displayedExpressions[indexPath.row]
        
        let qandADetailsViewController = UIViewController.withName("QandADetailsViewController", storyBoardIdentifier: "QandAStoryboard") as! MSBaseViewController
        
        if let mainTopic = self.topBarTitleLabel?.text
        {
             qandADetailsViewController.reloadWithObject(mainTopic)
        }
       
        qandADetailsViewController.reloadWithObject(selectedQustionTopic)
        
        self.navigationController?.pushViewController(qandADetailsViewController, animated: true)
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
            self.displayedExpressions = self.allExpressions ?? [Expression]()
            self.QandATableView.reloadData()
            return
        }
        var filterdExpressoins = [Expression]()
        
        var searchTextWithOutGershim = searchText.replacingOccurrences(of: "\"", with: "")
        searchTextWithOutGershim = searchText.replacingOccurrences(of: "״", with: "")
        searchTextWithOutGershim = searchText.replacingOccurrences(of: "”", with: "")
        
        
        for expressoin in self.allExpressions!
        {
            var expressoinKey = "\(expressoin.key!)"
            expressoinKey = expressoinKey.replacingOccurrences(of: "\"", with: "")
            
            if expressoinKey.contains(searchTextWithOutGershim)
                || expressoin.value.contains(searchTextWithOutGershim)
            {
                filterdExpressoins.append(expressoin)
            }
        }
        
        self.displayedExpressions = filterdExpressoins
        self.QandATableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        self.displayedExpressions = self.allExpressions ?? [Expression]()
        self.QandATableView.reloadData()
    }
}


