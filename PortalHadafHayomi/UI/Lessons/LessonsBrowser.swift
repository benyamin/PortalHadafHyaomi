//
//  LessonsBrowser.swift
//  PortalHadafHayomi
//
//  New lessons selection: masechet → daf (opens under the masechet) → maggidei shiur (pushed like a
//  navigation controller). Filters: sort (masechtot / all maggidei shiur / favorite maggidei shiur),
//  which lessons (all / saved / history) and media type.
//

import UIKit

// MARK: - Look

enum LessonsBrowserStyle {
    static let burgundy = UIColor(HexColor: "781F24")
    static let darkBurgundy = UIColor(HexColor: "5A1520")
    static let parchment = UIColor(HexColor: "F9F3DB")
    static let openBackground = UIColor(HexColor: "FFF6E0")
    static let sectionBackground = UIColor(HexColor: "F1E8CC")
    static let border = UIColor(HexColor: "DCCFAE")
    static let line = UIColor(HexColor: "E5DAB8")
    static let dafBackground = UIColor(HexColor: "F6EED6")
    static let gold = UIColor(HexColor: "B58B3A")
    static let goldLight = UIColor(HexColor: "F3DFA8")
    static let secondaryText = UIColor(HexColor: "6B5E4E")
    static let text = UIColor(HexColor: "1F1A17")
    static let savedBlue = UIColor(HexColor: "1E5BB8")

    static func nameFont(_ size:CGFloat) -> UIFont {
        return UIFont(name: "BroshMF", size: size + 1) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

/// Small rounded tag ("הדף היומי", "מתנגן")
final class LessonsTagLabel: UILabel {
    var insets = UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 9)
    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: insets)) }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
    static func make(_ text:String, gold:Bool) -> LessonsTagLabel {
        let tag = LessonsTagLabel()
        tag.text = text
        tag.font = UIFont.boldSystemFont(ofSize: 12)
        tag.textColor = gold ? .white : LessonsBrowserStyle.darkBurgundy
        tag.backgroundColor = gold ? LessonsBrowserStyle.gold : LessonsBrowserStyle.goldLight
        tag.layer.cornerRadius = 10
        tag.layer.masksToBounds = true
        tag.setContentHuggingPriority(.required, for: .horizontal)
        tag.setContentCompressionResistancePriority(.required, for: .horizontal)
        return tag
    }
}

// MARK: - What the lessons screen gives the browser

protocol LessonsBrowserDataSource: AnyObject {
    var browserSortOption:LessonsSortOption { get }
    var browserFilterOption:LessonsFilterOption { get }
    var browserMediaOption:LessonsMediaTypeOption { get }
    var browserShowsHistory:Bool { get }
    /// maggidei shiur for the "by maggid shiur" sort (already sorted / filtered)
    var browserMaggidShiurs:[MaggidShiur] { get }
    var browserCurrentLesson:Lesson? { get }
    var browserIsPlaying:Bool { get }

    func browserPlay(_ lesson:Lesson)
    func browserSave(_ lesson:Lesson)
    func browserDelete(_ lesson:Lesson)
    func browserIsSaving(_ lesson:Lesson) -> Bool
    func browserDownloadProgress(_ lesson:Lesson) -> Float
}

// MARK: - Data helpers

enum LessonsBrowserData {

    static func lesson(_ masechet:Masechet, page:Page, maggid:MaggidShiur) -> Lesson? {
        guard let base = LessonsManager.sharedManager.getLessonForMasechet(masechet, andMaggidShiour: maggid),
              let lesson = base.copy() as? Lesson else { return nil }
        lesson.page = page
        return lesson
    }

    static func mediaMatches(_ maggid:MaggidShiur, _ media:LessonsMediaTypeOption) -> Bool {
        switch media {
        case .All: return true
        case .Audio: return maggid.mediaType == .Audio
        case .Video: return maggid.mediaType == .Video
        }
    }

