//
//  PreferredDateViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/1/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class PreferredDateViewController: MSMessagesAppViewController, TimeMatrixModelListener, CalendarViewSizeListener, UITextFieldDelegate {
    
    enum Container {
        case calendar
        case startTime
        case endTime
    }
    @IBOutlet weak var startTimeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endTimeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    var model: TimeMatrixModel?
    
    var timeFormatter = DateFormatter()
    
    var currentExpandedContainer = Container.calendar
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeFormatter.dateStyle = .none;
        self.timeFormatter.timeStyle = .short;
        
        self.automaticallyAdjustsScrollViewInsets = true
        CalendarViewDisplayManager.instance.sizeListeners.insert(self)
        
        let modelManager = TimeMatrixModelManager.instance
        modelManager.modelListeners.insert(self)
        self.onChange(model: modelManager.model)
    }
    
    // Update Start Time Text Field
    @IBAction func startTimePickerUpdate(_ sender: UIDatePicker) {
        startTime.text = timeFormatter.string(from: startTimePicker.date)
        self.model?.preferredStartTime = TimeMatrixTime(date: startTimePicker.date)
    }
    
    // Update End Time Text Field
    @IBAction func endTimePickerUpdate(_ sender: UIDatePicker) {
        endTime.text = timeFormatter.string(from: endTimePicker.date)
        self.model?.preferredEndTime = TimeMatrixTime(date: endTimePicker.date)
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
                self.startTimePickerUpdate(self.startTimePicker)
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
                self.endTimePickerUpdate(self.endTimePicker)
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
    
    func onChange(model: TimeMatrixModel?) {
        self.model = model
    }
}
