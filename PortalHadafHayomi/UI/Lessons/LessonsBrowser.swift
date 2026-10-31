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
    /// the three-column picker (sort by masechet / maggid shiur); the navigation list is used for history
    weak var columnsView:LessonsColumnsPickerView?

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
        columnsView?.refreshState()
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


// MARK: - Three-column lesson picker (like the original picker, as lists)
//
//  Sort by masechet:      [ masechtot ] [ dafim ] [ maggidei shiur ]   (right → left)
//  Sort by maggid shiur:  [ maggidei shiur ] [ masechtot ] [ dafim ]
//  Tap the last column to play (tap the playing lesson again to pause).
//  Long-press a lesson: download / delete, add to / remove from favorites.

final class LessonsColumnsPickerView: UIView, UITableViewDataSource, UITableViewDelegate
{
    weak var source:LessonsBrowserDataSource?

    private let columns:[UITableView] = [UITableView(), UITableView(), UITableView()]
    private var widthConstraints = [NSLayoutConstraint]()
    private let emptyLabel = UILabel()

    // data
    private var masechtot = [Masechet]()
    private var pages = [Page]()
    private var maggidim = [MaggidShiur]()

    // selection
    private var selectedMasechet:Masechet?
    private var selectedPage:Page?
    private var selectedMaggid:MaggidShiur?

    // durations of the lessons of the selected daf (lesson path -> "43:11")
    private var durations = [String:String]()
    private var durationsProcesses = [String:GetLessonsInfoProcess]()
    private var durationsRequested = Set<String>()

    /// FIX: the sort the columns were BUILT with. Reading the sort live made the tables ask for the
    /// new sort's rows before they were rebuilt -> "Invalid update: invalid number of rows" crash.
    private var displayedByMaggid = false
    private var isByMaggid:Bool { return displayedByMaggid }

    static let selectedBackground = LessonsBrowserStyle.burgundy   // as the chosen half of the sort switch
    static let divider = UIColor(HexColor: "8C2A2A")

