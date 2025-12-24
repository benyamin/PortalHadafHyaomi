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
    @IBOutlet weak var venuesTableViewBottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var countriesTextField: ChecklistTextField!
    @IBOutlet weak var citiesTextField: ChecklistTextField!
    @IBOutlet weak var fromTimeTextField: TimeTextField!
    @IBOutlet weak var toTimeTextField: TimeTextField!
    
    var lessonCountries:[String] = [String]()
    var lessonCities:[String] = [String]()
    
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
            
            self.lessonCountries = Array(Set(lessonVenues.compactMap(\.sregionname)))
                .sorted { $0.localizedCompare($1) == .orderedAscending }
            
            var countriesChecklistItems = [String]()
           // countriesChecklistItems.append("st_all".localize())
            countriesChecklistItems.append(contentsOf: self.lessonCountries)
            countriesTextField.checklistItems = countriesChecklistItems
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
      
        self.fromTimeTextField.placeholder = "st_select_from_time".localize()
        self.toTimeTextField.placeholder = "st_select_to_time".localize()
        
        self.countriesTextField.maxSelectedItems = 1
        self.countriesTextField.placeholder = "st_select_country".localize()
        self.countriesTextField.onSelectionChanged = {[weak self] selected in
            
            guard let self else { return }

            let selected = Set(self.countriesTextField.selectedItems)

            self.lessonCities = lessonVenues
                .filter { selected.contains($0.sregionname) }
                .compactMap { $0.city }
                .reduce(into: Set<String>()) { $0.insert($1) } // unique
                .sorted { $0.localizedCompare($1) == .orderedAscending }
            
            self.citiesTextField.checklistItems = self.lessonCities
        }
        
        citiesTextField.maxSelectedItems = 1
        citiesTextField.placeholder = "st_select_city".localize()
        self.citiesTextField.onSelectionChanged = { selected in
           // self.updateDisplayedVenues()
        }
        
        self.sortSegmentedSecondaryTopConstraint.priority = UILayoutPriority(rawValue: 900)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(keyboardWillChangeFrame),
                  name: UIResponder.keyboardWillChangeFrameNotification,
                  object: nil
              )
        
        self.getLessonVenues()
        self.getUserLocatoin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
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
        return self.lessonVenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonVenueTableCell", for:indexPath) as! LessonVenueTableCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        
        cell.reloadWithObject(self.lessonVenues[indexPath.row])
        
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
    
    //Mark: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
        searchBar.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.updateDisplayedVenues()
    }
    
    func updateDisplayedVenues(){
        
        let searchText = self.searchBar.text ?? ""
        
        var filterdVenues = [LessonVenue]()
        for lessonVenue in HadafHayomiManager.sharedManager.lessonVenues
        {
            if lessonVenue.city.hasPrefix(searchText)
                || (lessonVenue.address?.hasPrefix(searchText))!
                || lessonVenue.maggid.hasPrefix(searchText)
            {
                if self.citiesTextField.selectedItems.count > 0 {
                    if self.citiesTextField.selectedItems.contains(lessonVenue.city) {
                        filterdVenues.append(lessonVenue)
                    }
                }
                else{
                    filterdVenues.append(lessonVenue)
                }
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
        self.venuesTableViewBottomConstraint.constant = overlap

           UIView.animate(
               withDuration: duration,
               delay: 0,
               options: UIView.AnimationOptions(rawValue: curveRaw << 16),
               animations: { self.view.layoutIfNeeded() },
               completion: nil
           )
       }
}
