//
//  CarPlaySceneDelegate.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import UIKit
import CarPlay
import MediaPlayer

@available(iOS 13.0, *)
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    // MARK: - Scene Lifecycle
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        print("CarPlay scene connecting...")
        
        self.interfaceController = interfaceController
        self.interfaceController?.delegate = self
        
        // Set up the initial template safely
        setupInitialTemplate()
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        print("CarPlay scene disconnecting...")
        self.interfaceController = nil
    }
    
    // MARK: - Initial Setup
    
    private func setupInitialTemplate() {
        guard let interfaceController = self.interfaceController else {
            print("No interface controller available")
            return
        }
        
        do {
            let mainTemplate = createMainTabBarTemplate()
            interfaceController.setRootTemplate(mainTemplate, animated: false, completion: nil)
            print("CarPlay template set successfully")
        } catch {
            print("Error setting up CarPlay template: \(error)")
            
            // Fallback to simple template
            let fallbackTemplate = createFallbackTemplate()
            interfaceController.setRootTemplate(fallbackTemplate, animated: false, completion: nil)
        }
    }
    
    private func createFallbackTemplate() -> CPListTemplate {
        let item = CPListItem(text: "דף היומי", detailText: "הפעל שיעור")
        item.setImage(UIImage(systemName: "book.fill"))
        
        let section = CPListSection(items: [item])
        return CPListTemplate(title: "דף היומי", sections: [section])
    }
    
    private func createMainTabBarTemplate() -> CPTabBarTemplate {
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
        if let todaysMasechet = HadafHayomiManager.sharedManager.todaysMaschet,
           let todaysPage = HadafHayomiManager.sharedManager.todaysPage {
            let todayItem = CPListItem(text: "דף היום - \(todaysPage.symbol ?? "")", 
                                     detailText: "מסכת \(todaysMasechet.name ?? "")")
            todayItem.setImage(UIImage(systemName: "calendar.circle.fill"))
            todayItem.handler = { [weak self] _, completion in
                self?.presentMaggiShiursForMasechet(todaysMasechet, page: todaysPage)
                completion()
            }
            
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
            self?.presentMasechetSelection()
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
    
    // MARK: - Navigation Methods
    
    private func presentMasechetSelection() {
        let masechtot = HadafHayomiManager.sharedManager.masechtot
        let items = masechtot.map { masechet -> CPListItem in
            let item = CPListItem(text: masechet.name, detailText: "\(masechet.numberOfPages!) דפים")
            item.setImage(UIImage(systemName: "book"))
            item.handler = { [weak self] _, completion in
                self?.presentPageSelection(for: masechet)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "בחר מסכת", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func presentPageSelection(for masechet: Masechet) {
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
        // Get all maggid shiurs from the shared manager instead of from the masechet
        let allMaggidShiurs = HadafHayomiManager.sharedManager.maggidShiurs
        
        // Filter maggid shiurs that have lessons for this masechet
        let availableMaggidShiurs = allMaggidShiurs.filter { maggidShiur in
            return maggidShiur.maschtot.contains { $0.name == masechet.name }
        }
        
        let items = availableMaggidShiurs.map { maggidShiur -> CPListItem in
            let item = CPListItem(text: maggidShiur.name, detailText: maggidShiur.language)
            item.setImage(UIImage(systemName: "person"))
            item.handler = { [weak self] _, completion in
                let lesson = Lesson(maschet: masechet, page: page, andMaggidShiur: maggidShiur)
                self?.playLesson(lesson)
                completion()
            }
            return item
        }
        
        // Handle case where no maggid shiurs are found
        if items.isEmpty {
            let noItemsItem = CPListItem(text: "אין מגידי שיעור זמינים", detailText: "לא נמצאו שיעורים עבור דף זה")
            noItemsItem.setImage(UIImage(systemName: "exclamationmark.triangle"))
            let section = CPListSection(items: [noItemsItem])
            let template = CPListTemplate(title: "בחר מגיד שיעור", sections: [section])
            interfaceController?.pushTemplate(template, animated: true, completion: nil)
        } else {
            let section = CPListSection(items: items)
            let template = CPListTemplate(title: "בחר מגיד שיעור", sections: [section])
            interfaceController?.pushTemplate(template, animated: true, completion: nil)
        }
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
    
    // MARK: - Playback Methods
    
    private func playLesson(_ lesson: Lesson) {
        // Update the playing lesson in LessonsManager
        LessonsManager.sharedManager.playingLesson = lesson
        
        // Start playback using existing BTPlayerManager
        if let playerView = BTPlayerManager.sharedManager.sharedPlayerView {
            // Set the lesson info
            let title = "מסכת \(lesson.masechet.name!) דף \(lesson.page!.symbol!)"
            let subtitle = lesson.maggidShiur.name
            
            playerView.title = title
            playerView.subTitle = subtitle ?? ""
            
            // Set the URL and play
            if let url = lesson.getUrl() {
                playerView.setPlayerUrl(url, durration: lesson.durration ?? 0)
                playerView.play()
            }
        }
        
        // Present Now Playing template
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        interfaceController?.presentTemplate(nowPlayingTemplate, animated: true, completion: nil)
        
        // Store recent lesson
        storeRecentLesson(lesson)
        
        // Update now playing info
        updateNowPlayingInfo(for: lesson)
    }
    
    private func updateNowPlayingInfo(for lesson: Lesson) {
        let title = "\(lesson.masechet?.name ?? "") - \(lesson.page?.symbol ?? "")"
        let artist = lesson.maggidShiur?.name ?? ""
        
        var metadata: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyAlbumTitle: "דף היומי"
        ]
        
        if let artwork = createLessonArtwork(for: lesson) {
            metadata[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = metadata
    }
    
    private func createLessonArtwork(for lesson: Lesson) -> MPMediaItemArtwork? {
        let image = UIImage(systemName: "book.fill") ?? UIImage()
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
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
}

// MARK: - CPInterfaceController Delegate

@available(iOS 13.0, *)
extension CarPlaySceneDelegate: CPInterfaceControllerDelegate {
    
    func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template appearance if needed
    }
    
    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template did appear if needed
    }
    
    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template will disappear if needed
    }
    
    func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        // Handle template did disappear if needed
    }
}
