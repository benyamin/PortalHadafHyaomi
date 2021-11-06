//
//  TablePickerView.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 27/02/2016.
//
//

import UIKit


class TablePickerView: UIView, UITableViewDataSource, UITableViewDelegate
{
    var pickerView = UIPickerView()
    
     var dataSource: UIPickerViewDataSource?
     var delegate: UIPickerViewDelegate?
    
    var pickerTables = [UITableView]()
    
    var topShadow = UIView()
    var bottomShadow = UIView()
    
    override init(frame:CGRect) {
        
        super.init(frame:frame)
        
        self.backgroundColor = UIColor.clear
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout()
    {
        
    }
    
    func reloadAllComponents()
    {
        self.setup()
        
    }
    
    func reloadComponent(_ component:Int)
    {
        if  component < self.pickerTables.count
        {
            let tableView = self.pickerTables[component]
            tableView.reloadData();
           
            if tableView.numberOfRows(inSection: 0) > 0
            {
                let centerCellPoint = CGPoint(x:tableView.bounds.width/2,y:tableView.center.y + tableView.contentOffset.y)
                if  let indexPath = tableView.indexPathForRow(at: centerCellPoint)
                {
                    self.delegate?.pickerView!(self.pickerView, didSelectRow: indexPath.row, inComponent: tableView.tag)
                }
            }
        }
    }
    
    func selectRow(_ row:Int, inComponent component:Int, animated:Bool)
    {
        if  component <= self.pickerTables.count
        {
            let tableView = self.pickerTables[component]
            
            let numberOfRows = tableView.numberOfRows(inSection: 0)
            if numberOfRows > 0 && numberOfRows > row
            {
                let rowIndexPath = IndexPath(row: row, section: 0)
                tableView.selectRow(at: rowIndexPath, animated: false, scrollPosition: .middle)
                
                /*
               let rowHeight = self.delegate?.pickerView!(pickerView, rowHeightForComponent: 0)
                let offsetY = rowHeight!*CGFloat(row)// + (tableView.tableHeaderView?.frame.size.height)!
               let contentOffSet = CGPoint(x: tableView.contentOffset.x, y: offsetY)
                tableView.setContentOffset(contentOffSet, animated: true)
 */
            }
        }
    }
    
    func setup()
    {
        topShadow.isUserInteractionEnabled = false
        topShadow.backgroundColor = UIColor.white
        topShadow.alpha = 0.6
        
        bottomShadow.isUserInteractionEnabled = false
        bottomShadow.backgroundColor = UIColor.white
        bottomShadow.alpha = 0.6
        
        
        for tableview in self.pickerTables
        {
            tableview.removeFromSuperview()
        }
        
        self.pickerTables.removeAll()

        
        if let numberOfComponents = self.dataSource?.numberOfComponents(in: pickerView)
        {
            var tableOrigenX = CGFloat(0.0)
            for component in 0 ..< numberOfComponents
            {
                let tableWidth = self.delegate?.pickerView!(pickerView, widthForComponent: component)
                
                let tableView = UITableView(frame: CGRect(x: tableOrigenX, y: 0, width: tableWidth!, height: self.bounds.size.height))
                
                tableOrigenX += tableWidth!
                
                tableView.tag =  component
              
                tableView.dataSource = self
                tableView.delegate = self
                
                tableView.backgroundColor = UIColor.clear
                
                tableView.showsVerticalScrollIndicator = false

                let rowHeight = self.delegate?.pickerView!(pickerView, rowHeightForComponent: 0)
                
                let spcae  = (self.frame.size.height/2) - (rowHeight!/2)
                
                let header:UIView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: spcae))
                 tableView.tableHeaderView = header
                
                let footer:UIView =  UIView(frame:CGRect(x: 0, y: 0, width: 0, height: spcae))
                tableView.tableFooterView = footer
                
                tableView.separatorStyle = .none
                
                self.addSubview(tableView)
                
                tableView.estimatedRowHeight = 0
                tableView.estimatedSectionHeaderHeight = 0
                tableView.estimatedSectionFooterHeight = 0
                
                self.pickerTables.append(tableView)
            }
        }
        
         let rowHeight = self.delegate?.pickerView!(pickerView, rowHeightForComponent: 0)
        let shadowHeight = (self.frame.size.height/2) - (rowHeight!/2)
        topShadow.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: shadowHeight)
        topShadow.layer.borderColor = UIColor.lightGray.cgColor
        topShadow.layer.borderWidth = 1.0
        
        bottomShadow.frame = CGRect(x: 0, y: (self.frame.size.height/2) + (rowHeight!/2), width: self.frame.size.width, height: shadowHeight)
        bottomShadow.layer.borderColor = UIColor.lightGray.cgColor
        bottomShadow.layer.borderWidth = 1.0
        
        self.addSubview(topShadow)
        self.addSubview(bottomShadow)

    }
    open func numberOfRowsInSection(_ sectoin:Int) -> Int
    {
        let table = pickerTables[sectoin]
        let numberOfrowsInSection = self.tableView(table, numberOfRowsInSection: 0)
       return numberOfrowsInSection
    }
    
    // MARK: - TableView Methods:
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let numberOfRows = (self.dataSource?.pickerView(pickerView, numberOfRowsInComponent: tableView.tag))!
        return numberOfRows
    }
    
   open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let rowView = self.delegate?.pickerView!(self.pickerView, viewForRow: indexPath.row, forComponent: tableView.tag, reusing: nil)
        
        rowView?.backgroundColor = UIColor.clear
        
        let cell = UITableViewCell(frame: (rowView?.frame)!)
        
        cell.backgroundColor = UIColor.clear
        
   
        let contentView = UIView(frame:rowView!.frame)
            contentView.frame = rowView!.frame
              contentView.addSubview(rowView!)
      
      cell.addSubview(contentView)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let rowHeight = self.delegate?.pickerView!(pickerView, rowHeightForComponent: tableView.tag)
        
        return rowHeight!
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.numberOfRows(inSection: 0) > 0
        {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            
            self.delegate?.pickerView!(pickerView, didSelectRow: indexPath.row, inComponent: tableView.tag)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        self.scrollToTableCenter(tableView: scrollView as! UITableView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if decelerate == false
        {
            self.scrollToTableCenter(tableView: scrollView as! UITableView)
        }
    }
    
    func scrollToTableCenter(tableView: UITableView)
    {
        let centerCellPoint = CGPoint(x:tableView.bounds.width/2,y:tableView.center.y + tableView.contentOffset.y)
        
        if  let indexPath = tableView.indexPathForRow(at: centerCellPoint)
        {
            if tableView.numberOfRows(inSection: 0) > 0
            {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                
                self.delegate?.pickerView!(pickerView, didSelectRow: indexPath.row, inComponent: tableView.tag)
            }
        }
    }
    
    func selectedRow(inComponent component: Int) -> Int?
    {
        if component < self.pickerTables.count
        {
            let tableView = self.pickerTables[component]
            
            let centerCellPoint = CGPoint(x:tableView.bounds.width/2,y:tableView.center.y + tableView.contentOffset.y)
            
            let indexPath = tableView.indexPathForRow(at: centerCellPoint)
            
            return indexPath?.row
        }
        return 0
    }
}

