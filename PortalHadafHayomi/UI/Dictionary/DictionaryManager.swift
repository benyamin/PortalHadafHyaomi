//
//  DictionaryManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 07/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

class DictionaryManager
{
    static let sharedManager =  DictionaryManager()
    
    lazy var aramicWords:[TranslatedWord] = {
        
        let plistPath = Bundle.main.path(forResource: "AramicWordTranslation", ofType: "plist")
        let aramicWordsInfo = NSArray(contentsOfFile: plistPath!) as? [[String]]
        
        var aramicWords = [TranslatedWord]()
        for wordInfo in aramicWordsInfo!
        {
            var aramicWordInfo = [String:String]()
            
            aramicWordInfo["keyDispaly"] =  wordInfo[0]
            aramicWordInfo["key"] = wordInfo[1]
            aramicWordInfo["translatoin"] = wordInfo[2]
            aramicWordInfo["translatoin_clean"] = wordInfo[3]
            aramicWordInfo["sorce"] = wordInfo[4]
            
            aramicWords.append(TranslatedWord(info: aramicWordInfo))
        }
        
        return aramicWords
        
    }()
    
    lazy var hebrewWords:[TranslatedWord] = {
        
        var hebrewWords = [TranslatedWord]()
        
        for aramicWord in self.aramicWords
        {
            var hebrewWordInfo = [String:String]()
          
            let words = aramicWord.translatoin.components(separatedBy: ";")
            let cleanWords = aramicWord.translatoin_clean.components(separatedBy: ";")
            
            var hebrewWordsKeys = [String]()
            
            for word in words
            {
                hebrewWordInfo["keyDispaly"] = word.trimmeSideSpaces()
                
                var key = ""
                
                if let index = words.index(of: word)
                    ,index < cleanWords.count
                {
                    key = cleanWords[index].trimmeSideSpaces()
                }
                else{
                    key = word.trimmeSideSpaces()
                }
                
                key = key.replacingOccurrences(of: "(", with: "")
                key = key.replacingOccurrences(of: ")", with: "")
                key = key.replacingOccurrences(of: "\"", with: "")
                
                hebrewWordInfo["key"] = key

                hebrewWordInfo["translatoin"] = aramicWord.keyDispaly
                hebrewWordInfo["sorce"] = aramicWord.sorce
                
                let hebrewWord = TranslatedWord(info: hebrewWordInfo)
                
                if hebrewWordsKeys.contains(hebrewWord.key) == false
                    && hebrewWord.keyDispaly.count > 0
                {
                    hebrewWords.append(hebrewWord)
                    hebrewWordsKeys.append(hebrewWord.key)
                    
                    /*
                    if let existingHebrewWord = hebrewWords.filter( { return $0.translatoin == hebrewWord.translatoin } ).first
                    {
                        existingHebrewWord.translatoin += "; " + hebrewWord.translatoin
                        
                        print ("\(existingHebrewWord.key): \(existingHebrewWord.translatoin)")
                        
                    }
                     */
                }
            }
        }
        
        return hebrewWords.sorted(by: { $0.key < $1.key })
        
    }()
    
    func translateWord(_ word:String, fromDictioanry dictioanry:[TranslatedWord]) -> String?
    {
        //check if the category for the articale dos exsist in the articlesCategorysarray
        if let wordIndex = dictioanry.index(where: {$0.key == word})
        {
            return dictioanry[wordIndex].defaultTranslatoin
        }
        else if word.count > 2
        {
            let index = word.index(word.startIndex, offsetBy:1)
            var firstLeatr = String(word[..<index])
            let cutWord = String(word[index...])
            
            if let wordIndex = dictioanry.index(where: {$0.key == cutWord})
            {
                var translatedWord = dictioanry[wordIndex].defaultTranslatoin
                
                if dictioanry == self.aramicWords
                {
                    if firstLeatr == "ד"
                    {
                        firstLeatr = "ש"
                    }
                }
                
                translatedWord = firstLeatr + translatedWord
                return translatedWord
            }
        }
      return nil
    }
}
