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

class DateTimeViewController: MSMessagesAppViewController, TimeMatrixModelPreferredDayListener, TimeMatrixModelPreferredTimeListener, CalendarViewSizeListener {
    static let expandedItemSize = CGFloat(140)
    static let calendarContainerLargeSize = CGFloat(300)
    static let calendarContainerSmallSize = DateTimeViewController.calendarContainerLargeSize - DateTimeViewController.expandedItemSize
    
    static let nextButtonBackgroundColorEnabled = UIColor(hex: 0x3399FF)
    static let nextButtonBackgroundColorDisabled = UIColor.lightGray
    
    static let containerViewTransitionAnimationDuration = 0.75
    
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var availabilityContainer: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var calendarViewContainerHeightConstraint: NSLayoutConstraint!
    
    var currentTimeView = timeView.preferred
    
    var model = TimeMatrixModel()
    
    var hasSetPreferredDay = false
    var hasSetPreferredStartTime = false
    var hasSetPreferredEndTime = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: bring model in correctly
        TimeMatrixModelManager.instance.model = self.model
        
        self.model.preferredDayListeners.insert(self)
        self.onChange(preferredDay: self.model.preferredDay)
        
        self.model.preferredTimeListeners.insert(self)
        self.onChange(startTime: self.model.preferredStartTime)
        self.onChange(startTime: self.model.preferredEndTime)
        
        let calendarViewManager = CalendarViewDisplayManager.instance
        calendarViewManager.sizeListeners.insert(self)
        self.onChange(size: calendarViewManager.viewSize)
        
        self.showPreferredTime()
    }
    
    func onChange(size: CalendarViewDisplayManager.ViewSize) {
        switch size {
        case .small:
            self.calendarViewContainerHeightConstraint.constant = DateTimeViewController.calendarContainerSmallSize
            break
            
        case .large:
            self.calendarViewContainerHeightConstraint.constant = DateTimeViewController.calendarContainerLargeSize
            break
        }
    }
    
    func onSizeAnimationChange() {
        self.view.layoutIfNeeded()
    }
    
    @IBAction func backButtonTouch(_ sender: UIButton) {
        switch currentTimeView {
        case .preferred:
            let presentingViewController: UIViewController! = self.presentingViewController
            self.dismiss(animated: true) {
                presentingViewController.dismiss(animated: true)
            }
            break
            
        case .available:
            self.model.removeAllDays()
            self.showPreferredTime()
            break
        }
    }
    
    @IBAction func nextButtonTouch(_ sender: UIButton) {
        switch currentTimeView {
        case .preferred:
            self.showTimeMatrix()
            break
            
        case .available:
            ConversationManager.instance.sendInviteMessage(dateTime: self.model)
        }
        self.showTimeMatrix()
    }
    
    func showPreferredTime() {
        self.currentTimeView = .preferred
        self.backButton.setTitle("Cancel", for: .normal)
        self.nextButton.setTitle("Set Availability", for: .normal)
        
        UIView.animate(withDuration: DateTimeViewController.containerViewTransitionAnimationDuration) {
            self.timeContainer.alpha = 1
            self.availabilityContainer.alpha = 0
        }
        
        let calendarViewManager = CalendarViewDisplayManager.instance
        calendarViewManager.viewSize = .large
        calendarViewManager.configuration = .preferredDate
    }
    
    func showTimeMatrix() {
        self.currentTimeView = .available
        self.backButton.setTitle("Back", for: .normal)
        self.nextButton.setTitle("Create Invite", for: .normal)
        
        self.model.buildFromPreferredTimes()
        TimeMatrixDisplayManager.instance.informWillDisplay()
        
        UIView.animate(withDuration: DateTimeViewController.containerViewTransitionAnimationDuration) {
            self.timeContainer.alpha = 0
            self.availabilityContainer.alpha = 1
        }
        
        let calendarViewManager = CalendarViewDisplayManager.instance
        calendarViewManager.viewSize = .small
        calendarViewManager.configuration = .availableDates
        
        TutorialModalViewController.tutorialSenderDateTime.display(in: self)
    }
    
    func onChange(preferredDay: TimeMatrixDay?) {
        self.hasSetPreferredDay = (preferredDay != nil)
        self.checkIfPreferredDateTimeIsSet()
    }
    
    func onChange(startTime: TimeMatrixTime?) {
        self.hasSetPreferredStartTime = (startTime != nil)
        self.checkIfPreferredDateTimeIsSet()
    }
    
    func onChange(endTime: TimeMatrixTime?) {
        self.hasSetPreferredEndTime = (endTime != nil)
        self.checkIfPreferredDateTimeIsSet()
    }
    
    func checkIfPreferredDateTimeIsSet() {
        if self.hasSetPreferredDay && self.hasSetPreferredStartTime && self.hasSetPreferredEndTime {
            self.nextButton.isEnabled = true
            self.nextButton.backgroundColor = DateTimeViewController.nextButtonBackgroundColorEnabled
        }
        else {
            self.nextButton.isEnabled = false
            self.nextButton.backgroundColor = DateTimeViewController.nextButtonBackgroundColorDisabled
        }
    }
}
