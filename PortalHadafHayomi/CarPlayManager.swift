//
//  CarPlayManager.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import Foundation
import CarPlay
import MediaPlayer

@available(iOS 12.0, *)
class CarPlayManager: NSObject {
    
    static let shared = CarPlayManager()
    
    private var interfaceController: CPInterfaceController?
    
    override init() {
        super.init()
        
        // Only set up CarPlay if it's available
        if #available(iOS 14.0, *) {
            // iOS 14+ CarPlay setup
            setupCarPlayForModernVersions()
        } else if #available(iOS 12.0, *) {
            // iOS 12-13 CarPlay setup
            setupCarPlayForOlderVersions()
        }
    }
    
    @available(iOS 14.0, *)
    private func setupCarPlayForModernVersions() {
        // Modern CarPlay setup - handled by scene delegates
    }
    
    @available(iOS 12.0, *)
    private func setupCarPlayForOlderVersions() {
        // Legacy CarPlay setup for iOS 12-13
        // This would use the older CPApplicationDelegate pattern
    }
}

// MARK: - iOS 13+ Scene Support
@available(iOS 13.0, *)
extension CarPlayManager {
    
    func setInterfaceController(_ controller: CPInterfaceController) {
        self.interfaceController = controller
        setupInitialTemplate()
    }
    
    func clearInterfaceController() {
        self.interfaceController = nil
    }
    
    private func setupInitialTemplate() {
        guard let interfaceController = interfaceController else { return }
        
        // Create a simple list template to avoid crashes
        let items = [
            CPListItem(text: "דף היומי", detailText: "שיעורי דף היומי"),
        ]
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "דף היומי", sections: [section])
        
        interfaceController.setRootTemplate(template, animated: false, completion: nil)
    }
}