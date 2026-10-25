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
    
    // MARK: - Rotation
    // The iPad now uses a real iOS rotation (like the iPhone Talmud screen) instead of turning
    // the page with a transform. Landscape: side menu + page (or full screen page).
    // Portrait: the page fills the whole screen. A real rotation also keeps the PDF sharp.
    
    /// The orientations AppDelegate allows for the iPad layout (changed by the lock button)
    static var allowedOrientations:UIInterfaceOrientationMask = .all
    
    private var appliedLayout:String?
    
    @IBAction func lockRotationButtonClicked(_ sender:UIButton)
    {
        self.lockRotationButton.isSelected = !self.lockRotationButton.isSelected
        
        if self.lockRotationButton.isSelected
        {
            // Lock to the current orientation
            let orientation = self.view.window?.windowScene?.interfaceOrientation ?? .landscapeLeft
            switch orientation {
            case .portrait: Main_IPadViewController.allowedOrientations = .portrait
            case .portraitUpsideDown: Main_IPadViewController.allowedOrientations = .portraitUpsideDown
            case .landscapeRight: Main_IPadViewController.allowedOrientations = .landscapeRight
            default: Main_IPadViewController.allowedOrientations = .landscapeLeft
            }
        }
        else
        {
            Main_IPadViewController.allowedOrientations = .all
        }
        self.updateSupportedOrientations()
    }
    
    func updateSupportedOrientations()
    {
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return Main_IPadViewController.allowedOrientations
    }
    
    @IBAction func fullScreenButtonClicked(_ sender:UIButton)
    {
        self.fullScreenButton.isSelected =  !self.fullScreenButton.isSelected
        self.applyLayoutForCurrentSize(force: true, animated: true)
    }
    
    /// Device turned while the screen is locked: show the lock button is holding it
    @objc func rotated()
    {
        let deviceOrientation = UIDevice.current.orientation
        if !deviceOrientation.isPortrait && !deviceOrientation.isLandscape { return }
        
        if self.lockRotationButton.isSelected
        {
            let isPortraitScreen = self.view.bounds.height > self.view.bounds.width
            if deviceOrientation.isPortrait != isPortraitScreen
            {
                self.lockRotationButton.rotateAnimation(duration: 0.6, repeatCount:2.0)
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.applyLayoutForCurrentSize(force: false, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        let currentIndex = self.currentPageIndexPath()
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.applyLayoutForCurrentSize(force: true, animated: false, keepIndex: currentIndex)
        }, completion: { _ in
            self.scrollTalmudBack(to: currentIndex)
        })
    }
    
    func applyLayoutForCurrentSize(force:Bool, animated:Bool, keepIndex:IndexPath? = nil)
    {
        let size = self.view.bounds.size
        let layout:String
        if size.height > size.width {
            layout = "portrait"
        } else if self.fullScreenButton.isSelected {
            layout = "fullLandscape"
        } else {
            layout = "landscape"
        }
        if !force && layout == self.appliedLayout { return }
        self.appliedLayout = layout
        
        let currentIndex = keepIndex ?? self.currentPageIndexPath()
        
        switch layout {
        case "portrait":      self.setPortraitDisplay(currentIndex, animated: animated)
        case "fullLandscape": self.setFullLandscapeDisplay(currentIndex, animated: animated)
        default:              self.setLandscapeDisplay(currentIndex, animated: animated)
        }
    }
    
    /// The page in the middle of the screen (the first visible cell can be the neighbour page)
    func currentPageIndexPath() -> IndexPath
    {
        guard let collectionView = self.talmudViewController.pagesCollectionView else { return IndexPath(row: 0, section: 0) }
        let row = collectionView.centerRowIndex()
        if row >= 0 && row < collectionView.numberOfItems(inSection: 0) {
            return IndexPath(row: row, section: 0)
        }
        return collectionView.indexPathsForVisibleItems.first ?? IndexPath(row: 0, section: 0)
    }
    
    private func scrollTalmudBack(to indexPath:IndexPath)
    {
        guard let collectionView = self.talmudViewController.pagesCollectionView else { return }
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        if indexPath.row < collectionView.numberOfItems(inSection: 0) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func setMainContainerFrame(_ frame:CGRect, onTop:Bool, currentIndex:IndexPath, animated:Bool)
    {
        self.mainContainerView.translatesAutoresizingMaskIntoConstraints = true
        self.mainContainerView.transform = .identity
        if self.mainContainerView.superview !== self.view {
            self.view.addSubview(self.mainContainerView)
        }
        if onTop {
            self.view.bringSubviewToFront(self.mainContainerView)
        } else {
            self.view.sendSubviewToBack(self.mainContainerView)
        }
        
        let changes = {
            self.mainContainerView.frame = frame
            self.mainContainerView.layoutIfNeeded()
            self.scrollTalmudBack(to: currentIndex)
        }
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .allowUserInteraction, animations: changes, completion: { _ in
                self.scrollTalmudBack(to: currentIndex)
            })
        } else {
            changes()
            DispatchQueue.main.async { self.scrollTalmudBack(to: currentIndex) }
        }
    }
    
    /// Portrait: the page fills the whole screen
    func setPortraitDisplay(_ currentIndex:IndexPath, animated:Bool)
    {
        self.setMainContainerFrame(self.view.bounds, onTop: true, currentIndex: currentIndex, animated: animated)
    }
    
    /// Landscape, full screen button on: the page fills the whole screen
    func setFullLandscapeDisplay(_ currentIndex:IndexPath, animated:Bool)
    {
        self.setMainContainerFrame(self.view.bounds, onTop: true, currentIndex: currentIndex, animated: animated)
    }
    
    /// Landscape: page next to the side menu
    func setLandscapeDisplay(_ currentIndex:IndexPath, animated:Bool)
    {
        let frame = CGRect(x: 0, y: 0,
                           width: self.view.bounds.width - self.sideContainerViewWidthConstraint.constant,
                           height: self.view.bounds.height)
        self.setMainContainerFrame(frame, onTop: false, currentIndex: currentIndex, animated: animated)
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

