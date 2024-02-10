//
//  FourmDiscussoinViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/09/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class FourmDiscussoinViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, FourmDiscussionTableCellDelegate
{
    var discussion:ForumPost?
    var updateDiscussionWork:DispatchWorkItem?
        
    @IBOutlet weak var discussionTableView:UITableView?
    @IBOutlet weak var fourmUserInfoView:FourmUserInfoView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let numberOfChildren = self.discussion?.children, numberOfChildren > 0
             , self.discussion?.discussions == nil
        {
            self.getDiscussionDetials(discussion: self.discussion!)
        }
        else{
            self.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.updateDiscussionWork?.cancel()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.discussion = object as? ForumPost
    }
    
    func getDiscussionDetials(discussion:ForumPost, showLoadingView:Bool = true)
    {
        if showLoadingView {
            Util.showLoadingViewOnView(self.discussionTableView!)
        }
        
        GetForumDiscussionProcess().executeWithObject(discussion, onStart: { () -> Void in
            
        }, onComplete: { [self] (object) -> Void in
            
            discussion.discussions = object as? [ForumPost]
            
            self.reloadData()
            
            //Update discussion every 10 seconds
            self.updateDiscussionWork = DispatchWorkItem(block: {
                self.getDiscussionDetials(discussion: discussion, showLoadingView: false)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: self.updateDiscussionWork!)
            
        },onFaile: { (object, error) -> Void in
            
            self.reloadData()
        })
    }
    
    override func reloadData()
    {
        self.discussionTableView?.reloadData()
        
        Util.removeLoadingViewFromView(self.discussionTableView!)
    }
    
    func showDiscussionView(discussion:ForumPost)
    {
        let fourmDiscussoinViewController = UIViewController.withName("FourmDiscussoinViewController", storyBoardIdentifier: "ForumsStoryBoard") as! MSBaseViewController
        
        fourmDiscussoinViewController.reloadWithObject(discussion)
        
        self.navigationController?.pushViewController(fourmDiscussoinViewController, animated: true)
    }
    
    @IBAction func addMessageButtonClicked(_ sender:UIButton)
      {
        if HadafHayomiManager.sharedManager.logedInUser != nil{
            
            let forumAddMessageViewController = UIViewController.withName("ForumAddMessageViewController", storyBoardIdentifier: "ForumsStoryBoard") as! ForumAddMessageViewController
            
            if let discussion = self.discussion {
                forumAddMessageViewController.reloadWithObject(discussion)
            }
            
            forumAddMessageViewController.onMessageAdded = {(messageId) in
                
                BTAlertView.show(title: "st_fourm_did_add_message".localize(), message: "", buttonKeys: ["st_continue".localiz()], onComplete:{ (dismissButtonKey) in
                    
                    self.getDiscussionDetials(discussion: self.discussion!)
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
    
    @IBAction func refreshButtonClicked(_ sender:UIButton)
    {
        self.getDiscussionDetials(discussion: self.discussion!)
    }
    
    // MARK: - TableView Methods:
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0: //Main Post
            return 1
            
        case 1: //Post comments
           return self.discussion?.discussions?.count ?? 0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FourmDiscussionTableCell", for:indexPath) as! FourmDiscussionTableCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        switch indexPath.section {
        case 0: //Main Post
            cell.reloadWithObject(self.discussion!)
            cell.setMainLayout()
            break
            
        case 1: //Post comments
             cell.reloadWithObject(self.discussion!.discussions![indexPath.row])
             cell.delegate = self
             
             cell.setDefaultLahyout()
          
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //MARK: - FourmDiscussionTableCell delegate methods
    func fourmDiscussionTableCell(_ fourmDiscussionTableCell:FourmDiscussionTableCell, showFullDiscussion discussion:ForumPost)
    {
        self.showDiscussionView(discussion: discussion)
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
        
        webViewController.loadUrl(url.absoluteString, title: self.topBarTitleLabel?.text)
    }
}
