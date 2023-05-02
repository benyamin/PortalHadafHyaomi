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
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
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
             self.mainContainerView.bringSubview(toFront: self.topBarButtonsContentView)
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
    
    @objc func rotated()
    {
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
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.talmudViewController.pagesCollectionView.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.talmudViewController.pagesCollectionView.indexPathsForVisibleItems.first!
        }
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let colletoinCenterOnRootView = self.view.convert(self.mainContainerView.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.mainContainerView)
        self.mainContainerView.center = colletoinCenterOnRootView
        
        let rotationAngle = UIDevice.current.orientation == .portrait ?  Double.pi/2 : -Double.pi/2
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.mainContainerView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
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
    
    func setFullLandscapeDisplay()
    {
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.talmudViewController.pagesCollectionView.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.talmudViewController.pagesCollectionView.indexPathsForVisibleItems.first!
        }
        
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let colletoinCenterOnRootView = self.view.convert(self.mainContainerView.center, to:rootViewController.view)
        rootViewController.view.addSubview(self.mainContainerView)
        self.mainContainerView.center = colletoinCenterOnRootView
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
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
        var currentIndex = IndexPath(row: 0, section: 0)
        if self.talmudViewController.pagesCollectionView.indexPathsForVisibleItems.count > 0
        {
            currentIndex = self.talmudViewController.pagesCollectionView.indexPathsForVisibleItems.first!
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
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
            self.view.sendSubview(toBack: self.mainContainerView)
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

