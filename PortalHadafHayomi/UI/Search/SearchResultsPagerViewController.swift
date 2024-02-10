//
//  SearchResultsPagerViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/06/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SearchResultsPagerViewController: MSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var pagesCollectionView:UICollectionView?
    
    @IBOutlet weak var lockRotationContentView:UIView!
    @IBOutlet weak var lockRotationButton:UIButton!
    @IBOutlet weak var lockRotationArrowImageView:UIImageView!
    
     var talmudSearchResults = [SearchTalmudResult]()
    
    override func reloadWithObject(_ object: Any) {
        self.talmudSearchResults = object as! [SearchTalmudResult]
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.pagesCollectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pagesCollectionView?.semanticContentAttribute = .forceRightToLeft
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    
    @IBAction func lockRotationButtonClicked(_ sender:UIButton)
    {
        self.lockRotationButton.isSelected = !self.lockRotationButton.isSelected
        
        //If should rotate
        if self.lockRotationButton.isSelected == false
        {
            self.rotated()
        }
    }
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func rotated()
    {
        if self.lockRotationButton.isSelected
        {
            self.lockRotationArrowImageView.rotateAnimation(duration: 0.6, repeatCount:2.0)
            
            return
        }
        
        self.pagesCollectionView?.translatesAutoresizingMaskIntoConstraints = true
        self.lockRotationContentView.translatesAutoresizingMaskIntoConstraints = true
        
        if UIDevice.current.orientation.isLandscape {
            
            self.setLandscapeLayout()
        }
        else {
            
            //Is alredy in protert mode
            if self.pagesCollectionView?.superview == self.view
            {
                return
            }
            self.setProtraitLayout()
        }
    }
    
    func setLandscapeLayout()
    {
        var rotationAngle:Double!
        
        if pagesCollectionView == nil
        {
            return
        }
        
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.pagesCollectionView!.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.pagesCollectionView!.indexPathsForVisibleItems.first!
        }
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let colletoinCenterOnRootView = self.view.convert(self.pagesCollectionView!.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.pagesCollectionView!)
        self.pagesCollectionView?.center = colletoinCenterOnRootView
        
        if UIDevice.current.orientation == .landscapeLeft
        {
            rotationAngle = Double.pi/2
        }
        else if UIDevice.current.orientation == .landscapeRight
        {
            rotationAngle = -Double.pi/2
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.pagesCollectionView?.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
                let collectionFrameSize = CGSize(width: rootViewController.view.bounds.size.width, height: rootViewController.view.bounds.size.height)
                let collectionCenter = CGPoint(x: collectionFrameSize.width/2, y: collectionFrameSize.height/2)
                
                self.pagesCollectionView?.frame.size = collectionFrameSize
                self.pagesCollectionView?.center = collectionCenter
                
                if let flowLayout = self.pagesCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                self.pagesCollectionView?.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
        }, completion: {_ in
            
            let lockRotationCenter = self.view.convert(self.lockRotationContentView.center, to:rootViewController.view)
            rootViewController.view.addSubview(self.lockRotationContentView)
            self.lockRotationContentView.center = lockRotationCenter
            
            self.lockRotationContentView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        })
    }
    
    func setProtraitLayout()
    {
        if pagesCollectionView == nil
        {
            return
        }
        
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.pagesCollectionView!.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.pagesCollectionView!.indexPathsForVisibleItems.first!
        }
        
        let rotationAngle = 0
        
        let collectionHeight = self.view.bounds.size.height - (self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height)
        
        let collectionFrameSize = CGSize(width: self.view.bounds.size.width, height:collectionHeight)
        
        let topButtonsHeight:CGFloat = 35.0
        let collectionCenterY = (self.topBarView!.frame.origin.y + self.topBarView!.frame.size.height + topButtonsHeight) + (collectionHeight/2)
        let collectionCenter = CGPoint(x:  collectionFrameSize.width/2, y: collectionCenterY)
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let lockRotationCenter = rootViewController.view.convert(self.lockRotationContentView.center, to:self.topBarView!)
        self.topBarView!.addSubview(self.lockRotationContentView)
        self.lockRotationContentView.center = lockRotationCenter
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.pagesCollectionView?.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                self.lockRotationContentView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
                
                self.pagesCollectionView?.frame.size = collectionFrameSize
                self.pagesCollectionView?.center = collectionCenter
                
                if let flowLayout = self.pagesCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                self.pagesCollectionView?.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
                
        }, completion: {_ in
            
            let colletoinCenter = rootViewController.view.convert(self.pagesCollectionView!.center, to:self.view)
            self.view.addSubview(self.pagesCollectionView!)
            self.pagesCollectionView?.center = colletoinCenter
            self.view.sendSubviewToBack(self.pagesCollectionView!)
            
            
        })
    }
    
    //MARK: - CollectionView Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.talmudSearchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalmudPageCell", for: indexPath) as! TalmudPageCell
        
        let searchResult = talmudSearchResults[indexPath.row]
        
        let pageIndex = Int(searchResult.pageId!) ?? 1
        cell.reloadWithObject(pageIndex)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStop()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStop()
        }
    }
    
    func scrollViewDidStop()
    {
        self.pagesCollectionView?.scrollToNearestVisibleCell()
        
        /*
        let pageIndex = self.pagesCollectionView?.centerRowIndex() ?? -1
        
        let pageInfo = HadafHayomiManager.pageInfoForIndexInTalmud(pageIndex + 1)
        
        self.displyedMasceht = pageInfo["maschet"] as? Masechet
        self.displyedPage = pageInfo["page"] as! Page
        self.displyedPageSide =  pageInfo["pageSide"] as! Int
        
        self.topBarTitleLabel?.text = HadafHayomiManager.dispalyTitleForMaschet(self.displyedMasceht!, page: self.displyedPage, pageSide: self.displyedPageSide )
 */
    }
    
    //MARK: = TalmudPagePickerView delegate meothods
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didChangeComponent component:Int)
    {
    }
    
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didHide:Bool)
    {
        
    }
}
