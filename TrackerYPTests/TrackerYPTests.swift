import XCTest
import SnapshotTesting
@testable import TrackerYP


final class TrackerYPTests: XCTestCase {

    func testTrackersViewControllerSnapshot() throws {
        let vc = TrackersViewController(trackerStore: StubTrackerStore())
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkSnapshot() throws {
        let vc = TrackersViewController(trackerStore: StubTrackerStore())
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

extension TrackerYPTests {
    private struct StubTrackerStore: TrackerStoreProtocol {
        var delegate: TrackerStoreDelegate?
        
        var numberOfTrackers: Int = 3
        var numberOfSections: Int = 2
        
        private static let category = TrackerCategory(label: "Обучение")
        private static let trackers: [[Tracker]] = [
            [
                Tracker(
                    label: "Программирование",
                    emoji: "🙂",
                    color: .bunchOfSChoices[safe: 16]!,
                    schedule: [.saturday],
                    daysCount: 5,
                    pin: true,
                    category: category
                )
            ],
            [
                Tracker(
                    label: "Английский язык",
                    emoji: "🤔",
                    color: .bunchOfSChoices[safe: 14]!,
                    schedule: nil,
                    daysCount: 1,
                    pin: false,
                    category: category
                ),
                Tracker(
                    label: "Стрельба из лука",
                    emoji: "😪",
                    color: .bunchOfSChoices[safe: 9]!,
                    schedule: nil,
                    daysCount: 2,
                    pin: false,
                    category: category
                )
            ]
        ]
                
        func numberOfRowsInSection(_ section: Int) -> Int {
            switch section {
            case 0: return 1
            case 1: return 2
            default: return 0
            }
        }
        
        func headerLabelInSection(_ section: Int) -> String? {
            switch section {
            case 0: return "Закрепленные"
            case 1: return StubTrackerStore.category.label
            default: return nil
            }
        }
        
        func tracker(at indexPath: IndexPath) -> Tracker? {
            let tracker = StubTrackerStore.trackers[indexPath.section][indexPath.item]
            return tracker
        }
        
        func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {}
        func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {}
        func deleteTracker(_ tracker: Tracker) throws {}
        func togglePin(for tracker: Tracker) throws {}
        func loadFilteredTrackers(date: Date, searchString: String) throws {}
    }
}