    init(source:LessonsBrowserDataSource) {
        self.source = source
        super.init(frame: .zero)
        backgroundColor = LessonsBrowserStyle.parchment
        semanticContentAttribute = .forceRightToLeft

        for (index, table) in columns.enumerated() {
            table.tag = index
            table.dataSource = self
            table.delegate = self
            table.backgroundColor = .clear
            table.separatorStyle = .none
            table.showsVerticalScrollIndicator = false
            table.estimatedRowHeight = 0
            table.estimatedSectionHeaderHeight = 0
            table.estimatedSectionFooterHeight = 0
            if #available(iOS 15.0, *) { table.sectionHeaderTopPadding = 0 }
            table.register(LessonsColumnCell.self, forCellReuseIdentifier: LessonsColumnCell.reuseId)
            table.translatesAutoresizingMaskIntoConstraints = false
            addSubview(table)
        }
        // right → left: column 0 is on the right
        let c0 = columns[0], c1 = columns[1], c2 = columns[2]
        widthConstraints = [
            c0.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.27),
            c1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15)
        ]
        NSLayoutConstraint.activate(widthConstraints + [
            c0.rightAnchor.constraint(equalTo: rightAnchor),
            c1.rightAnchor.constraint(equalTo: c0.leftAnchor, constant: -4),
            c2.rightAnchor.constraint(equalTo: c1.leftAnchor, constant: -4),
            c2.leftAnchor.constraint(equalTo: leftAnchor)
        ] + columns.flatMap { [ $0.topAnchor.constraint(equalTo: topAnchor), $0.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2) ] })

        // the double lines between the columns and the line at the bottom
        for leftOf in [c0, c1] {
            for offset in [CGFloat(-1), CGFloat(-3)] {
                let line = UIView()
                line.backgroundColor = LessonsColumnsPickerView.divider
                line.translatesAutoresizingMaskIntoConstraints = false
                addSubview(line)
                NSLayoutConstraint.activate([
                    line.widthAnchor.constraint(equalToConstant: 1),
                    line.rightAnchor.constraint(equalTo: leftOf.leftAnchor, constant: offset + 1),
                    line.topAnchor.constraint(equalTo: topAnchor),
                    line.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            }
        }
        let bottomLine = UIView()
        bottomLine.backgroundColor = LessonsColumnsPickerView.divider
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLine)
        NSLayoutConstraint.activate([
            bottomLine.leftAnchor.constraint(equalTo: leftAnchor),
            bottomLine.rightAnchor.constraint(equalTo: rightAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 2)
        ])

        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = LessonsBrowserStyle.secondaryText
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 24),
            emptyLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Data

    /// Filters / sort changed (or data arrived): rebuild all columns, keep the selection when possible
    func reloadAll()
    {
        guard let source = source else { return }

        displayedByMaggid = (source.browserSortOption != .Maschtot)
        
        // column widths for the sort
        widthConstraints.forEach { $0.isActive = false }
        let c0 = columns[0], c1 = columns[1]
        widthConstraints = isByMaggid
            ? [c0.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.50), c1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.26)]
            : [c0.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.27), c1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15)]
        NSLayoutConstraint.activate(widthConstraints)

        if isByMaggid {
            maggidim = source.browserMaggidShiurs
            selectedMaggid = maggidim.first(where: { $0.id == selectedMaggid?.id }) ?? maggidim.first
            masechtot = selectedMaggid.map { LessonsBrowserData.masechtot(for: $0, source: source) } ?? []
        } else {
            masechtot = LessonsBrowserData.masechtot(for: nil, source: source)
        }
        selectedMasechet = masechtot.first(where: { $0.id == selectedMasechet?.id }) ?? masechtot.first
        reloadPages()

        let empty = (isByMaggid ? maggidim.isEmpty : masechtot.isEmpty)
        emptyLabel.isHidden = !empty
        emptyLabel.text = source.browserFilterOption == .Saved ? "st_saved_lessons_not_found".localize()
            : (source.browserSortOption == .FavoirteMagidiShiour ? "st_add_Favorite_maggid_shiour_message".localize() : "")
        columns.forEach { $0.isHidden = empty }

        columns.forEach { $0.reloadData() }
        scrollSelectionIntoView()
    }

    private func reloadPages()
    {
        guard let source = source else { return }
        if let masechet = selectedMasechet {
            pages = LessonsBrowserData.pages(masechet, maggid: isByMaggid ? selectedMaggid : nil, source: source)
        } else {
            pages = []
        }
        selectedPage = pages.first(where: { $0.index == selectedPage?.index }) ?? pages.first
        reloadMaggidim()
    }

    private func reloadMaggidim()
    {
        guard let source = source, !isByMaggid else { return }
        if let masechet = selectedMasechet, let page = selectedPage {
            let all = LessonsBrowserData.maggidim(masechet, page: page, only: nil, source: source)
            maggidim = all.filter { $0.isFavorite } + all.filter { !$0.isFavorite }
            loadDurations(masechet: masechet, page: page)
        } else {
            maggidim = []
        }
    }

    /// Durations of all the lessons of a daf (all maggidei shiur) – one request per daf, kept in a cache
    private func loadDurations(masechet:Masechet, page:Page?)
    {
        guard let page = page else { return }
        let key = "\(masechet.id ?? "")-\(page.index ?? -1)"
        if durationsRequested.contains(key) { return }
        durationsRequested.insert(key)

        let lesson = Lesson()
        lesson.masechet = masechet
        lesson.page = page
        let process = GetLessonsInfoProcess()
        durationsProcesses[key] = process
        process.executeWithObject(lesson, onStart: { }, onComplete: { [weak self] object in
            guard let self = self else { return }
            self.durationsProcesses[key] = nil
            guard let mediaLessons = object as? [MediaLesson] else { return }
            for mediaLesson in mediaLessons {
                if let path = mediaLesson.path, let display = mediaLesson.durationDisplay { self.durations[path] = display }
            }
            self.columns[2].reloadData()
        }, onFaile: { [weak self] _, _ in
            // try again the next time the daf is shown
            self?.durationsProcesses[key] = nil
            self?.durationsRequested.remove(key)
        })
    }

    /// Lessons data arrived after the picker was built: fill the empty columns
    func reloadIfNeeded()
    {
        guard let source = source else { return }
        let missing:Bool
        if isByMaggid {
            missing = maggidim.isEmpty && !source.browserMaggidShiurs.isEmpty
        } else {
            missing = masechtot.isEmpty
                || (maggidim.isEmpty && selectedPage != nil && source.browserFilterOption == .All
                    && !(selectedMasechet?.maggidShiurs.isEmpty ?? true))
        }
        if missing { reloadAll() }
    }
    
    /// Selected / playing marks changed (play, pause, download progress)
    func refreshState()
    {
        columns.forEach { table in
            // FIX: if the rows changed since the last reload, reload everything (reloading only the
            // visible rows of a table whose row count changed crashes)
            if table.numberOfRows(inSection: 0) != self.tableView(table, numberOfRowsInSection: 0) {
                table.reloadData()
                return
            }
            guard let visible = table.indexPathsForVisibleRows, !visible.isEmpty else { return }
            table.reloadRows(at: visible, with: .none)
        }
    }

    /// "לדף היומי": select today's masechet and daf (in maggid sort: in the chosen maggid shiur's list)
    func selectToday()
    {
        guard let todaysMasechet = HadafHayomiManager.sharedManager.todaysMaschet,
              let todaysPage = HadafHayomiManager.sharedManager.todaysPage else { return }
        guard let masechet = masechtot.first(where: { $0.id == todaysMasechet.id }) else {
            // not in the list (filters / this maggid shiur): nothing to move to
            return
        }
        selectedMasechet = masechet
        selectedPage = todaysPage
        reloadPages()
        columns.forEach { $0.reloadData() }
        scrollSelectionIntoView()
    }
    
    /// Start on the playing / selected lesson, otherwise today's daf
    func selectInitial()
    {
        guard let source = source else { return }
        displayedByMaggid = (source.browserSortOption != .Maschtot)
        if let lesson = source.browserCurrentLesson, lesson.masechet != nil {
            if isByMaggid { selectedMaggid = lesson.maggidShiur }
            selectedMasechet = lesson.masechet
            selectedPage = lesson.page
        } else if let masechet = HadafHayomiManager.sharedManager.todaysMaschet {
            selectedMasechet = masechet
            selectedPage = HadafHayomiManager.sharedManager.todaysPage
        }
        reloadAll()
    }

    /// skip: the column the user just tapped – it stays where it is
    private func scrollSelectionIntoView(skip:Int? = nil)
    {
        layoutIfNeeded()
        let rows:[Int?] = isByMaggid
            ? [maggidim.firstIndex(where: { $0.id == selectedMaggid?.id }),
               masechtot.firstIndex(where: { $0.id == selectedMasechet?.id }),
               pages.firstIndex(where: { $0.index == selectedPage?.index })]
            : [masechtot.firstIndex(where: { $0.id == selectedMasechet?.id }),
               pages.firstIndex(where: { $0.index == selectedPage?.index }),
               nil]
        for (index, row) in rows.enumerated() where index != skip {
            let table = columns[index]
            if let row = row, row < table.numberOfRows(inSection: 0) {
                table.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
            } else {
                table.setContentOffset(.zero, animated: false)
            }
        }
    }

    // MARK: What each column shows

    private enum Kind { case masechet, page, maggid, lessonMaggid, lessonPage }

    private func kind(of column:Int) -> Kind {
        if isByMaggid { return [.maggid, .masechet, .lessonPage][column] }
        return [.masechet, .page, .lessonMaggid][column]
    }

    private func lessonFor(row:Int, column:Int) -> Lesson? {
        switch kind(of: column) {
        case .lessonMaggid:
            guard let masechet = selectedMasechet, let page = selectedPage, row < maggidim.count else { return nil }
            return LessonsBrowserData.lesson(masechet, page: page, maggid: maggidim[row])
        case .lessonPage:
            guard let masechet = selectedMasechet, let maggid = selectedMaggid, row < pages.count else { return nil }
            return LessonsBrowserData.lesson(masechet, page: pages[row], maggid: maggid)
        default:
            return nil
        }
    }

    // MARK: Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch kind(of: tableView.tag) {
        case .masechet: return masechtot.count
        case .page, .lessonPage: return pages.count
        case .maggid, .lessonMaggid: return maggidim.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kind(of: tableView.tag) == .lessonMaggid || kind(of: tableView.tag) == .maggid ? 78 : 68
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LessonsColumnCell.reuseId, for: indexPath) as! LessonsColumnCell
        let row = indexPath.row
        let source = self.source

        switch kind(of: tableView.tag) {
        case .masechet:
            let masechet = masechtot[row]
            cell.configure(title: masechet.name ?? "", subtitle: nil, centered: true,
                           selected: masechet.id == selectedMasechet?.id,
                           today: LessonsBrowserData.isToday(masechet), state: .none)
        case .page:
            let page = pages[row]
            cell.configure(title: page.symbol ?? "", subtitle: nil, centered: true,
                           selected: page.index == selectedPage?.index,
                           today: selectedMasechet.map { LessonsBrowserData.isToday($0, page: page) } ?? false, state: .none)
        case .maggid:
            let maggid = maggidim[row]
            // maggid sort: a star button to add / remove the maggid shiur from the favorites
            cell.configure(title: maggid.name ?? "", subtitle: LessonsColumnCell.meta(for: maggid, duration: nil), centered: false,
                           selected: maggid.id == selectedMaggid?.id, today: false, state: .none, favorite: maggid.isFavorite,
                           onStar: { [weak self] in self?.toggleFavorite(maggid) })
        case .lessonMaggid:
            let maggid = maggidim[row]
            let lesson = lessonFor(row: row, column: tableView.tag)
            let path = lesson?.urlPath()?.replacingOccurrences(of: "http:", with: "https:")
            cell.configure(title: maggid.name ?? "", subtitle: LessonsColumnCell.meta(for: maggid, duration: path.flatMap { durations[$0] } ?? "--:--"),
                           centered: false, selected: false, today: false,
                           state: LessonsColumnCell.state(for: lesson, source: source), favorite: maggid.isFavorite,
                           onAction: saveAction(for: lesson))
        case .lessonPage:
            let page = pages[row]
            let lesson = lessonFor(row: row, column: tableView.tag)
            let path = lesson?.urlPath()?.replacingOccurrences(of: "http:", with: "https:")
            // maggid sort: the lesson duration under the daf (asked for when the daf is shown)
            if let masechet = selectedMasechet, path.flatMap({ durations[$0] }) == nil {
                loadDurations(masechet: masechet, page: page)
            }
            cell.configure(title: page.symbol ?? "", subtitle: path.flatMap { durations[$0] } ?? "--:--", centered: true, selected: false,
                           today: selectedMasechet.map { LessonsBrowserData.isToday($0, page: page) } ?? false,
                           state: LessonsColumnCell.state(for: lesson, source: source),
                           onAction: saveAction(for: lesson))
        }

        return cell
    }

    private func toggleFavorite(_ maggid:MaggidShiur) {
        maggid.isFavorite = !maggid.isFavorite
        if source?.browserSortOption == .FavoirteMagidiShiour {
            // the list shows only favorites: rebuild it
            reloadAll()
        } else {
            if !isByMaggid { reloadMaggidim() }
            columns.forEach { $0.reloadData() }
        }
    }

    /// The download / delete button of a lesson cell
    private func saveAction(for lesson:Lesson?) -> (() -> Void)? {
        guard let lesson = lesson else { return nil }
        return { [weak self] in
            guard let source = self?.source, !source.browserIsSaving(lesson) else { return }
            if LessonsManager.sharedManager.isSavedLesson(lesson) {
                source.browserDelete(lesson)
            } else {
                source.browserSave(lesson)
            }
            self?.refreshState()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch kind(of: tableView.tag) {
        case .masechet:
            selectedMasechet = masechtot[row]
            selectedPage = nil
            reloadPages()
            if let today = selectedMasechet, LessonsBrowserData.isToday(today) {
                selectedPage = pages.first(where: { LessonsBrowserData.isToday(today, page: $0) }) ?? selectedPage
                reloadMaggidim()
            }
            columns.forEach { $0.reloadData() }
            scrollSelectionIntoView(skip: tableView.tag)
        case .page:
            selectedPage = pages[row]
            reloadMaggidim()
            columns[1].reloadData()
            columns[2].reloadData()
            columns[2].setContentOffset(.zero, animated: false)
        case .maggid:
            selectedMaggid = maggidim[row]
            if let source = source { masechtot = LessonsBrowserData.masechtot(for: selectedMaggid, source: source) }
            selectedMasechet = masechtot.first(where: { $0.id == selectedMasechet?.id }) ?? masechtot.first
            reloadPages()
            columns.forEach { $0.reloadData() }
            scrollSelectionIntoView(skip: tableView.tag)
        case .lessonMaggid, .lessonPage:
            if let lesson = lessonFor(row: row, column: tableView.tag) {
                source?.browserPlay(lesson)
            }
        }
    }

    // MARK: Long press menu

    func tableView(_ table: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let kind = self.kind(of: table.tag)
        let row = indexPath.row

        var maggid:MaggidShiur?
        if kind == .maggid || kind == .lessonMaggid { maggid = row < maggidim.count ? maggidim[row] : nil }
        if kind == .lessonPage { maggid = selectedMaggid }
        let lesson = lessonFor(row: row, column: table.tag)
        guard maggid != nil || lesson != nil else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            var actions = [UIAction]()
            if let lesson = lesson, let source = self?.source, !source.browserIsSaving(lesson) {
                if LessonsManager.sharedManager.isSavedLesson(lesson) {
                    actions.append(UIAction(title: "מחק את השיעור השמור", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in source.browserDelete(lesson) })
                } else {
                    actions.append(UIAction(title: "הורד את השיעור", image: UIImage(systemName: "arrow.down.to.line")) { _ in source.browserSave(lesson) })
                }
            }
            if let maggid = maggid {
                let isFavorite = maggid.isFavorite
                actions.append(UIAction(title: isFavorite ? "הסר מהמועדפים" : "הוסף למועדפים", image: UIImage(systemName: isFavorite ? "star.slash" : "star")) { _ in
                    maggid.isFavorite = !isFavorite
                    if self?.isByMaggid == false { self?.reloadMaggidim() }
                    self?.columns.forEach { $0.reloadData() }
                })
            }
            return UIMenu(title: maggid?.name ?? "", children: actions)
        }
    }
}

