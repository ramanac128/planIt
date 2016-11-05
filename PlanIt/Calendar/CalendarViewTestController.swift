//
//  CalendarViewTestController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/4/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class CalendarViewTestController: MSMessagesAppViewController {
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeMatrixView: TimeMatrixView!
    
    var model = TimeMatrixModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        CalendarViewDisplayManager.instance.model = model
        //timeMatrixView.model = model
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func preferredTouch(_ sender: UIButton) {
        CalendarViewDisplayManager.instance.configuration = .preferredDate
        self.calendarViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func availableTouch(_ sender: UIButton) {
        CalendarViewDisplayManager.instance.configuration = .availableDates
        self.calendarViewHeightConstraint.constant = 165
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
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
