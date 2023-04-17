//
//  CalendarViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

class CalendarViewController: MSBaseViewController, UICollectionViewDelegate, JewishCallPopOverDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate,TalmudPagePickerViewDelegate
{
    @IBOutlet weak var jewishCallCollectionView:UICollectionView!
    @IBOutlet weak var dateSelectionView:UIView!
    @IBOutlet weak var datePicker:UIDatePicker!
    @IBOutlet weak var datePickerTypeSegmentedController:UISegmentedControl!
    @IBOutlet weak var dateSelectionDisplayButton:UIButton!
    @IBOutlet weak var dateSelectionViewTopConstraint:NSLayoutConstraint!
    @IBOutlet weak var selectDateButton:UIButton?
    @IBOutlet weak var selectDateLabel:UILabel?
    @IBOutlet weak var cancelSelecttionDateButton:UIButton?
    @IBOutlet weak var dispalyTypeSegmentedControl:UISegmentedControl!
    @IBOutlet weak var searchButton:UIButton!
    @IBOutlet weak var selectPageButton:UIButton!
    @IBOutlet weak var dismissTalmudPagePickerButton:UIButton!
    @IBOutlet weak var talmudPagePickerBaseView:UIView!
    @IBOutlet weak var talmudPagePickerBaseViewBottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var talmudPagePickerView:TalmudPagePickerView!
    
    var firstDisplayedMonth:CallendarMonth!
    var displayedCalendar = Calendar.hebrew
    
    let numberOfMonths = 12 * 80
    
    var popover:Popover?
    
