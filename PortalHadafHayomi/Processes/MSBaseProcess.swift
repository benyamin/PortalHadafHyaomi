//
//  MSBaseProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 03/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

open class MSBaseProcess: NSObject
{
    deinit {
        print ("deinit Process: \(self.classForCoder)")
    }
    
    open var onStart:(() -> Void)?
    open var onProgress:((_ object:Any) -> Void)?
    open var onComplete:((_ object:Any) -> Void)?
    open var onFaile:((_ object:Any?, _ error:NSError) -> Void)?
    
    //Closures
    open func executeWithObject(_ object:Any?, onStart:@escaping (() -> Void), onComplete:@escaping (_ object:Any) -> Void , onFaile:@escaping (_ object:Any?, _ error:NSError) -> Void)
    {
        self.onStart = onStart
        self.onComplete = onComplete
        self.onFaile = onFaile
        
        self.executeWithObj(object)
        self.onStart?()
    }
    
    
    open func executeWithObject(_ object:Any?, onStart:@escaping (() -> Void), onProgress:@escaping (_ object:Any) -> Void, onComplete:@escaping (_ object:Any) -> Void , onFaile:@escaping (_ object:Any?, _ error:NSError) -> Void)
    {
        self.onStart = onStart
        self.onProgress = onProgress
        self.onComplete = onComplete
        self.onFaile = onFaile
        
        self.executeWithObj(object)
        self.onStart?()
    }
    
    open func executeWithObj(_ obj:Any?)
    {
        
    }
    open func cancel()
    {
        self.onStart = nil
        self.onComplete = nil
        self.onFaile = nil
    }
}
