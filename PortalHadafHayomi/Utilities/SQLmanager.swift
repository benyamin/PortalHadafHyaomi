//
//  SQLmanager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class SQLmanager:DataObject
{
    class func openDatabase(_ DBFileName:String) -> OpaquePointer?
    {
        var db:OpaquePointer? = nil
        
        do {
            let manager = FileManager.default
            
            let documentsURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(DBFileName)
            
            var rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
            if rc == SQLITE_CANTOPEN {
                
                let fileName = DBFileName.components(separatedBy: ".").first!
                let fileType = DBFileName.components(separatedBy: ".").last!
                
                let bundleURL = Bundle.main.url(forResource: fileName, withExtension: fileType)!
                try manager.copyItem(at: bundleURL, to: documentsURL)
                rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
            }
            
            if rc != SQLITE_OK {
                print("Error: \(rc)")
                return nil
            }
            
            return db
        } catch {
            print(error)
            return nil
        }
    }
    
    class func getData(_ tableFieldsArray:[String], from tableName:String, where constrent:String?, fromDBFile dbFileName:String) -> [[String:Any]]?
    {
        var queryObjectsInfo = [[String:Any]]()

        autoreleasepool {
            
            if let db = SQLmanager.openDatabase(dbFileName)
            {
                var queryStatement: OpaquePointer? = nil
                
                var queryRequest = "SELECT "
                
                for field in tableFieldsArray
                {
                    queryRequest += field
                    
                    if field != tableFieldsArray.last
                    {
                        queryRequest += ", "
                    }
                }
                
                queryRequest += " FROM " + tableName
                
                if constrent != nil
                {
                    queryRequest += " WHERE \(constrent!)"
                }
                
                queryRequest += " ;"
                
                print ("SQL getData request: \(queryRequest)")
                
                if sqlite3_prepare_v2(db, queryRequest, -1, &queryStatement, nil) == SQLITE_OK {
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        
                       // let id = sqlite3_column_int(queryStatement, 0)
                        
                        var queryResultDictoinary = [String:Any]()
                        
                        for index in 0 ..< tableFieldsArray.count
                        {
                            if let column_text = sqlite3_column_text(queryStatement, Int32(index))
                            {
                                let fieldName = tableFieldsArray[index]
                                 let fieldValue = String(cString: column_text)
                                
                                queryResultDictoinary[fieldName] = fieldValue
                            }
                        }
                        
                        queryObjectsInfo.append(queryResultDictoinary)
                    }
                    
                    if queryObjectsInfo.count == 0
                    {
                         print("Query returned no results")
                    }
                    
                } else {
                    print("SELECT statement could not be prepared")
                }
                
                sqlite3_finalize(queryStatement)
                
                sqlite3_close(db)
            }
        }
        
        return queryObjectsInfo
    }
    

    
    class func insertOrReplaceData(dataDictionary:[String:String], toTable tableName:String, toDBFile dbFileName:String)
    {
        autoreleasepool {
            
            if let db = SQLmanager.openDatabase(dbFileName)
            {
                var validFields = [String]()
                
                for key in dataDictionary.keys
                {
                    validFields.append(key)
                }
                
              //var statement = "INSERT INTO \(tableName) ("
                var statement = "REPLACE INTO \(tableName) ("
              
                //add all fields requird to the sql statment
            
                for field in validFields
                {
                    statement += field.replacingOccurrences(of: "'", with: "''")
                    
                    if field != validFields.last
                    {
                         statement += ","
                    }
                    else{
                        statement += ")"
                    }
                }
                
                statement += " Values("
                
                 for field in validFields
                 {
                    let fieldValue = dataDictionary[field]!
                    statement += "'" + fieldValue.replacingOccurrences(of: "'", with: "''") + "'"
                    
                    if field != validFields.last
                    {
                        statement += ","
                    }
                    else{
                        statement += ");"
                    }
                }
                
                print ("SQL statment: \(statement)")
               
                var insertStatement: OpaquePointer? = nil
                
                if sqlite3_prepare_v2(db, statement, -1, &insertStatement, nil) == SQLITE_OK {
       
                    if sqlite3_step(insertStatement) == SQLITE_DONE {
                        print("Successfully inserted row.")
                    } else {
                        print("Could not insert row.")
                    }
                } else {
                    print("INSERT statement could not be prepared.")
                }
               
                sqlite3_finalize(insertStatement)
              
            }
        }
    }
    
    class func deleteData(dataDictionary:[String:String], fromTable tableName:String, inDBFile dbFileName:String)
    {
        self.deleteData(dataArray: [dataDictionary], fromTable: tableName, inDBFile: dbFileName)
    }
    
    class func deleteData(dataArray:[[String:String]], fromTable tableName:String, inDBFile dbFileName:String)
    {
        autoreleasepool {
            
            if let db = SQLmanager.openDatabase(dbFileName)
            {
                for dataDictionary in dataArray
                {
                    var statement = "DELETE FROM " + tableName + " WHERE "
                    
                    var queryKeys = [String]()
                    for key in dataDictionary.keys
                    {
                        queryKeys.append(key)
                    }
                    
                    for key in queryKeys
                    {
                        statement += key + "=" + "'\(dataDictionary[key]!)'"
                        
                        if key != queryKeys.last
                        {
                            statement += " AND "
                        }
                    }
                    
                    print ("SQL statment: \(statement)")
                    
                    var deleteStatement: OpaquePointer? = nil
                    if sqlite3_prepare_v2(db, statement, -1, &deleteStatement, nil) == SQLITE_OK {
                        if sqlite3_step(deleteStatement) == SQLITE_DONE {
                            print("Successfully deleted row.")
                        } else {
                            print("Could not delete row.")
                        }
                    } else {
                        print("DELETE statement could not be prepared")
                    }
                    
                    sqlite3_finalize(deleteStatement)
                }
                sqlite3_close(db)
            }
        }
    }
}

