//
//  HadafHayomiProjectViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 16/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class HadafHayomiProjectViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    
    lazy var topicstList:[HadafHayomiProjectTopic] = {
        
        var topicstList = [HadafHayomiProjectTopic]()
        topicstList.append(HadafHayomiProjectTopic(id: "1", title: "תולדות הדף היומי", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=30"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "2", title: "תולדות מהר׳׳ם שפירא", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=140"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "3", title: "חשיבות לימוד הדף היומי", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=69"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "4", title: "כתבות בענייני דף יומי", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=36"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "5", title: "סיפורים אישיים", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=229"))
        
         topicstList.append(HadafHayomiProjectTopic(id: "5", title: "סיומי הש׳׳ס", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=335"))
        
        topicstList.append(HadafHayomiProjectTopic(id: "5", title: "משנה יומית לדף היומי", iconImage: "star_icon.png", link:"http://daf-yomi.com/mobile/content.aspx?id=247"))
        
       
        return topicstList
    }()
    

    @IBOutlet weak var topicsTableView:UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBarTitleLabel?.text = "st_The_Daf_Yomi_Project".localize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.topicstList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HadafHayomiProjectTopicTableCell", for:indexPath) as! MSBaseTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.reloadWithObject(self.topicstList[indexPath.row])
        
        
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
            //Link for web site
            if topicLink.hasPrefix("http")
            {
                let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
                
                webViewController.loadUrl(topicLink, title: selectedTopic.title)
                
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            else //Link for text file
            {
                let textViewController = BTTextViewController(nibName: "BTTextViewController", bundle: nil)
                
                textViewController.relodWithFile(fileName:topicLink, fileType: "rtf", title: selectedTopic.title)
                
                self.navigationController?.pushViewController(textViewController, animated: true)
            }
        }
    }
}

