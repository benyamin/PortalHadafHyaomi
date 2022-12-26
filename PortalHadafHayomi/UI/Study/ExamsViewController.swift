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
    
    @IBOutlet weak var examTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        self.getExam()
    }
    
    func setupUI(){
        self.topBarTitleLabel?.text = "st_Exams".localize()
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
    
    //MARK: - TableView Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.questions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamQuestionTableCell", for:indexPath) as! MSBaseTableViewCell
        
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
