//
//  SavedLessonsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SavedLessonsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var lessonsTableView:UITableView?
    @IBOutlet weak var noSavedLessonsMessageLabel:UILabel?
    @IBOutlet weak var deleteButton:UIButton?
    
    var masechtotWithSavedLessons:[Masechet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setMasechtotWithSavedLessons()
        
          self.noSavedLessonsMessageLabel?.text = "st_no_saved_lessons_message_label".localize()
        
         self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setMasechtotWithSavedLessons()
        
        self.reloadData()
    }
    
    override func reloadData()
    {
        if (self.masechtotWithSavedLessons?.count ?? 0) > 0
        {
            self.noSavedLessonsMessageLabel?.isHidden = true
            self.lessonsTableView?.isHidden = false
            self.deleteButton?.alpha = 1.0
            self.deleteButton?.isUserInteractionEnabled = true
            
            self.lessonsTableView?.reloadData()
        }
        else{
            self.noSavedLessonsMessageLabel?.isHidden = false
            self.lessonsTableView?.isHidden = true
            self.deleteButton?.alpha = 0.5
            self.deleteButton?.isUserInteractionEnabled = false
        }
    }
    
    func setMasechtotWithSavedLessons()
    {
        self.masechtotWithSavedLessons = [Masechet]()
        
        if let masechetot = HadafHayomiManager.sharedManager.masechtotWithSavedLessons
        {
            for masechet in masechetot
            {
                masechet.setSavedLessons()
                self.masechtotWithSavedLessons?.append(masechet.copy())
            }
        }
    }
    
    @IBAction func deleteButtonClicked(_ sender:UIButton)
    {
        if self.masechtotWithSavedLessons == nil
        {
            return
        }
        
        var selectedLessons = [Lesson]()
        
        for masecht in self.masechtotWithSavedLessons!
        {
            if let savedLessons = masecht.savedLessons
            {
                for lesson in savedLessons
                {
                    if lesson.isSelected
                    {
                        selectedLessons.append(lesson)
                    }
                }
            }
        }
        
        let alertTitle = "st_delete_lessons_alert_title".localize()
        let alertMessage = String(format: "st_delete_lessons_alert_message".localize(), arguments: ["\(selectedLessons.count)"])
        
        let alertDeleteButtonTitle = "st_delete".localize()
        let alertCancelButtonTitle = "st_cancel".localize()
        BTAlertView.show(title: alertTitle, message: alertMessage, buttonKeys: [alertDeleteButtonTitle,alertCancelButtonTitle], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == alertDeleteButtonTitle
            {
                 self.deleteLessons(selectedLessons)
            }
        })
       
    }
    
    func deleteLessons(_ lessons:[Lesson])
    {
        RemoveLessonProcess().executeWithObject(lessons, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            HadafHayomiManager.sharedManager.setMasechtotWithSavedLessons()
            self.setMasechtotWithSavedLessons()
            
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    // MARK: - TableView Methods:
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.masechtotWithSavedLessons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "MasechetSelectionCell") as! MSBaseTableViewCell
        
        sectionHeader.reloadWithObject(self.masechtotWithSavedLessons![section])
        
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let masechet = self.masechtotWithSavedLessons![section]
        
        return masechet.savedLessons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonSelectionCell", for:indexPath) as! MSBaseTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
         let masechet = self.masechtotWithSavedLessons![indexPath.section]
        let lesson = masechet.savedLessons![indexPath.row]
        
        cell.reloadWithObject(lesson)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }


}