    open var onDisplayPageForDate:((_ date:Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide date selection view
        self.dateSelectionViewTopConstraint.constant = -1 * self.dateSelectionView.frame.size.height
        
        let layout = self.jewishCallCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        self.jewishCallCollectionView.isHidden = true
        
        self.dispalyTypeSegmentedControlValueChanged(self.dispalyTypeSegmentedControl)
        
        self.selectDateLabel?.text = Calendar.hebrew.dayDisaplyName(from: Date(), forLocal: "he_IL")
        
        let calendarImageName = UIImage(named: "Calender_icon_empty.png")
        let calendarImage = UIImage.imageWithTintColor(calendarImageName!, color: UIColor(HexColor: "781F24"))
        
        dateSelectionDisplayButton.backgroundColor = UIColor.clear
        dateSelectionDisplayButton.setImage(calendarImage, for: .normal)
        
        self.dateSelectionView.layer.shadowColor = UIColor.darkGray.cgColor
        self.dateSelectionView.layer.shadowOpacity = 0.8
        self.dateSelectionView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.dateSelectionView.layer.shadowRadius = 2.0
        
        self.selectPageButton.layer.borderColor = UIColor(HexColor: "791F23").cgColor
        self.selectPageButton.layer.borderWidth = 1.0
        self.selectPageButton.layer.cornerRadius = 3.0
        
        self.dismissTalmudPagePickerButton.layer.borderColor = UIColor(HexColor: "791F23").cgColor
        self.dismissTalmudPagePickerButton.layer.borderWidth = 1.0
        self.dismissTalmudPagePickerButton.layer.cornerRadius = 3.0
        
        self.talmudPagePickerBaseView.layer.borderColor = UIColor(HexColor: "791F23").cgColor
        self.talmudPagePickerBaseView.layer.borderWidth = 1.0
        
        self.talmudPagePickerBaseView.layer.masksToBounds = false
        self.talmudPagePickerBaseView.layer.shadowColor = UIColor.black.cgColor
        self.talmudPagePickerBaseView.layer.shadowOpacity = 0.5
        self.talmudPagePickerBaseView.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.talmudPagePickerBaseView.layer.shadowRadius = 2
        
        self.hideTalmudPagePickerView(animated: false)
        
        self.datePickerTypeSegmentedController.setTitle("st_hebrew_dates".localize(), forSegmentAt: 0)
        self.datePickerTypeSegmentedController.setTitle("st_gregorian_dates".localize(), forSegmentAt: 1)
        self.datePickerTypeSegmentedController.setTitle("st_todays_page".localize(), forSegmentAt: 2)
        
        self.selectDateButton?.setTitle("st_select".localize(), for: .normal)
        self.cancelSelecttionDateButton?.setTitle("st_cancel".localize(), for: .normal)
        
        self.dispalyTypeSegmentedControl.setTitle("st_hebrew_calendar".localize(), forSegmentAt: 0)
        self.dispalyTypeSegmentedControl.setTitle("st_gregorian_calendar".localize(), forSegmentAt: 1)
        
        self.selectPageButton!.setTitle("st_select".localize(), for: .normal)
        self.dismissTalmudPagePickerButton!.setTitle("st_cancel".localize(), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  self.jewishCallCollectionView.isHidden
        {
            self.jewishCallCollectionView.delegate = self
            self.jewishCallCollectionView.dataSource = self
            
              self.jewishCallCollectionView.reloadData()
            
            let sectoin = displayedCalendar.monthBetweenDates(firstDate: self.firstDisplayedMonth.startDayDate, secondDate: Date())
            
            self.jewishCallCollectionView.scrollToItem(at: IndexPath(row: 0, section: sectoin), at: .top, animated: false)
            
             let reusableHeaderview = self.jewishCallCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "JewishCallCollectionHeaderView", for: IndexPath(row: 0, section: 0)) as! JewishCallCollectionHeaderView
            
            let contentOffSet = CGPoint(x:  self.jewishCallCollectionView.contentOffset.x, y:  self.jewishCallCollectionView.contentOffset.y - reusableHeaderview.frame.size.height)
            self.jewishCallCollectionView.setContentOffset(contentOffSet, animated: false)
            
            self.jewishCallCollectionView.isHidden = false
            
            self.datePickerTypeSegmentedController.selectedSegmentIndex = 0 //HebrowCalendar
            self.datePickerTypeSegmentedControllerValueChanged( self.datePickerTypeSegmentedController)
        }
        
        self.setTalmudPagePickerView()
    }
    
    func setTalmudPagePickerView()
    {
        self.talmudPagePickerView.delegate = self
        
        let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet!
        let todaysPage = HadafHayomiManager.sharedManager.todaysPage!
        self.talmudPagePickerView.scrollToMasechet(todaysMaschet, page: todaysPage, pageSide: 0, animated: false)
    }
    
    @IBAction func dispalyTypeSegmentedControlValueChanged(_ sedner:AnyObject)
    {
        if dispalyTypeSegmentedControl.selectedSegmentIndex == 0//hebrew calendar
        {
            self.displayedCalendar = .hebrew
            
            self.firstDisplayedMonth = HebrewMonth.monthForDate(Date(year: 1995, month: 1, day: 1))
        }
        
        else if dispalyTypeSegmentedControl.selectedSegmentIndex == 1//gregorian calendar
        {
            self.displayedCalendar = .gregorian
            
            self.firstDisplayedMonth = GregorianMonth.monthForDate(Date(year: 1995, month: 1, day: 1))
            
        }
        
        self.jewishCallCollectionView.reloadData()
        
        //If view did appear
         if self.jewishCallCollectionView.isHidden == false //view did appear
         {
            self.scrollToDate(self.datePicker.date, animated:false)
        }
    }
    
    @IBAction func datePickerTypeSegmentedControllerValueChanged(_ sedner:AnyObject)
    {
         if  datePickerTypeSegmentedController.selectedSegmentIndex == 0//Show Hebrew dates Picker
         {
            self.datePicker.calendar = Calendar.hebrew
            self.datePicker.locale = Locale(identifier: "he_IL")
            
            //self.datePicker.semanticContentAttribute = .forceRightToLeft
        }
         else if datePickerTypeSegmentedController.selectedSegmentIndex == 1//Show Gregorian dates Picker
         {
            self.datePicker.calendar = Calendar.gregorian
            self.datePicker.locale = Locale(identifier: "en_US")
        }
        
         else //Todays page
         {
            self.datePicker.setDate(Date(), animated: true)
            
            var selectedSegmentIndex = 0
            if self.datePicker.calendar == Calendar.gregorian
            {
                    selectedSegmentIndex = 1
            }
                    
             self.datePickerTypeSegmentedController.selectedSegmentIndex = selectedSegmentIndex
            return
        }
        
        self.datePicker.minimumDate = firstDisplayedMonth.startDayDate
        
         if self.displayedCalendar == .hebrew
         {
            let lastMonth = HebrewMonth.monthByAddingNumberOfMonth(self.numberOfMonths, toMonth: self.firstDisplayedMonth as! HebrewMonth)
            self.datePicker.maximumDate = lastMonth.endDayDate
         }
         else
         {
            let lastMonth = GregorianMonth.monthByAddingNumberOfMonth(self.numberOfMonths, toMonth: self.firstDisplayedMonth as! GregorianMonth)
            self.datePicker.maximumDate = lastMonth.endDayDate
        }
            
        self.datePicker.reloadInputViews()
            
    }
    
    
    @IBAction func searchButtonButtonClicked(_ sender:AnyObject)
    {
        self.showTalmudPagePickerView()
    }
    
    @IBAction func dateSelectionDisplayButtonClicked(_ sender:AnyObject)
    {
        //If date picker is hidden
        if self.dateSelectionViewTopConstraint.constant != 0
        {
            self.showDatePicker()
        }
    }
    
    @IBAction func selectDateButtonClicked(_ sender:AnyObject)
    {
        self.scrollToDate(self.datePicker.date, animated:false)
        
        self.hideDatePicker()
    }
    
    @IBAction func hideDateButtonClicked(_ sender:AnyObject)
    {
         self.hideDatePicker()
    }

    func showDatePicker()
    {
         self.dateSelectionViewTopConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func hideDatePicker()
    {
        self.dateSelectionViewTopConstraint.constant = -1 * self.dateSelectionView.frame.size.height
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func scrollToDate(_ date:Date, animated:Bool)
    {
        let section = displayedCalendar.monthBetweenDates(firstDate: self.firstDisplayedMonth.startDayDate, secondDate: date)
        
        if section < self.numberOfSections(in: self.jewishCallCollectionView)
        {
            self.jewishCallCollectionView.scrollToItem(at: IndexPath(row: 0, section: section), at: .top, animated: animated)
        }
    }
    
    //MARK: - CollectoinView Delegate Mthods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.numberOfMonths
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let reusableHeaderview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "JewishCallCollectionHeaderView", for: indexPath) as! JewishCallCollectionHeaderView
            
            if self.displayedCalendar == Calendar.hebrew
            {
                let month = HebrewMonth.monthByAddingNumberOfMonth(indexPath.section, toMonth: self.firstDisplayedMonth as! HebrewMonth)
                
                reusableHeaderview.reloadWithMonth(month)
            }
            else{
                let month = GregorianMonth.monthByAddingNumberOfMonth(indexPath.section, toMonth: self.firstDisplayedMonth as! GregorianMonth)
                
                reusableHeaderview.reloadWithMonth(month)
            }
            
            return reusableHeaderview
            
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var month = CallendarMonth()
        if self.displayedCalendar == Calendar.hebrew
        {
            month = HebrewMonth.monthByAddingNumberOfMonth(section, toMonth: self.firstDisplayedMonth as! HebrewMonth)
        }
        else{
            month = GregorianMonth.monthByAddingNumberOfMonth(section, toMonth: self.firstDisplayedMonth as! GregorianMonth)
        }
        
        let prefixDayes = month.startDay! - 1
        let sufixDayes = 7 - month.endDay!
        
        let displayedMonthNumberOfDays =  month.numberOfDays + prefixDayes + sufixDayes
        
        return displayedMonthNumberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JewishCallCollectionCell", for: indexPath) as! JewishCallCollectionCell
        
        var month = CallendarMonth()
        if self.displayedCalendar == .hebrew
        {
            month = HebrewMonth.monthByAddingNumberOfMonth(indexPath.section, toMonth: self.firstDisplayedMonth as! HebrewMonth)
        }
        else{
            month = GregorianMonth.monthByAddingNumberOfMonth(indexPath.section, toMonth: self.firstDisplayedMonth as! GregorianMonth)
        }
        
         let prefixDayes = month.startDay! - 1
        let firstDisplayedDate = Date(timeInterval: TimeInterval(-1*prefixDayes*24*60*60), since: month.startDayDate)
        
        var date = Date(timeInterval: TimeInterval(indexPath.row*24*60*60), since: firstDisplayedDate).localTimeZoneDate()
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = date.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        date = Date(timeIntervalSince1970: timezoneEpochOffset)
        
        cell.reloadWithObject(date)
        
       if self.displayedCalendar == Calendar.hebrew
        {
            cell.mainDateLabel.text =  Calendar.hebrew.dayDisaplyName(from: date, forLocal: "he_IL")
            cell.secondaryDateLabel.text =  Calendar.gregorian.dayDisaplyName(from: date, forLocal: "en_US")
        }
        else{
            cell.mainDateLabel.text = Calendar.gregorian.dayDisaplyName(from: date, forLocal: "en_US")
            cell.secondaryDateLabel.text = Calendar.hebrew.dayDisaplyName(from: date, forLocal: "he_IL")
        }
      
        
        if date.isBetweenDates(month.startDayDate, secondDate: month.endDayDate)
            || date.isEqual(to: month.startDayDate)
        {
            cell.setEnabledLayout()
        }
        else{
             cell.setDisabledLayout()
        }
        
        cell.mainDateLabel.textColor = UIColor(HexColor: "6A2423")
        cell.secondaryDateLabel.textColor = UIColor(HexColor: "6A2423")
        cell.pageLabel.textColor = UIColor(HexColor: "6A2423")
        
        if date.isToday()
        {
            cell.backgroundColor = UIColor(HexColor: "F9F3DB")
        }
        else if date.isEqualDayAsDate(self.datePicker.date)
        {
            cell.backgroundColor = UIColor(HexColor: "6A2423")
            
            cell.mainDateLabel.textColor = UIColor(HexColor: "F9F3DB")
            cell.secondaryDateLabel.textColor = UIColor(HexColor: "F9F3DB")
            cell.pageLabel.textColor = UIColor(HexColor: "F9F3DB")
        }
        else{
            cell.backgroundColor = UIColor(HexColor: "DCDCDC")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size = collectionView.bounds.size.width/7
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for cell in collectionView.visibleCells
        {
            cell.reloadInputViews()
        }
        let cell = collectionView.cellForItem(at: indexPath)
        self.showPopOverForCell(cell as! JewishCallCollectionCell)
        
    }
    
    func showPopOverForCell(_ cell:JewishCallCollectionCell) {
        
        if let jewishCallPopOver = UIView.viewWithNib("JewishCallPopOver") as? JewishCallPopOver
        {
            jewishCallPopOver.reloadWithDate(cell.date)
            jewishCallPopOver.delegate = self
            
            let options = [
                .type(.up)
                ] as [PopoverOption]
            self.popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
            self.popover?.show(jewishCallPopOver, fromView: cell, inView: self.view)
           // self.popover?.show(jewishCallPopOver, fromView: cell)
        }
    }
    
    //MARK: = JewishCallPopOver Delegate methods
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, didChangeStatusForDate date:Date)
    {
        self.jewishCallCollectionView.reloadData()
    }
    
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, dismissButtonClicked button:UIButton)
    {
        self.popover?.dismiss()
    }
    
