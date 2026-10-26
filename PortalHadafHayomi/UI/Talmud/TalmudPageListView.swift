//
//  TalmudPageListView.swift
//  PortalHadafHayomi
//
//  The page picker as a list: one section per masechet. Tapping a masechet opens it
//  (only one open at a time) and shows its dafim as cards, two per row; each daf card
//  holds two small cards for עמוד א and עמוד ב. Tapping an amud calls onSelect.
//

import UIKit

/// One amud the list can show (side: 0 = ע״א, 1 = ע״ב, like HadafHayomiManager.pageIndexFor).
struct TalmudListAmud {
    let page: Page
    let side: Int
}

/// Download state of one amud
enum TalmudAmudSaveState {
    case unavailable   // this display type can't be saved: no icon
    case notSaved      // download icon
    case downloading   // small spinner
    case saved         // blue text + delete icon
}

/// One daf card: the daf and the amudim to show in it (usually both, fewer for saved pages / last page).
struct TalmudListDaf {
    let page: Page
    let sides: [Int]
}

final class TalmudPageListView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Input
    
    /// The masechtot to show, and for each one the dafim (with their amudim) to show.
    var masechtot = [Masechet]() { didSet { reload() } }
    var dafimProvider: ((Masechet) -> [TalmudListDaf])?
    /// Download state of an amud (icon on its side)
    var saveState: ((Masechet, Page, Int) -> TalmudAmudSaveState)?
    
    /// Called when the user taps an amud
    var onSelect: ((Masechet, Page, Int) -> Void)?
    /// Called when the user taps the download / delete icon of an amud
    var onDownload: ((Masechet, Page, Int) -> Void)?
    var onDelete: ((Masechet, Page, Int) -> Void)?
    
    // MARK: State
    
    private var openMasechetIndex: Int?
    private var openDafim = [TalmudListDaf]()
    private var current: (masechet: Masechet, pageIndex: Int, side: Int)?
    
    static let gold = UIColor(HexColor: "B58B3A")
    
    /// Today's daf (הדף היומי) page index, if it is in this masechet
    private func todaysPageIndex(in masechet: Masechet) -> Int? {
        guard let todaysMasechet = HadafHayomiManager.sharedManager.todaysMaschet,
              let todaysPage = HadafHayomiManager.sharedManager.todaysPage,
              todaysMasechet === masechet || (todaysMasechet.name != nil && todaysMasechet.name == masechet.name)
        else { return nil }
        return todaysPage.index
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    /// "לדף היומי" button at the top of the list (shown when set)
    var onTodaysPage: (() -> Void)? {
        didSet { self.updateTodaysPageHeader() }
    }
    
    private func updateTodaysPageHeader() {
        guard onTodaysPage != nil else {
            tableView.tableHeaderView = nil
            return
        }
        let container = UIView(frame: CGRect(x: 0, y: 0, width: max(tableView.bounds.width, 320), height: 68))
        container.backgroundColor = .clear
        
        let button = UIControl()
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = TalmudPageListView.gold.cgColor
        button.semanticContentAttribute = .forceRightToLeft
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(todaysPageTapped), for: .touchUpInside)
        
        let icon = UIImageView(image: UIImage(systemName: "calendar"))
        icon.tintColor = .white
        icon.contentMode = .center
        icon.backgroundColor = TalmudPageListView.gold
        icon.layer.cornerRadius = 16
        icon.clipsToBounds = true
        
        let title = UILabel()
        title.text = "st_go_to_todays_page".localize()
        title.font = UIFont.boldSystemFont(ofSize: 15)
        title.textColor = TalmudPageListView.burgundy
        
        let subtitle = UILabel()
        if let masechet = HadafHayomiManager.sharedManager.todaysMaschet,
           let page = HadafHayomiManager.sharedManager.todaysPage {
            subtitle.text = "\(masechet.name ?? "") \(page.symbol ?? "")"
        }
        subtitle.font = UIFont.systemFont(ofSize: 12)
        subtitle.textColor = UIColor(HexColor: "6B5E4E")
        
        let texts = UIStackView(arrangedSubviews: [title, subtitle])
        texts.axis = .vertical
        texts.alignment = .leading
        texts.semanticContentAttribute = .forceRightToLeft
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.left"))
        arrow.tintColor = TalmudPageListView.burgundy
        arrow.contentMode = .scaleAspectFit
        
        let row = UIStackView(arrangedSubviews: [icon, texts, UIView(), arrow])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.semanticContentAttribute = .forceRightToLeft
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(row)
        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            row.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            row.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),
            arrow.widthAnchor.constraint(equalToConstant: 14)
        ])
        button.accessibilityLabel = "\(title.text ?? "") \(subtitle.text ?? "")"
        button.accessibilityTraits = .button
        button.isAccessibilityElement = true
        
        tableView.tableHeaderView = container
    }
    
    @objc private func todaysPageTapped() {
        onTodaysPage?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // keep the header as wide as the list
        if let header = tableView.tableHeaderView, header.frame.width != tableView.bounds.width, tableView.bounds.width > 0 {
            header.frame.size.width = tableView.bounds.width
            tableView.tableHeaderView = header
        }
    }
    
    static let burgundy = UIColor(HexColor: "781F24")
    static let parchment = UIColor(HexColor: "F9F3DB")
    static let amudBackground = UIColor(HexColor: "F6EED6")
    static let border = UIColor(HexColor: "DCCFAE")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        semanticContentAttribute = .forceRightToLeft
        backgroundColor = TalmudPageListView.parchment
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 52
        tableView.rowHeight = 50
        // Exact (not estimated) heights, so the list does not jump when a masechet opens
        tableView.estimatedRowHeight = 50
        tableView.estimatedSectionHeaderHeight = 52
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.contentInset.bottom = 50           // room for the save button
        tableView.semanticContentAttribute = .forceRightToLeft
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 0 }
        tableView.register(TalmudDafRowCell.self, forCellReuseIdentifier: TalmudDafRowCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: Public
    
    func reload() {
        if let open = openMasechetIndex, open < masechtot.count {
            openDafim = dafimProvider?(masechtot[open]) ?? []
        } else {
            openMasechetIndex = nil
            openDafim = []
        }
        tableView.reloadData()
    }
    
    /// Refreshes the visible rows (download icons) without moving the list
    func reloadVisibleRows() {
        guard let visible = tableView.indexPathsForVisibleRows, !visible.isEmpty else { return }
        tableView.reloadRows(at: visible, with: .none)
    }
    
    /// Opens the masechet of the current page, highlights the amud and scrolls to it.
    func showCurrent(masechet: Masechet, page: Page, side: Int) {
        current = (masechet, page.index, side)
        guard let section = masechtot.firstIndex(where: { $0 === masechet }) else {
            reload()
            return
        }
        // Open with the masechtot list only (all closed); the current masechet is marked "הדף הנוכחי"
        openMasechetIndex = nil
        reload()
        
        if section < tableView.numberOfSections {
            tableView.layoutIfNeeded()
            let headerRect = tableView.rectForHeader(inSection: section)
            let maxOffset = max(0, tableView.contentSize.height - tableView.bounds.height + tableView.adjustedContentInset.bottom)
            let offset = min(maxOffset, max(0, headerRect.midY - tableView.bounds.height / 2))
            tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
        }
    }
    
    // MARK: Open / close a masechet
    
    @objc private func headerTapped(_ sender: UIControl) {
        let section = sender.tag
        guard section < tableView.numberOfSections else { return }
        
        // Remember where the tapped masechet is on screen
        let headerScreenY = tableView.rectForHeader(inSection: section).minY - tableView.contentOffset.y
        
        if openMasechetIndex == section {
            openMasechetIndex = nil                       // close it
        } else {
            openMasechetIndex = section                   // open it (the previous one closes)
        }
        
        UIView.performWithoutAnimation {
            reload()
            tableView.layoutIfNeeded()
            
            // Keep the tapped masechet at the same place on screen
            let inset = tableView.adjustedContentInset
            let minOffset = -inset.top
            let maxOffset = max(minOffset, tableView.contentSize.height + inset.bottom - tableView.bounds.height)
            let wanted = tableView.rectForHeader(inSection: section).minY - headerScreenY
            tableView.setContentOffset(CGPoint(x: 0, y: min(maxOffset, max(minOffset, wanted))), animated: false)
        }
    }
    
    // MARK: Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return masechtot.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == openMasechetIndex else { return 0 }
        return (openDafim.count + 1) / 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let masechet = masechtot[section]
        let isOpen = (section == openMasechetIndex)
        let isCurrent = (current?.masechet === masechet)
        
        let header = UIControl()
        header.tag = section
        header.backgroundColor = isOpen ? UIColor(HexColor: "FFF6E0") : .white
        header.semanticContentAttribute = .forceRightToLeft
        header.accessibilityLabel = masechet.name
        header.accessibilityTraits = .button
        header.addTarget(self, action: #selector(headerTapped(_:)), for: .touchUpInside)
        
        let nameLabel = UILabel()
        nameLabel.text = masechet.name
        nameLabel.font = UIFont(name: "BroshMF", size: 20) ?? UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = TalmudPageListView.burgundy
        
        let rangeLabel = UILabel()
        if let first = masechet.pages.first?.symbol, let last = masechet.pages.last?.symbol {
            rangeLabel.text = "\(first) – \(last)"
        }
        rangeLabel.font = UIFont.systemFont(ofSize: 13)
        rangeLabel.textColor = UIColor(HexColor: "6B5E4E")
        
        let arrow = UIImageView(image: UIImage(systemName: isOpen ? "chevron.up" : "chevron.down"))
        arrow.tintColor = TalmudPageListView.burgundy
        arrow.contentMode = .scaleAspectFit
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, UIView(), rangeLabel, arrow])
        if isCurrent, let pageIndex = current?.pageIndex,
           let page = masechet.pages.first(where: { $0.index == pageIndex }) {
            let tag = TalmudTagLabel()
            tag.text = "הדף הנוכחי: \(page.symbol ?? "")\(current?.side == 1 ? ":" : ".")"
            tag.font = UIFont.boldSystemFont(ofSize: 12)
            tag.textColor = UIColor(HexColor: "5A1520")
            tag.backgroundColor = UIColor(HexColor: "F3DFA8")
            tag.layer.cornerRadius = 11
            tag.layer.masksToBounds = true
            stack.insertArrangedSubview(tag, at: 1)
        }
        if let todayIndex = todaysPageIndex(in: masechet),
           let page = masechet.pages.first(where: { $0.index == todayIndex }) {
            let tag = TalmudTagLabel()
            tag.text = "הדף היומי: \(page.symbol ?? "")"
            tag.font = UIFont.boldSystemFont(ofSize: 12)
            tag.textColor = .white
            tag.backgroundColor = TalmudPageListView.gold
            tag.layer.cornerRadius = 11
            tag.layer.masksToBounds = true
            stack.insertArrangedSubview(tag, at: 1)
        }
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.semanticContentAttribute = .forceRightToLeft
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(stack)
        
        let line = UIView()
        line.backgroundColor = UIColor(HexColor: "E5DAB8")
        line.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(line)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 16),
            line.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            line.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TalmudDafRowCell.reuseId, for: indexPath) as! TalmudDafRowCell
        let masechet = masechtot[indexPath.section]
        
        let first = indexPath.row * 2
        let dafim = Array(openDafim[first ..< min(first + 2, openDafim.count)])
        
        let currentPageIndex = (current?.masechet === masechet) ? current?.pageIndex : nil
        cell.configure(dafim: dafim,
                       currentPageIndex: currentPageIndex,
                       todaysPageIndex: todaysPageIndex(in: masechet),
                       currentSide: current?.side,
                       saveState: { [weak self] page, side in self?.saveState?(masechet, page, side) ?? .unavailable },
                       onSelect: { [weak self] page, side in
                            self?.current = (masechet, page.index, side)
                            self?.onSelect?(masechet, page, side)
                       },
                       onDownload: { [weak self] page, side in self?.onDownload?(masechet, page, side) },
                       onDelete: { [weak self] page, side in self?.onDelete?(masechet, page, side) })
        return cell
    }
}

