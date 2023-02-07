//
//  AVPlayerViewControllerExtension.swift
//  AVPlayerViewController-Subtitles
//
//  Created by Crt Gregoric on 11/02/2022.
//  Copyright © 2022 Marc Hervera. All rights reserved.
//

import AVKit

#if os(iOS)
public extension AVPlayerViewController {
    
    private struct AssociatedKeys {
        static var FontKey = "FontKey"
        static var ColorKey = "FontKey"
        static var SubtitleKey = "SubtitleKey"
        static var SubtitleHeightKey = "SubtitleHeightKey"
        static var PayloadKey = "PayloadKey"
        static var SubtitleViewKey = "SubtitleViewKey"
    }
    
    // MARK: - Public properties
    
    fileprivate var subtitleView: SubtitleView? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleViewKey) as? SubtitleView }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleViewKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
 
    
    fileprivate var subtitleViewHeightConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey) as? NSLayoutConstraint }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private properties
    
    fileprivate var parsedPayload: NSDictionary? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.PayloadKey) as? NSDictionary }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.PayloadKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Public methods
    
    func addSubtitles() {
        // Create label
        addSubtitleView()
    }
    
    func open(fileFromLocal filePath: URL, encoding: String.Encoding = .utf8) throws {
        let contents = try String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL, encoding: String.Encoding = .utf8) {
        subtitleView?.textLabel?.text = "..."
        let dataTask = URLSession.shared.dataTask(with: filePath) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                //Check status code
                if statusCode != 200 {
                    NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                    return
                }
            }
            
            // Update UI elements on main thread
            DispatchQueue.main.async {
                self.subtitleView?.textLabel.text = ""
                if let checkData = data as Data?, let contents = String(data: checkData, encoding: encoding) {
                    self.show(subtitles: contents)
                }
            }
        }
        dataTask.resume()
    }
    
    func show(subtitles string: String) {
        // Parse
        parsedPayload = try! Subtitles.parseSubRip(string)
        if let parsedPayload = parsedPayload {
            addPeriodicNotification(parsedPayload: parsedPayload)
        }
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        // Add Dictionary content direct to Payload
        parsedPayload = dictionaryContent
        if let parsedPayload = parsedPayload {
            addPeriodicNotification(parsedPayload: parsedPayload)
        }
    }
    
    func addPeriodicNotification(parsedPayload: NSDictionary) {
        // Add periodic notifications
        let interval = CMTimeMake(1, 60)
        self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let strongSelf = self, let label = strongSelf.subtitleView?.textLabel else {
                return
            }
            
            // Search && show subtitles
            label.text = Subtitles.searchSubtitles(strongSelf.parsedPayload, time.seconds)
            
            // Adjust size
            let baseSize = CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude)
            let rect = label.sizeThatFits(baseSize)
            if label.text != nil {
                strongSelf.subtitleViewHeightConstraint?.constant = rect.height + 5.0
            } else {
                strongSelf.subtitleViewHeightConstraint?.constant = rect.height
            }
        }
    }
    
    fileprivate func addSubtitleView() {
        guard subtitleView == nil else {
            return
        }
        
        // Label
        subtitleView = SubtitleView.create()
        subtitleView?.translatesAutoresizingMaskIntoConstraints = false
        subtitleView?.layer.cornerRadius = 6
        //let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 40.0 : 22.0
        //subtitleView?.textLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
       // subtitleView?.textLabel?.shadowOffset = CGSize(width: 1.0, height: 1.0)
       // subtitleView?.textLabel?.layer.shadowOpacity = 0.9
       // subtitleView?.textLabel?.layer.shadowRadius = 1.0
       // subtitleView?.textLabel?.layer.shouldRasterize = true
       // subtitleView?.textLabel?.layer.rasterizationScale = UIScreen.main.scale
       // subtitleView?.textLabel?.lineBreakMode = .byWordWrapping
        
        contentOverlayView?.addSubview(subtitleView!)
        subtitleView!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subtitleView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        subtitleView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -20).isActive = true
        subtitleView!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true

        
        // Position
        /*
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[l]-(20)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleView!])
        contentOverlayView?.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[l]-(30)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleView!])
        contentOverlayView?.addConstraints(constraints)
        subtitleViewHeightConstraint = NSLayoutConstraint(item: subtitleView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 30.0)
        
        contentOverlayView?.addConstraint(subtitleViewHeightConstraint!)
         */
    }
    
}
#endif
