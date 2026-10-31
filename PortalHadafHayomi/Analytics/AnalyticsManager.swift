//
//  AnalyticsManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/12/2025.
//  Copyright © 2025 Binyamin Trachtman. All rights reserved.
//

import Foundation
import os.log
import FirebaseCore
import FirebaseAnalytics

class AnalyticsManager {

    // MARK: - Singleton
    static let shared = AnalyticsManager()
    
    private let logger = Logger(subsystem: "com.hadafhayomi.app", category: "Analytics")

    private init() { }

    func startTracking(){
        // FIX: the "Add car play" change replaced Firebase with a local log only,
        // so nothing reached Google Analytics since that version
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Analytics.setAnalyticsCollectionEnabled(true)
        logger.info("Analytics tracking started")
    }
    
    // MARK: - Public API
    func logEvent(_ event: String, info: [String: Any]?) {
        Analytics.logEvent(event, parameters: info)
        if let info = info {
            logger.info("Event: \(event), Parameters: \(String(describing: info))")
        } else {
            logger.info("Event: \(event)")
        }
    }
    
}
