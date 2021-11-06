//
//  TalmudPagePickerViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 01/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol TalmudPagePickerViewControllerDelegate: class
{
    func talmudPagePickerViewControllerDidChange(_ talmudPagePickerViewController:TalmudPagePickerViewController, component:Int)
}

class TalmudPagePickerViewController: MSBaseViewController,TalmudPagePickerViewDelegate
{
    weak var delegate:TalmudPagePickerViewControllerDelegate?
    
    @IBOutlet weak var selectPageTitleLabel:UILabel?
    
    var selectedMasechet:Masechet?{
        get{
            return self.talmudPagePickerView.selectedMasechet
        }
    }
    
    var selectedPage:Page?{
        get{
            return self.talmudPagePickerView.selectedPage
        }
    }
    var selectedPageSide:Int?{
        get{
            return self.talmudPagePickerView.selectedPageSide
        }
    }
    
    @IBOutlet weak var talmudPagePickerView:TalmudPagePickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talmudPagePickerView.delegate = self
        
        self.selectPageTitleLabel?.text = "st_select_page".localize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         self.scrollToTodaysPage()
        
        self.talmudPagePickerView.shouldHighlightSavedPages = true
    }
    
    func scrollToTodaysPage()
    {
        let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet!
        let todaysPage = HadafHayomiManager.sharedManager.todaysPage!
        
        self.talmudPagePickerView.scrollToMasechet(todaysMaschet, page: todaysPage, pageSide: 1, animated: false)
        
      //  self.scrollToMaschet(todaysMaschet, page: todaysPage, pageSide:0,  animated: false)
    }
    
    func scrollToMaschet(_ maschet:Masechet, page:Page, pageSide:Int, animated:Bool)
    {
         self.talmudPagePickerView.scrollToMasechet(maschet, page: page, pageSide:pageSide, animated: animated)
    }
    
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didChangeComponent component:Int)
    {
        self.delegate?.talmudPagePickerViewControllerDidChange(self, component:component)
    }
    
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didHide:Bool)
    {
        
    }
    
    @IBAction func saveMultiplePageButtonClicked(_ sender:UIButton) {
                
        if let pageRangePickerView = UIView.viewWithNib("TalmudPageRangePickerView") as? TalmudPageRangePickerView {
           
            let arrowHight = CGFloat(15)
            let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: arrowHight))
            arrow.image = UIImage.imageWithTintColor(UIImage(named: "Triangle.png")!, color: UIColor(HexColor: "791F23"))
            
            let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 260, height: pageRangePickerView.frame.size.height + arrowHight))
            popUpView.addSubview(arrow)
            popUpView.layer.cornerRadius = 3.0
            arrow.center = CGPoint(x: sender.frame.origin.x, y:  arrow.center.y)
            pageRangePickerView.layer.borderColor = UIColor(HexColor:"791F23").cgColor
            
            pageRangePickerView.layer.borderWidth = 2.0
            pageRangePickerView.layer.cornerRadius = 3.0
            pageRangePickerView.frame.origin.y = arrowHight
            pageRangePickerView.frame.size.width = popUpView.frame.size.width
            popUpView.addSubview(pageRangePickerView)
            let options = [
                .type(.down)
                ] as [PopoverOption]
            
          
            let popover = Popover(options: options, showHandler: nil, dismissHandler: {
                self.talmudPagePickerView.reloadData()
            })
            popover.show(popUpView, fromView: sender, inView: self.view)
            
            if let selectedMasechet =  self.talmudPagePickerView.selectedMasechet
                ,let selectedPage =  self.talmudPagePickerView.selectedPage {
                
                let currentPageIndex = HadafHayomiManager.sharedManager.pageIndexFor(selectedMasechet, page: selectedPage, pageSide: 1)
                
                pageRangePickerView.reloadWithObject(currentPageIndex)
            }
        }
    }
    
}
