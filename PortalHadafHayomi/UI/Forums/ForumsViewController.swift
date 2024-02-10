//
//  ForumsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 08/09/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class ForumsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, FourmDiscussionTableCellDelegate, WKNavigationDelegate
{
    var discussions:[ForumPost]?
    
    var currentDiscussionsPage = 0
    
    var sholdLoadMoreDiscussions = false
    
    var selectedDiscussionsId = "1"
    
    var getForumPostsProcess:GetForumPostsProcess?
    
    @IBOutlet weak var discussionsTableView:UITableView?
    
    @IBOutlet weak var searchFourmLabel:UILabel?
    @IBOutlet weak var searchBaseView:UIView?
    @IBOutlet weak var searchTextField:UITextField?
    @IBOutlet weak var searchButton:UIButton?
    
    @IBOutlet weak var fourmUserInfoView:FourmUserInfoView?
    
    @IBOutlet weak var sortBySegmentedController:UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchButton?.layer.cornerRadius = 3.0
        
        self.searchFourmLabel?.text = "st_search_fourm".localize()
        self.searchButton?.setTitle("st_search".localize(), for: .normal)
        
        self.sortBySegmentedController.setTitle("st_fourm_sort_by_last_comment".localize(), forSegmentAt: 0)
        self.sortBySegmentedController.setTitle("st_fourm_sort_by_last_message".localize(), forSegmentAt: 1)
        
        if HadafHayomiManager.sharedManager.logedInUser == nil
            , let userInfo = UserDefaults.standard.object(forKey:"loginUserData") as? [String:Any] {
            
            self.runSilegntLoginWithInfo(userInfo)
        }
        else{
             self.revokeDiscussions()
             self.updateUI()
        }
        
        self.sortBySegmentedController.selectedSegmentIndex = 0 //Sort by last comment
    }
    
    func runSilegntLoginWithInfo(_ userInfo:[String:Any]) {
        LoginProcess().executeWithObject(userInfo, onStart: { () -> Void in
            
             Util.showLoadingViewOnView(self.discussionsTableView!)
            
        }, onComplete: { (object) -> Void in
            
            Util.hideDefaultLoadingView()
            
            HadafHayomiManager.sharedManager.logedInUser = object as? User
            
            self.revokeDiscussions()
            self.updateUI()
            
        },onFaile: { (object, error) -> Void in
            Util.hideDefaultLoadingView()
            
            self.revokeDiscussions()
            self.updateUI()
        })
    }
    
    func updateUI() {
        
        self.fourmUserInfoView?.updateUI()
    }
    
    @IBAction func addMessageButtonClicked(_ sender:UIButton)
    {
        if HadafHayomiManager.sharedManager.logedInUser != nil{
            
            let forumAddMessageViewController = UIViewController.withName("ForumAddMessageViewController", storyBoardIdentifier: "ForumsStoryBoard") as! ForumAddMessageViewController
            
            forumAddMessageViewController.onMessageAdded = {(messageId) in
                
                BTAlertView.show(title: "st_fourm_did_add_message".localize(), message: "", buttonKeys: ["st_continue".localiz()], onComplete:{ (dismissButtonKey) in
                    
                    self.revokeDiscussions()
                })
                
            }
            self.navigationController?.pushViewController(forumAddMessageViewController, animated: true)
        }
        else {
            
            let alertTitle = "st_fourm_login_required_title".localize()
            let alertMessage = "st_fourm_login_required_message".localize()
            let loginButton = "st_signin".localize()
            BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: ["st_cancel".localize(),loginButton], onComplete:{ (dismissButtonKey) in
                
                if dismissButtonKey == loginButton
                {
                    self.fourmUserInfoView?.login()
                }
            })
        }
    }
   
    @IBAction func searchButtonClicked(_ sender:UIButton)
    {
        self.revokeDiscussions()
        self.searchTextField?.resignFirstResponder()
    }
    
    @IBAction func refreshButtonClicked(_ sender:UIButton)
    {
        Util.showLoadingViewOnView(self.discussionsTableView!)
        self.getDiscussions()
    }
    
    @IBAction func sortBySegmentedControllerValueChanged(_ sedner:AnyObject){
        self.getDiscussions()
    }
    
    func revokeDiscussions()
    {
        self.discussions = nil
        self.discussionsTableView?.reloadData()
        
        self.currentDiscussionsPage = 0
        
        self.getDiscussions()
    }

    func getDiscussions()
    {
        self.getForumPostsProcess?.cancel()
        self.getForumPostsProcess = nil
        
        if self.discussions == nil || self.discussions!.count == 0
        {
            if discussionsTableView != nil
            {
                Util.showLoadingViewOnView(self.discussionsTableView!)
            }
        }
        
        let numberOfResults = 20
        
        self.currentDiscussionsPage += 1
        
        var params = [String:String]()
        
        params["page"] = ("\(self.currentDiscussionsPage)")
        params["pagesize"] = ("\(numberOfResults)")
        
        params["forumid"] = self.selectedDiscussionsId

        params["chofshi"] = self.searchTextField?.text ?? ""
        
        params["order"] = self.sortBySegmentedController.selectedSegmentIndex == 0 ? "1" : "0"
        
        self.getForumPostsProcess = GetForumPostsProcess()
        
        getForumPostsProcess?.executeWithObject(params, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.getForumPostsProcess = nil
            
            Util.removeLoadingViewFromView(self.discussionsTableView!)
            
            if self.discussions == nil
            {
                self.discussions = [ForumPost]()
            }
            
            let newDiscussions = object as! [ForumPost]
            
            self.discussions?.append(contentsOf:newDiscussions)
            
            if self.discussions == nil || self.discussions?.count == 0
            {
                var alertMessage = "st_search_no_results_message".localize()
                alertMessage += "\n" + "st_try_agin_later".localize()
                
               self.setNoAvalibleDiscussionsFound(alertTitle: "", alertMessage:alertMessage)
                return
            }
            
            //If the number of the discussions recived are same as the numberOfResults required, this indicates that thare are more discussions to request
            if newDiscussions.count == numberOfResults
            {
                self.sholdLoadMoreDiscussions = true
            }
            else{
                self.sholdLoadMoreDiscussions = false
            }
            
            
            self.discussionsTableView?.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
             Util.removeLoadingViewFromView(self.discussionsTableView!)
            
             self.getForumPostsProcess = nil
            
            if error.localizedDescription == "cancelled"
            {
                self.getDiscussions()
                return
            }
            //If request for fourm discussion failed
            if self.discussions == nil || self.discussions?.count == 0
            {
                let errorTitle = "st_error".localize()
                let errorMessage = "st_general_system_error".localize()
                 self.setNoAvalibleDiscussionsFound(alertTitle: errorTitle, alertMessage:errorMessage)
            }
        })
    }
        
    func showDiscussionView(discussion:ForumPost)
    {
        let fourmDiscussoinViewController = UIViewController.withName("FourmDiscussoinViewController", storyBoardIdentifier: "ForumsStoryBoard") as! MSBaseViewController
        
        fourmDiscussoinViewController.reloadWithObject(discussion)
        
        self.navigationController?.pushViewController(fourmDiscussoinViewController, animated: true)
    }
    
    func setNoAvalibleDiscussionsFound(alertTitle:String, alertMessage:String)
    {
        Util.hideDefaultLoadingView()
        
        self.discussions = nil
        self.discussionsTableView?.reloadData()
        
        let alertTryAgionButtonTitle = "st_try_again".localize()
        let alertCancelButtonTitle = "st_cancel".localize()
        
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertTryAgionButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == alertTryAgionButtonTitle
            {
                 self.getDiscussions()
            }
        })
        
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRows = 0
        if self.discussions != nil
        {
            numberOfRows = self.discussions!.count
            
            if sholdLoadMoreDiscussions
            {
                numberOfRows += 1
            }
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // If show show loading view for last row
        if indexPath.row == self.discussions?.count
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingDataTableCell", for:indexPath) as! MSBaseTableViewCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.reloadData()
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FourmDiscussionTableCell", for:indexPath) as! FourmDiscussionTableCell
            
            cell.reloadWithObject(self.discussions![indexPath.row])
            cell.delegate = self
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDiscussion = self.discussions![indexPath.row]
        self.showDiscussionView(discussion: selectedDiscussion)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //If last row
        if indexPath.row == self.discussions?.count
        {
            self.getDiscussions()
        }
    }
    
    
    //MARK: - FourmDiscussionTableCell delegate methods
     func fourmDiscussionTableCell(_ fourmDiscussionTableCell:FourmDiscussionTableCell, showFullDiscussion discussion:ForumPost)
     {
        let selectedDiscussion = discussion
        
        self.showDiscussionView(discussion: selectedDiscussion)
    }
    
    func fourmDiscussionTableCell(_ fourmDiscussionTableCell:FourmDiscussionTableCell, shouldStartLoadURL url:URL)
    {
        let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                ,rootViewController is Main_IPadViewController
            {
                let mainViewController = rootViewController as! Main_IPadViewController
                
                mainViewController.presentViewController(webViewController, onContainer: mainViewController.mainContainerView)
            }
        }
        else{
            self.navigationController?.pushViewController(webViewController, animated: true)
            
        }
        
        webViewController.loadUrl(url.absoluteString, title: "st_forum".localize())
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        /*
        let js = ("document.getElementsByClassName(\"clsMainTable\")[0].setAttribute('style',\"width:100%\");document.getElementsByClassName(\"clsContainer\")[0].setAttribute('style',\"width:auto\");document.getElementsByClassName(\"clsContentText\")[0].setAttribute('style',\"max-width:none;width:100%\");")
        
        webView.evaluateJavaScript(js) { (result, error) in
            if error != nil {
            }
        }
 */
        /*
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.containerHeight.constant = height as! CGFloat
                })
            }
            
        })
 */
    }
}
