//
//  UILabel+Extras.swift
//  TravelSystems
//
//  Created by Binyamin Trachtman on 2/28/16.
//  Copyright © 2016 Binyamin Trachtman. All rights reserved.
//

import UIKit

private var clickableSubstring:String!
private var tapTarget:NSObject!
private var tapAction:Selector!
private var tapGesture:UITapGestureRecognizer!

public extension UILabel
{
    var optimalHeight : CGFloat
        {
        get
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = self.lineBreakMode
            label.font = self.font
            label.text = self.text
            
            label.sizeToFit()
            
            return label.frame.height
        }
    }
    
    func showblockingView()
    {
       let blockingView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/2))
        blockingView.center = CGPoint(x: blockingView.center.x, y: self.frame.size.height/2)
        blockingView.tag = 333
        blockingView.backgroundColor = UIColor.lightGray
        self.addSubview(blockingView)
    }
    
    func hideblockingView()
    {
         if let blockingView = self.viewWithTag(333)
         {
            blockingView.removeFromSuperview()
        }
    }
    
    func addClickableSubString(target: NSObject, action: Selector, subString:String)
    {
        if tapGesture == nil
        {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            self.addGestureRecognizer(tapGesture)
            self.isUserInteractionEnabled = true
        }
        
        self.attributedText =  self.text?.addAttribute(["name":NSAttributedStringKey.foregroundColor.rawValue,"value": UIColor.blue], ToSubString: subString, ignoreCase:false)
        
        clickableSubstring = subString
        tapTarget = target
        tapAction = action
    }
    
    @objc func handleTap(_ tapRecognizer: UITapGestureRecognizer)
    {
        
        if let _ = self.boundingRectForSubString(clickableSubstring)
        {
             //print ("print:\(touchPoint)")
               // print ("clickableRect:\(clickableRect)")
                 tapTarget.perform(tapAction, with: nil)
        }
    }
    
    func boundingRectForSubString(_ subString:String) -> CGRect? {
        
        let range = (self.text! as NSString).range(of: subString)
         guard let attributedText = attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        
        layoutManager.addTextContainer(textContainer)
        
        var glyphRange = NSRange()
        
        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
       
    }

}
