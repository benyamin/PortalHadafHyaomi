//
//  BTPlayerManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 14/10/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

public class  BTPlayerManager {
    
    static let sharedManager =  BTPlayerManager()
    
    lazy var player:IPlayerProtocol! = {
        
        let player = BTAVPlayer()
        player.setup()
        
        return player
    }()
    
    lazy var sharedPlayerView:BTPlayerView! = {
        
        let audioPlayer = Bundle.main.loadNibNamed("BTPlayerView", owner: nil, options: nil)![0] as! BTPlayerView
        
        return audioPlayer
    }()
}
