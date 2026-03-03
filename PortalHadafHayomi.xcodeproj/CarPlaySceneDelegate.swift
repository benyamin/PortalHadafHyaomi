//
//  CarPlaySceneDelegate.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import UIKit
import CarPlay

@available(iOS 13.0, *)
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    // MARK: - Scene Lifecycle
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        self.interfaceController?.delegate = self
        
        // Set up CarPlay controller
        CarPlayController.shared.setInterfaceController(interfaceController)
        
        // Set up the initial template
        setupInitialTemplate()
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        CarPlayController.shared.clearInterfaceController()
        self.interfaceController = nil
    }
    
    // MARK: - Initial Setup
    
    private func setupInitialTemplate() {
        let mainTemplate = CarPlayController.shared.createMainTemplate()
        interfaceController?.setRootTemplate(mainTemplate, animated: false, completion: nil)
    }
}

// MARK: - CPInterfaceController Delegate

@available(iOS 13.0, *)
extension CarPlaySceneDelegate: CPInterfaceControllerDelegate {
    
    func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template appearance if needed
    }
    
    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template did appear if needed
    }
    
    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template will disappear if needed
    }
    
    func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template did disappear if needed
    }
}