    static func masechtot(for maggid:MaggidShiur?, source:LessonsBrowserDataSource) -> [Masechet] {
        let all = maggid?.maschtot ?? HadafHayomiManager.sharedManager.masechtot
        guard source.browserFilterOption == .Saved else { return all }
        return all.filter { $0.hasSavedLessonForMaggidShiour(maggid, andPage: nil) }
    }

    static func pages(_ masechet:Masechet, maggid:MaggidShiur?, source:LessonsBrowserDataSource) -> [Page] {
        guard source.browserFilterOption == .Saved else { return masechet.pages }
        return masechet.pages.filter { $0.hasSavedLessonForMasechet(masechet, andMagidShior: maggid) }
    }

    static func maggidim(_ masechet:Masechet, page:Page, only maggid:MaggidShiur?, source:LessonsBrowserDataSource) -> [MaggidShiur] {
        let all = maggid.map { [$0] } ?? masechet.maggidShiurs
        return all.filter { m in
            guard mediaMatches(m, source.browserMediaOption) else { return false }
            if source.browserFilterOption == .Saved {
                guard let lesson = lesson(masechet, page: page, maggid: m) else { return false }
                return LessonsManager.sharedManager.isSavedLesson(lesson)
            }
            return true
        }
    }

    static func isToday(_ masechet:Masechet, page:Page? = nil) -> Bool {
        guard let todaysMasechet = HadafHayomiManager.sharedManager.todaysMaschet else { return false }
        let sameMasechet = todaysMasechet === masechet || (todaysMasechet.id != nil && todaysMasechet.id == masechet.id)
        guard sameMasechet else { return false }
        guard let page = page else { return true }
        return HadafHayomiManager.sharedManager.todaysPage?.index == page.index
    }

    static func isCurrent(_ masechet:Masechet, page:Page? = nil, source:LessonsBrowserDataSource) -> Bool {
        guard let current = source.browserCurrentLesson, current.masechet != nil else { return false }
        guard current.masechet === masechet || current.masechet.id == masechet.id else { return false }
        guard let page = page else { return true }
        return current.page?.index == page.index
    }
}

// MARK: - The browser (a navigation controller under the filters)

final class LessonsBrowser: NSObject, UIGestureRecognizerDelegate
{
    weak var source:LessonsBrowserDataSource?
    let navigationController:UINavigationController

    init(source:LessonsBrowserDataSource) {
        self.source = source
        self.navigationController = UINavigationController()
        super.init()
        navigationController.setNavigationBarHidden(true, animated: false)
        // Hebrew: screens come in from the left, swipe back from the right
        navigationController.view.semanticContentAttribute = .forceRightToLeft
        navigationController.navigationBar.semanticContentAttribute = .forceRightToLeft
        navigationController.view.backgroundColor = LessonsBrowserStyle.parchment
        navigationController.interactivePopGestureRecognizer?.delegate = self
        self.rebuildRoot()
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController.viewControllers.count > 1
    }

    private var rootKey:String?

    /// Filters changed: new first screen (keeps it when nothing relevant changed)
    func rebuildRoot(force:Bool = false)
    {
        guard let source = source else { return }
        let key = "\(source.browserSortOption)-\(source.browserFilterOption)-\(source.browserMediaOption)-\(source.browserShowsHistory)"
        if !force, key == rootKey, !navigationController.viewControllers.isEmpty {
            self.reloadVisible()
            return
        }
        rootKey = key

        let root:UIViewController
        if source.browserShowsHistory {
            root = LessonsHistoryViewController(browser: self)
        } else if source.browserSortOption == .Maschtot {
            root = LessonsDafListViewController(browser: self, maggid: nil)
        } else {
            root = LessonsMaggidListViewController(browser: self)
        }
        navigationController.setViewControllers([root], animated: false)
    }

    /// Refresh what is on screen (download progress, playing mark, saved marks)
    func reloadVisible()
    {
        for vc in navigationController.viewControllers {
            (vc as? LessonsBrowserScreen)?.reloadScreen()
        }
    }

    // MARK: Navigation

