//
//  UnderlinedView.swift
//  CodeInputView
//
//  Created by Milos Dimic on 9/21/18.
//  Copyright © 2018 Milos Dimic. All rights reserved.
//

import UIKit

class UnderlinedView: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var labelMain: UILabel!
    @IBOutlet weak var viewUnderline: UIView!
    
    // MARK: - Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public Methods
    
    func setUnderline(toColor color: UIColor) {
        viewUnderline.backgroundColor = color
    }
    
    func setField(text: String) {
        labelMain.text = text
    }
}
