//
//  AnalyticsManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 20/12/2025.
//  Copyright © 2025 Binyamin Trachtman. All rights reserved.
//

import Foundation
import os.log

class AnalyticsManager {

    // MARK: - Singleton
    static let shared = AnalyticsManager()
    
    private let logger = Logger(subsystem: "com.hadafhayomi.app", category: "Analytics")

    private init() { }

    func startTracking(){
        logger.info("Analytics tracking started")
    }
    
    // MARK: - Public API
    func logEvent(_ event: String, info: [String: Any]?) {
        if let info = info {
            logger.info("Event: \(event), Parameters: \(String(describing: info))")
        } else {
            logger.info("Event: \(event)")
        }
    }
    
}
