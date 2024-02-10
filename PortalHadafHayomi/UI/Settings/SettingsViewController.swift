//
//  SettingsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 30/01/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController:MSBaseViewController, UITableViewDelegate, UITableViewDataSource, SettableItemCellDelegate
{
    var userSettings:[SetableItem]?
    
    @IBOutlet weak var settingsTableView:UITableView?
    
    class func createWith(settings:[SetableItem]) -> SettingsViewController{
        
        let storyboard = UIStoryboard(name: "SettingsStoryboard", bundle: nil)
        let settingsViewController =  storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsViewController.userSettings = settings
        
        return settingsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(speechActivatoinComplete(_:)), name: NSNotification.Name(rawValue: "SpeechActivatoinComplete"), object: nil)
    }
    
    @objc func speechActivatoinComplete(_ notification: Notification)
    {
        if let speechActivatoin = self.getSetableItemByKey("SpeechActivatoin")
        {
            speechActivatoin.setValue(true)
        }
        self.settingsTableView?.reloadData()
    }
    
    func getSetableItemByKey(_ key:String) -> SetableItem?
    {
        if userSettings != nil
        {
            for  setableItem in self.userSettings!
            {
                if setableItem.key == key
                {
                   return setableItem
                }
            }
        }
        return nil
    }
    
   override func reloadData() {
        
        self.settingsTableView?.reloadData()
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.userSettings?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cellIdentifier = "SettableItemCell"
        
        if let settablItem = self.userSettings?[indexPath.row]
        {
            if settablItem.type == "Bool"
            {
                if settablItem.key == "DailyReminder"
                {
                    cellIdentifier = "SettableItemReminderCell"
                }
                else{
                    cellIdentifier = "SettableItemSwitchCell"
                }
            }
        }
         let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! SettableItemCell
        
        cell.delegate = self
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        
        cell.reloadWithItem(self.userSettings![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let setableItem = self.userSettings![indexPath.row]
        
        if setableItem.key == "SavedPages"
        {
              let savedPagesViewController =  UIViewController.withName("SavedPagesViewController", storyBoardIdentifier: "SettingsStoryboard") as! MSBaseViewController
            
            self.navigationController?.pushViewController(savedPagesViewController, animated: true)
        }
        else if setableItem.key == "SavedLessons"
        {
            let savedLessonsViewController =  UIViewController.withName("SavedLessonsViewController", storyBoardIdentifier: "SettingsStoryboard") as! MSBaseViewController
            
            self.navigationController?.pushViewController(savedLessonsViewController, animated: true)
        }
        else if setableItem.key == "MyPages"
        {
            let savedPagesViewController =  UIViewController.withName("MyPagesViewController", storyBoardIdentifier: "SettingsStoryboard") as! MSBaseViewController
            
            self.navigationController?.pushViewController(savedPagesViewController, animated: true)
        }
        else if setableItem.key == "Donation"
        {
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            
            let donationPageLink = "st_donation_page_link".localize()
            let webPageTitle = "st_Donation".localize()
            
            webViewController.loadUrl(donationPageLink, title: webPageTitle)
            
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //MARK SettableItemCell Delegate methods
     func settableItemCell(_ settableItemCell:SettableItemCell, showItemInfo item:SetableItem)
     {
        if let infoUrlPath = item.infoUrlPath
        {
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            
            webViewController.loadUrl(infoUrlPath, title: "סירי")
            
           self.present(webViewController, animated: true, completion: nil)
        }
    }
    
}
