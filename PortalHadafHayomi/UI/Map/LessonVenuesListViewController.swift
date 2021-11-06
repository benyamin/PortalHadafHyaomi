//
//  LessonVenuesListViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/03/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

protocol LessonVenuesListViewControllerDelegate: class
{
     func LessonVenuesListViewController(_ lessonVenuesListViewController:LessonVenuesListViewController, didUpdateVenues lessonVneues:[LessonVenue])
    
     func LessonVenuesListViewController(_ lessonVenuesListViewController: LessonVenuesListViewController, didSelectLessonVenue lessonVenue: LessonVenue)
}

class LessonVenuesListViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var venuesTableView:UITableView!
    
    weak var delegate:LessonVenuesListViewControllerDelegate?
    
     var lessonVenues = [LessonVenue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topBarTitleLabel?.text = "st_lessons_list".localize()
            
         self.getLessonVenues()
    }

    func getLessonVenues()
    {
        Util.showDefaultLoadingView()
        GetLessonVenuesProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            Util.hideDefaultLoadingView()
            HadafHayomiManager.sharedManager.lessonVenues = object as! [LessonVenue]
            
            self.lessonVenues =  HadafHayomiManager.sharedManager.lessonVenues
            
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
              Util.hideDefaultLoadingView()
        })
    }
    
    override func reloadData()
    {
        self.lessonVenues  = self.lessonVenues .sorted(by: { $0.city < $1.city })
            
        self.venuesTableView.reloadData()
        
        self.delegate?.LessonVenuesListViewController(self, didUpdateVenues:  self.lessonVenues)
    }
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.lessonVenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonVenueTableCell", for:indexPath) as! LessonVenueTableCell
        
        cell.reloadWithObject(self.lessonVenues[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedLessonVenue = (self.lessonVenues[indexPath.row])
        self.delegate?.LessonVenuesListViewController(self, didSelectLessonVenue: selectedLessonVenue)
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
        var filterdVenues = [LessonVenue]()
        for lessonVenue in HadafHayomiManager.sharedManager.lessonVenues
        {
            if lessonVenue.city.hasPrefix(searchText)
                || (lessonVenue.address?.hasPrefix(searchText))!
                || lessonVenue.maggid.hasPrefix(searchText)
            {
                filterdVenues.append(lessonVenue)
            }
        }
        
        self.lessonVenues = filterdVenues
        self.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        self.lessonVenues = HadafHayomiManager.sharedManager.lessonVenues
        self.reloadData()
    }
}
