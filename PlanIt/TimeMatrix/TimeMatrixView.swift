//
//  TimeMatrixView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/14/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixView: UIStackView {
    
    // MARK: - Subviews
    
    weak var scrollView: TimeMatrixScrollView!
    weak var labelRow: TimeMatrixDayLabelRow!
    
    
    // MARK: - Properties
    
    var model: TimeMatrixModel? {
        didSet {
            if oldValue !== self.model {
                if let model = self.model {
                    self.scrollView?.model = model
                    self.labelRow?.model = model
                }
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.alignment = .fill
        self.distribution = .fill
        self.spacing = 0
        self.axis = .vertical
        
        let scrollView = TimeMatrixScrollView()
        let labelRow = TimeMatrixDayLabelRow()
        
        self.scrollView = scrollView
        self.labelRow = labelRow
        self.addArrangedSubview(labelRow)
        self.addArrangedSubview(scrollView)
    }
}
