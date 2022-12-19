//
//  UIView+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 9/10/15.
//  Copyright (c) 2015 Binyamin Trachtman. All rights reserved.
//

import UIKit

private var _isTintable:Bool = false

extension UIView
{
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as? UIViewController
            }
        }
        return nil
    }
    
    public class func viewWithNib(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        
        return UIView.loadFromNibNamed(nibNamed, bundle: bundle)
    }
    
    public class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        
        return UINib(
            
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    public class func initWithNibName(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        var bundle = bundle
        
        let view = self.init()

        if bundle == nil
        {
            bundle = Bundle.main
        }
        
        let xibs =  bundle!.loadNibNamed(nibNamed, owner: view, options: nil)
        
        if (xibs?.count)! > 0
        {
            let xibView = Bundle.main.loadNibNamed(nibNamed, owner: view, options: nil)?[0] as! UIView
            view.backgroundColor = UIColor.clear
            view.clipsToBounds = xibView.clipsToBounds
            view.frame = xibView.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(xibView)
     
            /*
            
            xibView.addConstraint(NSLayoutConstraint.constraintsWithi
            [xibView addConstraint:[NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
            
            [xibView addConstraint:[NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
            
            [xibView addConstraint:[NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
            
            [xibView addConstraint:[NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
                
                */
                
            
             return view
        }
        else
        {
            return nil
        }
    }
    
    public var isTintable : Bool {
        get
        {
            return _isTintable
        }
        
        set(boolValue)
        {
            _isTintable = boolValue
        }
    }
    
   public func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    public func addSidedConstraints()
    {
        if let superView = self.superview
        {
            let bottomConstraint = NSLayoutConstraint(item:  self, attribute: .bottom, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .bottom, multiplier: 1, constant: 0)
            superView.addConstraint(bottomConstraint)
            
            let topConstraint = NSLayoutConstraint(item:  self, attribute: .top, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .top, multiplier: 1, constant: 0)
            superView.addConstraint(topConstraint)
            
            let leadingConstraint = NSLayoutConstraint(item:  self, attribute: .leading, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .leading, multiplier: 1, constant: 0)
            superView.addConstraint(leadingConstraint)
            
            let trailingConstraint = NSLayoutConstraint(item:  self, attribute: .trailing, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .trailing, multiplier: 1, constant: 0)
            superView.addConstraint(trailingConstraint)
            
            // self.leadingAnchor.constraint(equalTo: superView.layoutMarginsGuide.leadingAnchor).isActive = true
            // self.trailingAnchor.constraint(equalTo: superView.layoutMarginsGuide.trailingAnchor).isActive = true
            
            
        }
    }
    
        public func addSidedConstraints(top:Bool, bottom:Bool, leading:Bool, trailing:Bool)
    {
        if let superView = self.superview
        {
            if top
            {
                let topConstraint = NSLayoutConstraint(item:  self, attribute: .top, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .top, multiplier: 1, constant: 0)
                superView.addConstraint(topConstraint)
            }
            
            if bottom
            {
                let bottomConstraint = NSLayoutConstraint(item:  self, attribute: .bottom, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .bottom, multiplier: 1, constant: 0)
                superView.addConstraint(bottomConstraint)
            }
            
            
            if leading
            {
                let leadingConstraint = NSLayoutConstraint(item:  self, attribute: .leading, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .leading, multiplier: 1, constant: 0)
                superView.addConstraint(leadingConstraint)
            }
            
            if trailing
            {
                let trailingConstraint = NSLayoutConstraint(item:  self, attribute: .trailing, relatedBy: NSLayoutRelation.equal, toItem:  superView, attribute: .trailing, multiplier: 1, constant: 0)
                superView.addConstraint(trailingConstraint)
            }
        }
    }
    
    public func bottom() -> CGFloat
    {
       return  self.frame.origin.y + self.frame.size.height
    }
    
    public func rotateAnimation(duration: CFTimeInterval = 2.0, repeatCount:Float)
    {
        //Rotate 360
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = repeatCount//Float.greatestFiniteMagnitude;
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    public func constraintForAttribute(_ attirbute:NSLayoutAttribute) -> NSLayoutConstraint?
    {
        for constraint in self.constraints
        {
            if constraint.firstAttribute == attirbute
         //   || constraint.secondAttribute == attirbute
            {
                return constraint
            }
        }
        return  nil
    }
    
    public func bottomConstraint() -> NSLayoutConstraint?
    {
        return self.getConstrintForAttribute(.bottom)
    }
    
    public func getConstrintForAttribute(_ attirbute:NSLayoutAttribute) -> NSLayoutConstraint?
    {
        for constraint in self.constraints
        {
            //Top bar height constraint
            if constraint.firstAttribute == attirbute
            {
                return constraint
            }
        }
        
        return nil
    }
    
    public func setLocalizatoin()
    {
        for subView in self.subviews
        {
            if subView is UILabel
            {
                let label = (subView as! UILabel)
                
                if let text = label.text
                {
                    var key = "st_\(text.lowercased())"
                    key = key.replacingOccurrences(of: " ", with: "_")
                    let LocalizedString = key.localize()
                    
                    //Check the string has a localized value
                    label.text = LocalizedString.hasPrefix("st_") == false ? LocalizedString : text
                }
            }
            else{
                subView.setLocalizatoin()
            }
        }
    }
    
    func centerBounds() -> CGPoint {
        return CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
}
