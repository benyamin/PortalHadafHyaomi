//
//  AboutViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 19/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class AboutViewController: MSBaseViewController {

    @IBOutlet weak var displaySegmentedControlr:UISegmentedControl!
    @IBOutlet weak var infoWebView:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set selected index to show About information
        self.displaySegmentedControlr.selectedSegmentIndex = 0
        self.loadWebWithPath("https://app.daf-yomi.com/mobile/content.aspx?id=241")
        
        self.displaySegmentedControlr.setTitle("st_about".localize(), forSegmentAt: 0)
        
        self.displaySegmentedControlr.setTitle("st_messages".localize(), forSegmentAt: 1)
        
        self.displaySegmentedControlr.setTitle("st_regulations".localize(), forSegmentAt: 2)
        
        let segmentFontAttribute = [NSAttributedString.Key.font: UIFont(name: "BroshMF", size: 18)!,
                                    NSAttributedString.Key.foregroundColor: UIColor(HexColor: "FAF2DD")]
        
        let segmentSelectedFontAttribute = [NSAttributedString.Key.font: UIFont(name: "BroshMF", size: 18)!,
                                            NSAttributedString.Key.foregroundColor: UIColor(HexColor:"7F2B30")]
        
        displaySegmentedControlr.setTitleTextAttributes(segmentFontAttribute, for: .normal)
        displaySegmentedControlr.setTitleTextAttributes(segmentSelectedFontAttribute, for: .selected)        
    }
    
    @IBAction func displaySegmentedControlrValueChanged(_ sedner:AnyObject)
    {
        if self.displaySegmentedControlr.selectedSegmentIndex == 0//Show About Information
        {
            self.loadWebWithPath("https://app.daf-yomi.com/mobile/content.aspx?id=241")
        }
        
        else if self.displaySegmentedControlr.selectedSegmentIndex == 1//Show messages
        {
            self.loadWebWithPath("https://app.daf-yomi.com/mobile/content.aspx?id=288")
        }
        
       else if self.displaySegmentedControlr.selectedSegmentIndex == 2//Show Terms and conditions
        {
            self.loadWebWithPath("https://app.daf-yomi.com/mobile/content.aspx?id=242")
        }
    }
    
    func loadWebWithPath(_ urlPath:String)
    {
        if let url = URL(string: urlPath)
        {
            let requestObj = URLRequest(url: url)
            
            if self.infoWebView.isLoading
            {
                self.infoWebView.stopLoading()
            }
            self.infoWebView.loadRequest(requestObj)
        }
    }

}
