//
//  LessonsPickerView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 15/01/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import UIKit

enum LessonsSortOption {
    case Maschtot
    case AllMagidiShiurs
    case FavoirteMagidiShiour
}

enum LessonsFilterOption {
    case All
    case Saved
}

enum LessonsMediaTypeOption {
    case All
    case Audio
    case Video
}

@objc protocol LessonsPickerViewDelegate: class
{
    func lessonsPickerViewDidChangeSelection()
    func isSavingLessonInProgress(lesson:Lesson) -> Bool
    func lessonDownloadPrecnetage(lesson:Lesson) -> Float
    func lessonsPickerView(_ pickerView: LessonsPickerView, didSelectRow row: Int, inComponent component: Int)
}

class LessonsPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource
{
    weak var delegate:LessonsPickerViewDelegate?
    
    var pickerView:TablePickerView!
   // var pickerView:UIPickerView!
    
    var selectedLesson:Lesson?
    
    var masechtotComponentTag = 2
    var pagesComponentTag = 1
    var magidShioursComponentTag = 0
        
    var lessonsSortOption:LessonsSortOption = .Maschtot{
        didSet{
            
            if lessonsSortOption == .Maschtot
            {
                self.masechtotComponentTag = 2
                self.pagesComponentTag = 1
                self.magidShioursComponentTag = 0
            }
            else if lessonsSortOption == .AllMagidiShiurs
                        || lessonsSortOption == .FavoirteMagidiShiour
            {
                self.magidShioursComponentTag = 2
                self.masechtotComponentTag = 1
                self.pagesComponentTag = 0
            }
          
            self.pickerView.removeFromSuperview()
            self.addPicker()
           // self.pickerView.reloadAllComponents()
            self.reloadData()
        }
    }
    
    var lessonsFilterOption:LessonsFilterOption = .All{
        didSet{
            self.reloadData()
        }
    }
    
    var lessonsMediaTypeOption:LessonsMediaTypeOption = .All{
        didSet{
            self.reloadData()
        }
    }
    
    var displayedMasechetot = [Masechet]()
    var displayedPages = [Page]()
    var displayedMaggidShiours = [MaggidShiur]()
    
    var selectedMaschet:Masechet?{
        get{
            if displayedMasechetot.count == 0 {
                return nil
            }
            
            if let maschetIndex = self.pickerView.selectedRow(inComponent: self.masechtotComponentTag)
            ,maschetIndex < self.displayedMasechetot.count {
                return self.displayedMasechetot[maschetIndex]
            }
            else{
                return self.displayedMasechetot.last
            }
            
        }
    }
    
    var selectedMaggidShiur:MaggidShiur?{
        
        get{
            if displayedMaggidShiours.count == 0 {
                return nil
            }
            
            if let magidShiursIndex = self.pickerView.selectedRow(inComponent: self.magidShioursComponentTag)
            , magidShiursIndex < self.displayedMaggidShiours.count {
                return self.displayedMaggidShiours[magidShiursIndex]
            }
            else{
                return self.displayedMaggidShiours.last
            }
            
        }
    }
    
