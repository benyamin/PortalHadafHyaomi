//
//  LoadingDataTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 13/06/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class LoadingDataTableCell: MSBaseTableViewCell {

   @IBOutlet public weak var loadingGifImageview:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadingGifImageview?.image = UIImage.gifWithName("ajax-loader")
    }
    
    override func reloadData() {
        self.loadingGifImageview?.image = UIImage.gifWithName("ajax-loader")
    }

}
