//
//  MidotAndShiourimViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 11/11/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MidotAndShiourimViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    var midotAndShuourimReferences = [LinkInfo]()
    
    @IBOutlet weak var tableView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topBarTitleLabel?.text = "measurements".localize()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.midotAndShuourimReferences = object as! [LinkInfo]
        
        self.reloadData()
    }
    
    override func reloadData() {
        self.tableView?.reloadData()
    }

    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.midotAndShuourimReferences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReferenceTableViewCell", for:indexPath) as! MSBaseTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let refrence = self.midotAndShuourimReferences[indexPath.row]
        
        cell.reloadWithObject(refrence)
        
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
        
        let refrence = self.midotAndShuourimReferences[indexPath.row]
        
        if refrence.path == "MeasurementCalculatorViewController"
        {
            self.showCalculator()
        }
        else{
            let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
    
            let title = "measurements".localize()
            webViewController.loadUrl(refrence.path!, title: title)
            
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    func showCalculator()
    {
        let calculatorViewController = UIViewController.withName("MeasurementCalculatorViewController", storyBoardIdentifier: "Measurements")
        self.navigationController?.pushViewController(calculatorViewController, animated: true)
    }

}
