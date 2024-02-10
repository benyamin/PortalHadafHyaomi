//
//  SearchResultTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/06/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SearchResultTableCell: MSBaseTableViewCell {
    
    var searchResult:SearchTalmudResult?
    
    @IBOutlet weak var resultPageLabel:UILabel?
    @IBOutlet weak var resultSourceLabel: UILabel?
    @IBOutlet weak var resultTextLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func reloadWithObject(_ object:Any){
        
        self.searchResult = object as? SearchTalmudResult
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.resultPageLabel?.text = searchResult?.page
        self.resultTextLabel?.text = searchResult?.text
        
        if let source = searchResult?.source
        {
           self.resultSourceLabel?.text = "(" + source + ")"
        }
        
        if self.resultTextLabel != nil
        {
            
            if let text = searchResult?.text
            {
                self.resultTextLabel?.attributedText = self.setBoldText(searchResult!.searchText, inText:text)
            }
        }
    }
    
    func setBoldText(_ boldString:String, inText text:String) -> NSAttributedString?
    {
        do {
            
            let attributedText = NSMutableAttributedString(string: text)
            
            let regex = try NSRegularExpression(pattern: ("(?<=)\(boldString)"))
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            for result in results
            {
                
                let boldFont = UIFont.boldSystemFont(ofSize: self.resultTextLabel!.font.pointSize+1)
                attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: result.range)
            }
            
            return attributedText
            
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    func makeMatchingPartBold(myLabel:UILabel, searchText: String) {
        
        // check label text & search text
        guard
            let labelText = myLabel.text
            else {
                return
        }
        
        // bold attribute
        let boldAttr = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: myLabel.font.pointSize)]
        
        // check if label text contains search text
        if let matchRange: Range = labelText.lowercased().range(of: searchText.lowercased()) {
            
            // get range start/length because NSMutableAttributedString.setAttributes() needs NSRange not Range<String.Index>
            let matchRangeStart: Int = labelText.distance(from: labelText.startIndex, to: matchRange.lowerBound)
            let matchRangeEnd: Int = labelText.distance(from: labelText.startIndex, to: matchRange.upperBound)
            let matchRangeLength: Int = matchRangeEnd - matchRangeStart
            
            // create mutable attributed string & bold matching part
            let newLabelText = NSMutableAttributedString(string: labelText)
            newLabelText.setAttributes(boldAttr, range: NSMakeRange(matchRangeStart, matchRangeLength))
            
            // set label attributed text
            myLabel.attributedText = newLabelText
        }
    }
    
}
