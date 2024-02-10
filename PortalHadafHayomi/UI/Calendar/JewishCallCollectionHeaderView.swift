//
//  JewishCallCollectionHeaderView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class JewishCallCollectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var monthNameLabel:UILabel!
    @IBOutlet weak var daysContentView:UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        
         self.setLocalizatoin()
    }
    
    func reloadWithMonth(_ month:CallendarMonth)
    {
        if month is HebrewMonth
        {
            self.monthNameLabel.attributedText = self.titleTextForHebrewMonth(month as! HebrewMonth)
        }
        else if month is GregorianMonth
        {
             self.monthNameLabel.attributedText = self.titleTextForGregorianMonth(month as! GregorianMonth)
        }
    }
    
    func titleTextForHebrewMonth(_ month:HebrewMonth) -> NSAttributedString
    {
        var text = ""
        
        var hebrowDateDispalyText = ""
        hebrowDateDispalyText += Calendar.hebrew.monthDisaplyName(from: month.startDayDate, forLocal: "he_IL")
        hebrowDateDispalyText += " - "
        hebrowDateDispalyText += Calendar.hebrew.yearDisaplyName(from: month.startDayDate, forLocal:"he_IL")
        
        var gregorianDateDispalyText = "( "
        let gregorianFirstDayMonth = Calendar.gregorian.monthDisaplyName(from: month.startDayDate, forLocal: "en_US")
        gregorianDateDispalyText += gregorianFirstDayMonth
        
        let gregorianLastDayMonth = Calendar.gregorian.monthDisaplyName(from: month.endDayDate, forLocal: "en_US")
        
        if gregorianLastDayMonth != gregorianFirstDayMonth
        {
            gregorianDateDispalyText += "-" + gregorianLastDayMonth
        }
        
        let gregorianFirstDayYear = Calendar.gregorian.yearDisaplyName(from: month.startDayDate, forLocal:"en_US")
        gregorianDateDispalyText += " " + gregorianFirstDayYear
        
        let gregorianlastDayYear = Calendar.gregorian.yearDisaplyName(from: month.endDayDate, forLocal:"en_US")
        
        if gregorianlastDayYear != gregorianFirstDayYear
        {
            gregorianDateDispalyText += "-" + gregorianlastDayYear
        }
        
        gregorianDateDispalyText += " )"
        text += hebrowDateDispalyText + " " + gregorianDateDispalyText
        
        let attributedText = text.addAttribute(["name":NSAttributedString.Key.font.rawValue,"value": UIFont.boldSystemFont(ofSize: 11)], ToSubString: gregorianDateDispalyText, ignoreCase:true)
        
        return attributedText
    }
    
    func titleTextForGregorianMonth(_ month:GregorianMonth) -> NSAttributedString
    {
        var text = ""
        
        var gregorianDateDispalyText = ""
        gregorianDateDispalyText += Calendar.gregorian.monthDisaplyName(from: month.startDayDate, forLocal: "en_US")
        gregorianDateDispalyText += " - "
        gregorianDateDispalyText += Calendar.gregorian.yearDisaplyName(from: month.startDayDate, forLocal:"en_US")
        
        var hebrewDateDispalyText = "( "
        let hebrewFirstDayMonth = Calendar.hebrew.monthDisaplyName(from: month.startDayDate, forLocal: "he_IL")
        hebrewDateDispalyText += hebrewFirstDayMonth
        
        let hebrewLastDayMonth = Calendar.hebrew.monthDisaplyName(from: month.endDayDate, forLocal: "he_IL")
        
        if hebrewLastDayMonth != hebrewFirstDayMonth
        {
            hebrewDateDispalyText += "-" + hebrewLastDayMonth
        }
        
        let hebrewFirstDayYear = Calendar.hebrew.yearDisaplyName(from: month.startDayDate, forLocal:"he_IL")
        hebrewDateDispalyText += " " + hebrewFirstDayYear
        
        let hebrewlastDayYear = Calendar.hebrew.yearDisaplyName(from: month.endDayDate, forLocal:"he_IL")
        
        if hebrewlastDayYear != hebrewFirstDayYear
        {
            hebrewDateDispalyText += "-" + hebrewlastDayYear
        }
        
        hebrewDateDispalyText += " )"
        text += gregorianDateDispalyText + " " + hebrewDateDispalyText
        
        let attributedText = text.addAttribute(["name":NSAttributedString.Key.font.rawValue,"value": UIFont.boldSystemFont(ofSize: 11)], ToSubString: hebrewDateDispalyText, ignoreCase:true)
        
        return attributedText
    }
}
