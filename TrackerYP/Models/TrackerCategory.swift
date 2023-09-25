import UIKit
 
struct TrackerCategory {
    let label: String
    let trackers: [Tracker]
    
    init(label: String, trackers: [Tracker]) {
        self.label = label
        self.trackers = trackers
    }
}

extension TrackerCategory {
    static let mockData: [TrackerCategory]
    = [
        TrackerCategory(
            label: "Работа",
            trackers: [
            ]
        ),
        TrackerCategory(
            label: "Учеба",
            trackers: [
            ]
        ),
        TrackerCategory(
            label: "Домашние дела",
            trackers: [
            ]
        )
    ]
}
