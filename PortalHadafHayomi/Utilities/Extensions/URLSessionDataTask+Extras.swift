//
//  URLSessionDataTask+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 06/01/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

extension  URLSessionDataTask
{
    private static var _request:BaseRequest?
    
    var request:BaseRequest? {
        get {
            return URLSessionDataTask._request
        }
        set(newValue) {
           URLSessionDataTask._request = newValue
        }
    }
}
