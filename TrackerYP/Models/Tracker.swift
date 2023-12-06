import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: [WeekDay]?
    let daysCount: Int
    let pin: Bool
    let category: TrackerCategory
    
    init(id: UUID = UUID(), label: String, emoji: String, color: UIColor, schedule: [WeekDay]?, daysCount: Int, pin: Bool, category: TrackerCategory) {
        self.id = id
        self.title = label
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.daysCount = daysCount
        self.pin = pin
        self.category = category
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.title = tracker.title
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.schedule = tracker.schedule
        self.daysCount = tracker.daysCount
        self.pin = tracker.pin
        self.category = tracker.category
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color, let category = data.category else { fatalError() }
        
        self.id = UUID()
        self.title = data.label
        self.emoji = emoji
        self.color = color
        self.schedule = data.schedule
        self.daysCount = data.daysCount
        self.pin = data.pin
        self.category = category
    }
    
    var data: Data {
        Data(label: title, emoji: emoji, color: color, schedule: schedule, daysCount: daysCount, category: category)
    }
}

extension Tracker {
    struct Data {
        var label: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var schedule: [WeekDay]? = nil
        var daysCount: Int = 0
        var pin: Bool = false
        var category: TrackerCategory? = nil
    }
}