    func showMaggidim(masechet:Masechet, page:Page, only maggid:MaggidShiur?, animated:Bool = true)
    {
        let vc = LessonsMaggidimViewController(browser: self, masechet: masechet, page: page, maggid: maggid)
        navigationController.pushViewController(vc, animated: animated)
    }

    func showDafim(of maggid:MaggidShiur)
    {
        let vc = LessonsDafListViewController(browser: self, maggid: maggid)
        navigationController.pushViewController(vc, animated: true)
    }

    /// Open the masechet of a lesson in the first screen (e.g. the playing lesson)
    func reveal(masechet:Masechet, page:Page?)
    {
        guard let root = navigationController.viewControllers.first as? LessonsDafListViewController else { return }
        root.open(masechet: masechet, page: page)
    }

    /// "לדף היומי": open today's masechet and show today's maggidei shiur
    func showTodaysPage()
    {
        guard let masechet = HadafHayomiManager.sharedManager.todaysMaschet,
              let page = HadafHayomiManager.sharedManager.todaysPage else { return }
        if source?.browserSortOption != .Maschtot || source?.browserShowsHistory == true { return }
        navigationController.popToRootViewController(animated: false)
        self.reveal(masechet: masechet, page: page)
        self.showMaggidim(masechet: masechet, page: page, only: nil)
    }
}

protocol LessonsBrowserScreen: AnyObject {
    func reloadScreen()
}

// MARK: - Header with a back button (pushed screens)

final class LessonsBackHeader: UIView
{
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    var onBack:(() -> Void)?

    init(title:String, subtitle:String?) {
        super.init(frame: .zero)
        backgroundColor = LessonsBrowserStyle.openBackground
        semanticContentAttribute = .forceRightToLeft

        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        back.tintColor = LessonsBrowserStyle.burgundy
        back.backgroundColor = .white
        back.layer.borderWidth = 1
        back.layer.borderColor = LessonsBrowserStyle.border.cgColor
        back.layer.cornerRadius = 3
        back.accessibilityLabel = "חזרה"
        back.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = LessonsBrowserStyle.nameFont(20)
        titleLabel.textColor = LessonsBrowserStyle.burgundy
        titleLabel.textAlignment = .right
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = LessonsBrowserStyle.secondaryText
        subtitleLabel.textAlignment = .right
        let texts = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        texts.axis = .vertical
        texts.alignment = .trailing
        texts.translatesAutoresizingMaskIntoConstraints = false

        let line = UIView()
        line.backgroundColor = LessonsBrowserStyle.line
        line.translatesAutoresizingMaskIntoConstraints = false

        addSubview(back)
        addSubview(texts)
        addSubview(line)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 54),
            back.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            back.centerYAnchor.constraint(equalTo: centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 34),
            back.heightAnchor.constraint(equalToConstant: 34),
            texts.rightAnchor.constraint(equalTo: back.leftAnchor, constant: -10),
            texts.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10),
            texts.centerYAnchor.constraint(equalTo: centerYAnchor),
            line.leftAnchor.constraint(equalTo: leftAnchor),
            line.rightAnchor.constraint(equalTo: rightAnchor),
            line.bottomAnchor.constraint(equalTo: bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func backTapped() { onBack?() }
}

// MARK: - Screen 1: masechtot; a masechet opens its dafim under it

final class LessonsDafListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LessonsBrowserScreen
{
    weak var browser:LessonsBrowser?
    /// nil = all masechtot (sort by masechet); set = the masechtot of one maggid shiur
    let maggid:MaggidShiur?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var masechtot = [Masechet]()
    private var openIndex:Int?
    private var openPages = [Page]()
    static let columns = 4

