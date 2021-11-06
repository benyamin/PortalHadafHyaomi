//
//  IPlayerProtocol.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 08/09/2016.
//
//

import Foundation
import AVFoundation

protocol IPlayerProtocolDelegate: class {
    
    func playerIsReadyToPlay(player:IPlayerProtocol)
    func playerFailed(player:IPlayerProtocol)
    func playerDidUpdateInfo(player:IPlayerProtocol)
    func playerDidStop(player:IPlayerProtocol)
}

protocol  IPlayerProtocol
{
    var delegate: IPlayerProtocolDelegate { get set }
    
    var subTitle : String { get set }
    
    func setup()
    
    func play()
    func stop()
    func pause()
    func status() -> String
    func removeTimeObserver(observer: Any)
    func setPlayerItemPath(itemPathUrl:URL?)
    func isActive() -> Bool
    func isPlaying() -> Bool
    func duration() -> CMTime?
    func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Swift.Void)
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Void) -> Any
    func currentTime() -> CMTime
    func setRate(_ rate:Float)
    func rate() -> Float
    
    func setTitle(_ title:String)
    func getTitle() -> String
    
    func setSubTitle(_ title:String)
    func getSubTitle() -> String

}
