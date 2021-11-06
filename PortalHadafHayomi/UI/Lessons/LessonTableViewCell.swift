//
//  LessonTableViewCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 09/12/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class LessonTableViewCell: MSBaseTableViewCell {

    var onPlayLesson:((_ lesson:Lesson) -> Void)?
    
    var lesson:Lesson?
    
    @IBOutlet weak var lessonPageLabel:UILabel?
    @IBOutlet weak var lessonMaggidShiurLabel:UILabel?
    @IBOutlet weak var durationLabel:UILabel?
    @IBOutlet weak var playButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadWithObject(_ object: Any) {
        self.lesson = object as? Lesson
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.lessonPageLabel?.text = ("מסכת \(self.lesson?.masechet.name ?? "") דף \(self.lesson?.page?.symbol ?? "")")
        self.lessonMaggidShiurLabel?.text = self.lesson?.maggidShiur.name
        self.durationLabel?.text = self.lesson?.durationDisplay
    }
    
    @IBAction func playButtonClicked(){
        
        if lesson != nil {
            self.onPlayLesson?(lesson!)
        }
    }
    
}