    init(browser:LessonsBrowser, maggid:MaggidShiur?) {
        self.browser = browser
        self.maggid = maggid
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LessonsBrowserStyle.parchment
        view.semanticContentAttribute = .forceRightToLeft

        var topAnchor = view.topAnchor
        if let maggid = maggid {
            let header = LessonsBackHeader(title: maggid.name ?? "", subtitle: "בחר מסכת ודף")
            header.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
            header.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(header)
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: view.topAnchor),
                header.leftAnchor.constraint(equalTo: view.leftAnchor),
                header.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
            topAnchor = header.bottomAnchor
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 48
        tableView.estimatedRowHeight = 48
        tableView.sectionHeaderHeight = 50
        tableView.estimatedSectionHeaderHeight = 50
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 0 }
        tableView.semanticContentAttribute = .forceRightToLeft
        tableView.register(LessonsDafRowCell.self, forCellReuseIdentifier: LessonsDafRowCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        reloadScreen()
    }

    func reloadScreen()
    {
        guard let source = browser?.source else { return }
        let openMasechet = openIndex.flatMap { $0 < masechtot.count ? masechtot[$0] : nil }
        masechtot = LessonsBrowserData.masechtot(for: maggid, source: source)
        if let openMasechet = openMasechet, let index = masechtot.firstIndex(where: { $0 === openMasechet || $0.id == openMasechet.id }) {
            openIndex = index
            openPages = LessonsBrowserData.pages(masechtot[index], maggid: maggid, source: source)
        } else {
            openIndex = nil
            openPages = []
        }
        if isViewLoaded { tableView.reloadData() }
    }

    /// Open a masechet (closed list otherwise) and scroll it into view
    func open(masechet:Masechet, page:Page?)
    {
        loadViewIfNeeded()
        guard let source = browser?.source,
              let index = masechtot.firstIndex(where: { $0 === masechet || $0.id == masechet.id }) else { return }
        openIndex = index
        openPages = LessonsBrowserData.pages(masechtot[index], maggid: maggid, source: source)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        var row = 0
        if let page = page, let position = openPages.firstIndex(where: { $0.index == page.index }) {
            row = position / LessonsDafListViewController.columns
        }
        if row < tableView.numberOfRows(inSection: index) {
            tableView.scrollToRow(at: IndexPath(row: row, section: index), at: .middle, animated: false)
        } else if index < tableView.numberOfSections {
            tableView.scrollRectToVisible(tableView.rectForHeader(inSection: index), animated: false)
        }
    }

    // MARK: Table

