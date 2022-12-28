//
//  ExamsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ExamsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    var questions:[ExamQuestion]?
    var examCompleted = false
    var selectedMasechet:Masechet?
    
    let selectMasechetDefaultText = "st_all_masechtot".localize()
    let selectPageDefaultText = "st_all".localize()
    
    @IBOutlet weak var examTableView:UITableView!
    @IBOutlet weak var bottomBar:UIView!
    @IBOutlet weak var checkExamButton:UIButton!
    @IBOutlet weak var examScoreLabel:UILabel!
    
    @IBOutlet weak var pageSelectionView:UIView!
    @IBOutlet weak var createExamView:UIView!
    @IBOutlet weak var createExamButton:UIButton!
    @IBOutlet weak var hideCreateExamViewButton:UIButton!
    @IBOutlet weak var createExamViewHeightConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var selectMasechetTextField:UITextField?
    @IBOutlet weak var selectFromPageTextField:UITextField?
    @IBOutlet weak var selectToPageTextField:UITextField?
    
    @IBOutlet weak var pagePickerBaseView:UIView?
    @IBOutlet weak var pagePickerView:UIPickerView?
    @IBOutlet weak var pagePickerSelectButton:UIButton?
    @IBOutlet weak var pagePickerBaseViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var todaysPageButton:UIButton?
    
    @IBOutlet weak var explantionView:UIView!
    @IBOutlet weak var explantionMessageLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    func setupUI(){
        self.topBarTitleLabel?.text = "st_Exams".localize()
        self.checkExamButton.setTitle("st_cehck_exams".localize(), for: .normal)
        self.checkExamButton.layer.borderWidth = 1.0
        self.checkExamButton.layer.cornerRadius = 3.0
        self.checkExamButton.layer.borderColor = UIColor(HexColor:"791F23").cgColor
        self.examScoreLabel.isHidden = true
        
        self.bottomBar.addUpperShadow()
        
        self.createExamView.addBottomShadow()
                
        self.pagePickerBaseView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.pagePickerBaseView?.layer.shadowOpacity = 0.5
        self.pagePickerBaseView?.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.pagePickerBaseView?.layer.shadowRadius = 2.0
        
        self.pagePickerSelectButton?.setTitle("st_hide".localize(), for: .normal)
        self.pagePickerSelectButton?.layer.borderWidth = 1.0
        self.pagePickerSelectButton?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
        
        self.todaysPageButton?.setTitle("st_move_to_todays_page".localize(), for: .normal)
        self.todaysPageButton?.layer.borderWidth = 1.0
        self.todaysPageButton?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
        
        self.createExamButton?.setTitle("st_create_exam".localize(), for: .normal)
        
        self.examTableView.alpha = 0.2
        self.examTableView.isUserInteractionEnabled = false
        
        self.pageSelectionView?.setLocalizatoin()
        
        self.explantionMessageLabel.text = "st_exam_instructions".localize()
        
        explantionView.layer.borderWidth = 1.0
        explantionView.layer.borderColor = UIColor(HexColor:"6A2423").cgColor
        explantionView.layer.cornerRadius = 3.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Current selected display page in Talmud VC
        if let selectedPageInfo = UserDefaults.standard.object(forKey: "selectedPageInfo") as? [String:Any]
            ,let maschetId = selectedPageInfo["maschetId"] as? String
            ,let maschent = HadafHayomiManager.sharedManager.getMasechetById(maschetId)
            ,let pageIndex = selectedPageInfo["pageIndex"] as? Int{
            
            self.select(maseceht: maschent, fromPageIndex: pageIndex, toPageIndex: pageIndex)
        }
        else{
            self.scrollToTodaysPage()
        }
    }
    
    func createExam() {
        
        self.examCompleted = false
        
        self.createExamButton.isUserInteractionEnabled = false
        
        Util.showDefaultLoadingView()
        
        if let masechetIndex = self.pagePickerView?.selectedRow(inComponent: 2)
        ,let fromPage = self.pagePickerView?.selectedRow(inComponent: 1)
        ,let toPage = self.pagePickerView?.selectedRow(inComponent: 0){
            
            let  examInfo = (masechetId:masechetIndex+1, minPage:fromPage+1, maxPage:toPage+1)
            GetTalmudQAProcess().executeWithObject(examInfo, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                Util.hideDefaultLoadingView()
                
                if let exams = object as? [Exam] {
                    self.questions = self.getRandomQuestionsFromExams(exams)
                }
                else{
                    self.questions = nil
                }
                self.reloadData()
                
                if self.questions == nil || self.questions!.count == 0 {
                    BTAlertView.show(title: "st_create_exam".localize(), message: "st_no_exam_found_for_selected_pages".localize(), buttonKeys: ["st_ok".localize()]) { dismissButtonKey in }
                }
                else{
                    self.setDefaultLayout()
                }
                
                self.createExamButton.isUserInteractionEnabled = true
                
            },onFaile: { (object, error) -> Void in
                Util.hideDefaultLoadingView()
                
                self.createExamButton.isUserInteractionEnabled = true
            })
        }
    }
    
    override func reloadData() {
        self.examTableView.reloadData()
    }
    
    func getRandomQuestionsFromExams(_ exams:[Exam]) -> [ExamQuestion]{
        var allQuestions = [ExamQuestion]()
        for exam in exams {
            allQuestions.append(contentsOf: exam.questions ?? [ExamQuestion]())
        }
        if allQuestions.count == 0 {
            return allQuestions
        }
        else{
            return allQuestions[randomPick: (allQuestions.count-1) >= 10 ? 10 : allQuestions.count-1]
        }
    }
    
    @IBAction func checkExamButtonClicked(_ sender:UIButton){
        var score = 0
        if let questions = self.questions {
            for question in questions {
                if let answers = question.answers {
                    for answer in answers {
                        //If did select correct answer
                        if answer.isSelected && answer.isCorrect {
                            score += 100/questions.count
                        }
                    }
                }
            }
        }
        
        self.examScoreLabel.text = "st_exam_score".localize(withArgumetns: ["\(Int(score))"])
        self.examScoreLabel.isHidden = false
        
        self.examCompleted = true
        self.examTableView.reloadData()
    }
    
    @IBAction func hideCreateExamViewButtonClicked(_ sender:UIButton){
        self.setDefaultLayout()
    }
    
    @IBAction func pagePickerSelectButtonClicked(_ sender:UIButton)
    {
        self.hidePagePicker(animated: true)
    }
    
    @IBAction func createExamButtonClicked(_ sender:UIButton){
        self.createExam()
    }
    
    @IBAction func todaysPageButtonClicked(_ sender:UIButton){
        self.scrollToTodaysPage()
    }
    
    func scrollToTodaysPage(){
        if let todaysMaschet = HadafHayomiManager.sharedManager.todaysMaschet
            ,let todaysPage = HadafHayomiManager.sharedManager.todaysPage {
            
            self.select(maseceht: todaysMaschet, fromPageIndex: todaysPage.index, toPageIndex: todaysPage.index)
        }
    }
    
    func select(maseceht:Masechet, fromPageIndex:Int, toPageIndex:Int) {
        
        if let maschetIndex = HadafHayomiManager.sharedManager.masechtot.index(of: maseceht){
            self.pagePickerView?.selectRow(maschetIndex, inComponent: 2, animated: false)
            self.didSelectMasechet(maseceht)
            
            //Select from page
            self.pagePickerView?.selectRow(fromPageIndex, inComponent: 1, animated: false)
            self.didSelectFromPageIndex(fromPageIndex)
            
            //Select to page
            self.pagePickerView?.selectRow(toPageIndex, inComponent: 0, animated: false)
            self.didSelectToPageIndex(toPageIndex)
        }
    }
    
    func showCreateExamView() {
        self.createExamViewHeightConstraint.constant = 111
    }
    
    func hideCreateExamView() {
        self.createExamViewHeightConstraint.constant = self.pageSelectionView.frame.size.height+1
    }
    
    func setDefaultLayout(){
        self.explantionView.isHidden = true
        self.hideCreateExamView()
        self.hidePagePicker(animated: true)
        self.examTableView.alpha = 1.0
        self.examTableView.isUserInteractionEnabled = true
    }
    
    //MARK: - TableView Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.questions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamQuestionTableCell", for:indexPath) as! ExamQuestionTableCell
        
        if examCompleted {
            cell.isUserInteractionEnabled = false
            cell.highlightCorrectAnswer = true
        }
        else{
            cell.isUserInteractionEnabled = true
            cell.highlightCorrectAnswer = false
        }
        
        if let question = self.questions?[indexPath.row] {
            cell.reloadWithObject(question)
        }
        
        return cell
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.explantionView.isHidden = false
        self.showCreateExamView()
        self.showPicker(self.pagePickerView!, animated:true)
        self.examTableView.alpha = 0.2
        self.examTableView.isUserInteractionEnabled = false
        
        return false
    }
    
    func showPicker(_ picker:UIPickerView, animated:Bool)
    {
        self.pagePickerView?.isHidden = true
        
        picker.isHidden = false
        
        self.pagePickerBaseViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func hidePagePicker(animated:Bool)
    {
        self.pagePickerBaseViewBottomConstraint?.constant = -1*(self.pagePickerBaseView!.frame.size.height)
                
        UIView.animate(withDuration:animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
        
    }
    //MARK: - UIPickerView Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        switch component
        {
        case 0://To page
            return self.selectedMasechet?.pages.count ?? 0
            
        case 1://From page
            return self.selectedMasechet?.pages.count ?? 0
            
        case 2://Masechet
            return HadafHayomiManager.sharedManager.masechtot.count
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        switch component {
            
        case 0, 1://Page
            return pickerView.frame.size.width/4
            
        case 2://Maschet
            return pickerView.frame.size.width/2
            
        default:
            return pickerView.frame.size.width/2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pikerLabel = view as? UILabel ?? UILabel()
        pikerLabel.textAlignment = .center
        
        pikerLabel.font = UIFont(name:"BroshMF", size: 20)!
        pikerLabel.textColor = UIColor(HexColor: "781F24")
        pikerLabel.text = ""
        
        
        switch component
        {
        case 0: //To page
            
            if let page = selectedMasechet?.pages[row]{
                pikerLabel.text = "לדף " + page.symbol
                
                if let seletedFromPageRow =  self.pagePickerView?.selectedRow(inComponent: 1){
                    pikerLabel.alpha = 1.0
                    
                    if row < seletedFromPageRow || row > seletedFromPageRow+10 {
                        pikerLabel.alpha = 0.3
                    }
                }
            }
         
            break
           
        case 1: //From page
            if let page = selectedMasechet?.pages[row]{
                pikerLabel.text = "מדף " + page.symbol
            }
            
        case 2://masechet
            pikerLabel.text = HadafHayomiManager.sharedManager.masechtot[row].name
            
            break
            
        default:
            break
        }
        
        return pikerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 2 // Did select Masechet
        {
            let masehcet = HadafHayomiManager.sharedManager.masechtot[row]
            self.didSelectMasechet(masehcet)
        }
        
        else  if component == 1 // From page
        {
            self.didSelectFromPageIndex(row)
        }
        
        else  if component == 0 // To page
        {
            self.didSelectToPageIndex(row)
        }
    }
    
    func didSelectMasechet(_ masechet:Masechet?)
    {
        if self.selectedMasechet != masechet{
            
            self.questions = nil
            self.reloadData()
            
            self.selectedMasechet = masechet
            self.selectMasechetTextField?.text = self.selectedMasechet?.name
            
            self.pagePickerView?.reloadComponent(1)// From page
            
            if var seletedFromPageRow = self.pagePickerView?.selectedRow(inComponent: 1)
            {
                if seletedFromPageRow >= self.selectedMasechet!.numberOfPages {
                    seletedFromPageRow = self.selectedMasechet!.numberOfPages-1
                }
                self.pickerView( self.pagePickerView!, didSelectRow: seletedFromPageRow, inComponent: 1)
            }
        }
    }
    
    func didSelectFromPageIndex(_ fromPageIndex:Int)
    {
        if let page = selectedMasechet?.pages[fromPageIndex] {
            self.selectFromPageTextField?.text =  page.symbol
        }
        
        self.pagePickerView?.reloadComponent(0)// To page
        
        var selectedToPageRow = self.pagePickerView!.selectedRow(inComponent: 0)
        
        if selectedToPageRow < fromPageIndex{
            selectedToPageRow = fromPageIndex
        }
        if let numberOfPages = selectedMasechet?.pages.count
            ,selectedToPageRow >= numberOfPages {
            selectedToPageRow = numberOfPages-1
        }
        self.pagePickerView?.selectRow(selectedToPageRow, inComponent: 0, animated: true)
        self.pickerView(self.pagePickerView!, didSelectRow: selectedToPageRow, inComponent: 0)
    }
    
    func didSelectToPageIndex(_ toPageIndex:Int)
    {
        var seletedFromPageRow =  self.pagePickerView!.selectedRow(inComponent: 1)
        
        if let numberOfPages = selectedMasechet?.pages.count
            , seletedFromPageRow > numberOfPages-1 {
            seletedFromPageRow =  numberOfPages-1
        }
        var seletedToPageRow = toPageIndex
        
        if seletedToPageRow != 0 && seletedToPageRow < seletedFromPageRow
        {
            seletedToPageRow = seletedFromPageRow
            self.pagePickerView?.selectRow(seletedToPageRow, inComponent: 0, animated: true)
            self.pickerView(self.pagePickerView!, didSelectRow: seletedToPageRow, inComponent: 0)
            return
        }
        
        if seletedToPageRow > seletedFromPageRow+10
        {
            seletedToPageRow = seletedFromPageRow+10
            
            self.pagePickerView?.selectRow(seletedToPageRow, inComponent: 0, animated: true)
            self.pickerView(self.pagePickerView!, didSelectRow: seletedToPageRow, inComponent: 0)
            return
        }
        
        if let page = selectedMasechet?.pages[seletedToPageRow]{
            self.selectToPageTextField?.text =  page.symbol
        }
    }
}
