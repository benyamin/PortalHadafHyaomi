//
//  MasechtPagesCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 22 Adar I 5779.
//  Copyright © 5779 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MasechtPagesCell: MSBaseTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var pageSelectingCellDelegate:PageSelectingCellDelegate?
    
    var masechet:Masechet?
    var pages:[Page]?
    
    let pageCellHeight = CGFloat(44)
    
    var selectedPagesIndexs = [Int]()
    
    var displayPages = false
    
    @IBOutlet weak var checkBoxButton:UIButton?
    
    @IBOutlet weak var pagesCollectionView:UICollectionView?
    @IBOutlet weak var pagesCollectionViewHeightConstraint:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pagesCollectionView?.semanticContentAttribute = .forceRightToLeft
        
        var checkBoxOffImage = UIImage(named: "Checkbox_off.png")
        checkBoxOffImage = UIImage.imageWithTintColor(checkBoxOffImage!, color: UIColor(HexColor: "FAF2DD"))
        self.checkBoxButton?.setImage(checkBoxOffImage, for: .normal)
        
        var checkBoxOnImage = UIImage(named: "Checkbox_on.png")
        checkBoxOnImage = UIImage.imageWithTintColor(checkBoxOnImage!, color: UIColor(HexColor: "FAF2DD"))
        self.checkBoxButton?.setImage(checkBoxOnImage, for: .selected)
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.masechet = object as? Masechet
        self.pages = masechet?.pages
                
        self.reloadData()
    }
    
    override func reloadData() {
                
        self.updateDisplay()
        self.pagesCollectionView?.reloadData()
    }
    
    func updateDisplay() {
        if self.displayPages
            ,let pagesCount = self.pages?.count
        {
            let numberOfRows = Int(pagesCount/4) + 1//((CGFloat(savedPagesCount))/4).round(.up)
            self.pagesCollectionViewHeightConstraint?.constant = CGFloat(numberOfRows) * self.pageCellHeight + CGFloat(2 * numberOfRows)           
        }
        else{
            self.pagesCollectionViewHeightConstraint?.constant = 0
        }
    }
    
    @IBAction func checkBoxButtonClicked(_ sener:UIButton)
    {
        self.checkBoxButton?.isSelected = !(self.checkBoxButton?.isSelected ?? true)
        
        if self.pages != nil
        {
            for page in self.pages!
            {
                page.isSelected = self.checkBoxButton?.isSelected ?? false
            }
        }
        
        self.pagesCollectionView?.reloadData()
    }
    
    //MARK: - CollectionView Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.pages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageSelectingCell", for: indexPath) as! PageSelectingCell
        
        cell.delegate = self.pageSelectingCellDelegate
        
        let page = self.pages![indexPath.row]
        cell.reloadWithObject(page)
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.bounds.size.width-6)/4
        return CGSize(width: width, height: self.pageCellHeight)
    }
}
