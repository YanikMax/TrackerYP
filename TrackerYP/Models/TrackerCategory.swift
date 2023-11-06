import UIKit

struct TrackerCategory {
    let label: String
    let id: UUID
    
    init(label: String, id: UUID = UUID()) {
        self.label = label
        self.id = id
    }
}
