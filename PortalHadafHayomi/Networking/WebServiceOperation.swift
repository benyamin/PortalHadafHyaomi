//
//  WebServiceOperation.swift
//  MikvehIsrael
//
//  Created by Binyamin Trachtman on 8/27/15.
//  Copyright (c) 2015 Binyamin Trachtman. All rights reserved.
//

import Foundation

class WebServiceOperation
{
    var request:BaseRequest!
    
    var onStart:(() -> Void)?
    var onComplete:((_ dictionary:[String:Any], _ error:NSError?) -> Void)?
    var onFaile:((_ object:NSObject, _ error:NSError) -> Void)?
    
    var response:URLResponse!
    
    var responseData:NSMutableData!
}
