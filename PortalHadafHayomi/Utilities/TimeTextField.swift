//
//  TimeTextField.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 24/12/2025.
//  Copyright © 2025 Binyamin Trachtman. All rights reserved.
//

import UIKit

final class TimeTextField: UITextField {
//let selectedLanguage =  UserDefaults.standard.object(forKey: "selectedLanguage") as? String ?? "language_he_IL"
    // MARK: - Public configuration

    var timeFormat: String = "h:mm a" {
        didSet { updateText() }
    }

    /// nil = no selection
    var selectedDate: Date? {
        didSet {
            updateText()
            updateClearButtonVisibility()
        }
    }

    var defaultPickerDate: Date = Date()

    // MARK: - Private properties

    private let timePicker = UIDatePicker()

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        return f
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {
        setupPicker()
        setupToolbar()
        setupClearButton()
        updateText()
    }

    private func setupPicker() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        inputView = timePicker
    }

    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let clear = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )

        let flex = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )

        toolbar.items = [clear, flex, done]
        inputAccessoryView = toolbar
    }

    private func setupClearButton() {
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        rightView = clearButton
        rightViewMode = .always
        updateClearButtonVisibility()
    }

    // MARK: - UIResponder

    override func becomeFirstResponder() -> Bool {
        timePicker.date = selectedDate ?? defaultPickerDate
        return super.becomeFirstResponder()
    }

    // MARK: - Actions

    @objc private func timeChanged() {
        selectedDate = timePicker.date
    }

    @objc private func clearTapped() {
        selectedDate = nil
        resignFirstResponder()
    }

    @objc private func doneTapped() {
        if selectedDate == nil {
            selectedDate = timePicker.date
        }
        resignFirstResponder()
    }

    // MARK: - Helpers

    private func updateText() {
        formatter.dateFormat = timeFormat

        if let date = selectedDate {
            formatter.timeStyle = .short
                  formatter.dateStyle = .none
                  text = formatter.string(from: date)
        } else {
            text = nil // placeholder visible
        }
    }

    private func updateClearButtonVisibility() {
        clearButton.isHidden = (selectedDate == nil)
    }
}

