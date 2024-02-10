//
//  BTProgressCircleView.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 12/08/2016.
//
//

import UIKit

class BTProgressCircleView: UIView {
    
    var precentageLabel:UILabel!
    var circleLayer:CAShapeLayer!
    var activityIndicatorView:UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        let defaultCircleLayer = CAShapeLayer()
        
        let defaultCirclePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2,y: frame.size.width/2), radius: (frame.size.width-10)/2, startAngle: CGFloat(0), endAngle:CGFloat(.pi * 2.0), clockwise: true)
        
        defaultCircleLayer.path = defaultCirclePath.cgPath
        defaultCircleLayer.fillColor = UIColor.clear.cgColor
        defaultCircleLayer.strokeColor = UIColor(red: 255/255, green: 219/255, blue: 119/255, alpha: 1.0).cgColor
        defaultCircleLayer.lineWidth = 3.0
        
        self.layer.addSublayer(defaultCircleLayer)

        
        circleLayer = CAShapeLayer()

        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2,y: frame.size.width/2), radius: (frame.size.width-10)/2, startAngle: CGFloat(0), endAngle:CGFloat(.pi * 2.0), clockwise: true)
        
        circleLayer.path = circlePath.cgPath
    
        
        //change the fill color
        circleLayer.fillColor = UIColor.clear.cgColor
        
        //you can change the stroke color
        circleLayer.strokeColor = UIColor(red: 111/255, green: 37/255, blue: 35/255, alpha: 1.0).cgColor
        
        //you can change the line width
        circleLayer.lineWidth = 3.0
        
        self.layer.addSublayer(circleLayer)
        
        self.precentageLabel = UILabel(frame:self.bounds)
        //self.precentageLabel.frame.origin.y += 5
        precentageLabel.textAlignment = .center
        precentageLabel.text = "100%"
        precentageLabel.font = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.thin)
        
        self.addSubview(precentageLabel)
        self.precentageLabel.isHidden = true
        
        self.activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.activityIndicatorView.center = precentageLabel.center
        self.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
    }
    
    func updatePrecnetage(precentage:Float)
    {
        if precentage > 0
        {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
             self.precentageLabel.isHidden = false
        }
        else{
             self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
            self.precentageLabel.isHidden = true
        }
        
        let endAngle = Double.pi * Double(precentage * 2)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2,y: frame.size.width/2), radius: (frame.size.width-10)/2, startAngle: CGFloat(0), endAngle:CGFloat(endAngle), clockwise: true)
        
        self.circleLayer.path = circlePath.cgPath
        
        precentageLabel.text = "\(Int(precentage * 100))%"
    }

}
