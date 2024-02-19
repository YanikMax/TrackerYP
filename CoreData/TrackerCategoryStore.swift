import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
    func didFailWithError(_ error: Error)
}

final class TrackerCategoryStore: NSObject {
    // MARK: - Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    var categoriesCoreData: [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    var categories = [TrackerCategory]()
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.dateCreated, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Lifecycle
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try self.init(context: context)
        } catch {
            fatalError("Failed to initialize TrackerCategoryStore: \(error)")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    // MARK: - Methods
    func categoryCoreData(with id: UUID) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString)
        
        do {
            let category = try context.fetch(request)
            return category[0]
        } catch {
            throw error
        }
    }
    
    func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard
            let idString = coreData.categoryId,
            let id = UUID(uuidString: idString),
            let label = coreData.label
        else { throw StoreError.decodeError }
        return TrackerCategory(label: label, id: id)
    }
    
    @discardableResult func makeCategory(with label: String) throws -> TrackerCategory {
        let category = TrackerCategory(label: label)
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.categoryId = category.id.uuidString
        trackerCategoryCoreData.dateCreated = Date()
        trackerCategoryCoreData.label = category.label
        try context.save()
        return category
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        do {
            let categoryToDelete = try getCategoryCoreData(by: category.id)
            context.delete(categoryToDelete)
            try context.save()
        } catch {
            delegate?.didFailWithError(error)
            throw error
        }
    }
    
    func updateCategory(with data: TrackerCategory.Data) throws {
        let category = try getCategoryCoreData(by: data.id)
        category.label = data.label
        try context.save()
    }
    
    private func getCategoryCoreData(by id: UUID) throws -> TrackerCategoryCoreData {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        guard let category = fetchedResultsController.fetchedObjects?.first else { throw StoreError.fetchCategoryError }
        fetchedResultsController.fetchRequest.predicate = nil
        try fetchedResultsController.performFetch()
        return category
    }
}

extension TrackerCategoryStore {
    enum StoreError: Error {
        case decodeError,
             fetchCategoryError
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
