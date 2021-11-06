//
//  Map_IPadViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 06/03/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Map_IPadViewController: MSBaseViewController, MKMapViewDelegate, LessonVenuesListViewControllerDelegate
{
     @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var mapView:MKMapView!
    
    var lessonsAnnotations = [LessonVenueAnnotation]()
    
    var lessonVenuesListViewController:LessonVenuesListViewController!{
        didSet{
            lessonVenuesListViewController.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = "st_lessons_map".localize()
    }
    
    //MARK:- MapView delegate methods 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView:MKAnnotationView!
        
        if let annotation = annotation as? LessonVenueAnnotation
        {
            annotationView = self.getDefaultAnnotationViewForAnnotation(annotation)
            return annotationView
            
        }
        return nil
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
    
    //MARK LessonVenuesListViewController Delegate methods
    
    func LessonVenuesListViewController(_ lessonVenuesListViewController:LessonVenuesListViewController, didUpdateVenues lessonVneues:[LessonVenue])
    {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        self.lessonsAnnotations = [LessonVenueAnnotation]()
        for lessonVenue in lessonVneues
        {
            let lessonAnnotation = LessonVenueAnnotation()
            lessonAnnotation.lessonVenue = lessonVenue
            
            self.lessonsAnnotations.append(lessonAnnotation)
        }
        
        self.mapView.addAnnotations(self.lessonsAnnotations)
    }
    
    func LessonVenuesListViewController(_ lessonVenuesListViewController: LessonVenuesListViewController, didSelectLessonVenue lessonVenue: LessonVenue) {
        
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
