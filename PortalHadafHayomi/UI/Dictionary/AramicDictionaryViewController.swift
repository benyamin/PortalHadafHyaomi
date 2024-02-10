//
//  AramicDictionaryViewController.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 07/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class AramicDictionaryViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UITextViewDelegate
{
    @IBOutlet weak var displaySegmentedControlr:UISegmentedControl!
    @IBOutlet weak var sourceLanguageLabel:UILabel?
    @IBOutlet weak var translationLanguageLabel:UILabel?
    @IBOutlet weak var aramicListTableView:UITableView!
    @IBOutlet weak var aramicListTableViewBottomConstrains:NSLayoutConstraint!
    
    @IBOutlet weak var freeTextView:UIView!
    @IBOutlet weak var sorceTextViewTitleLabel:UILabel?
    @IBOutlet weak var sorceTextView:UITextView!
    @IBOutlet weak var translationTextViewTitleLabel:UILabel?
    @IBOutlet weak var translationTextView:UITextView!
    @IBOutlet weak var freeTextViewBottomConstrains:NSLayoutConstraint!
    @IBOutlet weak var searchBar:UISearchBar!
    
     var firstAppearacne = true
    
    var selectedDictionary = [TranslatedWord]()
    {
        didSet{
            
             self.displayedDiactionary = selectedDictionary
            
            if selectedDictionary ==  DictionaryManager.sharedManager.hebrewWords
            {
                self.sourceLanguageLabel?.text = "עברית"
                 self.translationLanguageLabel?.text = "ארמית"
            }
            if selectedDictionary ==  DictionaryManager.sharedManager.aramicWords
            {
                self.sourceLanguageLabel?.text = "ארמית"
                self.translationLanguageLabel?.text = "עברית"
            }
            
            self.sorceTextViewTitleLabel?.text = self.sourceLanguageLabel?.text
            self.translationTextViewTitleLabel?.text = self.translationLanguageLabel?.text
            
            self.sorceTextView.text = ""
            self.translationTextView.text = ""
            
            self.aramicListTableView.reloadData()

        }
    }
    
    var displayedDiactionary = [TranslatedWord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.searchBar.layer.shadowOpacity = 0.8
        self.searchBar.layer.shadowRadius = 3.0
        self.searchBar.layer.shadowColor = UIColor.gray.cgColor
        
        Util.showDefaultLoadingView()

        //Set selected index to show list view
        self.displaySegmentedControlr.selectedSegmentIndex = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.firstAppearacne
        {
            self.firstAppearacne = false
            
            self.selectedDictionary = DictionaryManager.sharedManager.aramicWords
            
            self.aramicListTableView.reloadData()
            
            Util.hideDefaultLoadingView()
        }
        
        self.view.addSubview(self.freeTextView)
        let freeTextViewOrigenY = self.displaySegmentedControlr.frame.origin.y + self.displaySegmentedControlr.frame.size.height
        self.freeTextView.frame = CGRect(x: 0, y: freeTextViewOrigenY, width: self.view.bounds.width, height: self.view.frame.size.height - freeTextViewOrigenY)
        self.freeTextView.isHidden = true
    }
    
    @IBAction func switchDictoianryButtonClicked(_ sedner:AnyObject)
    {
        if self.selectedDictionary == DictionaryManager.sharedManager.aramicWords
        {
            self.selectedDictionary = DictionaryManager.sharedManager.hebrewWords
        }
        else{
            self.selectedDictionary = DictionaryManager.sharedManager.aramicWords
        }
    }
        
     @IBAction func displaySegmentedControlrValueChanged(_ sedner:AnyObject)
     {
        if self.displaySegmentedControlr.selectedSegmentIndex == 0//free text
        {
            self.freeTextView.isHidden = false
            self.sorceTextView.becomeFirstResponder()
        }
         if self.displaySegmentedControlr.selectedSegmentIndex == 1//list
         {
            self.freeTextView.isHidden = true
            self.sorceTextView.resignFirstResponder()
        }
    }
        

    // MARK: - TableView Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       return self.displayedDiactionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
         let cell = tableView.dequeueReusableCell(withIdentifier: "AramicDictionaryCell", for:indexPath) as! MSBaseTableViewCell
        
        cell.reloadWithObject(self.displayedDiactionary[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //Mark: - UISearchBarDelegate
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
     {
        searchBar.showsCancelButton = true
        searchBar.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        var priamryFilterdWords = [TranslatedWord]()
        var secondaryFilterdWords = [TranslatedWord]()
        var otherFilterdWords = [TranslatedWord]()
        for word in self.selectedDictionary
        {
            if word.key.hasPrefix(searchText){
                priamryFilterdWords.append(word)
            }
            else{
                let subWords = word.key.components(separatedBy: " ")
                for subWord in subWords{
                    if subWord.hasPrefix(searchText) {
                        secondaryFilterdWords.append(word)
                    }
                    else if subWord.contains(searchText){
                        otherFilterdWords.append(word)
                    }
                }
            }
        }
        
        self.displayedDiactionary = priamryFilterdWords + secondaryFilterdWords + otherFilterdWords
        self.aramicListTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        self.displayedDiactionary = self.selectedDictionary
        
        self.aramicListTableView.reloadData()
    }
    
    //MARK: - Keyboard notifications
    @objc override func keyboardWillAppear(_ notification: Notification)
    {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
             let applicationWindow = UIApplication.shared.keyWindow!
            let bottomPadding = applicationWindow.frame.size.height - self.view.frame.size.height
            
            self.freeTextViewBottomConstrains.constant = keyboardSize.height - bottomPadding
            self.aramicListTableViewBottomConstrains.constant = keyboardSize.height - bottomPadding
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
                {
                    self.view.setNeedsLayout()
                    
            }, completion: {_ in
            })
            
        }
    }
    
    @objc override func keyboardWillDisappear(_ notification: Notification)
    {
        if self.displaySegmentedControlr.selectedSegmentIndex == 1// List
        {
            self.aramicListTableViewBottomConstrains.constant = 0
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
                {
                    self.view.setNeedsLayout()
                    
            }, completion: {_ in
            })
            
        }
    }
    
    //MARK: - Textview Delegate methods
    func textViewDidChange(_ textView: UITextView)
    {
        if let aramicText = textView.text
        {
            self.translationTextView.text = self.translateText(aramicText)
        }
    }
    
     func translateText(_ aramicText:String) -> String
    {
        var translatoinText = " "
        
        let aramicWords = aramicText.components(separatedBy: " ")
        for word in aramicWords
        {
            if let translationWord = DictionaryManager.sharedManager.translateWord(word, fromDictioanry: self.selectedDictionary)
            {
                translatoinText += translationWord
                translatoinText += " "
            }
            else{
                if word.contains("\n"){
                    let additionalWords = word.components(separatedBy: "\n")
                    for subWord in additionalWords
                    {
                        if let translationWord = DictionaryManager.sharedManager.translateWord(subWord, fromDictioanry: self.selectedDictionary)
                        {
                            translatoinText += translationWord
                        }
                        else{
                            translatoinText += subWord
                        }
                        if subWord != additionalWords.last {
                            translatoinText += "\n"
                        }
                        else{
                            translatoinText += " "
                        }
                    }
                }
                else{
                    translatoinText += word
                    translatoinText += " "
                }
            }
        }
        
        return translatoinText
    }
    /*
    func translateText(_ aramicText:String) -> String
    {
        //While the text dos no have a translate, remoe last word and retry to tranlate the sentence
        var translatedText = ""
        
        var textToTranslate = aramicText
       
        while textToTranslate != " " && textToTranslate != ""
        {
            var translatoinWord1:String!
             var remainingText = textToTranslate
        while translatoinWord1 == nil
        {
            if let translatedWord = DictionaryManager.sharedManager.translatedWordForAramicWord(remainingText)
            {
                translatoinWord1 = translatedWord
            }
            else{
                let aramicWord = remainingText
                remainingText = remainingText.components(separatedBy: " ").dropLast().joined(separator: " ")
                
                //lastWord
                //This will acour if the word dos not have a translation
                if remainingText == ""
                {
                    remainingText = aramicWord
                    
                    let index = aramicWord.index(aramicWord.startIndex, offsetBy:1)
                    var firstLeatr = String(aramicWord[..<index])
                    let cutAramicWord = String(aramicWord[index...])
                    
                     if let translatedWord = DictionaryManager.sharedManager.translatedWordForAramicWord(cutAramicWord)
                     {
                        if firstLeatr == "ד"
                        {
                            firstLeatr = "ש"
                        }
                        
                        translatoinWord1 =  " " + translatedWord + firstLeatr
                    }
                     else{
                        translatoinWord1 = " " + aramicWord
                    }
                    
                }
            }
        }
        translatedText += translatoinWord1
            
        textToTranslate = textToTranslate.stringByReplacingFirstOccurrenceOfString(target: remainingText, withString: "")
        }
        
       return translatedText
    }
*/
}
