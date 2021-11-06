//
//  HebrewUtil.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 29/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

public class HebrewUtil
{
    public static let sharedUtil =  HebrewUtil()
    
    lazy var numToHebDictioarny:[Int:String] = {
        
        let numbersArray:[Int] = [1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,200,300,400]
        let lettersArray:[String] = ["א","ב","ג","ד","ה","ו","ז","ח","ט","י","כ","ל","מ","נ","ס","ע","פ","צ","ק","ר","ש","ת"]
        
        var numtoHebDictioarny = [Int:String]()
        
        for index in 0 ..< numbersArray.count
        {
            numtoHebDictioarny[ numbersArray[index]] = lettersArray[index]
        }
        
        return numtoHebDictioarny
    }()
    
    class func hebrewDisplayFromNumber(_ number:Int) -> String
    {
        var decimalArray = [Int]()
        
        var fractionNumber = number
        
        var decimalLocatoin = 1
        while fractionNumber > 0
        {
            decimalArray.append((fractionNumber%10) * decimalLocatoin)
            
            fractionNumber = fractionNumber/10
            
            decimalLocatoin *= 10
        }
        
        var hebrewDisplayFromNumber = ""
        
        decimalArray = decimalArray.reversed()
        for decimal in decimalArray
        {
            if let hebLetterForNumber = HebrewUtil.sharedUtil.numToHebDictioarny[decimal]
            {
                hebrewDisplayFromNumber = hebrewDisplayFromNumber + hebLetterForNumber
            }
        }
        
        if hebrewDisplayFromNumber.hasSuffix("יה")
        {
            hebrewDisplayFromNumber = (hebrewDisplayFromNumber as NSString).replacingOccurrences(of: "יה", with: "טו")
        }
        else if hebrewDisplayFromNumber.hasSuffix("יו")
        {
            hebrewDisplayFromNumber = (hebrewDisplayFromNumber as NSString).replacingOccurrences(of: "יו", with: "טז")
        }
        
        return hebrewDisplayFromNumber
    }
}
