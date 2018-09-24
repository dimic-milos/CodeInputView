//
//  MainViewController.swift
//  CodeInputView
//
//  Created by Milos Dimic on 9/21/18.
//  Copyright © 2018 Milos Dimic. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var viewContainer: UIView!
    private var codeInputView: CodeInputView!
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCodeInputView()
    }

    
    // MARK: - Private methods
    
    private func setupCodeInputView() {
        codeInputView = CodeInputView.initialize(numberOfFields: 6, fieldSpacing: 20, keyboardType: .default, autocapitalizationType: .allCharacters)
        codeInputView.delegate = self
        codeInputView.frame = viewContainer.bounds
        viewContainer.addSubview(codeInputView)
    }
}

// MARK: - CodeInputViewDelegate

extension MainViewController: CodeInputViewDelegate {
    func codeInputView(_ codeInputView: CodeInputView, didChangeFieldsOccupancyToStatus occupancyStatus: CodeInputView.OccupancyStatus) {
        switch occupancyStatus {
        case .allFull:
            break
        case .allEmpty:
            break
        case .partiallyFull:
            break
        }
    }
}

