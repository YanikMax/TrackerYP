import UIKit

struct TrackerCategory: Equatable {
    let label: String
    let id: UUID
    
    init(label: String, id: UUID = UUID()) {
        self.label = label
        self.id = id
    }
    
    var data: Data {
        Data(label: label, id: id)
    }
}

extension TrackerCategory {
    struct Data {
        var label: String
        let id: UUID
        
        init(label: String = "", id: UUID? = nil) {
            self.label = label
            self.id = id ?? UUID()
        }
    }
}
