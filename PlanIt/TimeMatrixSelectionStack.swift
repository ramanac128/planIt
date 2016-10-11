//
//  TimeMatrixSelectionStack.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionStack: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.alignment = .fill
        self.distribution = .fillEqually
        self.axis = .vertical
    }
    
    var day: TimeMatrixDay?
    
    func from(cellModels: [TimeMatrixCellModel], forDay: TimeMatrixDay) {
        day = forDay
        for cellModel in cellModels {
            let selectionCell = TimeMatrixSelectionCell()
            cellModel.add(stateListener: selectionCell)
            self.addArrangedSubview(selectionCell)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
