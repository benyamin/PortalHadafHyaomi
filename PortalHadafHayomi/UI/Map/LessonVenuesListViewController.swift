//
//  LessonVenuesListViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/03/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import CoreLocation

protocol LessonVenuesListViewControllerDelegate: class
{
     func LessonVenuesListViewController(_ lessonVenuesListViewController:LessonVenuesListViewController, didUpdateVenues lessonVneues:[LessonVenue])
    
     func LessonVenuesListViewController(_ lessonVenuesListViewController: LessonVenuesListViewController, didSelectLessonVenue lessonVenue: LessonVenue)
}

class LessonVenuesListViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, LessonVenueTableCellDelegate
{
    
    var getUserLocationProcess:GetUserLocationProcess?
    var userLocation:CLLocation?
    
    @IBOutlet weak var venuesTableView:UITableView!
    @IBOutlet weak var sortSegmentedControlr:UISegmentedControl!
    
    weak var delegate:LessonVenuesListViewControllerDelegate?
    
    private var _lessonVenues:[LessonVenue]?
    var lessonVenues:[LessonVenue]!{
        get{
            return _lessonVenues ?? HadafHayomiManager.sharedManager.lessonVenues
        }
        set (value){
            if self.sortSegmentedControlr.selectedSegmentIndex == 0 {//Sort by City
                _lessonVenues = value.sorted(by:{ $0.city < $1.city })
            }
            else if self.sortSegmentedControlr.selectedSegmentIndex == 1 {//Sort by Distance
                _lessonVenues = value.sorted(by:{ $0.distanceFromUser < $1.distanceFromUser })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topBarTitleLabel?.text = "st_lessons_list".localize()
        
        self.sortSegmentedControlr.setTitle("st_sort_by_city".localize(), forSegmentAt: 0)
        self.sortSegmentedControlr.setTitle("st_sort_by_distance".localize(), forSegmentAt: 1)
            
        self.getLessonVenues()
        self.getUserLocatoin()
    }

    func getUserLocatoin(){
        
        self.getUserLocationProcess = GetUserLocationProcess()
        self.getUserLocationProcess?.executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            self.getUserLocationProcess = nil
            
            self.userLocation = object as? CLLocation
            
            if self.lessonVenues.count > 0 {
                self.updateVenues(self.lessonVenues, withUserLocatoin: self.userLocation!)
            }
            
        },onFaile: { (object, error) -> Void in
            self.getUserLocationProcess = nil
        })
    }
    
    func getLessonVenues()
    {
        Util.showDefaultLoadingView()
        GetLessonVenuesProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.lessonVenues  = object as! [LessonVenue]
            
            if self.userLocation != nil {
                self.updateVenues(self.lessonVenues, withUserLocatoin: self.userLocation!)
            }
            
            Util.hideDefaultLoadingView()
            HadafHayomiManager.sharedManager.lessonVenues = self.lessonVenues
                        
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
    
    func updateVenues(_ venues:[LessonVenue], withUserLocatoin location:CLLocation){
        for venue in venues {
            let venueLocation = CLLocation(latitude: venue.latitude,longitude: venue.longitude)
            venue.distanceFromUser = venueLocation.distance(from: location)/1000
        }
        self.venuesTableView.reloadData()
    }
    
    @IBAction func sortSegmentedControlrValueChanged(_ sedner:AnyObject)
    {
        if self.sortSegmentedControlr.selectedSegmentIndex == 0 {//Sort by City
            self.lessonVenues = self.lessonVenues.sorted(by:{ $0.city < $1.city })
        }
        else if self.sortSegmentedControlr.selectedSegmentIndex == 1 {//Sort by Distance
            self.lessonVenues = self.lessonVenues.sorted(by:{ $0.distanceFromUser < $1.distanceFromUser })
        }
        self.venuesTableView.reloadData()
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.lessonVenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonVenueTableCell", for:indexPath) as! LessonVenueTableCell
        
        cell.delegate = self
        
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
    
    //Mark: - LessonVenueTableCell delegate methods
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, showLessonOnMap lessonVenue:LessonVenue){
    }
    
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, showNavigationOptions lessonVenue:LessonVenue) {
        
        let lessonVenueFullAddress = "\(lessonVenue.city ?? "") \(lessonVenue.address ?? "") \(lessonVenue.location ?? "")"
        
        let actionSheet = NavigationActoinSheet.createWith(address: lessonVenueFullAddress, latitude: lessonVenue.latitude, longitude: lessonVenue.longitude)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if let ppc = actionSheet.popoverPresentationController {
                ppc.sourceView = lessonVenueTableCell
                ppc.sourceRect = lessonVenueTableCell.bounds
            }
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, share lessonVenue:LessonVenue) {
        
        let text = lessonVenue.dispalyedInformation
        if let image = UIImage(named: "Icon-App-60x60@2x.png")  {
            
            let shareAll = [text, image] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
