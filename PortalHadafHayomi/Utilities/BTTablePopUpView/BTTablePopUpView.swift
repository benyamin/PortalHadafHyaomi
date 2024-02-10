//
//  BTTablePopUpView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 17/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class TablePopUpViewCell: UITableViewCell
{
    @IBOutlet weak var optionLabel:UILabel?
    @IBOutlet weak var selectedImageView:UIImageView?
    
    func setSelected(_ selected:Bool)
    {
        self.selectedImageView?.image = UIImage(named:"check.png")
        self.selectedImageView?.isHidden = !selected
        self.optionLabel?.textColor = selected ? UIColor.blue : UIColor.darkGray
    }
}

public protocol BTTablePopUpViewDelegate: class
{
    func tablePopUpView(_ tablePopUpView:BTTablePopUpView, didSelectOption option:String!)
}

public class BTTablePopUpView:UIView, UITableViewDelegate, UITableViewDataSource
{
    public weak var delegate:BTTablePopUpViewDelegate?
    
    public var options:[String]!
    public var selectedOption:String!
    
    public var identifier:String!
    
    let tableCellIdentifier = "TablePopUpViewCell"
    
    @IBOutlet weak var topBarView:UIView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var tableHeightConstraint:NSLayoutConstraint!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableview.register(UINib(nibName: tableCellIdentifier, bundle: nil), forCellReuseIdentifier: tableCellIdentifier)
    }
    
    public func reloadWithOptions(_ options:[String], title:String!, selectedOption:String?)
    {
        self.titleLabel.text = title
        self.options = options
        self.selectedOption = selectedOption
        
        self.tableview.reloadData()
        
        let tableCellHeight = CGFloat(44.0)
        self.tableHeightConstraint.constant = CGFloat(options.count) * tableCellHeight
        
        if  let applicationWindow = UIApplication.shared.keyWindow
        {
            self.tableview.isScrollEnabled = true
            
            if (self.tableHeightConstraint.constant + tableCellHeight) > (applicationWindow.frame.size.height - 200)
            {
                self.tableHeightConstraint.constant = applicationWindow.frame.size.height - 156
                self.tableview.isScrollEnabled = true
            }
        }
    }
    
    // MARK: - TableView Methods:
    
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.options.count
        
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for:indexPath) as! TablePopUpViewCell
        
        let optionTitle = self.options[indexPath.row]
        cell.optionLabel?.text = optionTitle
        
        if selectedOption == nil
        {
            cell.setSelected(false)
        }
        else
        {
            print ("\(selectedOption!),\(optionTitle)")
            
            cell.setSelected("\(selectedOption!)" == optionTitle)
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       self.selectedOption = self.options[indexPath.row]
        tableView.reloadData()
        
        self.delegate?.tablePopUpView(self, didSelectOption: self.selectedOption)
    }
}

