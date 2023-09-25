import UIKit
 
struct Tracker: Identifiable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: [WeekDay]?
    
    init(id: UUID = UUID(), label: String, emoji: String, color: UIColor, schedule: [WeekDay]?) {
        self.id = id
        self.title = label
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.title = tracker.title
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.schedule = tracker.schedule
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color else { fatalError() }
        
        self.id = UUID()
        self.title = data.label
        self.emoji = emoji
        self.color = color
        self.schedule = data.schedule
    }
    
    var data: Data {
        Data(label: title, emoji: emoji, color: color, schedule: schedule)
    }
}

extension Tracker {
    struct Data {
        var label: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var schedule: [WeekDay]? = nil
    }
}
