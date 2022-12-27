//
//  ExamsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ExamsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{

    var exams:[Exam]?
    
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
    @IBOutlet weak var pagePickerTitleLabel:UILabel?
    @IBOutlet weak var pagePickerSelectButton:UIButton?
    @IBOutlet weak var pagePickerBaseViewBottomConstraint:NSLayoutConstraint?
    
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
        
        self.selectMasechetTextField?.text = selectMasechetDefaultText
        self.selectFromPageTextField?.text = selectPageDefaultText
        self.selectToPageTextField?.text = selectPageDefaultText
        
        self.pagePickerBaseView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.pagePickerBaseView?.layer.shadowOpacity = 0.5
        self.pagePickerBaseView?.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.pagePickerBaseView?.layer.shadowRadius = 2.0
        
        self.pagePickerSelectButton?.setTitle("st_hide".localize(), for: .normal)
        self.pagePickerSelectButton?.layer.borderWidth = 1.0
        self.pagePickerSelectButton?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
        
        self.createExamButton?.setTitle("st_create_exam".localize(), for: .normal)
        
        self.examTableView.alpha = 0.2
        self.examTableView.isUserInteractionEnabled = false
        
        self.pageSelectionView?.setLocalizatoin()
        
            //self.explantionMessage = "בחר את הדפים שעליהם הינך מעוניין להיבחן"
    }
    
    func createExam() {
        
        self.examCompleted = false
        
        Util.showDefaultLoadingView()
        
        if let masechet = self.selectedMasechet
        ,let fromPage =  self.pagePickerView?.selectedRow(inComponent: 1)
        ,let toPage =  self.pagePickerView?.selectedRow(inComponent: 0){
            
            let  examInfo = (masechetId:masechet.id, minPage:fromPage+1, maxPage:toPage+1)
            GetTalmudQAProcess().executeWithObject(examInfo, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                Util.hideDefaultLoadingView()
                
                self.exams = object as? [Exam]
                self.questions = self.getRandomQuestionsFromExams(self.exams!)
                self.reloadData()
                
                if self.questions == nil || self.questions!.count == 0 {
                    BTAlertView.show(title: "st_create_exam".localize(), message: "st_no_exam_found_for_selected_pages".localize(), buttonKeys: ["st_ok".localize()]) { dismissButtonKey in }
                }
                else{
                    self.setDefaultLayout()
                }
                
            },onFaile: { (object, error) -> Void in
                Util.hideDefaultLoadingView()
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
    
    func showCreateExamView() {
        self.createExamViewHeightConstraint.constant = 111
    }
    
    func hideCreateExamView() {
        self.createExamViewHeightConstraint.constant = self.pageSelectionView.frame.size.height+1
    }
    
    func setDefaultLayout(){
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
            if let selectedMasechet = self.selectedMasechet{
                let selectedFromPageIndex = pickerView.selectedRow(inComponent: 1)
                return selectedFromPageIndex == 0 ? 1 : selectedMasechet.pages.count + 1
            }
            else{
                return 1
            }
            
        case 1://From page
            return self.selectedMasechet?.pages.count ?? 0 + 1
            
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
        case 0, 1: //Page
            
            if row == 0
            {
                pikerLabel.text = "st_all_pages".localize()
            }
            else if let page = selectedMasechet?.pages[row-1]
            {
                if component == 0 // לדף
                {
                    pikerLabel.text = "לדף " + page.symbol
                    
                    if let seletedFromPageRow =  self.pagePickerView?.selectedRow(inComponent: 1){
                        
                        pikerLabel.alpha = row < seletedFromPageRow ? 0.3 : 1.0
                    }
                }
                else if component == 1 { // מדף
                    pikerLabel.text = "מדף " + page.symbol
                }
            }
            
            break
            
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
            let seletedFromPageRow = pickerView.selectedRow(inComponent: component)
            self.didSelectFromPageIndex(seletedFromPageRow)
        }
        
        else  if component == 0 // To page
        {
            let seletedToPageRow = pickerView.selectedRow(inComponent: component)
            self.didSelectToPageIndex(seletedToPageRow)
        }
    }
    
    func didSelectMasechet(_ masechet:Masechet?)
    {
        self.selectedMasechet = masechet
        self.selectMasechetTextField?.text = self.selectedMasechet?.name
        
        self.pagePickerView?.reloadComponent(1)// From page
        
        if let seletedFromPageRow = self.pagePickerView?.selectedRow(inComponent: 1)
        {
            self.pickerView( self.pagePickerView!, didSelectRow: seletedFromPageRow, inComponent: 1)
        }
    }
    
    func didSelectFromPageIndex(_ pageIndex:Int)
    {
        let selectedFromPageIndex = pageIndex
        
        if selectedFromPageIndex == 0
        {
            self.selectFromPageTextField?.text = selectPageDefaultText
        }
        else
        {
            if let page = selectedMasechet?.pages[selectedFromPageIndex-1]
            {
                self.selectFromPageTextField?.text =  page.symbol
            }
        }
        self.pagePickerView?.reloadComponent(0)// To page
        
        var seletedToPageRow = self.pagePickerView!.selectedRow(inComponent: 0)
        
        if seletedToPageRow != 0 && seletedToPageRow < selectedFromPageIndex
        {
            seletedToPageRow = selectedFromPageIndex
        }
        self.pagePickerView?.selectRow(seletedToPageRow, inComponent: 0, animated: true)
        self.pickerView(self.pagePickerView!, didSelectRow: seletedToPageRow, inComponent: 0)
    }
    
    func didSelectToPageIndex(_ pageIndex:Int)
    {
        let seletedFromPageRow =  self.pagePickerView!.selectedRow(inComponent: 1)
        
        var seletedToPageRow = pageIndex
        
        if seletedToPageRow != 0 && seletedToPageRow <= seletedFromPageRow
        {
            seletedToPageRow = seletedFromPageRow+1
            
            self.pagePickerView?.selectRow(seletedToPageRow, inComponent: 0, animated: true)
            self.pickerView(self.pagePickerView!, didSelectRow: seletedToPageRow, inComponent: 0)
            return
        }
        
        if seletedToPageRow == 0 // From page
        {
            self.selectToPageTextField?.text = selectPageDefaultText
        }
        else
        {
            if let page = selectedMasechet?.pages[seletedToPageRow-1]
            {
                self.selectToPageTextField?.text =  page.symbol
            }
        }
    }
}
