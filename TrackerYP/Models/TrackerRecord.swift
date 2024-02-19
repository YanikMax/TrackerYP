import Foundation

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
    let id: UUID
    
    init(trackerId: UUID, date: Date, id: UUID = UUID()) {
        self.trackerId = trackerId
        self.date = date
        self.id = id
    }
}
