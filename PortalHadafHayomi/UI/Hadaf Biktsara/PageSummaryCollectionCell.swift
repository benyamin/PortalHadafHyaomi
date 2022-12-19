//
//  PageSummaryCollectionCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/05/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class PageSummaryCollectionCell: MSBaseCollectionViewCell, UITextViewDelegate
{
    var pageSummary:PageSummary?
    var textSize = 18
    
    var getPagSummaryProcess:GetPagSummaryProcess?
    
    @IBOutlet weak var cardView:UIView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var valueTextView:UITextView!
    @IBOutlet weak var loadingGifImageview:UIImageView?
    @IBOutlet weak var errorMessageLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView.layer.borderWidth = 1.0
        self.cardView.layer.borderColor =  UIColor(HexColor:"6A2423").cgColor
        self.cardView.layer.cornerRadius = 3.0
        
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.pageSummary = object as? PageSummary
        
        if let summary = self.pageSummary?.summary
            , summary.count > 0 {
            self.reloadData()
        }
        else{
            self.getPageSummary()
        } 
    }
    
    override func reloadData() {
                
        self.errorMessageLabel?.isHidden = true
        self.loadingGifImageview?.isHidden = true
        if var summary = self.pageSummary?.summary
        {
            //If summary is empty
            if summary.count == 0 {
                 self.errorMessageLabel?.text = "st_page_summary_empty_error".localize()
                self.errorMessageLabel?.isHidden = false
            }
            
            self.titleLabel.text = self.pageSummary?.key
            
            let style = "<style>body {text-align: right; font-size:\(self.textSize)px; }</style>"

            self.valueTextView.attributedText = summary.htmlAttributedString(style:style)
        }
        else{
            self.titleLabel.text = self.pageSummary?.key
            self.valueTextView.text = ""
        }
    }
    
    func getPageSummary(){
        
        var params = [String:String]()
        params["massechet"] = "\(self.pageSummary?.maseceht?.index ?? 0)"
        params["dafid"] = "\((self.pageSummary?.pageIndex ?? 0)+1)"
        
       self.getPagSummaryProcess?.cancel()
        
        self.loadingGifImageview?.image = UIImage.gifWithName("ajax-loader")
         self.loadingGifImageview?.isHidden = false
        
        self.getPagSummaryProcess =  GetPagSummaryProcess()
        
        self.getPagSummaryProcess?.executeWithObject(params, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.pageSummary?.summary = object as? String
            
            self.reloadData()
            
            self.loadingGifImageview?.image = nil
             self.loadingGifImageview?.isHidden = true

            
        },onFaile: { (object, error) -> Void in
            
            self.errorMessageLabel?.text = "st_page_summary_download_error".localize()
            
            self.errorMessageLabel?.isHidden = false
            
            self.loadingGifImageview?.image = nil
             self.loadingGifImageview?.isHidden = true
        })
    }
}
    
    //MARK: - UIText