    func numberOfSections(in tableView: UITableView) -> Int { return masechtot.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == openIndex else { return 0 }
        return (openPages.count + LessonsDafListViewController.columns - 1) / LessonsDafListViewController.columns
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let masechet = masechtot[section]
        let isOpen = section == openIndex

        let header = UIControl()
        header.tag = section
        header.backgroundColor = isOpen ? LessonsBrowserStyle.openBackground : .white
        header.semanticContentAttribute = .forceRightToLeft
        header.accessibilityLabel = masechet.name
        header.accessibilityTraits = .button
        header.addTarget(self, action: #selector(headerTapped(_:)), for: .touchUpInside)

        let name = UILabel()
        name.text = masechet.name
        name.font = LessonsBrowserStyle.nameFont(19)
        name.textColor = LessonsBrowserStyle.burgundy

        let range = UILabel()
        if let first = masechet.pages.first?.symbol, let last = masechet.pages.last?.symbol {
            range.text = "\(first) – \(last)"
        }
        range.font = UIFont.systemFont(ofSize: 13)
        range.textColor = LessonsBrowserStyle.secondaryText

        let arrow = UIImageView(image: UIImage(systemName: isOpen ? "chevron.up" : "chevron.down"))
        arrow.tintColor = LessonsBrowserStyle.burgundy
        arrow.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [name])
        if LessonsBrowserData.isToday(masechet), let page = HadafHayomiManager.sharedManager.todaysPage {
            stack.addArrangedSubview(LessonsTagLabel.make("הדף היומי: \(page.symbol ?? "")", gold: true))
        }
        if let source = browser?.source, LessonsBrowserData.isCurrent(masechet, source: source),
           let current = source.browserCurrentLesson {
            stack.addArrangedSubview(LessonsTagLabel.make((source.browserIsPlaying ? "מתנגן: " : "נבחר: ") + (current.page?.symbol ?? ""), gold: false))
        }
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(range)
        stack.addArrangedSubview(arrow)
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.semanticContentAttribute = .forceRightToLeft
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(stack)

        let line = UIView()
        line.backgroundColor = LessonsBrowserStyle.line
        line.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(line)
        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 14),
            stack.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -14),
            stack.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 16),
            line.leftAnchor.constraint(equalTo: header.leftAnchor),
            line.rightAnchor.constraint(equalTo: header.rightAnchor),
            line.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LessonsDafRowCell.reuseId, for: indexPath) as! LessonsDafRowCell
        let masechet = masechtot[indexPath.section]
        let first = indexPath.row * LessonsDafListViewController.columns
        let pages = Array(openPages[first ..< min(first + LessonsDafListViewController.columns, openPages.count)])
        let source = browser?.source
        cell.configure(pages: pages, columns: LessonsDafListViewController.columns,
                       isToday: { LessonsBrowserData.isToday(masechet, page: $0) },
                       isCurrent: { page in source.map { LessonsBrowserData.isCurrent(masechet, page: page, source: $0) } ?? false },
                       onSelect: { [weak self] page in
                            guard let self = self else { return }
                            self.browser?.showMaggidim(masechet: masechet, page: page, only: self.maggid)
                       })
        return cell
    }

    @objc private func headerTapped(_ sender:UIControl)
    {
        guard let source = browser?.source else { return }
        let section = sender.tag
        guard section < tableView.numberOfSections else { return }
        let headerScreenY = tableView.rectForHeader(inSection: section).minY - tableView.contentOffset.y

        if openIndex == section {
            openIndex = nil
            openPages = []
        } else {
            openIndex = section
            openPages = LessonsBrowserData.pages(masechtot[section], maggid: maggid, source: source)
        }
        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
            // keep the tapped masechet in the same place on screen
            let inset = tableView.adjustedContentInset
            let minOffset = -inset.top
            let maxOffset = max(minOffset, tableView.contentSize.height + inset.bottom - tableView.bounds.height)
            let wanted = tableView.rectForHeader(inSection: section).minY - headerScreenY
            tableView.setContentOffset(CGPoint(x: 0, y: min(maxOffset, max(minOffset, wanted))), animated: false)
        }
    }
}

/// One row of daf buttons (4 per row)
final class LessonsDafRowCell: UITableViewCell
{
    static let reuseId = "LessonsDafRowCell"
    private let rowStack = UIStackView()
    private var pages = [Page]()
    private var onSelect:((Page) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = LessonsBrowserStyle.openBackground
        contentView.semanticContentAttribute = .forceRightToLeft
        rowStack.axis = .horizontal
        rowStack.spacing = 6
        rowStack.distribution = .fillEqually
        rowStack.semanticContentAttribute = .forceRightToLeft
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            rowStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            rowStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(pages:[Page], columns:Int, isToday:(Page) -> Bool, isCurrent:(Page) -> Bool, onSelect:@escaping (Page) -> Void)
    {
        self.pages = pages
        self.onSelect = onSelect
        rowStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, page) in pages.enumerated() {
            let today = isToday(page)
            let current = isCurrent(page)
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(page.symbol, for: .normal)
            button.titleLabel?.font = LessonsBrowserStyle.nameFont(17)
            button.setTitleColor(today ? .white : LessonsBrowserStyle.text, for: .normal)
            button.backgroundColor = today ? LessonsBrowserStyle.burgundy : LessonsBrowserStyle.dafBackground
            button.layer.cornerRadius = 7
            button.layer.borderWidth = (today || current) ? 2 : 1
            button.layer.borderColor = (current ? LessonsBrowserStyle.gold : (today ? LessonsBrowserStyle.gold : LessonsBrowserStyle.border)).cgColor
            button.accessibilityLabel = "דף \(page.symbol ?? "")" + (today ? ", הדף היומי" : "") + (current ? ", השיעור הנבחר" : "")
            button.addTarget(self, action: #selector(dafTapped(_:)), for: .touchUpInside)
            rowStack.addArrangedSubview(button)
        }
        // keep the cards the same width in the last row
        for _ in pages.count ..< columns {
            rowStack.addArrangedSubview(UIView())
        }
    }

    @objc private func dafTapped(_ sender:UIButton) {
        guard sender.tag < pages.count else { return }
        onSelect?(pages[sender.tag])
    }
}

// MARK: - Screen 2: maggidei shiur of one daf (pushed)

final class LessonsMaggidimViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LessonsBrowserScreen
{
    weak var browser:LessonsBrowser?
    let masechet:Masechet
    let page:Page
    let onlyMaggid:MaggidShiur?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var header:LessonsBackHeader!
    private var favorites = [MaggidShiur]()
    private var others = [MaggidShiur]()

