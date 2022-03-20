//
//  AccessoriesListViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class AccessoriesListViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource
{
    lazy var expressionsViewController:ExpressionsViewController = {
       
        let expressionsViewController = UIViewController.withName("ExpressionsViewController", storyBoardIdentifier: "AccessoriesStoryboard") as! ExpressionsViewController
        
        return expressionsViewController
    }()

    lazy var accessoriesList:[Accessory] = {
        
        var accessoriesList = [Accessory]()
        accessoriesList.append(Accessory(id: "TC", title:  "history_of_chazal", iconImage: "Toldot_icon_ios.png", dataType:"HTML"))
        
        accessoriesList.append(Accessory(id: "MA", title: "concepts_and_values", iconImage: "Musagim_icon_ios.png", dataType:"HTML"))
        
        accessoriesList.append(Accessory(id: "MT", title: "talmudic_terms", iconImage: "Munachim_icon_ios.png", dataType:"HTML"))
        
        accessoriesList.append(Accessory(id: "MS", title:  "measurements", iconImage: "Midot_icon_ios.png", dataType:"Text"))
     
        accessoriesList.append(Accessory(id: "CAL", title: "st_calculator", iconImage: "Calculator_icon_ios.png", dataType:"Text"))
        
        accessoriesList.append(Accessory(id: "LR", title: "lazay_rashi", iconImage: "rashi_icon_ios.png", dataType:"Text"))
        
        accessoriesList.append(Accessory(id: "SH", title: "sefer_hearuch", iconImage: "rashi_icon_ios.png", dataType:"Text"))
        
        accessoriesList.append(Accessory(id: "RT", title: "acronyms", iconImage: "RasheiTevot_icon_ios.png", dataType:"Text"))
        
  
        
     //    accessoriesList.append(Accessory(id: "MAP", title: "מפות", iconImage: "map_icon_ios.png.png", dataType:"Text"))
        
        return accessoriesList
    }()
    
    func getAccessoryById(_ id:String) -> Accessory?
    {
        for accessory in accessoriesList
        {
            if accessory.id == id
            {
                return accessory
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBarTitleLabel?.text = "Accessories".localize()
    }
    
    func showLaazy_rashi()
    {
        self.navigationController?.pushViewController(self.expressionsViewController, animated: true)
        
        //If The selected accessory is equal to the last dispalyed accessory
        if self.expressionsViewController.accessory?.id == "LR" {
            return
        }
        
        self.expressionsViewController.setLoadingLayout()
        
         GetLaazy_rashiProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let accessory = self.getAccessoryById("LR")
            {
                accessory.expressions = object as? [Expression]
                self.expressionsViewController.reloadWithObject(accessory)
            }
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showRasheyTeivot()
    {
        self.navigationController?.pushViewController(self.expressionsViewController, animated: true)
        
        //If The selected accessory is equal to the last dispalyed accessory
        if self.expressionsViewController.accessory?.id == "RT" {
            return
        }
        
        self.expressionsViewController.setLoadingLayout()
        GetRasheyTeivotProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let accessory = self.getAccessoryById("RT")
            {
                accessory.expressions = object as? [Expression]
                self.expressionsViewController.reloadWithObject(accessory)
            }
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showTalmudExpression()
    {
        self.navigationController?.pushViewController(self.expressionsViewController, animated: true)
        
        //If The selected accessory is equal to the last dispalyed accessory
        if self.expressionsViewController.accessory?.id == "MT" {
            return
        }
        
        self.expressionsViewController.setLoadingLayout()
        
        GetTalmudExpressionProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let accessory = self.getAccessoryById("MT")
            {
                accessory.expressions = object as? [Expression]
                 self.expressionsViewController.reloadWithObject(accessory)
            }
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showMusagim()
    {
        self.navigationController?.pushViewController(self.expressionsViewController, animated: true)
        
        //If The selected accessory is equal to the last dispalyed accessory
        if self.expressionsViewController.accessory?.id == "MA" {
            return
        }
        
        self.expressionsViewController.setLoadingLayout()
        
        GetMusagimProces().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let accessory = self.getAccessoryById("MA")
            {
                accessory.expressions = object as? [Expression]
                 self.expressionsViewController.reloadWithObject(accessory)
            }
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showRabbisHistory()
    {
        self.navigationController?.pushViewController(self.expressionsViewController, animated: true)
        
        //If The selected accessory is equal to the last dispalyed accessory
        if self.expressionsViewController.accessory?.id == "TC" {
            return
        }
        
        self.expressionsViewController.setLoadingLayout()
        
        GetRabbisHistoryProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let accessory = self.getAccessoryById("TC")
            {
                accessory.expressions = object as? [Expression]
                self.expressionsViewController.reloadWithObject(accessory)
            }
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showMidotAndShiourim()
    {
        GetMidotAndShiurimInfoProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            var midotAndShuourimRefrenses = object as! [LinkInfo]
            
            let calculator = LinkInfo()
            calculator.title = "st_measurements_calculator_title"
            calculator.subTitle = "st_measurements_calculator_subtitle"
            calculator.path = "MeasurementCalculatorViewController"
            
            midotAndShuourimRefrenses.insert(calculator, at: 0)
            
             let midotAndShiourimViewController = UIViewController.withName("MidotAndShiourimViewController", storyBoardIdentifier: "AccessoriesStoryboard") as! MidotAndShiourimViewController
            
            midotAndShiourimViewController.reloadWithObject(midotAndShuourimRefrenses)
            
            self.navigationController?.pushViewController(midotAndShiourimViewController, animated: true)
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showSeferHearuch()
    {
        self.navigationController?.pushViewController(self.expressionsViewController, animated: true)
        
        //If The selected accessory is equal to the last dispalyed accessory
        if self.expressionsViewController.accessory?.id == "SH" {
            return
        }
        
        self.expressionsViewController.setLoadingLayout()
        
        GetSeferHearuchValuesProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            if let accessory = self.getAccessoryById("SH")
            {
                accessory.expressions = object as? [Expression]
                self.expressionsViewController.reloadWithObject(accessory)
            }
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func showCalculator()
    {
        let calculatorViewController = UIViewController.withName("MeasurementCalculatorViewController", storyBoardIdentifier: "Measurements")
        self.navigationController?.pushViewController(calculatorViewController, animated: true)
    }
    
    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.accessoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryTableCell", for:indexPath) as! MSBaseTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.reloadWithObject(self.accessoriesList[indexPath.row])
        
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
        
        let accessory = self.accessoriesList[indexPath.row]
        
        switch accessory.id {
        case "TC"://תודלות חכמים
            self.showRabbisHistory()
            break
            
        case "MA"://מושגים וערכים
            self.showMusagim()
            break
            
        case "MT"://מונחים תלמודיים
            self.showTalmudExpression()
            
            break
            
        case "MS"://מידות ושיעורים
            self.showMidotAndShiourim()
            
            break
            
        case "LR"://אוצר לעזי רש״י
             self.showLaazy_rashi()
             
            break
            
        case "SH": // ספר הערוך
             self.showSeferHearuch()
             
            break
            
        case "RT"://ראשי תיבות
             self.showRasheyTeivot()
             
            break
            
        case "CAL":// מחשבון מידות
            self.showCalculator()
            
            break
            
        default: break
            
        }

    }
}
