//
//  QandATopicsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//


import UIKit

class QandATopicsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    
    lazy var topicstList:[HadafHayomiProjectTopic] = {
        
        var topicstList = [HadafHayomiProjectTopic]()
        topicstList.append(HadafHayomiProjectTopic(id: "1", title:"st_learning_guidance".localize(), iconImage: "star_icon.png", link:"studying_Guidelines"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "2", title: "st_learning_determination".localize(), iconImage: "star_icon.png", link:"routine_Learning"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "3", title: "st_masechet_ending".localize(), iconImage: "star_icon.png", link:"siyum_Masechet"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "4", title: "st_general_qa".localize(), iconImage: "star_icon.png", link:"general_Questions"))
        
          topicstList.append(HadafHayomiProjectTopic(id: "5", title: "st_ask_a_question".localize(), iconImage: "ask_questions_icon.png", link:"https://app.daf-yomi.com/qnaAdd.aspx"))
        
         topicstList.append(HadafHayomiProjectTopic(id: "6", title: "st_the_daf_yomi_qa_book".localize(), iconImage: "Sefer_icon.png", link:"https://app.daf-yomi.com/mobile/content.aspx?id=332"))
        
        
        return topicstList
    }()
    
    
    @IBOutlet weak var topicsTableView:UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.topicstList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QandATopicTableCell", for:indexPath) as! QandATopicTableCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let topic = self.topicstList[indexPath.row]
        if topic.id == "5"
        {
            cell.cardView?.backgroundColor = UIColor(HexColor: "6A613A")

        }
        else if topic.id == "6"
        {
            cell.cardView?.backgroundColor = UIColor(HexColor: "B78238")
            
        }
        
        cell.reloadWithObject(topic)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTopic = self.topicstList[indexPath.row]
        
        if let topicLink = selectedTopic.link
        {
            if topicLink.hasPrefix("http")
            {
                self.openWebViewTopic(selectedTopic)
            }
            else{
                self.didSelectTopic(selectedTopic)
            }
        }
    }
    
    func openWebViewTopic(_ topic:HadafHayomiProjectTopic)
    {
        let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
        
        if topic.title == "st_ask_a_question".localize(){
            webViewController.shareButtonDisabled = true
        }
        else{
            webViewController.shareButtonDisabled = false
        }
        webViewController.loadUrl(topic.link!, title: topic.title)
        
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func didSelectTopic(_ topic:HadafHayomiProjectTopic)
    {
        let quastionsViewController = UIViewController.withName("QuastionsViewController", storyBoardIdentifier: "QandAStoryboard") as! MSBaseViewController
        
        quastionsViewController.reloadWithObject(topic)
        
        self.navigationController?.pushViewController(quastionsViewController, animated: true)
        
        GetQandAProcess().executeWithObject(topic.link!, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            quastionsViewController.reloadWithObject(object)
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
}


