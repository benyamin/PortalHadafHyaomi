//
//  ChecklistTextField.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 23/11/2025.
//  Copyright © 2025 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

final class ChecklistTextField: UITextField {

    // MARK: - Public API

    /// Closure called when selected items change
    var onSelectionChanged: (([String]) -> Void)?

    /// All available items (cities)
    var checklistItems: [String] = [] {
        didSet { filteredItems = checklistItems }
    }

    /// Optional limit for number of selections (nil = unlimited)
    var maxSelectedItems: Int?

    // MARK: - Internal state

    /// Filtered items currently displayed in dropdown (prefix match)
    private var filteredItems: [String] = []

    /// Items selected by the user (unique)
    var selectedItems:[String] = [] {
        didSet {
            updateTextFieldDisplay()
            onSelectionChanged?(Array(selectedItems))
        }
    }

    /// The user's current typed filter (only the part after selected list)
    private var filterText: String = "" {
        didSet {
            updateFilter()
        }
    }

    // MARK: - UI

    private lazy var dropdownTable: UITableView = {
        let t = UITableView()
        t.delegate = self
        t.dataSource = self
        t.layer.cornerRadius = 8
        t.tableFooterView = UIView()
        return t
    }()

    private var dropdownContainer = UIView()

    private lazy var backgroundDimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        v.addGestureRecognizer(tap)
        return v
    }()

    private lazy var clearButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .systemGray2
        b.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        b.addTarget(self, action: #selector(clearAllSelections), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle

    override func didMoveToWindow() {
        super.didMoveToWindow()
        rightView = clearButton
        rightViewMode = .always
        self.delegate = self
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    override func becomeFirstResponder() -> Bool {
        let r = super.becomeFirstResponder()
        showDropdown()
        return r
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil { hideDropdown() }
    }

    // MARK: - Dropdown presentation

    private func showDropdown() {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }

        // reset filter when opening
        filteredItems = checklistItems

        // dim background
        backgroundDimView.frame = window.bounds
        window.addSubview(backgroundDimView)
        UIView.animate(withDuration: 0.2) { self.backgroundDimView.alpha = 1 }

        // container
        dropdownContainer.frame = dropdownFrame(in: window)
        dropdownTable.frame = dropdownContainer.bounds
        dropdownContainer.addSubview(dropdownTable)

        window.addSubview(dropdownContainer)
        dropdownTable.reloadData()
        moveCaretToEnd()
    }

    private func hideDropdown() {
        
        filterText = ""
        updateTextFieldDisplay()
        
        UIView.animate(withDuration: 0.18, animations: {
            self.backgroundDimView.alpha = 0
        }, completion: { _ in
            self.backgroundDimView.removeFromSuperview()
        })
        dropdownContainer.removeFromSuperview()
    }

    private func dropdownFrame(in window: UIWindow) -> CGRect {
        let frameInWindow = convert(bounds, to: window)
        let rowHeight: CGFloat = 44
        let height = min(250, CGFloat(max(1, filteredItems.count)) * rowHeight)
        return CGRect(x: frameInWindow.minX, y: frameInWindow.maxY + 6, width: frameInWindow.width, height: height)
    }

    @objc private func didTapBackground() {
        hideDropdown()
        resignFirstResponder()
    }

    // MARK: - Clear action

    @objc private func clearAllSelections() {
        selectedItems.removeAll()
        filterText = ""
        dropdownTable.reloadData()
        moveCaretToEnd()
    }

    // MARK: - Filtering / Text management

    @objc private func textDidChange() {
        // derive filterText from current text by stripping selected part prefix
        let currentText = self.text ?? ""
        let selectedText = selectedItems.joined(separator: ", ")

        if selectedText.isEmpty {
            // everything is filter
            filterText = currentText
        } else if currentText.hasPrefix(selectedText) {
            var remainder = currentText.dropFirst(selectedText.count)
            if remainder.hasPrefix(", ") {
                remainder = remainder.dropFirst(2)
            }
            filterText = String(remainder)
        } else {
            // fallback (user edited unexpectedly) — treat whole text as filter
            filterText = currentText
        }

        // keep dropdown in sync
        dropdownTable.reloadData()
        // ensure caret at end
        moveCaretToEnd()
    }

    private func updateFilter() {
        if filterText.isEmpty {
            filteredItems = checklistItems
        } else {
            filteredItems = checklistItems.filter {
                $0.lowercased().hasPrefix(filterText.lowercased())
            }
        }
        // resize dropdown to match number of rows (if visible)
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow),
           dropdownContainer.superview != nil {
            dropdownContainer.frame = dropdownFrame(in: window)
            dropdownTable.frame = dropdownContainer.bounds
        }
    }

    private func updateTextFieldDisplay() {
        let selectedText = selectedItems.isEmpty ? "" : selectedItems.joined(separator: ", ") + ", "
        
        self.text = selectedText + filterText

        moveCaretToEnd()
    }

    // ensure the caret is at the end of the text
    private func moveCaretToEnd() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let end = self.endOfDocument as UITextPosition? {
                self.selectedTextRange = self.textRange(from: end, to: end)
            }
        }
    }

    // MARK: - Selection helper

    private func addSelection(_ item: String) {
        if let max = maxSelectedItems, selectedItems.count >= max {
            // silently ignore (could also show UI feedback)
            return
        }
        selectedItems.append(item)
        // after selection, reset filter so user can type anew
        filterText = ""
        filteredItems = checklistItems
        dropdownTable.reloadData()
        updateTextFieldDisplay()
    }
    
    private func removeSelection(_ item: String) {
        selectedItems.remove(item as NSString)
        updateTextFieldDisplay()
        dropdownTable.reloadData()
    }

    // MARK: - Deletion behavior (backspace)

    override func deleteBackward() {
        // CASE A: typed filter has characters -> remove last char only
        if !filterText.isEmpty {
            filterText.removeLast()
            updateTextFieldDisplay()
            dropdownTable.reloadData()
            return
        }

        // CASE B: filter empty -> remove last selected item and set filter to its prefix (drop last char)
        if !selectedItems.isEmpty {
            // determine deterministic "last" item: use alphabetical order
            guard let last = selectedItems.last else {
                super.deleteBackward()
                return
            }

            // remove it from selectedItems
            if let index = selectedItems.firstIndex(of: last) {
                selectedItems.remove(at: index)
            }

            // new filter becomes the removed item minus its last character (if any)
            if last.count > 1 {
                filterText = String(last.dropLast())
            } else {
                filterText = ""
            }

            // make sure we update filter and display
            updateTextFieldDisplay()
            dropdownTable.reloadData()
            return
        }

        // default behavior
        super.deleteBackward()
    }
}

