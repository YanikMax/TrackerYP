import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: [WeekDay]?
    let daysCount: Int
    
    init(id: UUID = UUID(), label: String, emoji: String, color: UIColor, schedule: [WeekDay]?, daysCount: Int) {
        self.id = id
        self.title = label
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.daysCount = daysCount
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.title = tracker.title
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.schedule = tracker.schedule
        self.daysCount = tracker.daysCount
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color else { fatalError() }
        
        self.id = UUID()
        self.title = data.label
        self.emoji = emoji
        self.color = color
        self.schedule = data.schedule
        self.daysCount = data.daysCount
    }
    
    var data: Data {
        Data(label: title, emoji: emoji, color: color, schedule: schedule, daysCount: daysCount)
    }
}

extension Tracker {
    struct Data {
        var label: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var schedule: [WeekDay]? = nil
        var daysCount: Int = 0
    }
}
