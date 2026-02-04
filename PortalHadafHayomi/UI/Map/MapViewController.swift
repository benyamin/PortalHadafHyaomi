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
    @IBOutlet weak var sortSegmentedSecondaryTopConstraint:NSLayoutConstraint!
    @IBOutlet weak var venuesTableViewBottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var countriesTextField: ChecklistTextField!
    @IBOutlet weak var citiesTextField: ChecklistTextField!
    @IBOutlet weak var fromTimeTextField: TimeTextField!
    @IBOutlet weak var toTimeTextField: TimeTextField!
    

    var lessonCities:[String] = [String]()
    
    var selectedCountry:String?
    var selectedCity:String?
    
    var userLocation:CLLocation?{
        didSet{
            if userLocation != nil {
                self.sortSegmentedSecondaryTopConstraint.priority = UILayoutPriority(rawValue: 500)
            }
        }
    }
    
    private var _displayedVenues:[LessonVenue]?
    var displayedVenues:[LessonVenue]!{
        get{
            return _displayedVenues ?? HadafHayomiManager.sharedManager.lessonVenues 
        }
        set (value){
            if self.sortSegmentedControlr.selectedSegmentIndex == 0 {//Sort by City
                _displayedVenues = value.sorted(by:{ $0.city < $1.city })
            }
            else if self.sortSegmentedControlr.selectedSegmentIndex == 1 {//Sort by Distance
                _displayedVenues = value.sorted(by:{ $0.distanceFromUser < $1.distanceFromUser })
            }
        }
    }
    var lessonsAnnotations = [LessonVenueAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.filterView.addBottomShadow()
        
        self.displaySegmentedControlr.setTitle("st_map".localize(), forSegmentAt: 0)
        self.displaySegmentedControlr.setTitle("st_list".localize(), forSegmentAt: 1)
        
        self.sortSegmentedControlr.setTitle("st_sort_by_city".localize(), forSegmentAt: 0)
        self.sortSegmentedControlr.setTitle("st_sort_by_distance".localize(), forSegmentAt: 1)
        
        self.getLesonVenues()
        self.getUserLocatoin()
        
        self.mapView.showsUserLocation = true
      
        self.fromTimeTextField.placeholder = "st_select_from_time".localize()
        self.toTimeTextField.placeholder = "st_select_to_time".localize()
        
        self.countriesTextField.maxSelectedItems = 1
        self.countriesTextField.placeholder = "st_select_country".localize()
        self.countriesTextField.onSelectionChanged = {[weak self] countries in
            
            guard let self else { return }

            self.selectedCountry = countries.first
            self.selectedCity = nil

            self.lessonCities = displayedVenues
                .filter { $0.sregionname == self.selectedCountry }
                .compactMap { $0.city }
                .reduce(into: Set<String>()) { $0.insert($1) } // unique
                .sorted { $0.localizedCompare($1) == .orderedAscending }
            
            self.citiesTextField.checklistItems = self.lessonCities
            
            self.updateDisplayedVenues()
        }
        
        citiesTextField.maxSelectedItems = 1
        citiesTextField.placeholder = "st_select_city".localize()
        self.citiesTextField.onSelectionChanged = { cities in
            self.selectedCity = cities.first
            self.updateDisplayedVenues()
        }
        
        self.sortSegmentedSecondaryTopConstraint.priority = UILayoutPriority(rawValue: 900)
        
        fromTimeTextField.onSelectionChanged = { [weak self] dates in
            
            guard let self else {return}
            
            guard let fromDate = dates.first else {
                // If "from" cleared → remove min constraint
                self.toTimeTextField.minDate = nil
                return
            }

            toTimeTextField?.minDate = fromDate

            // Optional: auto-clear invalid "to" time
            if let toDate =  self.toTimeTextField.selectedDate,
               toDate < fromDate {
                self.toTimeTextField.selectedDate = nil
            }
            
            self.updateDisplayedVenues()
        }
        
        toTimeTextField.onSelectionChanged = { [weak self] selectedTime in
            self?.updateDisplayedVenues()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(keyboardWillChangeFrame),
                  name: UIResponder.keyboardWillChangeFrameNotification,
                  object: nil
              )
        
        self.getLesonVenues()
        self.getUserLocatoin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
        
    
    func getLesonVenues()
    {
        GetLessonVenuesProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: {[weak self] (object) -> Void in
            
            guard let self else {return}
            
            HadafHayomiManager.sharedManager.lessonVenues = object as! [LessonVenue]
            
            self.displayedVenues =  HadafHayomiManager.sharedManager.lessonVenues
            
            let lessonCountries = Array(Set(displayedVenues.compactMap(\.sregionname)))
                .sorted { $0.localizedCompare($1) == .orderedAscending }
            
            var countriesChecklistItems = [String]()
           // countriesChecklistItems.append("st_all".localize())
            countriesChecklistItems.append(contentsOf: lessonCountries)
            self.countriesTextField.checklistItems = countriesChecklistItems
            
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func getUserLocatoin(){
        
        GetUserLocationProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.userLocation = object as? CLLocation
            
            if self.displayedVenues.count > 0 {
                self.updateVenues(self.displayedVenues, withUserLocatoin: self.userLocation!)
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
        self.displayedVenues  = self.displayedVenues.sorted(by: { $0.city < $1.city })
        
        self.mapView.removeAnnotations(self.lessonsAnnotations)
        
        self.lessonsAnnotations = [LessonVenueAnnotation]()
        for lessonVenue in self.displayedVenues
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
            self.displayedVenues = self.displayedVenues.sorted(by:{ $0.city < $1.city })
        }
        else if self.sortSegmentedControlr.selectedSegmentIndex == 1 {//Sort by Distance
            self.displayedVenues = self.displayedVenues.sorted(by:{ $0.distanceFromUser < $1.distanceFromUser })
        }
        self.venuesTableView.reloadData()
    }
      
    @IBAction func searchButtonClicked(_ sender:AnyObject) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
            annotationView.image = UIImage(named: "portalMapIcon")
            annotationView.canShowCallout = true
            
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(named: "nextButton"), for: .normal)
         
            btn.addTarget(self, action: #selector(annotationViewButtonClicked(_:)), for: .touchUpInside)
            btn.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30)
            annotationView.rightCalloutAccessoryView = btn

        }
        let btn = annotationView.rightCalloutAccessoryView as! UIButton
        if let lessonVenue = (annotationView.annotation as? LessonVenueAnnotation)?.lessonVenue {
            btn.userInfo = ["lessonVenue":lessonVenue]
        }
        
        return annotationView
    }
    
    @objc func annotationViewButtonClicked(_ button:UIButton)
    {
        if let lessonVenueTableCell = UIView.loadFromNibNamed("LessonVenueTableCell") as? LessonVenueTableCell {
            
            if let lessonVenue = button.userInfo?["lessonVenue"] {
                lessonVenueTableCell.reloadWithObject(lessonVenue)
                lessonVenueTableCell.delegate = self
               // lessonVenueTableCell.frame = lessonVenueBaseView.bounds
                
                BTPopUpView.show(view: lessonVenueTableCell, onComplete:{ })
            }
        }
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.displayedVenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonVenueTableCell", for:indexPath) as! LessonVenueTableCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        
        cell.reloadWithObject(self.displayedVenues[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func updateDisplayedVenues(){
   
        self.displayedVenues = self.updateFilteredVenues()
        
        if let center = self.centerCoordinate(for: displayedVenues) {
            
            let region = MKCoordinateRegion(
                   center: center,
                   latitudinalMeters: selectedCity != nil ? 10_000 : 500_000,
                   longitudinalMeters: selectedCity != nil ? 10_000 : 500_000
               )

               mapView.setRegion(region, animated: true)
        }
        
        self.reloadData()
    }
    
    func updateFilteredVenues() -> [LessonVenue] {
        let venues = HadafHayomiManager.sharedManager.lessonVenues

        let filteredVenues = venues.filter { venue in
            (selectedCountry == nil || venue.sregionname == selectedCountry)
            && (selectedCity == nil || venue.city == selectedCity)
            && venue.isWithinTimeRange(from: self.fromTimeTextField.selectedDate,
                                       to: self.toTimeTextField.selectedDate)
            && (citiesTextField.selectedItems.isEmpty
                || citiesTextField.selectedItems.contains(venue.city))
        }
        
        return filteredVenues
    }
    
    func centerCoordinate(for venues: [LessonVenue]) -> CLLocationCoordinate2D? {
        guard !venues.isEmpty else { return nil }

        let (latSum, lonSum) = venues.reduce(into: (0.0, 0.0)) {
            $0.0 += $1.latitude
            $0.1 += $1.longitude
        }

        return CLLocationCoordinate2D(
            latitude: latSum / Double(venues.count),
            longitude: lonSum / Double(venues.count)
        )
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
        if let image = UIImage(named: "Icon-App-60x60@2x.png")  {
            
            let shareAll = [text, image] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, connect lessonVenue:LessonVenue) {
        
        if let lessonId = lessonVenue.id {
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            
            let title = lessonVenue.city + " - " + lessonVenue.maggid
            webViewController.loadUrl("https://app.daf-yomi.com/ContactLessons.aspx?id=\(lessonId)", title: title)
            webViewController.shareButtonDisabled = true
            
            self.present(webViewController , animated: true, completion: nil)
        }
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
           guard
               let userInfo = notification.userInfo,
               let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
               let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
               let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
           else { return }

           // Convert to your view’s coordinate system
           let keyboardFrameInView = view.convert(frame, from: nil)

           let overlap = max(0, view.bounds.height - keyboardFrameInView.origin.y)

           UIView.animate(
               withDuration: duration,
               delay: 0,
               options: UIView.AnimationOptions(rawValue: curveRaw << 16),
               animations: { self.view.layoutIfNeeded() },
               completion: nil
           )
       }
}
