//
//  TimeMatrixViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/6/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixViewController: UIViewController, TimeMatrixResolutionListener {
    @IBOutlet weak var resolutionSegmnetedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayManager = TimeMatrixDisplayManager.instance
        displayManager.resolutionListeners.insert(self)
        self.onChange(resolution: displayManager.resolution, previous: .fifteenMinutes)
    }
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        switch resolution {
        case .fifteenMinutes:
            self.resolutionSegmnetedControl.selectedSegmentIndex = 0
            break
            
        case .thirtyMinutes:
            self.resolutionSegmnetedControl.selectedSegmentIndex = 1
            break
            
        case .oneHour:
            self.resolutionSegmnetedControl.selectedSegmentIndex = 2
            break
            
        default:
            self.resolutionSegmnetedControl.selectedSegmentIndex = 3
            break
        }
    }
    
    @IBAction func resolutionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let displayManager = TimeMatrixDisplayManager.instance
        switch sender.selectedSegmentIndex {
        case 0:
            displayManager.resolution = .fifteenMinutes
            break
            
        case 1:
            displayManager.resolution = .thirtyMinutes
            break
            
        case 2:
            displayManager.resolution = .oneHour
            break
            
        default:
            displayManager.resolution = .twoHours
            break
        }
    }
}
