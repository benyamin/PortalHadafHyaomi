//
//  SiyumAccessoriesViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 24/05/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.


import UIKit

class SiyumAccessoriesViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    
    lazy var topicstList:[SiyumTopic] = {
        
        var topicstList = [SiyumTopic]()
      
        topicstList.append(SiyumTopic(id: "7", title: "סיומים למסכתות", iconImage: "star.png", link:"http://daf-yomi.com/mobile/content.aspx?id=43"))
        /*
           topicstList.append(SiyumTopic(id: "6", title: "סיום מסכת", iconImage: "star.png", link:"http://daf-yomi.com/mobile/content.aspx?id=335"))
        */
        topicstList.append(SiyumTopic(id: "8", title: "דיני הסיום וביאורים", iconImage: "star.png", link:"http://daf-yomi.com/mobile/content.aspx?id=42"))
        
           topicstList.append(SiyumTopic(id: "12", title: "ספרים", iconImage: "star.png", link:"http://daf-yomi.com/mobile/content.aspx?id=70"))
        
        topicstList.append(SiyumTopic(id: "9", title: "נוסח ההדרן", iconImage: "star.png", link:"Hadran"))
        
        topicstList.append(SiyumTopic(id: "10", title: "קדיש הגדול", iconImage: "star.png", link:"TheBigKAdish"))
        
        topicstList.append(SiyumTopic(id: "11", title: "תפילת ר׳ נחוניה בן הקנה", iconImage: "star.png", link:"Rabbi_Nechonya _ben_Hakana"))
        
        return topicstList
    }()
    
    
    @IBOutlet weak var topicsTableView:UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBarTitleLabel?.text = "st_Maschet_Complition".localize()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SiyumTopicTableCell", for:indexPath) as! MSBaseTableViewCell
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


