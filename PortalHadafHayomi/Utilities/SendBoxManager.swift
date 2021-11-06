//
//  SendBoxManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class SendBoxManager:DataObject
{
    class func getPathForFileName(_ fileName:String) -> String?
    {
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return nil
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(fileName)
        
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false)
        {
            print("DB does not exist in documents folder")
            
            //Try to save the file to the send box documents
            if SendBoxManager.copyFile(fileName, toPath: finalDatabaseURL.path)
            {
                return finalDatabaseURL.path
            }
            else{
                return nil
            }
        }
        else{
            return finalDatabaseURL.path
        }
    }
    
    class func copyFile(_ fileName:String, toPath filePath:String) -> Bool
    {
        var success = false
        
        let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(fileName)
        
        do {
            
            try FileManager.default.copyItem(atPath: (documentsURL?.path)!, toPath: filePath)
            success = true
            
        } catch let error as NSError {
            
            print("Couldn't copy file to final location! Error:\(error.description)")
            success = false
        }
        
        return success
    }
    /*
    class func copyDatabaseIfNeeded(_ DBFileName:String)
    {
        // Move database file from bundle to documents folder
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return // Could not find documents URL
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(DBFileName)
        
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            print("DB does not exist in documents folder")
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(DBFileName)
            
            do {
                try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
    }
    */

}
