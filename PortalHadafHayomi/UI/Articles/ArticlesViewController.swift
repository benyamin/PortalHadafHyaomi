//
//  ArticlesViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 17/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ArticlesViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    var articaleCategory:ArticleCategory?
    
    @IBOutlet weak var articlesTableView:UITableView!
    
    lazy var articleWebView:BTWebViewController! = {
        
        let viewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }
    
    override func reloadWithObject(_ object:Any){
        
        self.articaleCategory = object as? ArticleCategory
        
        reloadData()
    }
    
    override func reloadData()
    {
        if self.articlesTableView != nil
        {
            if let title = self.articaleCategory?.title
            {
                self.topBarTitleLabel?.text = "st_\(title)".localize()

            }
            self.articlesTableView.reloadData()
        }
    }

    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.articaleCategory?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableCell", for:indexPath) as! MSBaseTableViewCell
        
        cell.reloadWithObject(self.articaleCategory!.articles[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let article = self.articaleCategory?.articles[indexPath.row]
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                    ,rootViewController is Main_IPadViewController
                {
                    let mainViewController = rootViewController as! Main_IPadViewController
                    
                    mainViewController.presentViewController(self.articleWebView, onContainer: mainViewController.mainContainerView)
                }
            }
            else{
                self.navigationController?.pushViewController(self.articleWebView, animated: true)
            }
            self.articleWebView.loadUrl(article.link, title:article.title)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }

}
