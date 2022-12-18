//
//  GetUserLocationProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

open class GetUserLocationProcess: MSBaseProcess, CLLocationManagerDelegate
{
    lazy var locationManager:CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    open override func executeWithObj(_ obj:Any?)
    {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else{
            self.locationManager.requestLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.onComplete?(location)
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.onFaile?(manager, error as NSError)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse{
            self.locationManager.requestLocation()
        }
    }
}
