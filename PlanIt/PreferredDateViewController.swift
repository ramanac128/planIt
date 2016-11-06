//
//  PreferredDateViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/1/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class PreferredDateViewController: MSMessagesAppViewController, CalendarViewSizeListener, UITextFieldDelegate {
    
    enum Container {
        case calendar
        case startTime
        case endTime
    }
    
    var currentExpandedContainer = Container.calendar
    
    @IBOutlet weak var startTimeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endTimeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true
        CalendarViewDisplayManager.instance.sizeListeners.insert(self)
        
    }
    
    // Update Start Time Text Field
    @IBAction func startTimePickerUpdate(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none;
        timeFormatter.timeStyle = .short;
        startTime.text = timeFormatter.string(from: startTimePicker.date)
    }
    
    // Update End Time Text Field
    @IBAction func endTimePickerUpdate(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none;
        timeFormatter.timeStyle = .short;
        endTime.text = timeFormatter.string(from:
            endTimePicker.date)
    }
    
    func onChange(size: CalendarViewDisplayManager.ViewSize) {
        // if size is large - minimize other 2
        if (size == .large) {
            startTimeHeightConstraint.constant = 0
            endTimeHeightConstraint.constant = 0
            currentExpandedContainer = .calendar
        }
    }
    
    func onSizeAnimationChange() {
        self.view.layoutIfNeeded()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    @IBAction func textBoxClicked(_ sender: UITextField) {
        if (sender.tag == 1) {
            // Start Button
            if (currentExpandedContainer == .startTime) {
                // Previously opened start time, so now want to close the text
                startTimeHeightConstraint.constant = 0
                currentExpandedContainer = .calendar
                CalendarViewDisplayManager.instance.viewSize = .large
            }
            else {
                // Changing start time input
                startTimeHeightConstraint.constant = DateTimeViewController.expandedItemSize
                endTimeHeightConstraint.constant = 0
                
                currentExpandedContainer = .startTime
                CalendarViewDisplayManager.instance.viewSize = .small
                
                UIView.animate(withDuration: CalendarViewDisplayManager.sizeChangeAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        else {
            // End button (sender.tag == 2)
            if (currentExpandedContainer == .endTime) {
                // Previously opened end time, so now want to close the text
                endTimeHeightConstraint.constant = 0
                currentExpandedContainer = .calendar
                CalendarViewDisplayManager.instance.viewSize = .large
            }
            else {
                // Changing end time input
                endTimeHeightConstraint.constant = DateTimeViewController.expandedItemSize
                startTimeHeightConstraint.constant = 0
                
                currentExpandedContainer = .endTime
                CalendarViewDisplayManager.instance.viewSize = .small
                
                UIView.animate(withDuration: CalendarViewDisplayManager.sizeChangeAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
