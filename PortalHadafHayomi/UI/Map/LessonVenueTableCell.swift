//
//  LessonVenueTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 18/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol LessonVenueTableCellDelegate: class
{
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, showLessonOnMap lessonVenue:LessonVenue)
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, showNavigationOptions lessonVenue:LessonVenue)
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, share lessonVenue:LessonVenue)
    func lessonVenueTableCell(_ lessonVenueTableCell:LessonVenueTableCell, connect lessonVenue:LessonVenue)
}

class LessonVenueTableCell: MSBaseTableViewCell {

    weak var delegate:LessonVenueTableCellDelegate?
    
    var lessonVenue:LessonVenue!
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var informatoinLabel:UILabel!
    @IBOutlet weak var showOnMapButton:UIButton?
    @IBOutlet weak var distanceLabel:UILabel?
    @IBOutlet weak var connectButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.showOnMapButton?.setTitle("st_show_on_map".localize(), for: .normal)
        self.connectButton?.setTitle("st_connect_venue_publisher".localize(), for: .normal)
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.lessonVenue = object as? LessonVenue
        
        self.titleLabel.text = self.lessonVenue.city + " - " + self.lessonVenue.maggid
        
        self.informatoinLabel.text = self.lessonVenue.dispalyedInformation
        
        if self.lessonVenue.distanceFromUser > 0 {
            self.distanceLabel?.isHidden = false
            
            if let currentLanguage = Locale.current.languageCode
                ,currentLanguage.hasSuffix("en") {
                
                let distanceInMiles = self.lessonVenue.distanceFromUser * 0.621371
                self.distanceLabel?.text = "st_distance_from_user".localize(withArgumetns: [ String(format: "%.2f", distanceInMiles)])
            }
            else{
                self.distanceLabel?.text = "st_distance_from_user".localize(withArgumetns: [ String(format: "%.2f", self.lessonVenue.distanceFromUser)])
            }
        }
        else{
            self.distanceLabel?.isHidden = true
        }
    }
    
    @IBAction func showOnMapButtonClicked(_ sender:UIButton)
    {
        self.delegate?.lessonVenueTableCell(self, showLessonOnMap: self.lessonVenue)
    }
    
    @IBAction func navigationButtonClicked(_ sender:UIButton)
    {
        self.delegate?.lessonVenueTableCell(self, showNavigationOptions: self.lessonVenue)
    }
    
    @IBAction func shareButtonClicked(_ sender:UIButton)
    {
        self.delegate?.lessonVenueTableCell(self, share: self.lessonVenue)
    }
    
    @IBAction func connectButtonClicked(_ sender:UIButton)
    {
        self.delegate?.lessonVenueTableCell(self, connect: self.lessonVenue)
    }
}
