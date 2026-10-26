//
//  MicropediaViewController.swift
//  PortalHadafHayomi
//
//  מיקרופדיה תלמודית – native screen over the daf-yomi.com dictionary (id=3):
//  חיפוש ערך / רשימת ערכים / חיפוש חופשי. An entry opens in BTWebViewController.
//

import UIKit
import WebKit

// MARK: - Model

struct MicropediaEntry {
    let title: String
    let url: URL
}

enum MicropediaResult {
    case entries([MicropediaEntry], didYouMean: Bool)
    case exactMatch(URL)
    case noResults
}

// MARK: - Data (site pages)

final class MicropediaService {
    
    static let baseURL = "https://daf-yomi.com/Dictionary.aspx?id=3"
    
    /// Free search address ({q} = the search text), from the site's Dictionary.js
    static let fullTextURLTemplate: String? = "https://daf-yomi.com/Dictionary.aspx?id=3&tab=fulltext&query={q}"
    
    private var task: URLSessionDataTask?
    
    /// חיפוש ערך
    func searchEntry(_ word: String, completion: @escaping (MicropediaResult) -> Void) {
        guard let url = URL(string: MicropediaService.baseURL + "&word=" + MicropediaService.encode(word)) else {
            completion(.noResults); return
        }
        load(url) { html in
            guard let html = html else { completion(.noResults); return }
            let entries = MicropediaService.parseEntries(html)
            if html.contains("אולי התכוונת") {
                completion(entries.isEmpty ? .noResults : .entries(entries, didYouMean: true))
            } else if html.contains("לא נמצא") {
                completion(.noResults)
            } else {
                // The site shows the entry itself when the word matches exactly
                completion(.exactMatch(url))
            }
        }
    }
    
    /// רשימת ערכים – entries of one letter
    func browse(letter: String, completion: @escaping (MicropediaResult) -> Void) {
        guard let url = URL(string: MicropediaService.baseURL + "&tab=browse&char=" + MicropediaService.encode(letter)) else {
            completion(.noResults); return
        }
        load(url) { html in
            let entries = html.map { MicropediaService.parseEntries($0) } ?? []
            completion(entries.isEmpty ? .noResults : .entries(entries, didYouMean: false))
        }
    }
    
    /// חיפוש חופשי
    func fullTextSearch(_ text: String, completion: @escaping (MicropediaResult) -> Void) {
        guard let template = MicropediaService.fullTextURLTemplate,
              let url = URL(string: template.replacingOccurrences(of: "{q}", with: MicropediaService.encode(text))) else {
            completion(.noResults); return
        }
        load(url) { html in
            let entries = html.map { MicropediaService.parseEntries($0) } ?? []
            completion(entries.isEmpty ? .noResults : .entries(entries, didYouMean: false))
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
    
    // MARK: Private
    
    private func load(_ url: URL, completion: @escaping (String?) -> Void) {
        cancel()
        let newTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            var html: String?
            if let data = data {
                html = String(data: data, encoding: .utf8)
                    ?? String(data: data, encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.windowsHebrew.rawValue))))
            }
            DispatchQueue.main.async { completion(html) }
        }
        task = newTask
        newTask.resume()
    }
    
    static func encode(_ text: String) -> String {
        return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
    }
    
    /// Every link to an entry (href with wordId=), in page order, without duplicates.
    static func parseEntries(_ html: String) -> [MicropediaEntry] {
        let pattern = "<a[^>]+href=[\"']([^\"']*wordId=(\\d+)[^\"']*)[\"'][^>]*>([\\s\\S]*?)</a>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        
        let ns = html as NSString
        var seen = Set<String>()
        var entries = [MicropediaEntry]()
        
        for match in regex.matches(in: html, range: NSRange(location: 0, length: ns.length)) {
            let href = decodeEntities(ns.substring(with: match.range(at: 1)))
            let wordId = ns.substring(with: match.range(at: 2))
            let title = decodeEntities(stripTags(ns.substring(with: match.range(at: 3))))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // FIX: always open the entry by its plain address (…Dictionary.aspx?id=3&wordId=N).
            // Links in "רשימת ערכים" carry extra parts (the browse tab / letter), so the site
            // showed the whole list page and the entry could not be cut out of it.
            guard !title.isEmpty, !seen.contains(wordId),
                  URL(string: href, relativeTo: URL(string: "https://daf-yomi.com/")) != nil,
                  let url = URL(string: MicropediaService.baseURL + "&wordId=" + wordId) else { continue }
            seen.insert(wordId)
            entries.append(MicropediaEntry(title: title, url: url))
        }
        return entries
    }
    
    private static func stripTags(_ text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    private static func decodeEntities(_ text: String) -> String {
        var result = text
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
        // numeric entities like &#1488;
        if let regex = try? NSRegularExpression(pattern: "&#(\\d+);") {
            let ns = result as NSString
            for match in regex.matches(in: result, range: NSRange(location: 0, length: ns.length)).reversed() {
                if let code = Int(ns.substring(with: match.range(at: 1))), let scalar = Unicode.Scalar(code) {
                    result = (result as NSString).replacingCharacters(in: match.range, with: String(Character(scalar)))
                }
            }
        }
        return result.replacingOccurrences(of: "&amp;", with: "&")
    }
}

