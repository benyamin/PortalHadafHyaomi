//
//  HomeViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/11/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

@objc protocol HomeViewControllerDelegate: class {
    func shouldHandleMenuItem(_ menuItem:MenuItem) -> Bool
}


class HomeViewController: MSBaseViewController,UICollectionViewDelegate, UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource
{
    weak var delegate:HomeViewControllerDelegate?
    
    @IBOutlet weak var menuButton:UIButton!
    @IBOutlet weak var logoImageView:UIImageView!
    @IBOutlet weak var mainViewContainer:UIView!
    @IBOutlet weak var currentDateLabel:UILabel!
    @IBOutlet weak var currentPageLabel:UILabel!
    @IBOutlet weak var logoAndTextImageView:UIImageView!
    @IBOutlet weak var menuCollectoinView:UICollectionView!
    @IBOutlet weak var bottomBarCollectionView:UICollectionView?
    @IBOutlet weak var counterLabel:UILabel?
    
    @IBOutlet weak var bottomMenuView:UIView!
    @IBOutlet weak var bottomMenuViewBottomConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var sideMenuView:UIView!
    @IBOutlet weak var sideMenuAlfhaView:UIView!
    @IBOutlet weak var sideMenuTableView:UIView!
    
    @IBOutlet weak var rateUsButtonLabel:UILabel?
    @IBOutlet weak var contactUsButtonLabel:UILabel?
    
    @IBOutlet weak var whatsAppButton:UIButton?
    
    weak var dispalyedViewController:UIViewController?
    
    lazy var talmudPagePickerViewController:TalmudPagePickerViewController = {
        
        let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
        let talmudPagePickerViewController =  storyboard.instantiateViewController(withIdentifier: "TalmudPagePickerViewController") as! TalmudPagePickerViewController
        
        return talmudPagePickerViewController
        
    }()
    
