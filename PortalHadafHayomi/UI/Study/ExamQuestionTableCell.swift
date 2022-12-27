//
//  ExamQuestionTableCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 26/12/2022.
//  Copyright © 2022 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ExamQuestionTableCell: MSBaseTableViewCell, UITableViewDelegate, UITableViewDataSource {

    var question:ExamQuestion?
    var highlightCorrectAnswer = false
    
    @IBOutlet var cardView:UIView!
    @IBOutlet var headerView:UIView!
    @IBOutlet var questionDescriptoinLabel:UILabel?
    @IBOutlet var answersTableView:UITableView!
    @IBOutlet var tableHegihtConstraint:NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView.layer.borderColor = UIColor(HexColor:"791F23").cgColor
        self.cardView.layer.borderWidth = 1.0
        self.cardView.layer.cornerRadius = 3.0
        
        self.headerView?.addBottomShadow()
        
        self.bringSubview(toFront: self.headerView)
    }
    
    override func reloadWithObject(_ object: Any) {
        self.question = object as? ExamQuestion
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.questionDescriptoinLabel?.text = self.question?.Qdescription ?? ""
        self.answersTableView?.reloadData()
        self.tableHegihtConstraint?.constant = CGFloat((self.question?.answers?.count ?? 0) * 44)
    }
    
    //MARK: - TableView Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.question?.answers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamAnswerTableCell", for:indexPath) as! MSBaseTableViewCell
        
        if let answer =  self.question?.answers?[indexPath.row]{
            cell.reloadWithObject(answer)
            
            if self.highlightCorrectAnswer && answer.isCorrect {
                cell.contentView.backgroundColor = UIColor(HexColor: "FAF2DD")
            }
            else{
                cell.contentView.backgroundColor = UIColor.white
            }
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let answers = self.question?.answers {
            for answer in answers {
                answer.isSelected = false
            }
            let selectedAnswer = answers[indexPath.row]
            selectedAnswer.isSelected = true
            
            tableView.reloadData()
        }
    }
}
