//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Richmond Starbuck on 10/5/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    @IBOutlet weak var timeMatrixView: TimeMatrixView!
    
    let model1 = TimeMatrixModel()
    let model2 = TimeMatrixModel()
    var currentModel: TimeMatrixModel!
    
    var days = [TimeMatrixDay]()
    var daySelections = [Bool]()
    
    @IBAction func planMeeting(_ sender: UIButton) {
        performSegue(withIdentifier: "nextPage", sender: self)
        requestPresentationStyle(.expanded)
        
    }
    override func viewDidLoad() {
        self.currentModel = self.model1
        super.viewDidLoad()
        
        let calendar = Calendar.current
        let today = Date()
        for index in 1...5 {
            let date = calendar.date(byAdding: .day, value: index, to: today)
            days.append(TimeMatrixDay(date: date!))
            daySelections.append(false)
        }
        
        
        // TODO: delete this
//        let model = TimeMatrixModel()
//        let calendar = Calendar.current
//        model.add(day: TimeMatrixDay(date: Date()))
//        model.add(day: TimeMatrixDay(date: calendar.date(byAdding: .day, value: 1, to: Date())!))
//        model.add(day: TimeMatrixDay(date: calendar.date(byAdding: .day, value: 2, to: Date())!))
//        model.add(day: TimeMatrixDay(date: calendar.date(byAdding: .day, value: 4, to: Date())!))
//        self.timeMatrixScrollView.model = model

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    func onDay(_ n: Int) {
        let index = n - 1
        let day = self.days[index]
        if self.daySelections[index] {
            self.currentModel.remove(day: day)
        }
        else {
            self.currentModel.add(day: day)
        }
        self.daySelections[index] = !self.daySelections[index]
    }

    @IBAction func onModel1(_ sender: AnyObject) {
        self.currentModel = self.model1
        self.timeMatrixView.model = self.currentModel
    }
    
    @IBAction func onModel2(_ sender: AnyObject) {
        self.currentModel = self.model2
        self.timeMatrixView.model = self.currentModel
    }
    
    @IBAction func onDay1(_ sender: AnyObject) {
        self.onDay(1)
    }
    
    @IBAction func onDay2(_ sender: AnyObject) {
        self.onDay(2)
    }
    
    @IBAction func onDay3(_ sender: AnyObject) {
        self.onDay(3)
    }
    
    @IBAction func onDay4(_ sender: AnyObject) {
        self.onDay(4)
    }
    
    @IBAction func onDay5(_ sender: AnyObject) {
        self.onDay(5)
    }
    
    @IBAction func onStandardTime(_ sender: AnyObject) {
        TimeMatrixDisplayManager.instance.timeFormat = .standard
    }
    
    @IBAction func onMilitaryTime(_ sender: AnyObject) {
        TimeMatrixDisplayManager.instance.timeFormat = .military
    }
    
    @IBAction func on15min(_ sender: AnyObject) {
        TimeMatrixDisplayManager.instance.resolution = .fifteenMinutes
    }
    
    @IBAction func on30min(_ sender: AnyObject) {
        TimeMatrixDisplayManager.instance.resolution = .thirtyMinutes
    }
    
    @IBAction func on1hr(_ sender: AnyObject) {
        TimeMatrixDisplayManager.instance.resolution = .oneHour
    }
    
    @IBAction func on2hr(_ sender: AnyObject) {
        TimeMatrixDisplayManager.instance.resolution = .twoHours
    }
}