// MARK: - Screen

final class MicropediaViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private enum Tab: Int { case search = 0, browse = 1, fullText = 2 }
    
    private let burgundy = UIColor(red: 0.48, green: 0.12, blue: 0.17, alpha: 1)
    private let parchment = UIColor(red: 0.976, green: 0.953, blue: 0.859, alpha: 1)
    private let letters = ["א","ב","ג","ד","ה","ו","ז","ח","ט","י","כ","ל","מ","נ","ס","ע","פ","צ","ק","ר","ש","ת"]
    
    private let service = MicropediaService()
    private var entries = [MicropediaEntry]()
    private var listTitle: String?
    private var currentTab: Tab = .search
    
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["חיפוש ערך", "רשימת ערכים", "חיפוש חופשי"])
    private let searchBar = UISearchBar()
    private let lettersScrollView = UIScrollView()
    private let lettersStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let messageLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let creditLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.semanticContentAttribute = .forceRightToLeft
        view.backgroundColor = parchment
        buildHeader()
        buildControls()
        buildList()
        select(.search)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: Layout
    
    private func buildHeader() {
        headerView.backgroundColor = burgundy
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        backButton.tintColor = .white
        backButton.accessibilityLabel = "חזרה"
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(backButton)
        
        titleLabel.text = "מיקרופדיה תלמודית"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8)
        ])
    }
    
    private func buildControls() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = burgundy
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.semanticContentAttribute = .forceRightToLeft
        searchBar.searchTextField.textAlignment = .right
        searchBar.returnKeyType = .search
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        lettersStack.axis = .horizontal
        lettersStack.spacing = 6
        lettersStack.translatesAutoresizingMaskIntoConstraints = false
        for letter in letters {
            let button = UIButton(type: .system)
            button.setTitle(letter, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.setTitleColor(burgundy, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
            lettersStack.addArrangedSubview(button)
        }
        lettersScrollView.showsHorizontalScrollIndicator = false
        lettersScrollView.semanticContentAttribute = .forceRightToLeft
        lettersScrollView.translatesAutoresizingMaskIntoConstraints = false
        lettersScrollView.addSubview(lettersStack)
        view.addSubview(lettersScrollView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 6),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            
            lettersScrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            lettersScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lettersScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lettersScrollView.heightAnchor.constraint(equalToConstant: 44),
            
            lettersStack.topAnchor.constraint(equalTo: lettersScrollView.contentLayoutGuide.topAnchor, constant: 2),
            lettersStack.bottomAnchor.constraint(equalTo: lettersScrollView.contentLayoutGuide.bottomAnchor, constant: -2),
            lettersStack.leadingAnchor.constraint(equalTo: lettersScrollView.contentLayoutGuide.leadingAnchor, constant: 12),
            lettersStack.trailingAnchor.constraint(equalTo: lettersScrollView.contentLayoutGuide.trailingAnchor, constant: -12),
            lettersStack.heightAnchor.constraint(equalTo: lettersScrollView.frameLayoutGuide.heightAnchor, constant: -4)
        ])
    }
    
    private func buildList() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EntryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        messageLabel.textColor = UIColor(white: 0.35, alpha: 1)
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        spinner.color = burgundy
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        // Credit at the bottom of the screen
        creditLabel.text = "באדיבות אנציקלופדיה תלמודית"
        creditLabel.textColor = UIColor(white: 0.35, alpha: 1)
        creditLabel.font = UIFont.systemFont(ofSize: 13)
        creditLabel.textAlignment = .center
        creditLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(creditLabel)
        
        NSLayoutConstraint.activate([
            creditLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            creditLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            creditLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 64),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: creditLabel.topAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 32),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 32)
        ])
    }
    
    // MARK: Tabs
    
    @objc private func tabChanged() {
        select(Tab(rawValue: segmentedControl.selectedSegmentIndex) ?? .search)
    }
    
    private func select(_ newTab: Tab) {
        currentTab = newTab
        service.cancel()
        spinner.stopAnimating()
        show(entries: [], title: nil)
        
        let isBrowse = (newTab == .browse)
        searchBar.isHidden = isBrowse
        lettersScrollView.isHidden = !isBrowse
        searchBar.text = ""
        
        switch newTab {
        case .search:
            searchBar.placeholder = "הקלד שם ערך, למשל: לוי"
            messageLabel.text = "חפש ערך לפי שמו"
        case .browse:
            searchBar.resignFirstResponder()
            messageLabel.text = "בחר אות לעיון ברשימת הערכים"
        case .fullText:
            searchBar.placeholder = "חפש מילה בתוך הערכים"
            messageLabel.text = MicropediaService.fullTextURLTemplate == nil
                ? "החיפוש החופשי יתווסף בקרוב"
                : "חפש מילה או ביטוי בתוך כל הערכים"
        }
    }
    
    // MARK: Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func letterTapped(_ sender: UIButton) {
        guard let letter = sender.title(for: .normal) else { return }
        for case let button as UIButton in lettersStack.arrangedSubviews {
            let isSelected = (button === sender)
            button.backgroundColor = isSelected ? burgundy : .white
            button.setTitleColor(isSelected ? .white : burgundy, for: .normal)
        }
        startLoading()
        service.browse(letter: letter) { [weak self] result in
            self?.handle(result, query: letter)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        searchBar.resignFirstResponder()
        startLoading()
        
        if currentTab == .fullText {
            service.fullTextSearch(text) { [weak self] result in self?.handle(result, query: text) }
        } else {
            service.searchEntry(text) { [weak self] result in self?.handle(result, query: text) }
        }
    }
    
    private func startLoading() {
        show(entries: [], title: nil)
        messageLabel.text = nil
        spinner.startAnimating()
    }
    
    private func handle(_ result: MicropediaResult, query: String) {
        spinner.stopAnimating()
        switch result {
        case .exactMatch(let url):
            let entry = MicropediaEntry(title: query, url: url)
            show(entries: [entry], title: "נמצא ערך")
            open(entry)   // one result: go straight to the entry
        case .entries(let found, let didYouMean):
            show(entries: found, title: didYouMean ? "לא נמצא ערך בשם \"\(query)\". אולי התכוונת:" : nil)
            // A search (not a letter list) with exactly one result: go straight to the entry
            if found.count == 1, currentTab != .browse {
                open(found[0])
            }
        case .noResults:
            show(entries: [], title: nil)
            messageLabel.text = "לא נמצאו ערכים עבור \"\(query)\""
        }
    }
    
    private func show(entries newEntries: [MicropediaEntry], title: String?) {
        entries = newEntries
        listTitle = title
        if !newEntries.isEmpty { messageLabel.text = nil }
        tableView.reloadData()
    }
    
    private func open(_ entry: MicropediaEntry) {
        navigationController?.pushViewController(MicropediaEntryViewController(entry: entry), animated: true)
    }
    
    // MARK: Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return entries.isEmpty ? nil : listTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath)
        cell.textLabel?.text = entries[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.numberOfLines = 0
        cell.semanticContentAttribute = .forceRightToLeft
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        open(entries[indexPath.row])
    }
}

