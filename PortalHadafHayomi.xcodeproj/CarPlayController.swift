//
//  CarPlayController.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import Foundation
import CarPlay
import UIKit

/// Main CarPlay controller that coordinates between CarPlay interface and app logic
@available(iOS 13.0, *)
class CarPlayController: NSObject {
    
    static let shared = CarPlayController()
    
    private var interfaceController: CPInterfaceController?
    private var currentTemplate: CPTemplate?
    
    override init() {
        super.init()
        setupCarPlaySession()
    }
    
    // MARK: - Setup
    
    private func setupCarPlaySession() {
        // Configure audio session for CarPlay
        CarPlayAudioManager.shared.setupAudioSession()
        
        // Listen for lesson changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lessonDidChange),
            name: NSNotification.Name("LessonDidChange"),
            object: nil
        )
    }
    
    // MARK: - Interface Controller Management
    
    func setInterfaceController(_ interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
    }
    
    func clearInterfaceController() {
        self.interfaceController = nil
    }
    
    // MARK: - Template Management
    
    func createMainTemplate() -> CPTabBarTemplate {
        let lessonsTemplate = createLessonsTemplate()
        let favoritesTemplate = createFavoritesTemplate()
        
        lessonsTemplate.tabTitle = "שיעורים"
        lessonsTemplate.tabImage = UIImage(systemName: "book.fill")
        
        favoritesTemplate.tabTitle = "מועדפים"
        favoritesTemplate.tabImage = UIImage(systemName: "heart.fill")
        
        return CPTabBarTemplate(templates: [lessonsTemplate, favoritesTemplate])
    }
    
    private func createLessonsTemplate() -> CPListTemplate {
        var sections: [CPListSection] = []
        
        // Today's Daf section
        if let todaysLesson = getTodaysLesson() {
            let todayItem = createLessonItem(for: todaysLesson)
            todayItem.setText("דף היום - \(todaysLesson.page?.symbol ?? "")")
            let todaySection = CPListSection(items: [todayItem], header: "דף היום", sectionIndexTitle: nil)
            sections.append(todaySection)
        }
        
        // Recent lessons
        if let recentLessons = getRecentLessons() {
            let recentItems = recentLessons.map { createLessonItem(for: $0) }
            let recentSection = CPListSection(items: recentItems, header: "שיעורים אחרונים", sectionIndexTitle: nil)
            sections.append(recentSection)
        }
        
        // Browse option
        let browseItem = CPListItem(text: "עיון לפי מסכת", detailText: "בחר מסכת, דף ומגיד שיעור")
        browseItem.setImage(UIImage(systemName: "list.bullet"))
        browseItem.handler = { [weak self] _, completion in
            self?.presentBrowseTemplate()
            completion()
        }
        
        let browseSection = CPListSection(items: [browseItem], header: "עיון", sectionIndexTitle: nil)
        sections.append(browseSection)
        
        return CPListTemplate(title: "שיעורי דף היומי", sections: sections)
    }
    
    private func createFavoritesTemplate() -> CPListTemplate {
        var sections: [CPListSection] = []
        
        // Favorite Maggid Shiurs
        let favoriteMaggiShiurs = HadafHayomiManager.sharedManager.maggidShiurs.filter { $0.isFavorite }
        
        if !favoriteMaggiShiurs.isEmpty {
            let favoriteItems = favoriteMaggiShiurs.map { maggidShiur -> CPListItem in
                let item = CPListItem(text: maggidShiur.name, detailText: maggidShiur.language)
                item.setImage(UIImage(systemName: "person.fill"))
                item.handler = { [weak self] _, completion in
                    self?.presentLessonsForMaggidShiur(maggidShiur)
                    completion()
                }
                return item
            }
            
            let favoritesSection = CPListSection(items: favoriteItems, header: "מגידי שיעור מועדפים", sectionIndexTitle: nil)
            sections.append(favoritesSection)
        }
        
        // Saved lessons
        if let savedLessons = getSavedLessons() {
            let savedItems = savedLessons.map { createLessonItem(for: $0) }
            let savedSection = CPListSection(items: savedItems, header: "שיעורים שמורים", sectionIndexTitle: nil)
            sections.append(savedSection)
        }
        
        // Empty state
        if sections.isEmpty {
            let emptyItem = CPListItem(text: "אין פריטים מועדפים", detailText: "הוסף מגידי שיעור מועדפים באפליקציה")
            emptyItem.setImage(UIImage(systemName: "heart"))
            let emptySection = CPListSection(items: [emptyItem])
            sections.append(emptySection)
        }
        
        return CPListTemplate(title: "מועדפים", sections: sections)
    }
    
    // MARK: - Navigation
    
    private func presentBrowseTemplate() {
        let masechtot = HadafHayomiManager.sharedManager.masechtot
        let items = masechtot.map { masechet -> CPListItem in
            let item = CPListItem(text: masechet.name, detailText: "\(masechet.numberOfPages!) דפים")
            item.setImage(UIImage(systemName: "book"))
            item.handler = { [weak self] _, completion in
                self?.presentPagesForMasechet(masechet)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "בחר מסכת", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func presentPagesForMasechet(_ masechet: Masechet) {
        let pages = masechet.pages
        let items = pages.map { page -> CPListItem in
            let item = CPListItem(text: "דף \(page.symbol ?? "")", detailText: nil)
            item.setImage(UIImage(systemName: "doc"))
            item.handler = { [weak self] _, completion in
                self?.presentMaggiShiursForMasechet(masechet, page: page)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "בחר דף - \(masechet.name ?? "")", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func presentMaggiShiursForMasechet(_ masechet: Masechet, page: Page) {
        let maggidShiurs = masechet.maggidShiurs
        let items = maggidShiurs.map { maggidShiur -> CPListItem in
            let item = CPListItem(text: maggidShiur.name, detailText: maggidShiur.language)
            item.setImage(UIImage(systemName: "person"))
            item.handler = { [weak self] _, completion in
                let lesson = Lesson(maschet: masechet, page: page, andMaggidShiur: maggidShiur)
                self?.playLesson(lesson)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "בחר מגיד שיעור", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func presentLessonsForMaggidShiur(_ maggidShiur: MaggidShiur) {
        var items: [CPListItem] = []
        
        for masechet in maggidShiur.maschtot {
            let item = CPListItem(text: masechet.name, detailText: "\(masechet.numberOfPages!) דפים")
            item.setImage(UIImage(systemName: "book"))
            item.handler = { [weak self] _, completion in
                self?.presentPagesForMasechetAndMaggidShiur(masechet, maggidShiur: maggidShiur)
                completion()
            }
            items.append(item)
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "בחר מסכת - \(maggidShiur.name ?? "")", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func presentPagesForMasechetAndMaggidShiur(_ masechet: Masechet, maggidShiur: MaggidShiur) {
        let pages = masechet.pages
        let items = pages.map { page -> CPListItem in
            let item = CPListItem(text: "דף \(page.symbol ?? "")", detailText: nil)
            item.setImage(UIImage(systemName: "doc"))
            item.handler = { [weak self] _, completion in
                let lesson = Lesson(maschet: masechet, page: page, andMaggidShiur: maggidShiur)
                self?.playLesson(lesson)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "בחר דף - \(masechet.name ?? "") - \(maggidShiur.name ?? "")", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    // MARK: - Playback
    
    private func playLesson(_ lesson: Lesson) {
        // Use the CarPlayAudioManager for playback
        CarPlayAudioManager.shared.playLesson(lesson)
        
        // Present Now Playing template
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        interfaceController?.presentTemplate(nowPlayingTemplate, animated: true, completion: nil)
        
        // Store recent lesson
        storeRecentLesson(lesson)
    }
    
    // MARK: - Data Helpers
    
    private func createLessonItem(for lesson: Lesson) -> CPListItem {
        let title = "\(lesson.masechet?.name ?? "") - \(lesson.page?.symbol ?? "")"
        let subtitle = lesson.maggidShiur?.name ?? ""
        
        let item = CPListItem(text: title, detailText: subtitle)
        item.setImage(getLessonImage(for: lesson))
        
        item.handler = { [weak self] _, completion in
            self?.playLesson(lesson)
            completion()
        }
        
        return item
    }
    
    private func getLessonImage(for lesson: Lesson) -> UIImage? {
        switch lesson.mediaType {
        case .Video:
            return UIImage(systemName: "play.rectangle.fill")
        case .Audio:
            return UIImage(systemName: "play.circle.fill")
        default:
            return UIImage(systemName: "waveform")
        }
    }
    
    private func getTodaysLesson() -> Lesson? {
        // Get today's daf from HadafHayomiManager
        // This is a placeholder - implement based on your existing logic
        return nil
    }
    
    private func getRecentLessons() -> [Lesson]? {
        if let recentData = UserDefaults.standard.array(forKey: "RecentCarPlayLessons") as? [[String: Any]] {
            return recentData.compactMap { Lesson(dictionary: $0) }.prefix(5).map { $0 }
        }
        return nil
    }
    
    private func getSavedLessons() -> [Lesson]? {
        return LessonsManager.sharedManager.lessons.filter {
            LessonsManager.sharedManager.isSavedLesson($0)
        }.prefix(5).map { $0 }
    }
    
    private func storeRecentLesson(_ lesson: Lesson) {
        var recentLessons = UserDefaults.standard.array(forKey: "RecentCarPlayLessons") as? [[String: Any]] ?? []
        
        // Remove if already exists
        recentLessons.removeAll { dict in
            if let id = dict["identifier"] as? String {
                return id == lesson.identifier
            }
            return false
        }
        
        // Add to beginning
        recentLessons.insert(lesson.deserializeDictioanry(), at: 0)
        
        // Keep only last 10
        if recentLessons.count > 10 {
            recentLessons = Array(recentLessons.prefix(10))
        }
        
        UserDefaults.standard.set(recentLessons, forKey: "RecentCarPlayLessons")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Notifications
    
    @objc private func lessonDidChange() {
        // Refresh templates if needed
        // This could be called when lessons data changes
    }
}