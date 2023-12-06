import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords(_ records: Set<TrackerRecord>)
}

protocol TrackerRecordStoreMethods {
    func loadFilteredTrackers(date: Date, searchString: String) throws
    func loadCompletedTrackers(by date: Date) throws
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool
    func isTrackerNotCompleted(trackerId: UUID, date: Date) -> Bool
}

final class TrackerRecordStore: NSObject {
    // MARK: - Properties
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    private var completedTrackers: Set<TrackerRecord> = []
    
    // MARK: - Lifecycle
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Methods
    func add(_ newRecord: TrackerRecord) throws {
        let trackerCoreData = try trackerStore.getTrackerCoreData(by: newRecord.trackerId)
        let TrackerRecordCoreData = TrackerRecordCoreData(context: context)
        TrackerRecordCoreData.recordId = newRecord.id.uuidString
        TrackerRecordCoreData.date = newRecord.date.removeTime()
        TrackerRecordCoreData.tracker = trackerCoreData
        
        let trackerIsCompleted = isTrackerCompleted(trackerId: newRecord.trackerId, date: newRecord.date)
        if trackerIsCompleted {
            // Трекер уже был отмечен как выполненный, поэтому не добавляем новую запись
            print("Этот трекер уже выполнен")
        } else {
            try context.save()
            completedTrackers.insert(newRecord)
            delegate?.didUpdateRecords(completedTrackers)
        }
    }
    
    func remove(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.recordId), record.id.uuidString
        )
        let records = try context.fetch(request)
        guard let recordToRemove = records.first else { return }
        context.delete(recordToRemove)
        try context.save()
        completedTrackers.remove(record)
        delegate?.didUpdateRecords(completedTrackers)
    }
    
    func loadCompletedTrackers(by date: Date) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), date.removeTime()! as NSDate)
        let recordsCoreData = try context.fetch(request)
        let records = try recordsCoreData.map { try makeTrackerRecord(from: $0) }
        completedTrackers = Set(records)
        delegate?.didUpdateRecords(completedTrackers)
    }
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.recordId),
                                        trackerId.uuidString,
                                        #keyPath(TrackerRecordCoreData.date),
                                        date as CVarArg)
        guard let trackerRecords = try? context.fetch(request) else {
            assertionFailure("Failed to fetch(request)")
            return false
        }
        return !trackerRecords.isEmpty
    }
    
    func isTrackerNotCompleted(trackerId: UUID, date: Date) -> Bool {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "NOT (%K == %@ AND %K == %@)",
                                        #keyPath(TrackerRecordCoreData.recordId),
                                        trackerId.uuidString,
                                        #keyPath(TrackerRecordCoreData.date),
                                        date as CVarArg)
        do {
            let trackerRecords = try context.fetch(request)
            return !trackerRecords.isEmpty
        } catch {
            print("Error fetching records: \(error)")
            return false
        }
    }
    
    func loadCompletedTrackers() throws -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let recordsCoreData = try context.fetch(request)
        let records = try recordsCoreData.map { try makeTrackerRecord(from: $0) }
        return records
    }
    
    private func makeTrackerRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let idString = coreData.recordId,
            let id = UUID(uuidString: idString),
            let date = coreData.date?.removeTime(),
            let trackerCoreData = coreData.tracker,
            let tracker = try? trackerStore.makeTracker(from: trackerCoreData)
        else { throw StoreError.decodeError }
        return TrackerRecord(trackerId: tracker.id, date: date, id: id)
    }
}

extension TrackerRecordStore {
    enum StoreError: Error {
        case decodeError
    }
}

extension Date {
    func removeTime() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)
    }
}

extension TrackerRecordStore: TrackerRecordStoreMethods {
    func loadFilteredTrackers(date: Date, searchString: String) throws {
        // Выполнить запрос для загрузки трекеров по заданным параметрам
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K CONTAINS[cd] %@",
                                        // выполняется фильтрация по recordId
                                        #keyPath(TrackerRecordCoreData.recordId), searchString)
        
        let filteredRecords = try context.fetch(request)
        let filteredTrackerRecords = try filteredRecords.map { try makeTrackerRecord(from: $0) }
        
        // Вызвать делегата для обновления отфильтрованных записей
        delegate?.didUpdateRecords(Set(filteredTrackerRecords))
    }
}

