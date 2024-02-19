import Foundation

extension TrackerStore {
    enum StoreError: Error {
        case decodeError,
             fetchTrackerError,
             deleteError,
             pinError
    }
}

enum CategoriesErrors: Error {
    case deleteError
    case addCategoryError
    case updateCategoryError
}
