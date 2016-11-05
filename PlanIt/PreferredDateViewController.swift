//
//  PreferredDateViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/1/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class PreferredDateViewController: MSMessagesAppViewController {
    
    
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    

     func startTimeEditing() {
        startDatePicker.minuteInterval = 15
        let currTime = Calendar.current
        let d = currTime.date(bySettingHour: 4, minute: 0, second: 0, of: Date())
        startDatePicker.setDate(d!, animated: false)
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker.minuteInterval = 15
        endDatePicker.minuteInterval = 15
        startTimeEditing()
        endTimeEditing()


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

}