    lazy var talmudNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("TalmudStoryboard", rootViewController: "TalmudViewController")
    }()
    
    lazy var lessonsNavigationController:UINavigationController = {
        
         return self.navControllerForStoryBoard("LessonsStoryboard", rootViewController: "LessonsViewController")
    }()
    
    lazy var articalesNavigationController:UINavigationController = {
        
         return self.navControllerForStoryBoard("ArticlesStoryboard", rootViewController: "ArticalesCategorysViewController")

    }()
    
    lazy var aramicDictionaryNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("AramicDictioanryStoryboard", rootViewController: "AramicDictionaryViewController")
        
    }()
    
    lazy var aboutNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("AboutStoryboard", rootViewController: "AboutViewController")
        
    }()
    
    lazy var accessoriesListNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("AccessoriesStoryboard", rootViewController: "AccessoriesListViewController")
        
    }()
    
    lazy var mapViewNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("MapStoryboard", rootViewController: "MapViewController")
        
    }()
    
    lazy var lessonVenuesListViewController:LessonVenuesListViewController = {
        
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
        let lessonVenuesListViewController =  storyboard.instantiateViewController(withIdentifier: "LessonVenuesListViewController") as! LessonVenuesListViewController
        
        return lessonVenuesListViewController
    }()
    
    lazy var contactUsWebView:BTWebViewController! = {
        
        let viewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        
        return viewController
    }()
    
    lazy var calendarNavigationController:UINavigationController = {
        
        let calendarNavigationController = self.navControllerForStoryBoard("CalendarStoryboard", rootViewController: "CalendarViewController")
        
        if let calendarViewController = calendarNavigationController.viewControllers.first as? CalendarViewController {
            calendarViewController.onDisplayPageForDate = { (date) in
                
                if let masechet = HadafHayomiManager.sharedManager.maschetForDate(date)
                    , let page = HadafHayomiManager.sharedManager.pageForDate(date, addOnePage:true){
                    
                    //For IPad
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        if let mainIpadViewController = UIApplication.shared.keyWindow?.rootViewController as? Main_IPadViewController {
                            
                            mainIpadViewController.talmudViewController.scrollToMaschet(masechet, page: page, pageSide:0,  animated: false)
                        }
                    }
                    else{
                          self.present(self.talmudNavigationController, animated: false, completion: nil)
                        
                        if let talmudViewController = self.talmudNavigationController.viewControllers.first as? TalmudViewController {
                            talmudViewController.scrollToMaschet(masechet, page: page, pageSide:0,  animated: false)
                        }
                    }
                }
            }
        }
        return calendarNavigationController
    }()
    
    lazy var hadafHayomiProjectNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("HadafHayomiProjectStoryboard", rootViewController: "HadafHayomiProjectViewController")
    }()
    
    lazy var surveysNavigationController:UINavigationController = {
      
        
         return self.navControllerForStoryBoard("SurveysStoryboard", rootViewController: "SurveyViewController")
      //  return self.navControllerForStoryBoard("SurveysStoryboard", rootViewController: "SurveysViewController")
    }()
    
    lazy var pagesSummaryNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("PageSummaryStoryboard", rootViewController: "PageSummaryViewController")
    }()
    
    lazy var siyumMasechetNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("SiyumMasechetStoryboard", rootViewController: "SiyumAccessoriesViewController")
    }()
    
    lazy var QndANavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("QandAStoryboard", rootViewController: "QandATopicsViewController")
    }()
    
    lazy var SearchTalmudNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("SearchTalmudStoryboard", rootViewController: "SearchTalmudViewController")
    }()
    
     lazy var FindChavrusaNavigationController:UINavigationController = {
        
          return self.navControllerForStoryBoard("ChavrusasStoryboard", rootViewController: "FindChavrusaViewController")
    }()
    
    lazy var ForumsNavigationController:UINavigationController = {
        
        return self.navControllerForStoryBoard("ForumsStoryBoard", rootViewController: "ForumsViewController")
    }()
        
   
    let menuItems = HadafHayomiManager.sharedManager.homeMenuItems
    let bottomBarItems = HadafHayomiManager.sharedManager.bottomBarItems
    
    lazy var sideMenuItems:[MenuItem] = {
        
        var menuItems = [MenuItem]()
        
        menuItems.append(MenuItem(dictionary:["name":"donations","title":"donations","imageName":"share_icon.png"]))
        
        return menuItems
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SpeechManager.sharedManager.shouldWelcomeOnLoad
        {
            SpeechManager.sharedManager.welcome()
        }
        else if SpeechManager.sharedManager.shouldListen
        {
            SpeechManager.sharedManager.listen()
        }
        
        
        self.menuCollectoinView.backgroundColor = .clear
        
       // let a = HadafHayomiManager.sharedManager.numberOfDaysToCycleComplition()
        
        /*
        mainViewContainer.layer.shadowColor = UIColor.darkGray.cgColor
        mainViewContainer.layer.shadowOpacity = 0.5
        mainViewContainer.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        mainViewContainer.layer.shadowRadius = 2.0
 */
        
        if let appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String]
            , let local = appleLanguages.first
        {
            var calendar = Calendar.hebrew
            if local != "he_IL"
            {
                calendar = Calendar.current
            }
            
            self.currentDateLabel.text = calendar.longDateDisplay(from: Date(), local: local)
        }
        else{
            self.currentDateLabel.text = Calendar.hebrew.longDateDisplay(from: Date(), local: "he_IL")
        }
       
        
        self.currentPageLabel.text = HadafHayomiManager.sharedManager.todaysPageDisplay()
        
       self.setCounterLabel()
        
        self.bottomBarCollectionView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.bottomBarCollectionView?.layer.shadowOpacity = 0.5
        self.bottomBarCollectionView?.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.bottomBarCollectionView?.layer.shadowRadius = 2.0
        
        self.bottomMenuViewBottomConstraint.constant = 0
        
        self.rateUsButtonLabel?.text = "Rate_Us".localize()
        self.contactUsButtonLabel?.text = "Contact".localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NotificationCenter.default.removeObserver(self, name: Notification.Name("settingsValueChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(_:)), name: Notification.Name("settingsValueChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSpeechManagerDidLoadLesson(_:)), name: Notification.Name("speechManagerDidLoadLesson"), object: nil)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        // SpeechManager.sharedManager.stopListening()
        
         NotificationCenter.default.removeObserver(self, name: Notification.Name("speechManagerDidLoadLesson"), object: nil)
    }
    
    func setCounterLabel()
    {
        if let showCounter = UserDefaults.standard.object(forKey: "setableItem_CounterDisplay") as? Bool
            ,showCounter == false
        {
            self.counterLabel?.isHidden = true
            return
        }
        
        self.counterLabel?.isHidden = false
        
        let numberOfDaysToCycleComplition = HadafHayomiManager.sharedManager.numberOfDaysToCycleComplition()
        if numberOfDaysToCycleComplition > 365
        {
            self.counterLabel?.removeFromSuperview()
        }
        else{
            switch numberOfDaysToCycleComplition
            {              
            case 0:
                self.counterLabel?.text = "st_talmud_completion_today".localize()
                break
                
            case 1:
                self.counterLabel?.text = "st_talmud_completion_tomorrow".localize()
                break
                
            case 2:
                self.counterLabel?.text = "st_talmud_completion_2days".localize()
                break
                
            case 3:
                self.counterLabel?.text = "st_talmud_completion_3days".localize()
                break
                
            default:
                
                  self.counterLabel?.text = String(format: "st_talmud_completion_multiple".localize(), arguments: ["\(numberOfDaysToCycleComplition)"])
                break
                
            }
        }
    }
       
    @objc func onNotification(_ notification: Notification)
    {
        self.setCounterLabel()
    }
    
    @objc func onSpeechManagerDidLoadLesson(_ notification: Notification)
    {
        if let audioLessonsItem = self.getItemByKey("AudioLessons")
        {
            self.willSelectItem(audioLessonsItem)
            self.didSelectItem(audioLessonsItem)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //If first load
        if sideMenuView.superview == nil
        {
            self.sideMenuView.frame = self.view.bounds
            self.view.addSubview(self.sideMenuView)
            self.hideSideMenuView(animated:false)
            
            if let defaultMenuItemName = UserDefaults.standard.object(forKey: "DefaultMenuItem") as? String
            {
                self.selectItemWithName(itemName: defaultMenuItemName)
            }
            else{
                 self.perform( #selector(scrollToFirstItem), with: nil, afterDelay: 1.0)
            }           
        }
        self.currentPageLabel.text = HadafHayomiManager.sharedManager.todaysPageDisplay()        
    }
    
    func selectItemWithName(itemName:String) {
        
        for menuItem in self.menuItems
        {
            if menuItem.name == itemName
            {
                self.willSelectItem(menuItem)
                self.didSelectItem(menuItem)
                
                break
            }
        }
    }
    
    func returnToRoot()
    {
        for menuItem in self.bottomBarItems
        {
            if menuItem.name == "Home"
            {
                self.didSelectItem(menuItem)
                break
            }
        }
    }
    
    @objc func scrollToFirstItem()
    {
        self.scrollBottomBarToItem(itemIndex: 0)
    }
    
    func scrollBottomBarToItem(itemIndex:Int)
    {
        if self.bottomBarCollectionView != nil
        {
            let selectedItemIndexPath = IndexPath(row:itemIndex, section: 0)
            self.bottomBarCollectionView?.selectItem(at:selectedItemIndexPath , animated: true, scrollPosition: .right)
            self.collectionView(self.bottomBarCollectionView!, didSelectItemAt: selectedItemIndexPath)
        }
    }
    
    @IBAction func menuButtonClicked(_ sender:AnyObject)
    {
        // If sideMenuView is visible
        if self.sideMenuView.frame.origin.x == 0
        {
              self.hideSideMenuView(animated:true)
        }
        else{
         
            self.showSideMenuView()
        }
    }
    
    @IBAction func rateUsButtonClicked(_ sender: Any)
    {
      //  let url = URL(string: "itms-apps://itunes.apple.com/app/721125355")!
        let url = URL(string: "itms-apps://itunes.apple.com/app/id721125355")!
        //http://itunes.apple.com/app/idyourID
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func contactUsButtonClicked(_ sender: Any)
    {
        self.present(self.contactUsWebView, animated: false, completion: nil)
        
        self.contactUsWebView.backButton.isHidden = true
        
        let contactUsLink = "https://app.daf-yomi.com/ContactUs.aspx"
        self.contactUsWebView.loadUrl(contactUsLink, title:"ContactUs".localize())
    }
    
    @IBAction func settingsButtonClicked(_ sender: Any)
    {
        GetUserSettingsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let userSettings = object as? [SetableItem] {
                
                HadafHayomiManager.sharedManager.userSettings = userSettings
                
                let settingsViewController = SettingsViewController.createWith(settings: userSettings)
                let navController = UINavigationController(rootViewController: settingsViewController)
                navController.setNavigationBarHidden(true, animated: false)
                
                if self.navigationController != nil
                {
                    self.navigationController?.present(navController, animated: true, completion: nil)
                }
                else{
                    self.view.superview?.parentViewController?.present(navController, animated: true, completion: nil)
                }
            }
            
        },onFaile: { (object, error) -> Void in
        })
    }
    
    @IBAction func whatsAppButtonClicked(){
        
        let phoneNumber =  "+972544931075"
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        }
    }
      
    func showSideMenuView()
    {
         self.sideMenuView.isHidden = false
        self.sideMenuAlfhaView.alpha = 0.5
        self.sideMenuView.frame.origin.x = 0
    }
    func hideSideMenuView(animated:Bool)
    {
        self.sideMenuAlfhaView.alpha = 0.0
        self.sideMenuView.frame.origin.x =  -self.sideMenuTableView.frame.size.width
        self.sideMenuView.isHidden = true
        
    }
    
    func willSelectItem(_ menuItem:MenuItem)
    {
        //If the item is also found in the buttom bar items, select it in the bottom bar
        for index in 0 ..< self.bottomBarItems.count
        {
            let bottomBarItem = self.bottomBarItems[index]
            if bottomBarItem.name == menuItem.name
            {
                self.scrollBottomBarToItem(itemIndex: index)
                break
            }
        }
    }
    
    @objc func didSelectItem(_ menuItem:MenuItem)
    {
        self.bottomMenuView.isHidden = true
        self.bottomBarCollectionView?.isHidden = false

        //If the delegate should handle the selected menu item
        //This is relvent for the ipad were the mainViewController handles sum of the selected menu Itme
        if self.delegate?.shouldHandleMenuItem(menuItem) == true
        {
            return
        }
        
        switch menuItem.name
        {
        case "Home":
            
            self.dispalyedViewController?.view.removeFromSuperview()
            self.dispalyedViewController = nil
            
             self.bottomMenuView.isHidden = false
             self.bottomBarCollectionView?.isHidden = true
            break
            
        case "AudioLessons":
            self.present(self.lessonsNavigationController, animated: false, completion: nil)
            break
            
        case "Talmud":
            
            self.displayTalmudView()
          
            break
            
        case "VideoLesson":
            break
            
        case "Contents":
             self.present(self.articalesNavigationController, animated: false, completion: nil)
            break
            
        case "Forum":
            break
            
        case "Calendar":
           self.present(self.calendarNavigationController, animated: false, completion: nil)
            break
            
        case "Accessories":
            self.present(self.accessoriesListNavigationController, animated: false, completion: nil)
            break
            
        case "AramicDictoianry":
             self.present(self.aramicDictionaryNavigationController, animated: false, completion: nil)
            break
            
        case "StudyHealpers":
            break
            
        case "LessonMap":
            //For IPad
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                    ,rootViewController is Main_IPadViewController
                {
                    //Connect the lesson venues list to the map view controller of the ipad
                   let mainViewController = rootViewController as! Main_IPadViewController
                    mainViewController.mapViewController.lessonVenuesListViewController = self.lessonVenuesListViewController
                }
                
                self.present(self.lessonVenuesListViewController, animated: false, completion: nil)
            }
            else{
                self.present(self.mapViewNavigationController, animated: false, completion: nil)
            }
            break
            
        case "MaschetComplition":
            break
            
        case "Surveys":
            self.present(self.surveysNavigationController, animated: false, completion: nil)
            break
            
        case "TheDafYomiProject":
             self.present(self.hadafHayomiProjectNavigationController, animated: false, completion: nil)
            break
            
        case "PagesSummary":
            self.present(self.pagesSummaryNavigationController, animated: false, completion: nil)
            break
            
        case "About":
            self.present(self.aboutNavigationController, animated: false, completion: nil)
            break
            
        case "Maschet_Complition":
            self.present(self.siyumMasechetNavigationController, animated: false, completion: nil)
            break
            
        case "Q&A":
            self.present(self.QndANavigationController, animated: false, completion: nil)
            break
            
        case "Search":
            
           self.present(self.SearchTalmudNavigationController, animated: false, completion: nil)
            
            break
            
        case "Chavrusa":
            
            self.present(self.FindChavrusaNavigationController, animated: false, completion: nil)
            
            break
            
        case "Forums":
            
            self.present(self.ForumsNavigationController, animated: false, completion: nil)
            
            break
            
        default:
            break
            
        }
    }
    
    func displayTalmudView(){
        
        //For IPad
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                ,rootViewController is Main_IPadViewController
            {
                //Connect the talmudPagePicker to the Talmud view controller of the ipad
                let mainViewController = rootViewController as! Main_IPadViewController
                mainViewController.talmudViewController.talmudPagePickerViewController = self.talmudPagePickerViewController
            }
            
             self.present(self.talmudPagePickerViewController, animated: false, completion: nil)
        }
        else{
              self.present(self.talmudNavigationController, animated: false, completion: nil)
        }
    }
    
    func navControllerForStoryBoard(_  storyBoardIdentifier:String, rootViewController VCIdentifier:String) -> UINavigationController
    {
        let storyboard = UIStoryboard(name: storyBoardIdentifier, bundle: nil)
        let viewController =  storyboard.instantiateViewController(withIdentifier: VCIdentifier)
        
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.isNavigationBarHidden = true
        
        return navController
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if  dispalyedViewController == viewControllerToPresent && dispalyedViewController?.view.superview == self.view
        {
            return
        }
        else{
            
            self.dispalyedViewController?.view.removeFromSuperview()
            self.view.addSubview(viewControllerToPresent.view)
            viewControllerToPresent.view.frame.size.height = self.bottomBarCollectionView?.frame.origin.y ?? 44
            viewControllerToPresent.view.frame.size.width = self.view.frame.width
            self.dispalyedViewController = viewControllerToPresent
            
            if self.dispalyedViewController is MSBaseViewController
            {
                (self.dispalyedViewController as! MSBaseViewController).showHomeButton()
            }
            else if self.dispalyedViewController is UINavigationController
            {
               if let rootView = (self.dispalyedViewController as! UINavigationController).viewControllers.first as? MSBaseViewController
               {
                    rootView.showHomeButton()
                }
            }
            
            if self.bottomBarCollectionView != nil
            {
                self.view.bringSubviewToFront(self.bottomBarCollectionView!)
            }
        }
    }
    
    func showLessonsViewWithLesson(_ lesson:Lesson)
    {
        self.present(self.lessonsNavigationController, animated: false, completion: nil)
        let lessonsViewController = self.lessonsNavigationController.viewControllers.first as! LessonsViewController
        
        lessonsViewController.lessonsPickerView.select(maschet: lesson.masechet, page: lesson.page!, maggidShior:lesson.maggidShiur)
        
    }
    
    //MARK: CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == menuCollectoinView
        {
              return self.menuItems.count
        }
        else if collectionView == bottomBarCollectionView
        {
            return self.bottomBarItems.count
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == menuCollectoinView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMenuItemCell", for: indexPath) as! MSBaseCollectionViewCell
            cell.reloadWithObject(self.menuItems[indexPath.row])
            return cell
        }
        else if collectionView == bottomBarCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBottomBarCell", for: indexPath) as! MSBaseCollectionViewCell
            cell.reloadWithObject(self.bottomBarItems[indexPath.row])
            return cell            
        }
        else
        {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == menuCollectoinView
        {
             return CGSize(width: 90, height: 90)
        }
        else if collectionView == bottomBarCollectionView
        {
              return CGSize(width: (self.view.frame.size.width/4)-3, height: 50)
        }
        else
        {
              return CGSize(width: 0, height: 0)
        }
    }
    
    // change background color when user touches cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if collectionView == menuCollectoinView
        {
            cell?.backgroundColor = UIColor(HexColor:"6A2423")
        }
        else if collectionView == bottomBarCollectionView
        {
             cell?.backgroundColor = UIColor(HexColor:"333333")
        }
    }
    
    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if collectionView == menuCollectoinView
        {
            cell?.backgroundColor = UIColor(HexColor:"8C2E2E")
        }
        else if collectionView == bottomBarCollectionView
        {
            cell?.backgroundColor = UIColor(HexColor:"333333")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == menuCollectoinView
        {
            let selectedMenuItem = self.menuItems[indexPath.row]
            
            self.willSelectItem(selectedMenuItem)
            self.didSelectItem(selectedMenuItem)
        }
        else if collectionView == bottomBarCollectionView
        {
            if let cell = collectionView.cellForItem(at: indexPath), cell is HomeBottomBarCell
            {
                (cell as! HomeBottomBarCell).setSelected(true)
            }

            self.didSelectItem(self.bottomBarItems[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
       if let cell = collectionView.cellForItem(at: indexPath), cell is HomeBottomBarCell
       {
          (cell as! HomeBottomBarCell).setSelected(false)
        }
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sideMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSideMenuCell", for:indexPath) as! MSBaseTableViewCell
        
        cell.reloadWithObject(self.sideMenuItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func getItemByKey(_ key:String) -> MenuItem?
    {
        for menuItem in self.menuItems
        {
            if menuItem.name == key
            {
                return menuItem
            }
        }
        return nil
    }
}
