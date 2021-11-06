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
}

class LessonVenueTableCell: MSBaseTableViewCell {

    weak var delegate:LessonVenueTableCellDelegate?
    
    var lessonVenue:LessonVenue!
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var informatoinLabel:UILabel!
    @IBOutlet weak var showOnMapButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.showOnMapButton?.setTitle("st_show_on_map".localize(), for: .normal)
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.lessonVenue = object as? LessonVenue
        
        self.titleLabel.text = self.lessonVenue.city + " - " + self.lessonVenue.maggid
        
        self.informatoinLabel.text = self.lessonVenue.dispalyedInformation
    }
    
    @IBAction func showOnMapButtonClicked(_ sender:UIButton)
    {
        self.delegate?.lessonVenueTableCell(self, showLessonOnMap: self.lessonVenue)
    }

}
