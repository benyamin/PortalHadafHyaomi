//
//  MSGetPagesStatusProcess.swift
//  DafYomiTrakingBoard
//
//  Created by Binyamin Trachtman on 14/02/2024.
//

import Foundation

class MSGetPagesStatusProcess:MSBaseProcess
{
    override func executeWithObj(_ obj:Any?) {
       return getPagesStatus()
    }
    
    func getPagesStatus(){
        
        let learndPagesDictionary = UserDefaults.standard.object(forKey:"pages") as? [String:[String:Any]] ?? [String:[String:Any]]()
        
        self.onCompleteWithObj(learndPagesDictionary)
    }
}