    init(browser:LessonsBrowser, masechet:Masechet, page:Page, maggid:MaggidShiur?) {
        self.browser = browser
        self.masechet = masechet
        self.page = page
        self.onlyMaggid = maggid
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LessonsBrowserStyle.parchment
        view.semanticContentAttribute = .forceRightToLeft

        header = LessonsBackHeader(title: "\(masechet.name ?? "") \(page.symbol ?? "")", subtitle: nil)
        header.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 62
        tableView.estimatedRowHeight = 62
        tableView.sectionHeaderHeight = 26
        tableView.estimatedSectionHeaderHeight = 26
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 0 }
        tableView.register(LessonsMaggidCell.self, forCellReuseIdentifier: LessonsMaggidCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        reloadScreen()
    }

    func reloadScreen()
    {
        guard let source = browser?.source else { return }
        let all = LessonsBrowserData.maggidim(masechet, page: page, only: onlyMaggid, source: source)
        favorites = all.filter { $0.isFavorite }
        others = all.filter { !$0.isFavorite }
        var subtitle = "\(all.count) שיעורים"
        if LessonsBrowserData.isToday(masechet, page: page) { subtitle += " · הדף היומי" }
        header?.subtitleLabel.text = all.isEmpty ? "לא נמצאו שיעורים לדף" : subtitle
        if isViewLoaded { tableView.reloadData() }
    }

    private func maggids(in section:Int) -> [MaggidShiur] {
        if favorites.isEmpty { return others }
        return section == 0 ? favorites : others
    }

    func numberOfSections(in tableView: UITableView) -> Int { return favorites.isEmpty ? 1 : 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return maggids(in: section).count }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let isFavorites = !favorites.isEmpty && section == 0
        label.text = "   " + (isFavorites ? "המועדפים שלי" : "כל מגידי השיעור")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = LessonsBrowserStyle.secondaryText
        label.backgroundColor = LessonsBrowserStyle.sectionBackground
        label.textAlignment = .right
        return label
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LessonsMaggidCell.reuseId, for: indexPath) as! LessonsMaggidCell
        let maggid = maggids(in: indexPath.section)[indexPath.row]
        guard let source = browser?.source, let lesson = LessonsBrowserData.lesson(masechet, page: page, maggid: maggid) else {
            cell.configure(title: maggid.name ?? "", subtitle: "", lesson: nil, maggid: maggid, source: nil)
            return cell
        }
        cell.configure(title: maggid.name ?? "", subtitle: LessonsMaggidCell.meta(for: maggid), lesson: lesson, maggid: maggid, source: source)
        cell.onFavoriteChanged = { [weak self] in self?.reloadScreen() }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let maggid = maggids(in: indexPath.section)[indexPath.row]
        if let lesson = LessonsBrowserData.lesson(masechet, page: page, maggid: maggid) {
            browser?.source?.browserPlay(lesson)
        }
    }
}

/// One maggid shiur row: name, details, ★, download / delete, play
final class LessonsMaggidCell: UITableViewCell
{
    static let reuseId = "LessonsMaggidCell"

    private let avatar = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let playingTag = LessonsTagLabel.make("מתנגן", gold: false)
    private let starButton = UIButton(type: .system)
    private let downloadButton = UIButton(type: .system)
    private let progressLabel = UILabel()
    private let playButton = UIButton(type: .system)

