//
//  ArticalesCategorysViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ArticalesCategorysViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, TalmudPagePickerViewDelegate
{
    var articlesCategorys = [ArticleCategory]()
    
    var firstAppearance:Bool = true
    var selectedMasechet:Masechet?
    var selectedPage:Page?
    
    @IBOutlet weak var articalesCategorysTableView:UITableView!
    
    @IBOutlet weak var talmudPagePickerView:TalmudPagePickerView!
    @IBOutlet weak var talmudPagePickerViewTopConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var todaysPageButton:UIButton!
    @IBOutlet weak var searchPageButton:UIButton!
    @IBOutlet weak var advanceSearchButton:UIButton!
    
    @IBOutlet weak var nextPageButton:UIButton!
    @IBOutlet weak var prePageButton:UIButton!
    
    @IBOutlet weak var searchButtonIconImageView:UIImageView!
    
    lazy var articlesViewController:ArticlesViewController = {
        
        let viewController =  UIViewController.withName("ArticlesViewController", storyBoardIdentifier: "ArticlesStoryboard") as! ArticlesViewController
        return viewController
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.articalesCategorysTableView.isHidden = true
                
        //Current selected display page in Talmud VC
        if let selectedPageInfo = UserDefaults.standard.object(forKey: "selectedPageInfo") as? [String:Any]
            ,let maschetId = selectedPageInfo["maschetId"] as? String
            ,let maschent = HadafHayomiManager.sharedManager.getMasechetById(maschetId)
            ,let pageIndex = selectedPageInfo["pageIndex"] as? Int{
            
            self.getArticalesCategorysForMasechet(maschent, andPage: Page(index: pageIndex))
        }
        else{
            let dispalyLastPageViewed = UserDefaults.standard.object(forKey: "setableItem_SaveLastSelectedPageInArticles") as? Bool ?? true
            
            if dispalyLastPageViewed
                ,let lastViewdPageArticles = UserDefaults.standard.object(forKey: "lastViewdPageArticles") as? [String:Int]
                ,let selectedPageIndex = lastViewdPageArticles["selectedPageIndex"]
                ,let page = HadafHayomiManager.sharedManager.getPageForPageIndex(selectedPageIndex)
                ,let maschent = HadafHayomiManager.sharedManager.getMasechetForPageIndex(selectedPageIndex){
                self.getArticalesCategorysForMasechet(maschent, andPage: page)
            }
            
            else {
                let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet!
                let todaysPage = HadafHayomiManager.sharedManager.todaysPage!
                self.getArticalesCategorysForMasechet(todaysMaschet, andPage: todaysPage)
            }
        }
        
        self.searchPageButton.layer.borderWidth = 1.0
        self.searchPageButton.layer.borderColor = self.talmudPagePickerView.backgroundColor!.cgColor
        self.searchPageButton.layer.shadowColor = UIColor.darkGray.cgColor
        self.searchPageButton.layer.shadowOpacity = 0.5
        self.searchPageButton.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        self.searchPageButton.layer.shadowRadius = 1.0
        
        self.todaysPageButton.layer.borderWidth = 1.0
          self.todaysPageButton.layer.borderColor = self.talmudPagePickerView.backgroundColor!.cgColor
          self.todaysPageButton.layer.shadowColor = UIColor.darkGray.cgColor
          self.todaysPageButton.layer.shadowOpacity = 0.5
          self.todaysPageButton.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
          self.todaysPageButton.layer.shadowRadius = 1.0
        
        self.advanceSearchButton.layer.borderWidth = 1.0
        self.advanceSearchButton.layer.borderColor = self.talmudPagePickerView.backgroundColor!.cgColor
        self.advanceSearchButton.layer.shadowColor = UIColor.darkGray.cgColor
        self.advanceSearchButton.layer.shadowOpacity = 0.5
        self.advanceSearchButton.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        self.advanceSearchButton.layer.shadowRadius = 1.0
        
        self.talmudPagePickerViewTopConstraint.constant = -1 * (self.talmudPagePickerView.frame.size.height - 1)
        
        self.searchPageButton.setTitle("st_search_page".localize(), for: .normal)
        self.advanceSearchButton.setTitle("st_advanced_search".localize(), for: .normal)
        self.todaysPageButton.setTitle("st_todays_page".localize(), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.firstAppearance == true
        {
            self.firstAppearance = false
            
           self.setTalmudPagePickerView()
        }
        
        //Current selected display page in Talmud VC
        if let selectedPageInfo = UserDefaults.standard.object(forKey: "selectedPageInfo") as? [String:Any]
            ,let maschetId = selectedPageInfo["maschetId"] as? String
            ,let maschent = HadafHayomiManager.sharedManager.getMasechetById(maschetId)
            ,let pageIndex = selectedPageInfo["pageIndex"] as? Int{
            
            self.getArticalesCategorysForMasechet(maschent, andPage: Page(index: pageIndex))
        }
        
    }
   
    func setTalmudPagePickerView()
    {
        talmudPagePickerView.delegate = self
        
        let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet!
        let todaysPage = HadafHayomiManager.sharedManager.todaysPage!
         talmudPagePickerView.scrollToMasechet(todaysMaschet, page: todaysPage, pageSide: 0, animated: false)
    }
    
    @IBAction func todaysPageButtonClicked(_ sender:UIButton)
    {
        if let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet
            , let todaysPage = HadafHayomiManager.sharedManager.todaysPage
        {
            self.getArticalesCategorysForMasechet(todaysMaschet, andPage: todaysPage)
            
            talmudPagePickerView.scrollToMasechet(todaysMaschet, page: todaysPage, pageSide: 0, animated: false)
        }
    }
    
    
    @IBAction func searchPageButtonClicked(_ sender:UIButton)
    {
        self.togglePagePickerViewDisplay()
    }
    
    @IBAction func advanceSearchButtonClicked(_ sender:UIButton)
    {
        let viewController = UIViewController.withName("SearchArticlesViewController", storyBoardIdentifier: "ArticlesStoryboard")
        
        self.navigationController?.pushViewController(viewController, animated: true)
       
    }
    
    @IBAction func nextPageButtonClicked(_ sender:UIButton)
    {
        if let masechet = self.selectedMasechet
           ,let page = self.selectedPage {
            
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: 1) {
                
                let nextPageIndex = pageIndex+2
                
                if let selectMasechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(nextPageIndex)
                   ,let selectPage = HadafHayomiManager.sharedManager.getPageForPageIndex(nextPageIndex) {
                    
                    self.getArticalesCategorysForMasechet(selectMasechet, andPage: selectPage)
                }
            }
        }
    }
    
    @IBAction func prePageButtonClicked(_ sender:UIButton)
    {
        if let masechet = self.selectedMasechet
           ,let page = self.selectedPage {
            
            if let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: 1) {
                
                let nextPageIndex = pageIndex-2
                
                if let selectMasechet = HadafHayomiManager.sharedManager.getMasechetForPageIndex(nextPageIndex)
                   ,let selectPage = HadafHayomiManager.sharedManager.getPageForPageIndex(nextPageIndex) {
                    
                    self.getArticalesCategorysForMasechet(selectMasechet, andPage: selectPage)
                }
            }
        }
    }
    
    func togglePagePickerViewDisplay()
    {
        // if talmud page picker view is open
        if self.talmudPagePickerViewTopConstraint.constant == 0
        {
            self.talmudPagePickerViewTopConstraint.constant = -1 * (self.talmudPagePickerView.frame.size.height - 1)
        }
        else//show page picker view
        {
            self.talmudPagePickerViewTopConstraint.constant = 0
            
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
                /*
                if pickerIsDisplayed
                {
                    self.pagesCollectionView.isUserInteractionEnabled = false
                    self.pagesCollectionView.alpha = 0.3
                }
                else{
                    self.pagesCollectionView.isUserInteractionEnabled = true
                    self.pagesCollectionView.alpha = 1.0
                }
 */
                
                
        }, completion: {_ in
            
            //if did hide talmud page picker
            if self.talmudPagePickerViewTopConstraint.constant != 0
            {
                self.talmudPagePickerView(self.talmudPagePickerView, didHide: true)
                self.searchPageButton.setTitle("st_search_page".localize(), for: .normal)
            }
            else{
                  self.searchPageButton.setTitle("st_select".localize(), for: .normal)
            }
        })
    }
    

    
    func getArticalesCategorysForMasechet(_ masechet:Masechet, andPage page:Page)
    {
        self.selectedMasechet = masechet
        self.selectedPage = page
        
        let pageIndex = HadafHayomiManager.sharedManager.pageIndexFor(masechet, page: page, pageSide: 1)
        UserDefaults.standard.set(["selectedPageIndex":pageIndex], forKey: "lastViewdPageArticles")
        UserDefaults.standard.synchronize()
        
        Util.showDefaultLoadingView()
        self.topBarTitleLabel?.text = "מסכת " + masechet.name + " " + "דף " + page.symbol
        
        let requiredArticalesInfo = ["masechet":masechet,
                                     "page":page]
     
        GetArticalesProcess().executeWithObject(requiredArticalesInfo, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.articlesCategorys = object as! [ArticleCategory]
            
            self.articalesCategorysTableView.reloadData()
            
            self.articalesCategorysTableView.isHidden = false
            
            Util.hideDefaultLoadingView()
            
        },onFaile: { (object, error) -> Void in
            
             Util.hideDefaultLoadingView()
            
            self.presentErrorAlertWithError(error)
        })
    }
    
    func presentErrorAlertWithError(_ error:NSError)
    {
        if let errorMessage = error.userInfo["NSLocalizedDescription"]
        {
            let errorTitle = "st_error".localize()
             let errorOkButton = "st_ok".localize()
            
            BTAlertView.show(title: errorTitle, message: errorMessage as! String, buttonKeys: [errorOkButton], onComplete:{ (dismissButtonKey) in
            })
        }
        else
        {
             let errorTitle = "st_error".localize()
             let errorOkButton = "st_ok".localize()
            let errorMessage = "st_general_system_error".localize()
            
            BTAlertView.show(title: errorTitle, message: errorMessage, buttonKeys: [errorOkButton], onComplete:{ (dismissButtonKey) in
            })
        }
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.articlesCategorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableCell", for:indexPath) as! MSBaseTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.reloadWithObject(self.articlesCategorys[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let articleCategory = self.articlesCategorys[indexPath.row]
        
        self.articlesViewController.reloadWithObject(articleCategory)
        
        self.navigationController?.pushViewController(self.articlesViewController, animated: true)
    }
    
    //MARK: = TalmudPagePickerView delegate meothods
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didChangeComponent component:Int)
    {
       
    }
    
     func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didHide:Bool)
     {
        if let selectedMasechet = talmudPagePickerView.selectedMasechet
        , let selectedPage = talmudPagePickerView.selectedPage
        {
               self.getArticalesCategorysForMasechet(selectedMasechet, andPage: selectedPage)
        }
    }
}