// MARK: - Entry screen: shows only #wordDefinitionArea of the site page

final class MicropediaEntryViewController: UIViewController, WKNavigationDelegate {
    
    private enum Mode { case loadingSitePage, showingEntry }
    
    private var entryURL: URL
    private let entryTitle: String
    private var mode: Mode = .loadingSitePage
    
    private let burgundy = UIColor(red: 0.48, green: 0.12, blue: 0.17, alpha: 1)
    private let parchment = UIColor(red: 0.984, green: 0.969, blue: 0.937, alpha: 1)
    
    private let headerTitleLabel = UILabel()
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init(entry: MicropediaEntry) {
        self.entryURL = entry.url
        self.entryTitle = entry.title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.semanticContentAttribute = .forceRightToLeft
        view.backgroundColor = parchment
        
        let header = UIView()
        header.backgroundColor = burgundy
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        backButton.tintColor = .white
        backButton.accessibilityLabel = "חזרה"
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(backButton)
        
        headerTitleLabel.text = entryTitle
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.adjustsFontSizeToFitWidth = true
        headerTitleLabel.minimumScaleFactor = 0.7
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerTitleLabel)
        
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = parchment
        webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        loadingIndicator.color = burgundy
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            
            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -4),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            headerTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            headerTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerTitleLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -60),
            
            webView.topAnchor.constraint(equalTo: header.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loadSitePage(entryURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Loading
    
    /// Step 1: load the full site page, hidden.
    private func loadSitePage(_ url: URL) {
        entryURL = url
        mode = .loadingSitePage
        webView.isHidden = true
        loadingIndicator.startAnimating()
        webView.load(URLRequest(url: url))
    }
    
    /// Step 2: take only the entry and show it in a clean page of our own.
    private func extractEntry() {
        webView.evaluateJavaScript(MicropediaEntryViewController.extractScript) { [weak self] result, _ in
            guard let self = self else { return }
            guard let info = result as? [String: Any],
                  let html = info["html"] as? String, !html.isEmpty else {
                // No entry block on this page (e.g. a list page): show the page as it is
                self.showWebView()
                return
            }
            if let title = info["title"] as? String, !title.isEmpty {
                self.headerTitleLabel.text = title
            }
            self.mode = .showingEntry
            self.webView.loadHTMLString(MicropediaEntryViewController.wrap(html), baseURL: self.entryURL)
        }
    }
    
    private func showWebView() {
        loadingIndicator.stopAnimating()
        webView.isHidden = false
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch mode {
        case .loadingSitePage:
            extractEntry()
        case .showingEntry:
            webView.scrollView.setContentOffset(.zero, animated: false)
            showWebView()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showWebView()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showWebView()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard mode == .showingEntry, navigationAction.navigationType == .linkActivated,
              let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // A jump inside this entry (table of contents, footnotes)
        if url.fragment != nil,
           url.absoluteString.components(separatedBy: "#").first == entryURL.absoluteString.components(separatedBy: "#").first {
            decisionHandler(.allow)
            return
        }
        
        // A link to another entry: load it and crop it the same way
        if url.host?.contains("daf-yomi.com") == true, url.absoluteString.contains("Dictionary.aspx") {
            decisionHandler(.cancel)
            // same plain entry address as the lists use (keeps the #section to jump to)
            if let wordId = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "wordId" })?.value,
               let plain = URL(string: MicropediaService.baseURL + "&wordId=" + wordId + (url.fragment.map { "#" + $0 } ?? "")) {
                loadSitePage(plain)
            } else {
                loadSitePage(url)
            }
            return
        }
        
        // Any other link: open in Safari
        decisionHandler(.cancel)
        UIApplication.shared.open(url)
    }
    
    // MARK: HTML
    
    /// Returns {title, html} of #wordDefinitionArea, with in-page links made relative (#cite_note-1).
    private static let extractScript = """
    (function () {
      var area = document.getElementById('wordDefinitionArea');
      if (!area || !area.querySelector('.wiki-content')) return null;
      var copy = area.cloneNode(true);
      var page = location.href.split('#')[0];
      var links = copy.querySelectorAll('a[href]');
      for (var i = 0; i < links.length; i++) {
        var href = links[i].href;
        if (href.indexOf('#') > 0 && href.split('#')[0] === page) {
          links[i].setAttribute('href', '#' + href.split('#')[1]);
        }
      }
      var titleEl = copy.querySelector('.boldtext');
      return { title: titleEl ? titleEl.textContent.trim() : '', html: copy.innerHTML };
    })();
    """
    
    private static func wrap(_ entryHTML: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="he" dir="rtl">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          html, body { margin: 0; background: #FBF7EF; }
          body { padding: 16px 16px 48px 16px; font-family: -apple-system, sans-serif; font-size: 18px; line-height: 1.65; color: #1F1A17; direction: rtl; -webkit-text-size-adjust: 100%; }
          body > div { background: transparent !important; padding: 0 !important; }
          .boldtext { font-size: 26px; font-weight: 700; color: #5A1520; margin-bottom: 8px; }
          a { color: #7A1F2B; }
          sup { font-size: 12px; }
          h2, h3, h4 { color: #5A1520; line-height: 1.3; margin: 24px 0 8px 0; }
          ul, ol { padding-right: 22px; padding-left: 0; }
          .toc, #toc { background: #FFFFFF; border: 1px solid #E5D9C2; border-radius: 12px; padding: 8px 12px; }
          img, table { max-width: 100%; height: auto; }
        </style>
        </head>
        <body>
        \(entryHTML)
        </body>
        </html>
        """
    }
}

