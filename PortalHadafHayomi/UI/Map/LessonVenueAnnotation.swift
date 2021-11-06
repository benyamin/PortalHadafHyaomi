//
//  LessonVenueAnnotation.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 18/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import MapKit

class LessonVenueAnnotation:NSObject, MKAnnotation {
    
    var lessonVenue:LessonVenue!
    
    func reloadWithLessonVenue(_ lessonVenue:LessonVenue)
    {
        self.lessonVenue = lessonVenue
    }
    
    // MARK: MKAnnotation Protocol methods
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2DMake(self.lessonVenue.latitude, self.lessonVenue.longitude)
    }
    
    var title: String? {
        
        return self.lessonVenue.city
    }
    
    var subtitle: String? {
        
        var subtitleText = self.lessonVenue.maggid!
        subtitleText += " " + "st_lesson_hour".localize()
        subtitleText += " " + self.lessonVenue.hour
        return subtitleText
    }
    
}
