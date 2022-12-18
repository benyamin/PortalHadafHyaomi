//
//  MapViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 18/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: MSBaseViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, LessonVenueTableCellDelegate
{
    @IBOutlet weak var displaySegmentedControlr:UISegmentedControl!
    @IBOutlet weak var sortSegmentedControlr:UISegmentedControl!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var venuesTableView:UITableView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var sortSegmentedSecondaryTopConstraint:NSLayoutConstraint!
    
    var userLocation:CLLocation?{
        didSet{
            if userLocation != nil {
                self.sortSegmentedSecondaryTopConstraint.priority = UILayoutPriority(rawValue: 500)
            }
        }
    }
    
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
    var lessonsAnnotations = [LessonVenueAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.layer.borderWidth = 1.0
        self.searchBar.layer.borderColor = UIColor(HexColor:"791F23").cgColor
        
        self.displaySegmentedControlr.setTitle("st_map".localize(), forSegmentAt: 0)
        self.displaySegmentedControlr.setTitle("st_list".localize(), forSegmentAt: 1)
        
        self.sortSegmentedControlr.setTitle("st_sort_by_city".localize(), forSegmentAt: 0)
        self.sortSegmentedControlr.setTitle("st_sort_by_distance".localize(), forSegmentAt: 1)
        
        self.getLessonVenues()
        self.getUserLocatoin()
        
        self.mapView.showsUserLocation = true
        
        self.sortSegmentedSecondaryTopConstraint.priority = UILayoutPriority(rawValue: 900)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getLessonVenues()
        self.getUserLocatoin()
    }
    
    func getLessonVenues()
    {
        GetLessonVenuesProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            HadafHayomiManager.sharedManager.lessonVenues = object as! [LessonVenue]
            
            self.lessonVenues =  HadafHayomiManager.sharedManager.lessonVenues
            
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func getUserLocatoin(){
        
        GetUserLocationProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.userLocation = object as? CLLocation
            
            if self.lessonVenues.count > 0 {
                self.updateVenues(self.lessonVenues, withUserLocatoin: self.userLocation!)
            }
            
        },onFaile: { (object, error) -> Void in
        })
    }
    
    func updateVenues(_ venues:[LessonVenue], withUserLocatoin location:CLLocation){
        for venue in venues {
            let venueLocation = CLLocation(latitude: venue.latitude,longitude: venue.longitude)
            venue.distanceFromUser = venueLocation.distance(from: location)/1000
        }
        self.venuesTableView.reloadData()
    }
    
    override func reloadData()
    {
        self.lessonVenues  = self.lessonVenues.sorted(by: { $0.city < $1.city })
        
        self.mapView.removeAnnotations(self.lessonsAnnotations)
        
        self.lessonsAnnotations = [LessonVenueAnnotation]()
        for lessonVenue in self.lessonVenues
        {
            let lessonAnnotation = LessonVenueAnnotation()
            lessonAnnotation.lessonVenue = lessonVenue
            
            self.lessonsAnnotations.append(lessonAnnotation)
        }
        
        self.mapView.addAnnotations(self.lessonsAnnotations)
        self.venuesTableView.reloadData()
    }
    
    @IBAction func displaySegmentedControlrValueChanged(_ sedner:AnyObject)
    {
        if self.displaySegmentedControlr.selectedSegmentIndex == 0//Show Map
        {
            self.venuesTableView.isHidden = true
            self.mapView.isHidden = false
           
        }
        if self.displaySegmentedControlr.selectedSegmentIndex == 1//Show List
        {
            self.venuesTableView.isHidden = false
            self.mapView.isHidden = true
        }
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
        
    @IBAction func addLessonButtonClicked(_ sender:AnyObject)
    {        
        let addVenueViewController =  UIViewController.withName("AddVenueViewController", storyBoardIdentifier: "MapStoryboard") as! AddVenueViewController
        self.navigationController?.pushViewController(addVenueViewController, animated: true)

    }
    
    //MARK:- MapView delegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView:MKAnnotationView!
        
        if let annotation = annotation as? LessonVenueAnnotation
        {
            annotationView = self.getDefaultAnnotationViewForAnnotation(annotation)
            return annotationView
            
        }
        else if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        else {
            return nil
        }
    }
    
    func getDefaultAnnotationViewForAnnotation(_ annotation:LessonVenueAnnotation) -> MKAnnotationView
    {
        let annotationIdentifier = "LessonVenueAnnotationView"
        
        var annotationView:MKAnnotationView!
        if let dequeuedView = self.mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
            
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView.image = UIImage(named: "map_marker_off")
            annotationView.canShowCallout = true


        }
        
        return annotationView
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.lessonVenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonVenueTableCell", for:indexPath) as! LessonVenueTableCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        
        cell.reloadWithObject(self.lessonVenues[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, showLessonOnMap lessonVenue:LessonVenue)
    {
        self.displaySegmentedControlr.selectedSegmentIndex = 0
        self.venuesTableView.isHidden = true
        self.mapView.isHidden = false
        
        for lessonAnnotation in self.lessonsAnnotations
        {
            if lessonAnnotation.lessonVenue == lessonVenue
            {
                 self.mapView.selectAnnotation(lessonAnnotation, animated: true)
                return
            }
        }
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
        if let image = UIImage(named: "defaultIcon")  {
            
            let shareAll = [text, image] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
