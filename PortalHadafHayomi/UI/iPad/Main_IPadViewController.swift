//
//  Main_IPadViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 31/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class Main_IPadViewController: UIViewController, HomeViewControllerDelegate
{
    @IBOutlet weak var sideContainerView:UIView!
    @IBOutlet weak var mainContainerView:UIView!
    @IBOutlet weak var sideContainerViewWidthConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var lockRotationButton:UIButton!
    
    @IBOutlet weak var fullScreenButton:UIButton!
    
    @IBOutlet weak var topBarButtonsContentView:UIView!
    @IBOutlet weak var topBarButtonsContentViewTopConstraint:NSLayoutConstraint!
    
    var presenterdViewController:UIViewController?

    
    lazy var homeViewController:HomeViewController = {
        
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let homeViewController =  storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.delegate = self
        
        return homeViewController
    }()
    
    lazy var talmudViewController:Talmud_IPadViewController = {
        
        let talmudViewController = UIViewController.withName("Talmud_IPadViewController", storyBoardIdentifier: "TalmudStoryboard")
        return talmudViewController  as! Talmud_IPadViewController
    }()
    
    lazy var mapViewController:Map_IPadViewController = {
        
        let mapViewController = UIViewController.withName("Map_IPadViewController", storyBoardIdentifier: "MapStoryboard")
        
        return mapViewController  as! Map_IPadViewController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sideContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        sideContainerView.layer.shadowOpacity = 0.5
        sideContainerView.layer.shadowOffset = CGSize(width:-2.0, height:0.0)
        sideContainerView.layer.shadowRadius = 2.0
        
        self.presentViewController(self.talmudViewController, onContainer: self.mainContainerView)
        self.presentViewController(self.homeViewController, onContainer: self.sideContainerView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    

    func presentViewController(_ viewController:MSBaseViewController, onContainer container:UIView)
    {
        self.presenterdViewController = viewController
        
        let controllerView = viewController.view
        controllerView!.frame = container.bounds
        
        if container == self.sideContainerView
        {
            viewController.view.clipsToBounds = true
        }
        
        container.addSubview(viewController.view)
        
        viewController.topBarImageView?.image = UIImage(named: "topBar750.png")

        if container == self.mainContainerView
        {
            if let topBar = viewController.topBarView
            {
                self.topBarButtonsContentViewTopConstraint.constant = topBar.frame.size.height/2 - 15
            }
            self.mainContainerView.bringSubviewToFront(self.topBarButtonsContentView)
        }
      /*
        viewController.topBarHeightConstraint?.constant = 60
 */

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
    
    @IBAction func fullScreenButtonClicked(_ sender:UIButton)
    {
        self.fullScreenButton.isSelected =  !self.fullScreenButton.isSelected
        
        if self.lockRotationButton.isSelected
        {
            return
        }
        
        if UIDevice.current.orientation.isPortrait
        {
            return
        }
        else if self.fullScreenButton.isSelected
        {
            self.setFullLandscapeDisplay()
        }
        else{
            self.setLandscapeDisplay()
        }
        
    }
    
    /// The page in the middle of the screen (the first visible cell can be the neighbour page)
    func currentPageIndexPath() -> IndexPath
    {
        let collectionView = self.talmudViewController.pagesCollectionView!
        let row = collectionView.centerRowIndex()
        if row >= 0 && row < collectionView.numberOfItems(inSection: 0) {
            return IndexPath(row: row, section: 0)
        }
        return collectionView.indexPathsForVisibleItems.first ?? IndexPath(row: 0, section: 0)
    }
    
    @objc func rotated()
    {
        // iPhone Duo (open): iOS rotates the screen itself, no manual turning of the page
        if UIDevice.current.userInterfaceIdiom != .pad
        {
            return
        }
        
        // Ignore face up / face down / unknown, so lying the iPad flat does not turn the page
        let deviceOrientation = UIDevice.current.orientation
        if !deviceOrientation.isPortrait && !deviceOrientation.isLandscape
        {
            return
        }
        
        if self.lockRotationButton.isSelected
        {
            self.lockRotationButton.rotateAnimation(duration: 0.6, repeatCount:2.0)
            
            return
        }
        
        self.mainContainerView.translatesAutoresizingMaskIntoConstraints = true
        
        if UIDevice.current.orientation.isPortrait {
            
            self.setPortraitDisplay()
        }
        else {
            if self.fullScreenButton.isSelected
            {
                self.setFullLandscapeDisplay()
            }
            else{
                self.setLandscapeDisplay()
            }
            
        }
    }
    
    func setPortraitDisplay()
    {
        let currentIndex = self.currentPageIndexPath()
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let colletoinCenterOnRootView = self.view.convert(self.mainContainerView.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.mainContainerView)
        self.mainContainerView.center = colletoinCenterOnRootView
        
        // The iPad screens stay in landscape, so in portrait the page is turned 90°.
        // Which way depends on which landscape side the screen is in;
        // using one fixed angle showed the page upside down on the other side.
        let interfaceOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .landscapeLeft
        var rotationAngle = (interfaceOrientation == .landscapeRight) ? -Double.pi/2 : Double.pi/2
        if UIDevice.current.orientation == .portraitUpsideDown {
            rotationAngle = -rotationAngle
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.mainContainerView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
                if let flowLayout = self.talmudViewController.pagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                // With a rotation, "frame" can't be set (iOS keeps the old landscape size, so the page
                // did not fill the screen). Set the size and center instead: the turned page is
                // as wide as the screen is tall, and as tall as the screen is wide.
                let rootBounds = rootViewController.view.bounds
                self.mainContainerView.bounds = CGRect(x: 0, y: 0, width: rootBounds.height, height: rootBounds.width)
                self.mainContainerView.center = CGPoint(x: rootBounds.midX, y: rootBounds.midY)
                self.mainContainerView.layoutIfNeeded()
                
                self.talmudViewController.pagesCollectionView.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
                
        }, completion: {_ in
            
        })
    }
    
    func setFullLandscapeDisplay()
    {
        let currentIndex = self.currentPageIndexPath()
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let colletoinCenterOnRootView = self.view.convert(self.mainContainerView.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.mainContainerView)
        self.mainContainerView.center = colletoinCenterOnRootView
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.mainContainerView.transform = .identity

                if let flowLayout = self.talmudViewController.pagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                self.mainContainerView.frame = rootViewController.view.bounds
                self.mainContainerView.layoutIfNeeded()
                
                self.talmudViewController.pagesCollectionView.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
                
        }, completion: {_ in
            
        })
    }
    
    func setLandscapeDisplay()
    {
        let currentIndex = self.currentPageIndexPath()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.mainContainerView.transform = .identity
                
                if let flowLayout = self.talmudViewController.pagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
                {
                    flowLayout.invalidateLayout()
                }
                
                self.mainContainerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - self.sideContainerViewWidthConstraint.constant, height: self.view.frame.height)
                
                self.mainContainerView.layoutIfNeeded()
                
                self.talmudViewController.pagesCollectionView.selectItem(at: currentIndex, animated: false, scrollPosition: .centeredHorizontally)
                
                
        }, completion: {_ in
            
            self.view.addSubview(self.mainContainerView)
            self.view.sendSubviewToBack(self.mainContainerView)
        })
    }
    
    //MARK: HomeViewController Delegate Methods
    func shouldHandleMenuItem(_ menuItem:MenuItem) -> Bool
    {
        switch menuItem.name
        {
        case "Talmud":
            
            self.presentViewController(self.talmudViewController, onContainer: self.mainContainerView)
             return false
            
        case "LessonMap":
            self.presentViewController(self.mapViewController, onContainer: self.mainContainerView)
            return false
            
        default:
            
            self.presentViewController(self.talmudViewController, onContainer: self.mainContainerView)
            
            return false
        }
    }
}

