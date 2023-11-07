import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Properties
    var categories = [TrackerCategory]()
    
    private let context: NSManagedObjectContext
    
    // MARK: - Lifecycle
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        try setupCategories(with: context)
    }
    
    // MARK: - Methods
    func categoryCoreData(with id: UUID) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.idCategory), id.uuidString)
        
        do {
            let category = try context.fetch(request)
            return category[0]
        } catch {
            throw error
        }
    }
    
    private func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard
            let idString = coreData.idCategory,
            let id = UUID(uuidString: idString),
            let label = coreData.label
        else { throw StoreError.decodeError }
        return TrackerCategory(label: label, id: id)
    }
    
    private func setupCategories(with context: NSManagedObjectContext) throws {
        let checkRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let result = try context.fetch(checkRequest)
        
        guard result.isEmpty else {
            categories = try result.map { try makeCategory(from: $0) }
            return
        }
        
        for category in [TrackerCategory(label: "Семья"), TrackerCategory(label: "Рабочий процесс"), TrackerCategory(label: "Менеджер учебы")] {
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.idCategory = category.id.uuidString
            categoryCoreData.dateCreated = Date()
            categoryCoreData.label = category.label
        }
        
        try context.save()
    }
}

extension TrackerCategoryStore {
    enum StoreError: Error {
        case decodeError
    }
}
