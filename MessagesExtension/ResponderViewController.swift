//
//  ResponderViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/11/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class ResponderViewController: MSMessagesAppViewController {

    var didLayoutSubviews = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.didLayoutSubviews {
            self.didLayoutSubviews = true
            TutorialModalViewController.tutorialResponderDateTime.display(in: self)
        }
    }
    
    @IBAction func notAvailableTouch(_ sender: Any) {
        //ConversationManager.instance.dismissMessagesApp()
    }
    
    @IBAction func sendResponseTouch(_ sender: Any) {
        //ConversationManager.instance.dismissMessagesApp()
    }
    
}