    private var lesson:Lesson?
    private var maggid:MaggidShiur?
    private weak var source:LessonsBrowserDataSource?
    var onFavoriteChanged:(() -> Void)?

    static func meta(for maggid:MaggidShiur) -> String {
        var parts = [String]()
        if let language = maggid.language, !language.isEmpty { parts.append(language) }
        switch maggid.mediaType {
        case .Audio: parts.append("שמע")
        case .Video: parts.append("וידאו")
        case .All: break
        }
        return parts.joined(separator: " · ")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.semanticContentAttribute = .forceRightToLeft

        avatar.font = UIFont.boldSystemFont(ofSize: 13)
        avatar.textColor = LessonsBrowserStyle.darkBurgundy
        avatar.textAlignment = .center
        avatar.layer.cornerRadius = 19
        avatar.layer.masksToBounds = true

        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = LessonsBrowserStyle.text
        titleLabel.textAlignment = .right
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = LessonsBrowserStyle.secondaryText
        subtitleLabel.textAlignment = .right
        let texts = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        texts.axis = .vertical
        // both lines fill the width and are right-aligned (the same right edge)
        texts.alignment = .fill
        texts.spacing = 1

        starButton.tintColor = LessonsBrowserStyle.gold
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        progressLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        progressLabel.textColor = LessonsBrowserStyle.savedBlue
        progressLabel.textAlignment = .center

        playButton.layer.cornerRadius = 18
        playButton.layer.borderWidth = 1.5
        playButton.layer.borderColor = LessonsBrowserStyle.burgundy.cgColor
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        // no initials circle: the name starts at the right edge
        let row = UIStackView(arrangedSubviews: [texts, UIView(), playingTag, starButton, downloadButton, progressLabel, playButton])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        row.semanticContentAttribute = .forceRightToLeft
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        let line = UIView()
        line.backgroundColor = LessonsBrowserStyle.line
        line.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(line)

        NSLayoutConstraint.activate([
            row.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
            row.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            row.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            starButton.widthAnchor.constraint(equalToConstant: 28),
            downloadButton.widthAnchor.constraint(equalToConstant: 28),
            progressLabel.widthAnchor.constraint(equalToConstant: 34),
            playButton.widthAnchor.constraint(equalToConstant: 36),
            playButton.heightAnchor.constraint(equalToConstant: 36),
            line.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            line.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            line.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title:String, subtitle:String, lesson:Lesson?, maggid:MaggidShiur?, source:LessonsBrowserDataSource?)
    {
        self.lesson = lesson
        self.maggid = maggid
        self.source = source
        titleLabel.text = title
        subtitleLabel.text = subtitle

        let words = title.replacingOccurrences(of: "הרב ", with: "").split(separator: " ")
        avatar.text = words.prefix(2).compactMap { $0.first.map(String.init) }.joined()
        let isFavorite = maggid?.isFavorite ?? false
        avatar.backgroundColor = isFavorite ? LessonsBrowserStyle.goldLight : UIColor(HexColor: "E8DDC0")

        starButton.isHidden = maggid == nil
        starButton.setImage(UIImage(systemName: isFavorite ? "star.fill" : "star"), for: .normal)
        starButton.accessibilityLabel = isFavorite ? "הסר מהמועדפים" : "הוסף למועדפים"

        guard let lesson = lesson, let source = source else {
            playButton.isHidden = true
            downloadButton.isHidden = true
            progressLabel.isHidden = true
            playingTag.isHidden = true
            return
        }
        playButton.isHidden = false

        let isCurrent = source.browserCurrentLesson?.identifier == lesson.identifier
        let isPlaying = isCurrent && source.browserIsPlaying
        playingTag.isHidden = !isCurrent
        playingTag.text = isPlaying ? "מתנגן" : "נבחר"
        backgroundColor = isCurrent ? LessonsBrowserStyle.openBackground : .white

        playButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
        playButton.tintColor = isPlaying ? .white : LessonsBrowserStyle.burgundy
        playButton.backgroundColor = isPlaying ? LessonsBrowserStyle.burgundy : .white
        playButton.accessibilityLabel = (isPlaying ? "השהה את השיעור של " : "נגן את השיעור של ") + title

        if source.browserIsSaving(lesson) {
            downloadButton.isHidden = true
            progressLabel.isHidden = false
            progressLabel.text = "\(Int(source.browserDownloadProgress(lesson) * 100))%"
        } else {
            progressLabel.isHidden = true
            downloadButton.isHidden = false
            let saved = LessonsManager.sharedManager.isSavedLesson(lesson)
            downloadButton.setImage(UIImage(systemName: saved ? "trash" : "arrow.down.to.line"), for: .normal)
            downloadButton.tintColor = saved ? UIColor(HexColor: "8C2A2A") : LessonsBrowserStyle.secondaryText
            downloadButton.accessibilityLabel = saved ? "מחק את השיעור השמור" : "הורד את השיעור"
        }
    }

    @objc private func starTapped() {
        guard let maggid = maggid else { return }
        maggid.isFavorite = !maggid.isFavorite
        onFavoriteChanged?()
    }

    @objc private func downloadTapped() {
        guard let lesson = lesson, let source = source else { return }
        if LessonsManager.sharedManager.isSavedLesson(lesson) {
            source.browserDelete(lesson)
        } else {
            source.browserSave(lesson)
        }
    }

    @objc private func playTapped() {
        guard let lesson = lesson else { return }
        source?.browserPlay(lesson)
    }
}

// MARK: - Sort by maggid shiur: list of maggidei shiur → his masechtot / dafim

final class LessonsMaggidListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LessonsBrowserScreen
{
    weak var browser:LessonsBrowser?
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var maggidim = [MaggidShiur]()
    private let emptyLabel = UILabel()

    init(browser:LessonsBrowser) {
        self.browser = browser
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LessonsBrowserStyle.parchment
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
        tableView.register(LessonsMaggidCell.self, forCellReuseIdentifier: LessonsMaggidCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.text = "st_add_Favorite_maggid_shiour_message".localize()
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = LessonsBrowserStyle.secondaryText
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            emptyLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24)
        ])
        reloadScreen()
    }

