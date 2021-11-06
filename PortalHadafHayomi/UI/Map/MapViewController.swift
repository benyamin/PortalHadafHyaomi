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
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var venuesTableView:UITableView!
    @IBOutlet weak var searchBar:UISearchBar!
    
    var lessonVenues = [LessonVenue]()
    var lessonsAnnotations = [LessonVenueAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.layer.borderWidth = 1.0
        self.searchBar.layer.borderColor = UIColor(HexColor:"791F23").cgColor
        
        self.displaySegmentedControlr.setTitle("st_map".localize(), forSegmentAt: 0)
        
         self.displaySegmentedControlr.setTitle("st_list".localize(), forSegmentAt: 1)
        
        self.getLessonVenues()
        
        self.mapView.showsUserLocation = true
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

}
