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
    
    static let baseScheme = "http"
    static let baseUrl = "www.planit.com"
    static let invitePath = "/invite"
    static let dayQueryName = "day[]"
    
    
    // MARK: - Properties
    
    var conversation: MSConversation?
    var masterMessagesViewController: MSMessagesAppViewController?
    
    var baseComponents: URLComponents {
        get {
            var components = URLComponents()
            components.scheme = ConversationManager.baseScheme
            components.host = ConversationManager.baseUrl
            return components
        }
    }
    
    
    // MARK: - Initialization
    
    private init() {}
    
    
    // MARK: - Message sending
    
    @discardableResult func sendInviteMessage(dateTime: TimeMatrixModel) -> Bool {
        guard let conversation = self.conversation else {
            return false
        }
        
        // since this is a new invite, make a new MSSession
        let session = MSSession()
        
        let description = self.inviteDescription()
        let url = self.inviteURL(dateTimeModel: dateTime)
        
        let message = MSMessage(session: session)
        message.url = url
        message.layout = description.layout
        message.summaryText = description.summary
    
        // create the message so the user can send it
        conversation.insert(message)
        
        self.masterMessagesViewController?.dismiss()
        
        return true
    }
    
    func inviteDescription() -> (layout: MSMessageLayout, summary: String) {
        // TODO make layout and summary from whatever we can get the data from
        
        let layout = MSMessageTemplateLayout()
        layout.caption = "Billy wants to meet with you, Sam, and Sandra this Thursday from 7:30pm to 9:00pm"
        layout.subcaption = "Tap here to respond"
        
        let summary = "Meeting invite from Billy for this Thursday from 7:30-9:00"
        
        return (layout: layout, summary: summary)
    }
    
    
    // MARK: - URL encoding
    
    func inviteURL(dateTimeModel: TimeMatrixModel) -> URL? {
        var components = self.baseComponents
        components.path = ConversationManager.invitePath
        
        var queryItems = [URLQueryItem]()
        
        let dayTimeQueryComponents = self.dateTimeQueryComponents(model: dateTimeModel)
        for component in dayTimeQueryComponents {
            let item = URLQueryItem(name: ConversationManager.dayQueryName, value: component)
            queryItems.append(item)
        }
        
        components.queryItems = queryItems
        
        return components.url
    }
    
    func dateTimeQueryComponents(model: TimeMatrixModel) -> [String] {
        var components = [String]()
        for day in model.activeDays {
            if let cells = model.cells[day], let query = self.dayQueryString(day: day, cells: cells) {
                components.append(query)
            }
        }
        return components
    }
    
    func dayQueryString(day: TimeMatrixDay, cells: [TimeMatrixCellModel]) -> String? {
        guard let timesString = self.dayTimesQueryString(cells: cells) else {
            return nil
        }
        
        let dayString = day.description
        let query = "\(dayString)$\(timesString)"
        return query
    }
    
    func dayTimesQueryString(cells: [TimeMatrixCellModel]) -> String? {
        var query: String? = nil
        var iStart = 0
        while iStart < cells.count {
            let currentState = cells[iStart].currentState
            if currentState != .unavailable {
                var iEnd = iStart + 1
                while (iEnd < cells.count && cells[iEnd].currentState == currentState) {
                    iEnd += 1
                }
                let part = self.timeQueryString(state: currentState, first: iStart, last: iEnd - 1)
                query = (query == nil ? part : query! + "+" + part)
                iStart = iEnd
            }
            else {
                iStart += 1
            }
        }
        return query
    }
    
    func timeQueryString(state: TimeMatrixCellModel.State, first: Int, last: Int) -> String {
        let characterEncoding = self.characterEncoding(fromState: state)
        return "\(characterEncoding)\(first)-\(last)"
    }
    
    func characterEncoding(fromState state: TimeMatrixCellModel.State) -> String {
        switch state {
        case .available: return "A"
        case .preferred: return "P"
        case .unavailable: return "U"
        }
    }
    
    
    // MARK: - URL decoding
    
    func dateTimeModel(queryItems: [URLQueryItem]) -> TimeMatrixModel {
        let model = TimeMatrixModel()
        
        for item in queryItems.filter({$0.name == ConversationManager.dayQueryName}) {
            if let value = item.value {
                let parts = value.components(separatedBy: "$")
                if parts.count > 1 {
                    let day = parts[0]
                    let times = parts[1]
                    self.insertCellModels(into: model, dayQuery: day, timesQuery: times)
                }
            }
        }
        
        return model
    }
    
    func insertCellModels(into model: TimeMatrixModel, dayQuery: String, timesQuery: String) {
        let day = TimeMatrixDay(dateString: dayQuery)
        model.add(day: day)
        
        var cells = [TimeMatrixCellModel]()
        cells.reserveCapacity(TimeMatrixModel.cellsPerDay)
        for index in 0..<TimeMatrixModel.cellsPerDay {
            cells.append(TimeMatrixCellModel(timeSlot: index))
        }
        
        let parts = timesQuery.components(separatedBy: "+")
        for part in parts {
            if let encoding = part.characters.first {
                let times = part.characters.dropFirst().split(separator: "-")
                if times.count == 2 {
                    if let first = Int(String(times[0])), let last = Int(String(times[1])) {
                        let state = self.cellState(fromCharacterEncoding: String(encoding))
                        for index in first...last {
                            cells[index].currentState = state
                        }
                        if state == .preferred {
                            model.preferredDay = day
                            model.preferredStartTime = TimeMatrixTime(rawValue: first)
                            model.preferredEndTime = TimeMatrixTime(rawValue: last + 1)
                        }
                    }
                }
            }
        }
        
        model.cells[day] = cells
    }
    
    func cellState(fromCharacterEncoding character: String) -> TimeMatrixCellModel.State {
        switch character {
        case "A": return .available
        case "P": return .preferred
        default: return .unavailable
        }
    }
    
}