    var selectedPage:Page?{
        get{
            if displayedPages.count == 0 {
                return nil
            }
            
            if let pageIndex = self.pickerView.selectedRow(inComponent: self.pagesComponentTag)
            ,pageIndex < self.displayedPages.count{
                  return self.displayedPages[pageIndex]
            }
            else{
                return self.displayedPages.last
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.semanticContentAttribute = .forceLeftToRight
       // UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        self.addPicker()
        
        if LessonsManager.sharedManager.lessons.count == 0
        {
             self.getLessons()
        }
        else{
            self.reloadData()
        }
    }
    
    func addPicker()
    {
      // self.pickerView = UIPickerView()//TablePickerView()
        self.pickerView = TablePickerView()
        self.pickerView.frame = self.bounds
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.addSubview(self.pickerView)
        self.sendSubview(toBack: self.pickerView)
        
        self.pickerView.semanticContentAttribute = .forceLeftToRight

        
        self.pickerView.reloadAllComponents()
        
        self.perform( #selector(updateDelegate), with: nil, afterDelay: 0.3)
    }
    
    func getLessons()
    {
        GetLessonsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onProgress: { (object) -> Void in
            
            //This returns for default lessons (last search)
            LessonsManager.sharedManager.lessons = object as! [Lesson]
            self.reloadData()
            
        }, onComplete: { (object) -> Void in
            
            LessonsManager.sharedManager.lessons = object as! [Lesson]
            
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func reloadData()
    {
        if self.pickerView == nil{
            return
        }
        
        if lessonsSortOption == .Maschtot
        {
           self.reloadDataByMasechtot()
        }
        else if lessonsSortOption == .AllMagidiShiurs || lessonsSortOption == .FavoirteMagidiShiour
        {
          self.reloadDataByMaggidShiours()
        }
    }
    
    func reloadComponent(_ component:Int)
    {
        self.pickerView.reloadComponent(component)
        self.delegate?.lessonsPickerViewDidChangeSelection()
    }
    
    func didSelectedMaschet(_ maschet:Masechet?)
    {
        if maschet != nil
        {
            if let masechetIndex = self.displayedMasechetot.index(of: maschet!)
            {
                self.pickerView(UIPickerView(), didSelectRow: masechetIndex, inComponent: self.masechtotComponentTag)
            }
        }
    }
    
    func reloadDataByMasechtot()
    {
        self.setDispalyedMasechtot()
        self.pickerView.reloadComponent(self.masechtotComponentTag)//Reload dispalyed Masehctot
        
        self.didSelectedMaschet(self.selectedMaschet)
    }
    
    func reloadDataByMaggidShiours()
    {
        self.setDisplayedMaggidShiours()
        self.pickerView.reloadComponent(self.magidShioursComponentTag)//Reload dispalyed MaggidShoiurs
        
        //Get and display masechtot for selected Maggid Shiour
        self.setDispalyedMasechtot()
        self.pickerView.reloadComponent(self.masechtotComponentTag)
        
        //Get pages for selected masechet
        self.setDisplayedPages()
        self.pickerView.reloadComponent(self.pagesComponentTag)
    }
    
    func setDisplayedPages()
    {
        self.displayedPages = self.selectedMaschet?.pages ?? [Page]()
        self.updateDisplayedPagesWithSavedLessons()
        
        self.displayedPages = self.runFiltersOnPages(displayedPages)
    }
    
    func setDispalyedMasechtot()
    {
        switch self.lessonsSortOption
        {
        case .Maschtot:
            self.displayedMasechetot = HadafHayomiManager.sharedManager.masechtot
            break
            
        case .AllMagidiShiurs:
            self.displayedMasechetot = self.selectedMaggidShiur?.maschtot ?? [Masechet]()
            break
            
        case .FavoirteMagidiShiour:
            self.displayedMasechetot = self.selectedMaggidShiur?.maschtot ?? [Masechet]()
            break
        }
        
        self.updateDisplayedMasechtotWithSavedLessons()
        self.displayedMasechetot = self.runFiltersOnMasechtot(self.displayedMasechetot)
    }
    
    func setDisplayedMaggidShiours()
    {
        switch self.lessonsSortOption
        {
        case .Maschtot:
            self.displayedMaggidShiours = self.selectedMaschet?.maggidShiurs ?? [MaggidShiur]()
            break
            
        case .AllMagidiShiurs:
            self.displayedMaggidShiours = HadafHayomiManager.sharedManager.maggidShiurs
            break
            
        case .FavoirteMagidiShiour:
            self.displayedMaggidShiours = HadafHayomiManager.sharedManager.maggidShiurs.filter{ $0.isFavorite == true }
            break
        }
        
        self.updateDisplayedMaggidShioursWithSavedLessons()
        self.displayedMaggidShiours = self.runFiltersOnMaggidShiours(self.displayedMaggidShiours)
        
        self.displayedMaggidShiours = self.sortMagidShioursbyLanguage()
    }
    
    func sortMagidShioursbyLanguage() -> [MaggidShiur]
    {
        var hebrewMaggidShiurs = [MaggidShiur]()
        var englishMaggidShiurs = [MaggidShiur]()
        
        for maggidShiour in self.displayedMaggidShiours
        {
            if maggidShiour.language.hasPrefix("English")
            {
                englishMaggidShiurs.append(maggidShiour)
            }
            else{
                 hebrewMaggidShiurs.append(maggidShiour)
            }
        }
        
        var sortedMagidShiours = [MaggidShiur]()
        
        if let appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String]
            , let local = appleLanguages.first
        {
            if local == "he_IL"
            {
                sortedMagidShiours.append(contentsOf: hebrewMaggidShiurs)
                sortedMagidShiours.append(contentsOf: englishMaggidShiurs)
            }
            else
            {
                sortedMagidShiours.append(contentsOf: englishMaggidShiurs)
                sortedMagidShiours.append(contentsOf: hebrewMaggidShiurs)
            }
        }
        
       // sortedMagidShiours = HadafHayomiManager.sharedManager.sortMaggidShiursArrayByLastPlayed(maggidShiursArray: sortedMagidShiours)
        
        return sortedMagidShiours
    }
    
    func runFiltersOnMasechtot(_ masehctot:[Masechet]) ->  [Masechet]
    {
        var filterdMaechtot = [Masechet]()
        
        for maechet in masehctot
        {
            if self.lessonsFilterOption == .Saved, maechet.hasSavedLessons != true
            {
                continue
            }
            
            filterdMaechtot.append(maechet)
        }
        
        return filterdMaechtot
    }
    
    func runFiltersOnMaggidShiours(_ maggidShiours:[MaggidShiur]) ->  [MaggidShiur]
    {
        var filterdMaggidShiours = [MaggidShiur]()
        
        for maggidShiur in maggidShiours
        {
            if self.lessonsMediaTypeOption == .Audio, maggidShiur.mediaType != .Audio
            {
                continue
            }
            else if self.lessonsMediaTypeOption == .Video, maggidShiur.mediaType != .Video
            {
                continue
            }
            
            if self.lessonsFilterOption == .Saved, maggidShiur.hasSavedLessons != true
            {
                continue
            }
           
            filterdMaggidShiours.append(maggidShiur)
        }
        
        return filterdMaggidShiours
    }
    
    func runFiltersOnPages(_ pages:[Page]) -> [Page]
    {
        var filterdPages = [Page]()
        
        for page in pages
        {
            if self.lessonsFilterOption == .Saved, page.hasSavedLessons != true
            {
                continue
            }
            filterdPages.append(page)
        }
        
        return filterdPages
    }
    
    func updateDisplayedPagesWithSavedLessons()
    {
        if self.lessonsSortOption == .Maschtot
        {
            for page in self.displayedPages
            {
                if page.hasSavedLessonForMasechet(self.selectedMaschet, andMagidShior: nil)
                {
                    page.hasSavedLessons = true
                }
                else{
                     page.hasSavedLessons = false
                }
            }
        }
    }
    
    func updateDisplayedMasechtotWithSavedLessons()
    {
        if self.lessonsSortOption == .Maschtot
        {
            for masechet in self.displayedMasechetot
            {
                masechet.hasSavedLessons = masechet.hasSavedLessonForMaggidShiour(nil, andPage: nil)
            }
        }
        else if self.lessonsSortOption == .AllMagidiShiurs || self.lessonsSortOption == .FavoirteMagidiShiour
        {
            for masechet in self.displayedMasechetot
            {
                masechet.hasSavedLessons = masechet.hasSavedLessonForMaggidShiour(self.selectedMaggidShiur, andPage: self.selectedPage)
            }
        }
    }
    
    func updateDisplayedMaggidShioursWithSavedLessons()
    {
        if self.lessonsSortOption == .Maschtot
        {
            for maggidShiour in self.displayedMaggidShiours
            {
                maggidShiour.hasSavedLessons = maggidShiour.hasSavedLessonForMasechet(self.selectedMaschet, andPage: self.selectedPage)
            }
        }
        else if self.lessonsSortOption == .AllMagidiShiurs || self.lessonsSortOption == .FavoirteMagidiShiour
        {
            for maggidShiour in self.displayedMaggidShiours
            {
                //If Masechet is nil and pages are nil, it indicates thate we want saved maggid shiours regardless to maschet or page
                 maggidShiour.hasSavedLessons = maggidShiour.hasSavedLessonForMasechet(nil, andPage:nil)
            }
        }
    }
    
     func select(maschet:Masechet, page:Page, maggidShior:MaggidShiur?)
     {
        switch self.lessonsSortOption
        {
        case .Maschtot:
            self.masechetDisplaySetSelected(maschet: maschet, page: page, maggidShior: maggidShior)
            break
            
        case .AllMagidiShiurs:
            
            self.maggidShoiurDisplaySetSelected(maschet: maschet, page: page, maggidShior: maggidShior ?? self.selectedMaggidShiur)
            break
            
        case .FavoirteMagidiShiour:
            self.maggidShoiurDisplaySetSelected(maschet: maschet, page: page, maggidShior: maggidShior ?? self.selectedMaggidShiur)
            break
        }
        
        self.delegate?.lessonsPickerViewDidChangeSelection()
    }
    
    func select(lesson:Lesson)
    {
        self.selectedLesson = lesson

        self.select(maschet: lesson.masechet, page: lesson.page!, maggidShior: lesson.maggidShiur)
    }
    
     func masechetDisplaySetSelected(maschet:Masechet, page:Page, maggidShior:MaggidShiur?)
     {
        if let requiredMasechet = self.displayedMasechetot.first(where: { $0.id == maschet.id })
        {
            //Scroll to selected Masechet
            if let masechetIndex = self.displayedMasechetot.index(of: requiredMasechet)
            {
                self.pickerView.selectRow(masechetIndex, inComponent: self.masechtotComponentTag, animated: true)
                
                //Set seletct row to update the selected masechet pages and maggid shiours
                self.pickerView(UIPickerView(), didSelectRow: masechetIndex, inComponent: self.masechtotComponentTag)
                
                //Scroll to selected page
                if let requiredPage = self.displayedPages.first(where: { $0.index == page.index })
                {
                    if let pageIndex = self.displayedPages.index(of: requiredPage)
                    {
                        self.pickerView.selectRow(pageIndex, inComponent: self.pagesComponentTag, animated: true)
                    }
                }
                
                if maggidShior != nil
                {
                    //Scroll to selected maggidShior
                    if let requiredMaggidShior = self.displayedMaggidShiours.first(where: { $0.id == maggidShior!.id })
                    {
                        if let maggidShiorIndex = self.displayedMaggidShiours.index(of: requiredMaggidShior)
                        {
                            self.pickerView.selectRow(maggidShiorIndex, inComponent: self.magidShioursComponentTag, animated: true)
                        }
                    }
                }
            }
        }
        
        self.perform( #selector(updateDelegate), with: nil, afterDelay: 0.3)
    }
    
    @objc func updateDelegate()
    {
        self.delegate?.lessonsPickerViewDidChangeSelection()
    }
    
    func maggidShoiurDisplaySetSelected(maschet:Masechet, page:Page, maggidShior:MaggidShiur!)
    {
        if let requiredMaggidShiour = self.displayedMaggidShiours.first(where: { $0.id == maggidShior.id })
        {
            //Scroll to selected MaggidShiour
            if let maggisShiourIndex = self.displayedMaggidShiours.index(of: requiredMaggidShiour)
            {
                self.pickerView.selectRow(maggisShiourIndex, inComponent: self.magidShioursComponentTag, animated: true)
                
                //Set seletct row to update the selected maggidShiour mesechtot and pages
                self.pickerView(UIPickerView(), didSelectRow: maggisShiourIndex, inComponent: 2)
                
                //Scroll to selected masechet
                if let requiredMesecht = self.displayedMasechetot.first(where: { $0.id == maschet.id })
                {
                    if let masechetIndex = self.displayedMasechetot.index(of: requiredMesecht)
                    {
                        self.pickerView.selectRow(masechetIndex, inComponent: self.masechtotComponentTag, animated: true)
                        
                        //Scroll to selected page
                        if let requiredPage = self.displayedPages.first(where: { $0.index == page.index })
                        {
                            if let pageIndex = self.displayedPages.index(of: requiredPage)
                            {
                                self.pickerView.selectRow(pageIndex, inComponent: self.pagesComponentTag, animated: true)
                            }
                        }
                    }
                }
                else{
                       let alertMessage = String(format: "st_lesson_not_found_message".localize(), arguments: [self.selectedMaggidShiur?.name ?? ""])
                    
                    BTAlertView.show(title: "", message: alertMessage, buttonKeys: ["st_ok".localize()], onComplete:{ (dismissButtonKey) in
                    })
                }
            }
        }
    }
    
    //MARK: - UIPickerView Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
       return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch component
        {
        case self.magidShioursComponentTag:
            return self.displayedMaggidShiours.count
            
        case self.pagesComponentTag:
            return self.displayedPages.count
            
        case self.masechtotComponentTag:
            return self.displayedMasechetot.count
            
        default:
            return 0
            
        }
    }
           
            
   func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        switch self.lessonsSortOption
        {
        case .Maschtot:
            switch(component)
            {
            case self.masechtotComponentTag:
                return 100
            case self.pagesComponentTag:
                return 50
            case self.magidShioursComponentTag:
                return self.pickerView.frame.size.width - 150
            default:
                return self.frame.size.width/3
            }
            
        case .AllMagidiShiurs, .FavoirteMagidiShiour:
            switch(component)
            {
            case self.magidShioursComponentTag:
                return self.pickerView.frame.size.width - 230
            case self.masechtotComponentTag:
                return 90
            case self.pagesComponentTag:
                return 130
            default:
                return self.frame.size.width/3
            }
        }
    }
    
     func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
     {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let componentWidth = self.pickerView(pickerView, widthForComponent: component)
        
        switch self.lessonsSortOption
        {
        case .Maschtot:
            switch(component)
            {
            case self.masechtotComponentTag:
                return self.masechetViewForRow(row, forComponent: component, reusing: view)
                
            case self.pagesComponentTag:
                let page = self.displayedPages[row]
                let rowView = UIView.viewWithNib("LessonPickerDefaultCell") as! LessonPickerDefaultCell
                rowView.frame.size.width = componentWidth
                rowView.reloadWithtitle(page.symbol, isSelected: page.hasSavedLessons)
                return rowView
                
            case self.magidShioursComponentTag:
                let maggidShiour = self.displayedMaggidShiours[row]
                let rowView = UIView.viewWithNib("LessonPickerMaggidShiourCell") as! LessonPickerMaggidShiourCell
                rowView.frame.size.width = componentWidth
                 rowView.titleLabelLeadingConstriant.constant = 80
                rowView.reloadWithMaggidShiour(maggidShiour)
                
                if let maschet = self.selectedMaschet, let page = self.selectedPage
                {
                    let lesson = Lesson(maschet: maschet,
                                        page: page,
                                        andMaggidShiur: maggidShiour)
                    
                    self.checkSelectedLesson(lesson: lesson, isDownloadingAtRow: rowView)
                }
                
                return rowView
                
            default:
                break
            }
            
        case .AllMagidiShiurs, .FavoirteMagidiShiour:
            switch(component)
            {
            case self.magidShioursComponentTag:
                let maggidShiour = self.displayedMaggidShiours[row]
                let rowView = UIView.viewWithNib("LessonPickerMaggidShiourCell") as! LessonPickerMaggidShiourCell
                rowView.frame.size.width = componentWidth
                rowView.titleLabelLeadingConstriant.constant = 8
                rowView.reloadWithMaggidShiour(maggidShiour)
                return rowView
                
            case self.masechtotComponentTag:
                 return self.masechetViewForRow(row, forComponent: component, reusing: view)
                
            case self.pagesComponentTag:
                let page = self.displayedPages[row]
                let rowView = UIView.viewWithNib("LessonPickerDefaultCell") as! LessonPickerDefaultCell
                rowView.frame.size.width = componentWidth
                rowView.reloadWithtitle(page.symbol, isSelected: page.hasSavedLessons)
                
                if let maschet = self.selectedMaschet, let maggidShiour = self.selectedMaggidShiur
                               {
                                   let lesson = Lesson(maschet: maschet,
                                                       page: page,
                                                       andMaggidShiur: maggidShiour)
                                   
                                   self.checkSelectedLesson(lesson: lesson, isDownloadingAtRow: rowView)
                               }
                
                return rowView
                
            default:
                break
            }
        }
        return UIView()
    }
    
    func masechetViewForRow(_ row: Int,forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let componentWidth = self.pickerView(UIPickerView(), widthForComponent: component)
        
        let masechet = self.displayedMasechetot[row]
        
        var rowView:LessonPickerDefaultCell!
        if view is LessonPickerDefaultCell
        {
            rowView = view as? LessonPickerDefaultCell
        }
        else
        {
            rowView = UIView.viewWithNib("LessonPickerDefaultCell") as? LessonPickerDefaultCell
        }
        rowView.frame.size.width = componentWidth
        rowView.reloadWithtitle(masechet.name, isSelected: masechet.hasSavedLessons)
        
        return rowView
    }
    func checkSelectedLesson(lesson:Lesson, isDownloadingAtRow rawView:UIView)
    {
        if  lesson.masechet != nil && lesson.page != nil &&  lesson.maggidShiur != nil
        {
            if self.delegate?.isSavingLessonInProgress(lesson: lesson) ?? false
            {
                let circleViewTag = 545
                var progressCircleView:BTProgressCircleView!
                
                if let view = rawView.viewWithTag(circleViewTag)
                {
                    progressCircleView = view as? BTProgressCircleView
                }
                else{
                    
                    progressCircleView =  BTProgressCircleView(frame: CGRect(x: 3, y: 3, width: 42, height: 42))
                    progressCircleView.tag = circleViewTag
                    rawView.addSubview(progressCircleView)
                }
                
                progressCircleView.updatePrecnetage(precentage: self.delegate!.lessonDownloadPrecnetage(lesson: lesson))
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch self.lessonsSortOption
        {
        case .Maschtot:
            switch(component)
            {
            case self.masechtotComponentTag:
                
                //ReloadPages
                let selectedPage = self.selectedPage
                self.setDisplayedPages()
                self.pickerView.reloadComponent(self.pagesComponentTag)
                
                if selectedPage != nil{
                    self.pickerView.selectRow(selectedPage!.index-1, inComponent: 1, animated: false)
                }

                
                //ReloadMagidShiours
               self.setDisplayedMaggidShiours()
                self.pickerView.reloadComponent(self.magidShioursComponentTag)
                break
                
            case self.pagesComponentTag:
                
                 //Loop through all MaggidShiours and mark MaggidShiours witch have saed lesson on the selected masechet and page
                self.updateDisplayedMaggidShioursWithSavedLessons()
                 self.pickerView.reloadComponent(self.magidShioursComponentTag)
                break
                
            case self.magidShioursComponentTag:
                break
            default:
                break
            }
            
        case .AllMagidiShiurs, .FavoirteMagidiShiour:
            switch(component)
            {
            case 2://MaggidShiur
                
                //Get and reload masechtot for selected MagidShior
                self.setDispalyedMasechtot()
                self.pickerView.reloadComponent(1)
                
                //Get and reload pages for selected masechet
                self.setDisplayedPages()
                self.pickerView.reloadComponent(self.pagesComponentTag)
                break
                
            case 1://Masceht
                
                //Get and reload pages for selected masechet
                self.setDisplayedPages()
                self.pickerView.reloadComponent(self.pagesComponentTag)
                break
                
            case 0://Page
                break
                
            default:
                break
            }
        }
 
        //self.delegate?.pick
        self.delegate?.lessonsPickerView(self, didSelectRow: row, inComponent: component)
    } 
}
