//
//  DateTimeViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/5/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import Messages

class DateTimeViewController: MSMessagesAppViewController, CalendarViewSizeListener {
    static let expandedItemSize = CGFloat(140)
    
    @IBOutlet weak var calendarViewContainerHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        let calendarManager = CalendarViewDisplayManager.instance
        calendarManager.sizeListeners.insert(self)
        self.onChange(size: calendarManager.viewSize)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onChange(size: CalendarViewDisplayManager.ViewSize) {
        switch size {
        case .small:
            self.calendarViewContainerHeightConstraint.constant += DateTimeViewController.expandedItemSize
            break
            
        case .large:
            self.calendarViewContainerHeightConstraint.constant -= DateTimeViewController.expandedItemSize
            break
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
