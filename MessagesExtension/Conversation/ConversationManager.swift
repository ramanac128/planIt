//
//  ConversationManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/11/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation
import Messages

class ConversationManager {
    static let instance = ConversationManager()
    
    static let baseUrl = URL(string: "http://www.planit.com")!
    
    
    // MARK: - Properties
    
    var conversation: MSConversation?
    var masterMessagesViewController: MSMessagesAppViewController?
    
    
    // MARK: - Initialization
    
    private init() {}
    
    
    // MARK: - Message sending
    
    @discardableResult func sendInviteMessage(dateTime: TimeMatrixModel) -> Bool {
        guard let conversation = self.conversation else {
            return false
        }
        
        // since this is a new invite, make a new MSSession
        let session = MSSession()
        
        let description = self.makeInviteDescription()
        let url = self.makeInviteURL(dateTime: dateTime)
        
        let message = MSMessage(session: session)
        message.url = url
        message.layout = description.layout
        message.summaryText = description.summary
    
        // create the message so the user can send it
        conversation.insert(message)
        
        self.masterMessagesViewController?.dismiss()
        
        return true
    }
    
    
    // MARK: - Builder methods
    
    func makeInviteURL(dateTime: TimeMatrixModel) -> URL {
        // TODO make URL from TimeMatrixModel
        return ConversationManager.baseUrl.appendingPathComponent("invite")
    }
    
    func makeInviteDescription() -> (layout: MSMessageLayout, summary: String) {
        // TODO make layout and summary from whatever we can get the data from
        
        let layout = MSMessageTemplateLayout()
        layout.caption = "Billy wants to meet with you, Sam, and Sandra this Thursday from 7:30pm to 9:00pm"
        layout.subcaption = "Tap here to respond"
        
        let summary = "Meeting invite from Billy for this Thursday from 7:30-9:00"
        
        return (layout: layout, summary: summary)
    }
}
