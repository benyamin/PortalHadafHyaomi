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
    
    var masechtot:[Masechet]{
        
        get{
            return HadafHayomiManager.sharedManager.masechtot
        }
    }

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
         return self.masechtot.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "MasechetTableHeaderCell") as! MSBaseTableViewCell
        
        let masechet = self.masechtot[section]
        sectionHeader.reloadWithObject(masechet)
        
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let masechet = self.masechtot[section]
        masechet.updatePagesWithNotes()
        masechet.updateMarkedPages()
        
       return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasechtPagesCell", for:indexPath) as! MasechtPagesCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.pageSelectingCellDelegate = self
        
        cell.reloadWithObject(self.masechtot[indexPath.section])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
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