// MARK: - A row of two daf cards

final class TalmudDafRowCell: UITableViewCell {
    
    static let reuseId = "TalmudDafRowCell"
    
    private let rowStack = UIStackView()
    private var amudActions = [UIButton: (Page, Int)]()
    private var onSelect: ((Page, Int) -> Void)?
    private var onDownload: ((Page, Int) -> Void)?
    private var onDelete: ((Page, Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.semanticContentAttribute = .forceRightToLeft
        
        rowStack.axis = .horizontal
        rowStack.spacing = 6
        rowStack.distribution = .fillEqually
        rowStack.semanticContentAttribute = .forceRightToLeft
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)
        
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(dafim: [TalmudListDaf], currentPageIndex: Int?, todaysPageIndex: Int? = nil, currentSide: Int?,
                   saveState: (Page, Int) -> TalmudAmudSaveState,
                   onSelect: @escaping (Page, Int) -> Void,
                   onDownload: @escaping (Page, Int) -> Void,
                   onDelete: @escaping (Page, Int) -> Void) {
        self.onSelect = onSelect
        self.onDownload = onDownload
        self.onDelete = onDelete
        amudActions.removeAll()
        rowStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for daf in dafim {
            let card = makeDafCard(daf, currentPageIndex: currentPageIndex, currentSide: currentSide, saveState: saveState)
            if daf.page.index == todaysPageIndex {
                // Today's daf: gold frame around the daf card
                card.layer.borderWidth = 2.5
                card.layer.borderColor = TalmudPageListView.gold.cgColor
                card.accessibilityLabel = "הדף היומי"
            }
            rowStack.addArrangedSubview(card)
        }
        if dafim.count == 1 {
            rowStack.addArrangedSubview(UIView())      // keep the last card half width
        }
    }
    
    private func makeDafCard(_ daf: TalmudListDaf, currentPageIndex: Int?, currentSide: Int?,
                             saveState: (Page, Int) -> TalmudAmudSaveState) -> UIView {
        let card = UIStackView()
        card.axis = .horizontal
        card.spacing = 4
        card.distribution = .fillEqually
        card.semanticContentAttribute = .forceRightToLeft
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.borderWidth = 1
        card.layer.borderColor = TalmudPageListView.border.cgColor
        
        for side in daf.sides {
            card.addArrangedSubview(makeAmud(daf.page, side: side,
                                             isCurrent: daf.page.index == currentPageIndex && side == currentSide,
                                             state: saveState(daf.page, side)))
        }
        if daf.sides.count == 1 {
            card.addArrangedSubview(UIView())          // e.g. a masechet that ends on ע״א
        }
        return card
    }
    
    /// One amud: its name (opens the page) and, on its side, the download / delete icon.
    private func makeAmud(_ page: Page, side: Int, isCurrent: Bool, state: TalmudAmudSaveState) -> UIView {
        let amudName = "\(page.symbol ?? "") ע״\(side == 0 ? "א" : "ב")"
        
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 0
        container.semanticContentAttribute = .forceRightToLeft
        container.backgroundColor = isCurrent ? TalmudPageListView.burgundy : TalmudPageListView.amudBackground
        container.layer.cornerRadius = 7
        container.clipsToBounds = true
        
        let titleButton = UIButton(type: .custom)
        titleButton.setTitle(amudName, for: .normal)
        titleButton.titleLabel?.font = UIFont(name: "BroshMF", size: 16) ?? UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.7
        let textColor: UIColor = isCurrent ? .white : (state == .saved ? .systemBlue : UIColor(HexColor: "1F1A17"))
        titleButton.setTitleColor(textColor, for: .normal)
        titleButton.addTarget(self, action: #selector(amudTapped(_:)), for: .touchUpInside)
        amudActions[titleButton] = (page, side)
        container.addArrangedSubview(titleButton)
        
        let iconColor: UIColor = isCurrent ? .white : UIColor(HexColor: "6B5E4E")
        switch state {
        case .unavailable:
            break
        case .notSaved:
            let download = iconButton(systemName: "arrow.down.to.line", color: iconColor, label: "הורד את \(amudName)")
            download.addTarget(self, action: #selector(downloadTapped(_:)), for: .touchUpInside)
            amudActions[download] = (page, side)
            container.addArrangedSubview(download)
        case .downloading:
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = isCurrent ? .white : .systemBlue
            spinner.startAnimating()
            spinner.widthAnchor.constraint(equalToConstant: 26).isActive = true
            container.addArrangedSubview(spinner)
        case .saved:
            let delete = iconButton(systemName: "trash", color: isCurrent ? .white : UIColor(HexColor: "8C2A2A"), label: "מחק את \(amudName)")
            delete.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            amudActions[delete] = (page, side)
            container.addArrangedSubview(delete)
        }
        return container
    }
    
    private func iconButton(systemName: String, color: UIColor, label: String) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = color
        button.accessibilityLabel = label
        button.widthAnchor.constraint(equalToConstant: 26).isActive = true
        return button
    }
    
    @objc private func amudTapped(_ sender: UIButton) {
        if let (page, side) = amudActions[sender] { onSelect?(page, side) }
    }
    
    @objc private func downloadTapped(_ sender: UIButton) {
        if let (page, side) = amudActions[sender] { onDownload?(page, side) }
    }
    
    @objc private func deleteTapped(_ sender: UIButton) {
        if let (page, side) = amudActions[sender] { onDelete?(page, side) }
    }
}


/// The small rounded tag ("הדף הנוכחי" / "הדף היומי") with room around the text
final class TalmudTagLabel: UILabel {
    var insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