/// A cell of the column picker
final class LessonsColumnCell: UITableViewCell
{
    static let reuseId = "LessonsColumnCell"
    enum State { case none, selected, playing, saved, downloading(Int) }

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stateIcon = UIImageView()
    private let actionButton = UIButton(type: .system)   // download / delete (lessons that are not the current one)
    private var onAction:(() -> Void)?
    private var subtitleRight:NSLayoutConstraint!
    private var subtitleCentered:NSLayoutConstraint!
    private let todayDot = UIView()
    private let line = UIView()
    private var titleRight:NSLayoutConstraint!
    private var titleLeftForText:NSLayoutConstraint!
    private var titleLeftCentered:NSLayoutConstraint!

    static func meta(for maggid:MaggidShiur, duration:String?) -> String {
        var parts = [String]()
        if let language = maggid.language, !language.isEmpty { parts.append(language) }
        switch maggid.mediaType {
        case .Audio: parts.append("שמע")
        case .Video: parts.append("וידאו")
        case .All: break
        }
        if let duration = duration { parts.append(duration) }
        // FIX: the language text can already include the media type ("עברית | שמע"),
        // so it showed twice. Split everything and keep each part once.
        var unique = [String]()
        for part in parts.flatMap({ $0.components(separatedBy: "|") }) {
            let clean = part.trimmingCharacters(in: .whitespaces)
            if !clean.isEmpty && !unique.contains(clean) { unique.append(clean) }
        }
        return unique.joined(separator: " | ")
    }