    func reloadScreen() {
        maggidim = browser?.source?.browserMaggidShiurs ?? []
        emptyLabel.isHidden = !maggidim.isEmpty
        if isViewLoaded { tableView.reloadData() }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return maggidim.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LessonsMaggidCell.reuseId, for: indexPath) as! LessonsMaggidCell
        let maggid = maggidim[indexPath.row]
        cell.configure(title: maggid.name ?? "", subtitle: LessonsMaggidCell.meta(for: maggid), lesson: nil, maggid: maggid, source: nil)
        cell.onFavoriteChanged = { [weak self] in self?.reloadScreen() }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        browser?.showDafim(of: maggidim[indexPath.row])
    }
}

// MARK: - History: lessons played lately

final class LessonsHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LessonsBrowserScreen
{
    weak var browser:LessonsBrowser?
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var lessons = [Lesson]()

    init(browser:LessonsBrowser) {
        self.browser = browser
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LessonsBrowserStyle.parchment
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 62
        tableView.register(LessonsMaggidCell.self, forCellReuseIdentifier: LessonsMaggidCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        reloadScreen()
    }

    func reloadScreen() {
        lessons = LessonsManager.sharedManager.getLastPlayedLessons()
        if isViewLoaded { tableView.reloadData() }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return lessons.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LessonsMaggidCell.reuseId, for: indexPath) as! LessonsMaggidCell
        let lesson = lessons[indexPath.row]
        let title = "\(lesson.masechet?.name ?? "") \(lesson.page?.symbol ?? "")"
        cell.configure(title: title, subtitle: lesson.maggidShiur?.name ?? "", lesson: lesson, maggid: nil, source: browser?.source)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        browser?.source?.browserPlay(lessons[indexPath.row])
    }
}
