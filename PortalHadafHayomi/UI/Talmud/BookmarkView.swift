//
//  BookmarkView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 15/04/2023.
//  Copyright © 2023 Binyamin Trachtman. All rights reserved.
//

import UIKit

class BookmarkView: UIView {

    private var locationIndicatorView:UIView!
    
    open var onDidMoveTo:((_ point:CGPoint) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        let bookmarkWidth = CGFloat(60)
        let origenY = CGFloat(30)
        
        super.init(frame: CGRect(x: frame.size.width - bookmarkWidth - 6 , y: origenY, width:bookmarkWidth, height: frame.size.height-(origenY*2)))
        self.backgroundColor = .clear
        
        let barViewWidh = CGFloat(6)
        let barView = UIView(frame: CGRect(x: bookmarkWidth - 14 , y: 0, width: barViewWidh, height: self.bounds.height))
        barView.backgroundColor = .lightGray
        barView.layer.borderColor = UIColor.blue.cgColor
        barView.layer.borderWidth = 1
        barView.layer.cornerRadius = barViewWidh/2
        self.addSubview(barView)
        
        let locationIndicatorWidth = frame.size.width-30
        self.locationIndicatorView = UIView(frame: CGRect(x: -1*locationIndicatorWidth + self.frame.size.width, y: 0, width:locationIndicatorWidth, height: 60))
        self.locationIndicatorView.backgroundColor = UIColor.clear

        let locationLineView = UIView(frame: CGRect(x: 0, y: self.locationIndicatorView.frame.size.height/2-1, width:self.locationIndicatorView.frame.size.width-10, height: 2))
        locationLineView.backgroundColor = .blue
        locationLineView.alpha = 0.4
        self.locationIndicatorView.addSubview(locationLineView)
        
        let bookMarkImageView = UIImageView(frame:CGRect(x: self.locationIndicatorView.frame.size.width-30, y: self.locationIndicatorView.frame.size.height/2-10, width: 30, height: 20))
        bookMarkImageView.image = UIImage(named: "bookmark.png")
        bookMarkImageView.contentMode = .scaleAspectFit
        self.locationIndicatorView.addSubview(bookMarkImageView)

        self.addSubview(self.locationIndicatorView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
               self.addGestureRecognizer(panGesture)
        bookMarkImageView.isUserInteractionEnabled = true
        self.locationIndicatorView.addGestureRecognizer(panGesture)
     
        self.clipsToBounds = false
    }
        
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
          guard gesture.view != nil else { return }
          
          let translation = gesture.translation(in: gesture.view?.superview)
          
          var newY = gesture.view!.center.y + translation.y
          
          
          // Limit the movement to stay within the bounds of the screen
        newY = max(16, newY)
        newY = min(self.bounds.height - 16, newY)
          
        let newCenterPoint = CGPoint(x: gesture.view!.center.x, y: newY)
        gesture.view?.center = newCenterPoint
        gesture.setTranslation(CGPoint.zero, in: gesture.view?.superview)
        
        self.onDidMoveTo?(newCenterPoint)
      }
    
    func scroll(to point:Double, animated:Bool){
        
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
            self.locationIndicatorView.center = CGPoint(x:self.locationIndicatorView.center.x , y: point)
        }, completion: {_ in
        })
    }
}