    func JewishCallPopOver(_ jewishCallPopOver:JewishCallPopOver, didSelectDisplayPageForDate date:Date){
                
        self.popover?.dismiss()

        self.onDisplayPageForDate?(date)
    }
    
    //MARK: = TalmudPagePickerView delegate meothods
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didChangeComponent component:Int)
    {
    }
    
    func talmudPagePickerView(_ talmudPagePickerView:TalmudPagePickerView, didHide:Bool)
    {
    }
    
    @IBAction func dismissTalmudPagePickerButtonClicked() {
        self.hideTalmudPagePickerView(animated: true)
    }
    
    @IBAction func selectPageButtonClicked() {
        
        if let selectedMasechet = talmudPagePickerView.selectedMasechet
            , let selectedPage = talmudPagePickerView.selectedPage {
            
            if let todayMasecht = HadafHayomiManager.sharedManager.todaysMaschet
            ,let todaysPage = HadafHayomiManager.sharedManager.todaysPage {
                
                let todaysPageIndex = todayMasecht.firstPageNumber + todaysPage.index
                
                let selectedPageIndex = selectedMasechet.firstPageNumber + selectedPage.index
                
                var numberOfDaysToSelectedPage = selectedPageIndex - todaysPageIndex
                if numberOfDaysToSelectedPage < 0 {
                    numberOfDaysToSelectedPage = HadafHayomiManager.sharedManager.numberOfDaysToCycleComplition() + selectedPageIndex
                }
                let selectedDate = Date().addingTimeInterval(TimeInterval(24*60*60*numberOfDaysToSelectedPage))
                self.datePicker.setDate(selectedDate, animated: false)
                self.scrollToDate(selectedDate, animated: false)
                self.jewishCallCollectionView.reloadItems(at: self.jewishCallCollectionView.indexPathsForVisibleItems)
            }
        }
        self.hideTalmudPagePickerView(animated: true)
    }
    
    func hideTalmudPagePickerView(animated:Bool) {
        
        self.talmudPagePickerBaseViewBottomConstraint.constant = -1 * self.talmudPagePickerBaseView.frame.size.height
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
                {
                    self.view.layoutIfNeeded()
                    
            }, completion: {_ in
            })
        }
        else{
             self.view.layoutIfNeeded()
        }
        
    }
    func showTalmudPagePickerView() {
        
        self.talmudPagePickerBaseViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
}
