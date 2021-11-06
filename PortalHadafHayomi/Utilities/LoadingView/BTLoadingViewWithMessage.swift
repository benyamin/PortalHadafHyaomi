//
//  BTLoadingViewWithMessage.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 23/10/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

public class BTLoadingViewWithMessage: UIView {
    
    @IBOutlet public weak var loadingGifImageview:UIImageView?
    
    @IBOutlet public weak var loadingImageBackGroundView:UIView?
    
    @IBOutlet public weak var messageLabel:UILabel?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageLabel?.text = "st_system_is_downloading_speech_audio_files".localize()
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingGifImageview?.image = UIImage.gifWithName("ajax-loader")
        
        self.loadingImageBackGroundView?.layer.cornerRadius = 5.0
    }
    
}
