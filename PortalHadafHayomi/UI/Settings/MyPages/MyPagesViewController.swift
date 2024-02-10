//
//  MyPagesViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 22 Adar I 5779.
//  Copyright © 5779 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MyPagesViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, PageSelectingCellDelegate
{
    @IBOutlet weak var displaySegmentedControl:UISegmentedControl?
    @IBOutlet weak var pagesTableView:UITableView?
    
    lazy var masechtotInfo:[(maschet:Masechet, displayPages:Bool)] = {
       
        var info = [(maschet:Masechet, displayPages:Bool)]()
        
        //Initial all maschtot with out displaying pages
        for masechet in  HadafHayomiManager.sharedManager.masechtot{
            info.append((maschet: masechet, displayPages: false))
        }
        return info
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.displaySegmentedControl?.setTitle("st_all_pages".localize(), forSegmentAt: 2)
         self.displaySegmentedControl?.setTitle("st_pages_learned".localize(), forSegmentAt: 1)
         self.displaySegmentedControl?.setTitle("st_pages_with_comments".localize(), forSegmentAt: 0)
        
        self.displaySegmentedControl?.selectedSegmentIndex = 2
        
        
        
        self.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func reloadData() {
    }
    
    @IBAction func displaySegmentedControlValueChanged(_ sedner:AnyObject)
    {
        self.reloadData()
    }
    
    // MARK: - TableView Methods:
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return self.masechtotInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "MasechetTableHeaderCell") as! MasechetTableHeaderCell
        
        let masechet = self.masechtotInfo[section].maschet
        sectionHeader.reloadWithObject(masechet)
        sectionHeader.onToggleButtonClicked = {
            self.masechtotInfo[section].displayPages = !self.masechtotInfo[section].displayPages
            for cell in tableView.visibleCells{
                if let indexPath = tableView.indexPath(for: cell)
                    ,indexPath.section == section {
                    tableView.beginUpdates()
                    (cell as! MasechtPagesCell).displayPages = self.masechtotInfo[section].displayPages
                    (cell as! MasechtPagesCell).updateDisplay()
                    tableView.endUpdates()
                    return
                }
            }
        }
        
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let masechet = self.masechtotInfo[section].maschet
        masechet.updatePagesWithNotes()
        masechet.updateMarkedPages()
        
       return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasechtPagesCell", for:indexPath) as! MasechtPagesCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.pageSelectingCellDelegate = self
        
        let masechetInfo = self.masechtotInfo[indexPath.section]
        cell.displayPages = masechetInfo.displayPages
        cell.reloadWithObject(masechetInfo.maschet)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //MARK: - PageSelectingCellDelegate
    
    func pageSelectingCell(_ pageSelectingCell:PageSelectingCell, didSelectNoteOnPage page:Page)
    {
        if page.note != nil
        {
            let noteViewController =  UIViewController.withName("NoteViewController", storyBoardIdentifier: "TalmudStoryboard") as! MSBaseViewController
            
            noteViewController.reloadWithObject(page.note!)
            self.navigationController?.pushViewController(noteViewController, animated: true)
        }
    }
}
