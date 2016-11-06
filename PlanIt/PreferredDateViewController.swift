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
    
    func onChange(size: CalendarViewDisplayManager.ViewSize) {
        
        // if size is large - minimize other 2 
        if (size == .large) {
            startTimeHeightConstraint.constant = 0
            endTimeHeightConstraint.constant = 0
        }
    }
    
    func onSizeAnimationChange() {
        self.view.layoutIfNeeded()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    var currentExpandedContainer = Container.calendar
    
    @IBOutlet weak var startTimeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endTimeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
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
    
    @IBAction func textBoxClicked(_ sender: UITextField) {
       
        if (currentExpandedContainer == .calendar) {
            CalendarViewDisplayManager.instance.viewSize = .large
        }
        
        // Start Button
        if (sender.tag == 1) {
            endTimeHeightConstraint.constant = 0
            
            // Previously opened start time, so now want to close the text
            if (currentExpandedContainer == .startTime) {
                startTimeHeightConstraint.constant = 0
                currentExpandedContainer = .calendar
                CalendarViewDisplayManager.instance.viewSize = .small
            }
                
            // Changing start time input
            else {
                startTimeHeightConstraint.constant = DateTimeViewController.expandedItemSize
                currentExpandedContainer = .startTime
            }
        }
            
        // End button (sender.tag == 2)
        else {
            startTimeHeightConstraint.constant = 0
            
            // Previously opened end time, so now want to close the text
            if (currentExpandedContainer == .endTime) {
                endTimeHeightConstraint.constant = 0
                currentExpandedContainer = .calendar
                CalendarViewDisplayManager.instance.viewSize = .small
            }
                
            // Changing end time input
            else {
                endTimeHeightConstraint.constant = DateTimeViewController.expandedItemSize
                currentExpandedContainer = .endTime
            }
        }
        
        UIView.animate(withDuration: 0.75) {
            self.view.layoutIfNeeded()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    
    func startTimeEditing() {
        let currTime = Calendar.current
        let d = currTime.date(bySettingHour: 4, minute: 0, second: 0, of: Date())
        startDatePicker.setDate(d!, animated: false)
        startDatePicker.minuteInterval = 15
        
        startDatePicker.backgroundColor = UIColor.white
        startDatePicker.datePickerMode = UIDatePickerMode.time
        startTime.inputView = startDatePicker
        
        // Intialize tool bar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Tool bar buttons
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: "doneStartClick")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: "cancelStartClick")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        startTime.inputAccessoryView = toolBar
    }
    
    func endTimeEditing() {
        //endDatePicker.minuteInterval = 15
        endDatePicker.backgroundColor = UIColor.white
        endDatePicker.datePickerMode = UIDatePickerMode.time
        endTime.inputView = endDatePicker
        
        // Intialize tool bar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Tool bar buttons
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: "doneEndClick")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: "cancelEndClick")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        endTime.inputAccessoryView = toolBar
    }
    
    func doneStartClick() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none;
        timeFormatter.timeStyle = .short;
        startTime.text = timeFormatter.string(from: startDatePicker.date)
        startTime.resignFirstResponder()
    }
    
    func doneEndClick() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none;
        timeFormatter.timeStyle = .short;
        endTime.text = timeFormatter.string(from: endDatePicker.date)
        endTime.resignFirstResponder()
    }
    
    func cancelStartClick() {
        startTime.resignFirstResponder()
    }
    
    func cancelEndClick() {
        endTime.resignFirstResponder()
    }

}
