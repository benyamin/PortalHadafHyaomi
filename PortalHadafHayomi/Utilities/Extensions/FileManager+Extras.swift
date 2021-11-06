//
//  FileManager+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 18/10/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

public extension FileManager
{
   class func write(text: String, to fileNamed: String, ofType fileType:String) -> Bool
    {
        let fileURL = FileManager.filePathFor(fileNamed: fileNamed, ofType: fileType)
        
        do {
            // writing to disk
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
            return true
            
        } catch {
            print("error writing to url:", fileURL, error)
             return false
        }
    }
    
    class func readFromFile(_ fileNamed: String, ofType fileType:String) -> String?
    {
        let fileURL = FileManager.filePathFor(fileNamed: fileNamed, ofType: fileType)
        
        do {
            let text = try String(contentsOf: fileURL)
            
            return text
           // print(mytext)   // "some text\n"
        } catch {
            print("error loading contents of:", fileURL, error)
            
            return nil
        }
    }
    
    class func fileModificationDate(_ fileNamed: String, ofType fileType:String) -> Date? {
        do {
            let fileURL = FileManager.filePathFor(fileNamed: fileNamed, ofType: fileType)
            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    class func filePathFor(fileNamed: String, ofType fileType:String) -> URL
    {
        // get the documents folder url
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileFullName = fileNamed + "." + fileType
        let fileURL = documentDirectory.appendingPathComponent(fileFullName)
        
        return fileURL
    }
}
