//
//  AramicDictionaryCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 07/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class AramicDictionaryCell: MSBaseTableViewCell {

    var aramicWord:TranslatedWord!
    
    @IBOutlet weak var keyLabel:UILabel!
    @IBOutlet weak var valueLabel:UILabel!
    @IBOutlet weak var sourceLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func reloadWithObject(_ object:Any){
        
        self.aramicWord = object as? TranslatedWord
        
        self.keyLabel.text = aramicWord.keyDispaly
        self.valueLabel.text = aramicWord.translatoin
        self.sourceLabel.text = aramicWord.sorce
    }

}
