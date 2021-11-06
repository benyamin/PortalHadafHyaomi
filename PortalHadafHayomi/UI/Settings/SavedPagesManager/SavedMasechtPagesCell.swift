//
//  SavedMasechtPagesCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 14/02/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SavedMasechtPagesCell: MSBaseTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var masechet:Masechet?
    var savedPages:[Page]?
    
    let pageCellHeight = CGFloat(44)
    
    var selectedPagesIndexs = [Int]()
    
    @IBOutlet weak var masechetNameLabel:UILabel?
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
        self.savedPages = masechet?.savedPages
      
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.masechetNameLabel?.text = self.masechet?.name
        
        if let savedPagesCount = self.savedPages?.count
        {
            let numberOfRows = Int(savedPagesCount/4) + 1//((CGFloat(savedPagesCount))/4).round(.up)
            self.pagesCollectionViewHeightConstraint?.constant = CGFloat(numberOfRows) * self.pageCellHeight + CGFloat(2 * numberOfRows)

        }
        self.pagesCollectionView?.reloadData()
    }
    
     @IBAction func checkBoxButtonClicked(_ sener:UIButton)
     {
        self.checkBoxButton?.isSelected = !(self.checkBoxButton?.isSelected ?? true)
        
        if self.savedPages != nil
        {
            for page in self.savedPages!
            {
                page.isSelected = self.checkBoxButton?.isSelected ?? false
            }
        }
        
        self.pagesCollectionView?.reloadData()
    }
    
    //MARK: - CollectionView Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.savedPages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageSelectingCell", for: indexPath) as! MSBaseCollectionViewCell
        
        cell.reloadWithObject(self.savedPages![indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.bounds.size.width-6)/4
        return CGSize(width: width, height: self.pageCellHeight)
    }
}
