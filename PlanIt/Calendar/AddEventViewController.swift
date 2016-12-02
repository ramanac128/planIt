//
//  AddEventViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 12/1/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventNameTextField: UITextField!
    
    var containingParent: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.25)
        self.view.isOpaque = false
        
        self.containerView.layer.cornerRadius = 8.0
        self.containerView.layer.borderWidth = 2.0
        self.containerView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func display(in parent: UIViewController) {
        self.containingParent = parent
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        parent.present(self, animated: true)
    }
    
    @IBAction func cancelTouch(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addTouch(_ sender: Any) {
        if let parent = self.containingParent as? CalendarViewController, let name = eventNameTextField.text {
            if !(name.isEmpty || parent.eventPickerData.contains(name)) {
                parent.insertNewEvent(name, animated: true)
            }
        }
        self.dismiss(animated: true)
    }
}
