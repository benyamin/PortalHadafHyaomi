//
//  SurveysViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 21/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class SurveysViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate
{
    @IBOutlet weak var surveysTableView:UITableView?
    
    var surveys = [Survey]()
    
    weak var loadingView:BTLoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getSurveys()
    }
    
    func getSurveys()
    {
        self.showLoadingView()
        
        GetSurveysProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLoadingView()
            
            self.surveys = object as! [Survey]
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
             self.hideLoadingView()
        })
    }

    override func reloadData()
    {
        self.surveysTableView?.reloadData()
    }
    
    
    func showLoadingView()
    {
        if let loadingView = UIView.viewWithNib("BTLoadingView") as? BTLoadingView
        {
             self.surveysTableView?.isHidden = true
            
            loadingView.frame = self.surveysTableView!.frame
            self.loadingView = loadingView
            
            self.view.addSubview(self.loadingView!)
            
        }
    }
    
    func hideLoadingView()
    {
        self.surveysTableView?.isHidden = false
        self.loadingView?.removeFromSuperview()
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.surveys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyTableCell", for:indexPath) as! MSBaseTableViewCell
        
        cell.reloadWithObject(self.surveys[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //https://app.daf-yomi.com/pollResults.aspx?id=903
        
         let survey = self.surveys[indexPath.row]
        if let surveyId = survey.Id
        {
            let webTitle = "st_survey".localize()
            let surveyUrl =  "https://app.daf-yomi.com/pollResults.aspx?mobile=1&id=" + surveyId
            
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
            webViewController.delegate = self
            webViewController.loadUrl(surveyUrl, title: webTitle)
            
            self.navigationController?.pushViewController(webViewController, animated: true)
            
            /*
             
             document.getElementsByClassName("clsMainTable")[0].setAttribute('style',"width:100%");
             document.getElementsByClassName("clsContainer")[0].setAttribute('style',"width:auto");
             document.getElementsByClassName("clsContentText")[0].setAttribute('style',"max-width:none;width:100%");
             
             

 */
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //MARK: - WebView DelegateMethods
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
     {
        
        let js = ("document.getElementsByClassName(\"clsMainTable\")[0].setAttribute('style',\"width:100%\");document.getElementsByClassName(\"clsContainer\")[0].setAttribute('style',\"width:auto\");document.getElementsByClassName(\"clsContentText\")[0].setAttribute('style',\"max-width:none;width:100%\");")
        
        webView.evaluateJavaScript(js) { (result, error) in
            if error != nil {
            }
        }
        //_ = webView.stringByEvaluatingJavaScript(from: js)
    }
}
