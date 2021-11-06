//
//  BTLoadingView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

public class BTLoadingView: UIView {
    
    @IBOutlet public weak var loadingGifImageview:UIImageView!
    
    @IBOutlet public weak var loadingImageBackGroundView:UIView!
    
    @IBOutlet public weak var errorMessageLabel:UILabel!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.errorMessageLabel.isHidden = true
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingGifImageview.image = UIImage.gifWithName("ajax-loader")
        
        self.loadingImageBackGroundView.layer.cornerRadius = 5.0
    }
    
}
