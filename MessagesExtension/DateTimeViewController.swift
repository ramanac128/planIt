//
//  DateTimeViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/5/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

enum timeView {
    case preferred, available
}

class DateTimeViewController: MSMessagesAppViewController, TimeMatrixModelDayListener {
    static let expandedItemSize = CGFloat(140)
    static let calendarContainerLargeSize = CGFloat(300)
    static let calendarContainerSmallSize = DateTimeViewController.calendarContainerLargeSize - DateTimeViewController.expandedItemSize
    
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var timeMatrixContainer: UIView!
        
    static let nextButtonBackgroundColorEnabled = UIColor(hex: 0x3399FF)
    static let nextButtonBackgroundColorDisabled = UIColor.lightGray
    
    static let containerViewTransitionAnimationDuration = 0.75
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var currentTimeView = timeView.preferred
    
    var model = TimeMatrixModel()
    
    var hasSetPreferredDay = false
    var hasSetPreferredStartTime = false
    var hasSetPreferredEndTime = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: bring model in correctly
        TimeMatrixModelManager.instance.model = self.model
        
        self.model.dayListeners.insert(self);
        
        let calendarViewManager = CalendarViewDisplayManager.instance
        calendarViewManager.viewSize = .large
        calendarViewManager.configuration = .availableDates
        
        self.showCalendarView()
    }
    
    func onSizeAnimationChange() {
        self.view.layoutIfNeeded()
    }
    
    @IBAction func backButtonTouch(_ sender: UIButton) {
        switch currentTimeView {
        case .preferred:
            ConversationManager.instance.dismissMessagesApp()
            break
            
        case .available:
            self.showCalendarView()
            break
        }
    }
    
    @IBAction func nextButtonTouch(_ sender: UIButton) {
        switch currentTimeView {
        case .preferred:
            self.showTimeMatrix()
            break
            
        case .available:
            let conversationManager = ConversationManager.instance
            conversationManager.sendInviteMessage(dateTime: self.model)
            conversationManager.dismissMessagesApp()
            break
        }
    }
    
    func showCalendarView() {
        self.currentTimeView = .preferred
        self.backButton.setTitle("Cancel", for: .normal)
        self.nextButton.setTitle("Next", for: .normal)
        
        UIView.animate(withDuration: DateTimeViewController.containerViewTransitionAnimationDuration) {
            self.calendarContainer.alpha = 1
            self.timeMatrixContainer.alpha = 0
        }
    }
    
    func showTimeMatrix() {
        self.currentTimeView = .available
        self.backButton.setTitle("Back", for: .normal)
        self.nextButton.setTitle("Send Invite", for: .normal)
        
        self.model.buildFromPreferredTimes()
        TimeMatrixDisplayManager.instance.informWillDisplay()
        
        UIView.animate(withDuration: DateTimeViewController.containerViewTransitionAnimationDuration) {
            self.calendarContainer.alpha = 0
            self.timeMatrixContainer.alpha = 1
        }
    }
    
    func checkIfDaysAreSet() {
        if self.model.days.count > 0 {
            self.nextButton.isEnabled = true
            self.nextButton.backgroundColor = DateTimeViewController.nextButtonBackgroundColorEnabled
        }
        else {
            self.nextButton.isEnabled = false
            self.nextButton.backgroundColor = DateTimeViewController.nextButtonBackgroundColorDisabled
        }
    }
    
    
    // MARK: - TimeMatrixModelDayListener protocol methods
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) {
        self.checkIfDaysAreSet()
    }
    
    func onRemoved(day: TimeMatrixDay) {
        self.checkIfDaysAreSet()
    }
}
