//
//  DispatchQueue+Extras.swift
//  HBCoreKit
//
//  Created by Binyamin on 17/09/2018.
//  Copyright © 2018 Binyamin. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    // This method will dispatch the `block` to self.
    // If `self` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
