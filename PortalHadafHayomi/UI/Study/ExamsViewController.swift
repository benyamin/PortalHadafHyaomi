//
//  ExamsViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ExamsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource{

    var exams:[Exam]?
    
    var questions:[ExamQuestion]?
    var examCompleted = false
    
    @IBOutlet weak var examTableView:UITableView!
    @IBOutlet weak var checkExamButton:UIButton!
    @IBOutlet weak var examScoreLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        self.getExam()
    }
    
    func setupUI(){
        self.topBarTitleLabel?.text = "st_Exams".localize()
        self.checkExamButton.setTitle("st_cehck_exams".localize(), for: .normal)
        self.checkExamButton.layer.borderWidth = 1.0
        self.checkExamButton.layer.cornerRadius = 3.0
        self.checkExamButton.layer.borderColor = UIColor(HexColor:"791F23").cgColor
        self.examScoreLabel.isHidden = true
    }
    
    func getExam() {
        
        Util.showDefaultLoadingView()
        
        let  examInfo = (masechetId:1, minPage:3, maxPage:6)
        GetTalmudQAProcess().executeWithObject(examInfo, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            Util.hideDefaultLoadingView()
            
            self.exams = object as? [Exam]
            self.questions = self.getRandomQuestionsFromExams(self.exams!)
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    override func reloadData() {
        self.examTableView.reloadData()
    }
    
    func getRandomQuestionsFromExams(_ exams:[Exam]) -> [ExamQuestion]{
        var allQuestions = [ExamQuestion]()
        for exam in exams {
            allQuestions.append(contentsOf: exam.questions ?? [ExamQuestion]())
        }
        
        return allQuestions[randomPick: (allQuestions.count-1) >= 10 ? 10 : allQuestions.count-1]
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
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        
        return UITableViewAutomaticDimension
    }
     */
}
