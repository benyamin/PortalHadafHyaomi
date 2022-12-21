//
//  MaggidiShiourTableView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 21/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MaggidiShiourTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var titleLabel:UILabel?
    
    var onDismiss:(() -> Void)?
        
    let tableCellIdentifier = "TableSelectionCell"

    class func create() -> MaggidiShiourTableView? {
        let maggidiShiourTableView = UIView.viewWithNib("MaggidiShiourTableView") as? MaggidiShiourTableView
        return maggidiShiourTableView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel?.text = "st_favorite_magid_shiours".localize()
        
        self.tableView?.register(UINib(nibName: tableCellIdentifier, bundle: nil), forCellReuseIdentifier: tableCellIdentifier)
        
        self.topBarView?.addBottomShadow()
        self.tableView?.reloadData()
    }
    
    @IBAction func dismissButtonClicked(_ sender:UIButton) {
        self.onDismiss?()
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return HadafHayomiManager.sharedManager.maggidShiurs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for:indexPath) as! TableSelectionCell
        
        let maggidShiour = HadafHayomiManager.sharedManager.maggidShiurs[indexPath.row]
        
        cell.onSelectioinChanged = {(selected) in
            maggidShiour.isFavorite = selected
        }
        
        cell.reloadWithObject((title:maggidShiour.name, isSelected:maggidShiour.isFavorite))
        
        return cell
    }
}
