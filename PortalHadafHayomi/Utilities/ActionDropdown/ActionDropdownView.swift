//
//  ActionDropdownView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 05/11/2025.
//  Copyright © 2025 Binyamin Trachtman. All rights reserved.
//

import UIKit

struct ActionItem {
    let key: String
    let title: String
    let image: UIImage?
    let onTap: (() -> Void)?
    let subActions: [ActionItem]?
    
    init(key: String, title: String, image: UIImage? = nil, subActions: [ActionItem]? = nil, onTap: (() -> Void)? = nil) {
        self.key = key
        self.title = title
        self.image = image
        self.subActions = subActions
        self.onTap = onTap
    }
}

final class ActionDropdownView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private var actions: [ActionItem]
    private let tableView = UITableView()
    private let backgroundView = UIView()
    private let cellHeight: CGFloat = 44
    private weak var parentView: UIView?
    private var expandedIndex: Int? = nil
    
    init(actions: [ActionItem]) {
        self.actions = actions
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupViews() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundView.addGestureRecognizer(tap)
        
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = .zero
        tableView.register(ActionCell.self, forCellReuseIdentifier: "cell")
        
        addSubview(tableView)
    }
    
    func show(relativeTo anchorView: UIView) {
        guard let window = anchorView.window else { return }
        parentView = window
        
        backgroundView.frame = window.bounds
        window.addSubview(backgroundView)
        
        let anchorFrame = anchorView.convert(anchorView.bounds, to: window)
        let width: CGFloat = 220
        let height: CGFloat = CGFloat(totalVisibleActions()) * cellHeight
        let originX = anchorFrame.midX - width / 2
        let originY = anchorFrame.maxY + 4
        
        frame = CGRect(x: originX, y: originY, width: width, height: height)
        tableView.frame = bounds
        window.addSubview(self)
        
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    private func totalVisibleActions() -> Int {
        var count = actions.count
        if let expandedIndex = expandedIndex {
            count += actions[expandedIndex].subActions?.count ?? 0
        }
        return count
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.backgroundView.alpha = 0
        }) { _ in
            self.backgroundView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Table
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        totalVisibleActions()
    }
    
    private func actionForRow(_ row: Int) -> (ActionItem, Bool) {
        if let expanded = expandedIndex {
            if row <= expanded { return (actions[row], false) }
            let subActions = actions[expanded].subActions ?? []
            if row <= expanded + subActions.count {
                let index = row - expanded - 1
                return (subActions[index], true)
            }
            let index = row - subActions.count
            return (actions[index], false)
        } else {
            return (actions[row], false)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (action, isSub) = actionForRow(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActionCell
        cell.configure(with: action, isSubAction: isSub)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (action, isSub) = actionForRow(indexPath.row)
        
        if isSub {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                action.onTap?()
            }
            return
        }
        
        if let subActions = action.subActions, !subActions.isEmpty {
            toggleExpand(at: indexPath.row)
        } else {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                action.onTap?()
            }
        }
    }
    
    private func toggleExpand(at index: Int) {
        tableView.beginUpdates()

        if let expanded = expandedIndex {
            // 1️⃣ Collapse existing expanded section
            if let subActions = actions[expanded].subActions {
                let start = expanded + 1
                let end = start + subActions.count
                let indexPaths = (start..<end).map { IndexPath(row: $0, section: 0) }
                expandedIndex = nil
                tableView.deleteRows(at: indexPaths, with: .fade)
            }

            // If user tapped the *same* expanded cell — stop here (collapse only)
            if expanded == index {
                tableView.endUpdates()
                animateHeightChange()
                return
            }
        }

        // 2️⃣ Expand new section
        if let subActions = actions[index].subActions, !subActions.isEmpty {
            expandedIndex = index
            let start = index + 1
            let end = start + subActions.count
            let indexPaths = (start..<end).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .fade)
        }

        tableView.endUpdates()
        animateHeightChange()
    }
    
    // Helper: smoothly animates the dropdown view height when expanding/collapsing
    private func animateHeightChange() {
        let newHeight = CGFloat(totalVisibleActions()) * cellHeight
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            var frame = self.frame
            frame.size.height = newHeight
            self.frame = frame
            self.tableView.frame = self.bounds
        }
    }
}

// MARK: - Custom Cell

final class ActionCell: UITableViewCell {
    
    private let arrowView = UIImageView()
    private let titleLabel = UILabel()
    private let iconView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        // Arrow (left)
        arrowView.contentMode = .scaleAspectFit
        arrowView.image = UIImage(systemName: "chevron.right")
        arrowView.tintColor = .gray
        
        // Title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        // Icon (right)
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        
        contentView.addSubview(arrowView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 12
        let iconSize: CGFloat = 26
        
        arrowView.frame = CGRect(x: padding,
                                 y: (bounds.height - 16) / 2,
                                 width: 12,
                                 height: 16)
        
        iconView.frame = CGRect(x: bounds.width - padding - iconSize,
                                y: (bounds.height - iconSize) / 2,
                                width: iconSize,
                                height: iconSize)
        
        let titleLeft = arrowView.isHidden ? padding : arrowView.frame.maxX + 10
        let titleRight = iconView.frame.minX - 10
        titleLabel.frame = CGRect(x: titleLeft,
                                  y: 0,
                                  width: titleRight - titleLeft,
                                  height: bounds.height)
    }
    
    func configure(with action: ActionItem, isSubAction: Bool) {
        titleLabel.text = action.title
        iconView.image = action.image
        arrowView.isHidden = (action.subActions?.isEmpty ?? true)
        
        if isSubAction {
            contentView.backgroundColor = UIColor.systemGray6
            titleLabel.frame.origin.x += 15
            arrowView.isHidden = true // sub actions don't have arrow
        } else {
            contentView.backgroundColor = .white
        }
    }
    
    // Optional: smooth arrow rotation (you can call this from expand/collapse)
    func setExpanded(_ expanded: Bool, animated: Bool) {
        guard !arrowView.isHidden else { return }
        let rotationAngle: CGFloat = expanded ? .pi / 2 : 0
        let duration: TimeInterval = animated ? 3 : 0
        UIView.animate(withDuration: duration) {
            self.arrowView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
}
