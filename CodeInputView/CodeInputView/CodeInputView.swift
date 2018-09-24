//
//  CodeInputView.swift
//  CodeInputView
//
//  Created by Milos Dimic on 9/24/18.
//  Copyright © 2018 Milos Dimic. All rights reserved.
//

protocol CodeInputViewDelegate: class {
    func codeInputView(_ codeInputView: CodeInputView, didChangeFieldsOccupancyToStatus occupancyStatus: CodeInputView.OccupancyStatus)
}

import UIKit

class CodeInputView: UIView {
    
    enum OccupancyStatus {
        case allFull
        case allEmpty
        case partiallyFull
    }
    
    // MARK: - Class methods
    
    static func initialize(numberOfFields: Int, fieldSpacing: CGFloat, keyboardType: UIKeyboardType, autocapitalizationType: UITextAutocapitalizationType) -> CodeInputView {
        let codeInputView = Bundle.main.loadNibNamed("CodeInputView", owner: self, options: nil)?.first as! CodeInputView
        codeInputView.numberOfFields = numberOfFields
        codeInputView.fieldSpacing = fieldSpacing
        codeInputView.keyboardType = keyboardType
        codeInputView.autocapitalizationType = autocapitalizationType
        
        codeInputView.createInputFields()
        codeInputView.setupView()
        codeInputView.setupGestureRecognizers()
        return codeInputView
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var stackViewMain: UIStackView!
    
    private let pasteboard = UIPasteboard.general
    private var numberOfFields: Int = 0
    private var fieldSpacing: CGFloat = 0
    
    // MARK: - UITextInputTraits
    
    var autocorrectionType: UITextAutocorrectionType = .no
    var keyboardType: UIKeyboardType = .default
    var autocapitalizationType: UITextAutocapitalizationType = .allCharacters
    
    weak var delegate: CodeInputViewDelegate?
    
    // MARK: - Computed properties
    
    var text: String {
        get {
            return returnUnderlinedViews(fromArrayOfViews: stackViewMain.arrangedSubviews)?.map({ $0.labelMain.text! as String }).joined() ?? ""
        }
        set {
            clearAllFields()
            
            for (index, character) in newValue.prefix(stackViewMain.arrangedSubviews.count).enumerated() {
                if let underlinedView = stackViewMain.arrangedSubviews[index] as? UnderlinedView {
                    underlinedView.setField(text: String(character))
                }
            }
            delegate?.codeInputView(self, didChangeFieldsOccupancyToStatus: checkOccupancy(forFields: stackViewMain.arrangedSubviews))
        }
    }
    
    var occupancyStatus: OccupancyStatus {
        return checkOccupancy(forFields: stackViewMain.arrangedSubviews)
    }
    
    // MARK: - Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Override methods
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(pasteString) || action == #selector(resignFirstResponder)
    }
    
    // MARK: - Gesture Handlers
    
    private func setupGestureRecognizers() {
        stackViewMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stackViewTapped)))
        stackViewMain.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(stackViewLongPressed)))
    }
    
    // MARK: - Public methods
    
    func changeUnderlineFillColor(toColor color: UIColor) {
        stackViewMain.arrangedSubviews.forEach({ ($0 as? UnderlinedView)?.setUnderline(toColor: color) })
    }
    
    func startInput() {
        becomeFirstResponder()
    }
    
    // MARK: - Private methods
    
    private func add(text: String) {
        if let label = returnFirstAvailableLabel(whichIsEmpty: true) {
            label.text = text
            delegate?.codeInputView(self, didChangeFieldsOccupancyToStatus: checkOccupancy(forFields: stackViewMain.arrangedSubviews))
        }
    }
    
    private func clearLastText() {
        if let label = returnFirstAvailableLabel(whichIsEmpty: false) {
            label.text = ""
            delegate?.codeInputView(self, didChangeFieldsOccupancyToStatus: checkOccupancy(forFields: stackViewMain.arrangedSubviews))
        }
    }
    
    private func createInputFields() {
        for _ in 0..<numberOfFields {
            let underlinedView = Bundle.main.loadNibNamed("UnderlinedView", owner: self, options: nil)?.first as! UnderlinedView
            stackViewMain.addArrangedSubview(underlinedView)
        }
    }
    
    private func setupView() {
        stackViewMain.spacing = fieldSpacing
    }
    
    private func showPastePopOverMenu() {
        guard !UIMenuController.shared.isMenuVisible else { return }
        UIMenuController.shared.setTargetRect(stackViewMain.frame, in: self)
        UIMenuController.shared.menuItems = [UIMenuItem(title: NSLocalizedString("Paste", comment: ""), action: #selector(pasteString))]
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    private func returnFirstAvailableLabel(whichIsEmpty isEmpty: Bool) -> UILabel? {
        var arrangedSubviews = stackViewMain.arrangedSubviews
        if !isEmpty {
            arrangedSubviews = arrangedSubviews.reversed()
        }
        
        if let underlinedViews = returnUnderlinedViews(fromArrayOfViews: arrangedSubviews) {
            for underlinedView in underlinedViews {
                if let label = returnFirstLabel(fromArrayOfViews: underlinedView.subviews, whichIsEmpty: isEmpty) {
                    return label
                }
            }
        }
        return nil
    }
    
    private func returnUnderlinedViews(fromArrayOfViews views: [UIView]) -> [UnderlinedView]? {
        return (views.filter { ($0 is UnderlinedView) }) as? [UnderlinedView]
    }
    
    private func returnFirstLabel(fromArrayOfViews views: [UIView], whichIsEmpty isEmpty: Bool) -> UILabel? {
        let label = views.first { (view) -> Bool in
            view is UILabel && ((view as! UILabel).text == "") == isEmpty
        }
        
        if let label = label as? UILabel {
            return label
        } else {
            return nil
        }
    }
    
    private func clearAllFields() {
        returnUnderlinedViews(fromArrayOfViews: stackViewMain.arrangedSubviews)?.filter { !($0.labelMain.text == "") }.forEach { $0.labelMain.text = "" }
    }
    
    private func checkOccupancy(forFields textFields: [UIView]) -> OccupancyStatus {
        let populatedFields = returnUnderlinedViews(fromArrayOfViews: stackViewMain.arrangedSubviews)?.filter { !($0.labelMain.text == "") } ?? []
        
        if populatedFields.count == numberOfFields {
            return OccupancyStatus.allFull
        } else if populatedFields.count == 0 {
            return OccupancyStatus.allEmpty
        } else {
            return OccupancyStatus.partiallyFull
        }
    }
    
    // MARK: - Action methods
    
    @objc private func stackViewTapped() {
        self.becomeFirstResponder()
    }
    
    @objc private func stackViewLongPressed() {
        showPastePopOverMenu()
    }
    
    @objc private func pasteString() {
        if let pastedString = pasteboard.string {
            text = pastedString
        }
    }
}

// MARK: - UIKeyInput

extension CodeInputView: UIKeyInput {
    
    var hasText: Bool {
        return true
    }
    
    func insertText(_ text: String) {
        add(text: text)
    }
    
    func deleteBackward() {
        clearLastText()
    }
}