    static func state(for lesson:Lesson?, source:LessonsBrowserDataSource?) -> State {
        guard let lesson = lesson, let source = source else { return .none }
        if source.browserIsSaving(lesson) { return .downloading(Int(source.browserDownloadProgress(lesson) * 100)) }
        if source.browserCurrentLesson?.identifier == lesson.identifier {
            return source.browserIsPlaying ? .playing : .selected
        }
        return LessonsManager.sharedManager.isSavedLesson(lesson) ? .saved : .none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.semanticContentAttribute = .forceRightToLeft

        titleLabel.textColor = LessonsBrowserStyle.text
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byClipping
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = LessonsBrowserStyle.text
        subtitleLabel.textAlignment = .right
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.6
        subtitleLabel.numberOfLines = 1
        stateIcon.contentMode = .scaleAspectFit
        stateIcon.tintColor = LessonsBrowserStyle.burgundy
        todayDot.backgroundColor = LessonsBrowserStyle.gold
        todayDot.layer.cornerRadius = 4
        line.backgroundColor = LessonsBrowserStyle.line

        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        actionButton.isHidden = true
        for v in [titleLabel, subtitleLabel, stateIcon, actionButton, todayDot, line] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
        }
        titleRight = titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        // room for the state icon on the left of a maggid shiur name; centered names use the whole width
        titleLeftForText = titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: actionButton.rightAnchor, constant: 6)
        titleLeftCentered = titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: 4)
        subtitleRight = subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor)
        subtitleCentered = subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor)
        NSLayoutConstraint.activate([
            titleRight,
            titleLeftForText,
            subtitleRight,
            actionButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 24),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            // 6pt between the text and the play / download button; longer text shrinks
            subtitleLabel.leftAnchor.constraint(greaterThanOrEqualTo: actionButton.rightAnchor, constant: 6),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            stateIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 6),
            stateIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stateIcon.widthAnchor.constraint(equalToConstant: 18),
            stateIcon.heightAnchor.constraint(equalToConstant: 18),
            todayDot.widthAnchor.constraint(equalToConstant: 8),
            todayDot.heightAnchor.constraint(equalToConstant: 8),
            todayDot.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            todayDot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            line.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            line.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            line.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func actionTapped() { onAction?() }

    private var centerYConstraint:NSLayoutConstraint?
    private var centerXConstraint:NSLayoutConstraint?

    func configure(title:String, subtitle:String?, centered:Bool, selected:Bool, today:Bool, state:State, favorite:Bool = false,
                   onAction:(() -> Void)? = nil, onStar:(() -> Void)? = nil)
    {
        self.onAction = onAction ?? onStar
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        titleLabel.font = centered ? LessonsBrowserStyle.nameFont(19) : UIFont.systemFont(ofSize: 19)
        titleLabel.textAlignment = centered ? .center : .right
        todayDot.isHidden = !today

        // centered names (masechet / daf) vs. a maggid shiur name with details under it
        centerYConstraint?.isActive = false
        centerXConstraint?.isActive = false
        if subtitle == nil {
            centerYConstraint = titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        } else {
            centerYConstraint = titleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 2)
        }
        centerYConstraint?.isActive = true
        titleRight.isActive = !centered
        titleLeftForText.isActive = !centered
        titleLeftCentered.isActive = centered
        subtitleRight.isActive = !centered
        subtitleCentered.isActive = centered
        subtitleLabel.textAlignment = centered ? .center : .right
        if centered {
            centerXConstraint = titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: onAction != nil ? 14 : 0)
            centerXConstraint?.isActive = true
        }

        var background:UIColor = .clear
        if selected {
            background = LessonsColumnsPickerView.selectedBackground
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = LessonsColumnsPickerView.divider.withAlphaComponent(0.6).cgColor
        } else {
            contentView.layer.borderWidth = 0
        }

        switch state {
        case .none:
            stateIcon.image = favorite ? UIImage(systemName: "star.fill") : nil
            stateIcon.tintColor = LessonsBrowserStyle.gold
        case .saved:
            stateIcon.image = UIImage(systemName: "arrow.down.circle.fill")
            stateIcon.tintColor = LessonsBrowserStyle.savedBlue
        case .downloading(let percent):
            stateIcon.image = UIImage(systemName: "arrow.down.circle")
            stateIcon.tintColor = LessonsBrowserStyle.savedBlue
            subtitleLabel.text = (subtitle.map { $0 + " | " } ?? "") + "\(percent)%"
            subtitleLabel.isHidden = false
        case .selected:
            background = LessonsColumnsPickerView.selectedBackground
            stateIcon.image = UIImage(systemName: "play.fill")
            stateIcon.tintColor = LessonsBrowserStyle.parchment
        case .playing:
            background = LessonsColumnsPickerView.selectedBackground
            stateIcon.image = UIImage(systemName: "pause.fill")
            stateIcon.tintColor = LessonsBrowserStyle.parchment
        }
        contentView.backgroundColor = background

        // a lesson that is not the current one: a download / delete button instead of the icon
        var showAction = false
        if onAction != nil {
            switch state {
            case .none, .saved: showAction = true
            default: break
            }
        }
        if onStar != nil { showAction = true }
        actionButton.isHidden = !showAction
        if onStar != nil {
            stateIcon.image = nil
            let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            actionButton.setImage(UIImage(systemName: favorite ? "star.fill" : "star", withConfiguration: config), for: .normal)
            actionButton.tintColor = LessonsBrowserStyle.gold
            actionButton.accessibilityLabel = favorite ? "הסר מהמועדפים" : "הוסף למועדפים"
        } else if showAction {
            stateIcon.image = nil
            let saved:Bool
            if case .saved = state { saved = true } else { saved = false }
            let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
            actionButton.setImage(UIImage(systemName: saved ? "trash" : "arrow.down.circle", withConfiguration: config), for: .normal)
            actionButton.tintColor = saved ? LessonsBrowserStyle.secondaryText : LessonsBrowserStyle.burgundy
            actionButton.accessibilityLabel = saved ? "מחק את השיעור השמור" : "הורד את השיעור"
        }
        
        // Selected / playing: light text (the color of the normal cell background) on the burgundy
        var isOnBurgundy = selected
        if case .playing = state { isOnBurgundy = true }
        if case .selected = state { isOnBurgundy = true }
        titleLabel.textColor = isOnBurgundy ? LessonsBrowserStyle.parchment : LessonsBrowserStyle.text
        subtitleLabel.textColor = isOnBurgundy ? LessonsBrowserStyle.parchment : LessonsBrowserStyle.text

        var label = title
        if let subtitle = subtitleLabel.text, !subtitleLabel.isHidden { label += ", " + subtitle }
        if today { label += ", הדף היומי" }
        if case .playing = state { label += ", מתנגן" }
        accessibilityLabel = label
        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}
