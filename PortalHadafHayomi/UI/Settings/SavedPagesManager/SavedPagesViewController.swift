//
//  SavedPagesViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 14/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SavedPagesViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var pagesTableView:UITableView?
    @IBOutlet weak var noSavedPagesMessageLabel:UILabel?
    @IBOutlet weak var deleteButton:UIButton?
    
    var masechtotWithSavedPages:[Masechet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setMasechtotWithSavedPages()
        
        self.noSavedPagesMessageLabel?.text = "st_no_saved_pages_message_label".localize()
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
         self.setMasechtotWithSavedPages()
        
        self.reloadData()
    }
    
    override func reloadData()
    {
        if (self.masechtotWithSavedPages?.count ?? 0) > 0
        {
            self.noSavedPagesMessageLabel?.isHidden = true
            self.pagesTableView?.isHidden = false
            self.deleteButton?.alpha = 1.0
            self.deleteButton?.isUserInteractionEnabled = true
            
             self.pagesTableView?.reloadData()
        }
        else{
            self.noSavedPagesMessageLabel?.isHidden = false
            self.pagesTableView?.isHidden = true
            self.deleteButton?.alpha = 0.5
            self.deleteButton?.isUserInteractionEnabled = false
        }
       
    }
    
    func setMasechtotWithSavedPages()
    {
        self.masechtotWithSavedPages = [Masechet]()
        
        let masechetot = HadafHayomiManager.sharedManager.getMessechtotWithSavedPages()
        for masechet in masechetot
        {
            self.masechtotWithSavedPages?.append(masechet.copy())
        }
    }

    @IBAction func deleteButtonClicked(_ sender:UIButton)
    {
        if self.masechtotWithSavedPages == nil
        {
            return
        }
        else{
            
             self.deletePages()
        }
     
    }
    
    func deletePages()
    {
        var selectedPages = [Page]()
        var pagesIndexes = [Int]()
        for maeschet in self.masechtotWithSavedPages!
        {
            let masechetSavedPages = maeschet.savedPages
            for page in masechetSavedPages
            {
                if page.isSelected
                {
                    selectedPages.append(page)
                    
                    print ("maeschet:\(maeschet.name!) page:\(page.symbol!)")
                    
                    if let pageAIndex = HadafHayomiManager.sharedManager.pageIndexFor(maeschet, page: page, pageSide: 0)
                    {
                         pagesIndexes.append(pageAIndex)
                    }
                     if let pageBIndex = HadafHayomiManager.sharedManager.pageIndexFor(maeschet, page: page, pageSide: 1)
                     {
                        pagesIndexes.append(pageBIndex)
                    }
                }
            }
        }
        
        let alertTitle = "st_remove_pages_title".localize()
        let alertMessage = String(format: "st_remove_pages_message".localize(), arguments: [selectedPages.count])
        
        let alertDeleteButtonTitle = "st_delete".localize()
        let alertCancelButtonTitle = "st_cancel".localize()
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertDeleteButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == alertDeleteButtonTitle
            {
                self.runPagesRemovalProcess(pagesIndexes: pagesIndexes)
            }
        })
    }
    
    func runPagesRemovalProcess(pagesIndexes:[Int])
    {
        RemovePageProcess().executeWithObject(pagesIndexes, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.setMasechtotWithSavedPages()
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
            print(error)
        })
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.masechtotWithSavedPages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedMasechtPagesCell", for:indexPath) as! MSBaseTableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.reloadWithObject(self.masechtotWithSavedPages![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
}
