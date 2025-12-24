//
//  AnalyticsManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/12/2025.
//  Copyright © 2025 Binyamin Trachtman. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics

class AnalyticsManager {

    // MARK: - Singleton
    static let shared = AnalyticsManager()

    private init() { }

    func startTracking(){
        FirebaseApp.configure()
    }
    // MARK: - Public API
    func logEvent(_ event: String, info: [String: Any]?) {
        Analytics.logEvent(event, parameters:info)
    }
    
}
