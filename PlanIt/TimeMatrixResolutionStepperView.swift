//
//  TimeMatrixResolutionStepperView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/6/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixResolutionStepperView: UIStackView, TimeMatrixResolutionListener {

    weak var stepper: UIStepper!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.alignment = .center
        self.distribution = .fill
        self.spacing = 0
        self.axis = .vertical
        
        let stepper = UIStepper()
        stepper.wraps = false
        stepper.autorepeat = false
        stepper.isContinuous = false
        stepper.minimumValue = 2
        stepper.maximumValue = 5
        stepper.addTarget(self, action: #selector(stepperValueChanged(sender:)), for: .valueChanged)
        
        self.addArrangedSubview(stepper)
        self.stepper = stepper
        
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        self.addConstraint(height)
        
        let displayManager = TimeMatrixDisplayManager.instance
        displayManager.resolutionListeners.insert(self)
        self.onChange(resolution: displayManager.resolution, previous: .fifteenMinutes)
    }
    
    func stepperValueChanged(sender: UIStepper!) {
        TimeMatrixDisplayManager.instance.resolution = self.resolutionFrom(stepperValue: sender.value)
    }
    
    
    func stepperValueFrom(resolution: TimeMatrixDisplayManager.Resolution) -> Double {
        switch resolution {
        case .fifteenMinutes: return 5
        case .thirtyMinutes: return 4
        case .oneHour: return 3
        case .twoHours: return 2
        case .fourHours: return 1
        case .eightHours: return 0
        }
    }
    
    func resolutionFrom(stepperValue: Double) -> TimeMatrixDisplayManager.Resolution {
        switch stepperValue {
        case 5: return .fifteenMinutes
        case 4: return .thirtyMinutes
        case 3: return .oneHour
        case 2: return .twoHours
        default: return .thirtyMinutes
        }
    }
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        self.stepper.value = self.stepperValueFrom(resolution: resolution)
    }
}