// MARK: - UITableView DataSource / Delegate

extension ChecklistTextField: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let id = "ChecklistCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
            ?? UITableViewCell(style: .default, reuseIdentifier: id)

        let item = filteredItems[indexPath.row]
        cell.textLabel?.text = item
        cell.accessoryType = selectedItems.contains(item) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredItems[indexPath.row]
        
        if selectedItems.contains(item) {
            removeSelection(item)
        }
        else{
            addSelection(item)
        }
    }
}

// MARK: - UITextFieldDelegate (optional extras)

extension ChecklistTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // allow editing; showDropdown is called from becomeFirstResponder
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // optional: dismiss on return
        textField.resignFirstResponder()
        
        hideDropdown()
        return true
    }
}

/*
final class ChecklistTextField: UITextField, UITableViewDelegate, UITableViewDataSource {

    var onSelectionChanged: (([String]) -> Void)?

    var checklistItems: [String] = [] {
        didSet { selectedItems.removeAll() }
    }

    var selectedItems: Set<String> = [] {
        didSet {
            clearButton.isHidden = selectedItems.isEmpty
        }
    }
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray2
        button.frame = CGRect(x: 4, y: 0, width: 24, height: 24)
        button.addTarget(self, action: #selector(clearAllSelections), for: .touchUpInside)
        return button
    }()

    private lazy var dropdownTable: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 8
        table.layer.borderWidth = 1
        table.layer.borderColor = UIColor.systemGray4.cgColor
        return table
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()

        rightView = clearButton
        rightViewMode = .always
    }

    private var dropdownContainer = UIView()

    /// NEW: Background overlay behind dropdown
    private lazy var backgroundDimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        v.addGestureRecognizer(tap)
        return v
    }()

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil { hideDropdown() }
    }

    override func becomeFirstResponder() -> Bool {
        showDropdown()
        return false
    }

    // MARK: - Show / Hide Dropdown

    private func showDropdown() {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }

        // --- Add dim background ---
        backgroundDimView.frame = window.bounds
        window.addSubview(backgroundDimView)

        UIView.animate(withDuration: 0.2) {
            self.backgroundDimView.alpha = 1
        }

        // --- Position dropdown ---
        let frameInWindow = self.convert(self.bounds, to: window)

        dropdownContainer.frame = CGRect(
            x: frameInWindow.minX,
            y: frameInWindow.maxY + 4,
            width: frameInWindow.width,
            height: min(250, CGFloat(checklistItems.count) * 44)
        )

        dropdownTable.frame = dropdownContainer.bounds
        dropdownContainer.addSubview(dropdownTable)

        window.addSubview(dropdownContainer)

        dropdownTable.reloadData()
    }

    @objc private func didTapBackground() {
        hideDropdown()
    }

    private func hideDropdown() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundDimView.alpha = 0
        }, completion: { _ in
            self.backgroundDimView.removeFromSuperview()
        })

        dropdownContainer.removeFromSuperview()
    }

    // MARK: - Table Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checklistItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "cell")

        let item = checklistItems[indexPath.row]

        cell.textLabel?.text = item
        cell.accessoryType = selectedItems.contains(item) ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = checklistItems[indexPath.row]

        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
        
        self.text = selectedItems.joined(separator: ", ")
        onSelectionChanged?(Array(selectedItems))

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc private func clearAllSelections() {
        selectedItems.removeAll()
        self.text = ""
        dropdownTable.reloadData()
        onSelectionChanged?([])
    }
}
*/
