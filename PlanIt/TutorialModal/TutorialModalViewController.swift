//
//  TutorialModalViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/9/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

struct TutorialModalParameters {
    var text: String
    var backgroundColor: Int
    
    init(text: String, backgroundColor: Int = 0xFFFF33) {
        self.text = text
        self.backgroundColor = backgroundColor
    }
    
    func display(in parent: UIViewController) {
        let modal = TutorialModalViewController()
        let _ = modal.view // trick to force IBOutlet initialization
        modal.setParameters(self)
        modal.display(in: parent)
    }
}

class TutorialModalViewController: UIViewController {
    
    // MARK: - Static initialization parameter sets
    
    static let tutorialSenderDateTime = TutorialModalParameters(text: "Select alternative meeting days on the calendar,  then drag across the red squares to set your available times. Swipe the time labels up and down to scroll.")
    
    static let tutorialResponderDateTime = TutorialModalParameters(text: "Drag across the red cells to indicate the times you're available to meet. Swipe the time labels up and down to scroll.")
    
    // MARK: - Variables
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!

    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.25)
        self.view.isOpaque = false
        
        self.containerView.layer.cornerRadius = 8.0
        self.containerView.layer.borderWidth = 2.0
        self.containerView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func setParameters(_ parameters: TutorialModalParameters) {
        self.descriptionLabel.text = parameters.text
        self.containerView.backgroundColor = UIColor(hex: parameters.backgroundColor)
    }
    
    func display(in parent: UIViewController) {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        parent.present(self, animated: true)
    }
    
    
    // MARK: - Navigation
    
    @IBAction func dismissButtonTouch(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
