import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - Layout elements
    private let statisticLabel = UILabel()
    private let mainSpacePlaceholderStack = UIStackView()
    private let statisticsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    var statisticViewModel: StatisticViewModel?
    private let trackerRecordStore = TrackerRecordStore()
    private let completedTrackersView = StatisticView(name: NSLocalizedString("finishedTrackers", comment: ""))
    private let trackerStore = TrackerStore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        statisticLabel.configureLabel(
            text: (NSLocalizedString("statisticLabel", comment: "")),
            addToView: view,
            ofSize: 34,
            weight: .bold
        )
        configureViews()
        configureConstraints()
        mainSpacePlaceholderStack.configurePlaceholderStack(imageName: "EmojiCry", text: (NSLocalizedString("noStatistics", comment: "")))
        statisticViewModel?.onTrackersChange = { [weak self] trackers in
            guard let self else { return }
            self.checkContent(with: trackers)
            self.setupCompletedTrackersBlock(with: trackers.count)
            checkMainPlaceholderVisability()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticViewModel?.viewWillAppear()
        AnalyticsService.shared.sendOpenScreenEvent(screen: .main)
    }
    
    private func setupCompletedTrackersBlock(with count: Int) {
        completedTrackersView.setNumber(count)
    }

    private func checkMainPlaceholderVisability() {
        let hasTrackers = !statisticsStack.isHidden
        mainSpacePlaceholderStack.isHidden = hasTrackers
    }

    private func checkContent(with trackers: [TrackerRecord]) {
        statisticsStack.isHidden = trackers.isEmpty
        checkMainPlaceholderVisability()
    }

}

// MARK: - Layout methods
private extension StatisticViewController {
    func configureViews() {
        [statisticLabel, mainSpacePlaceholderStack, statisticsStack].forEach { view.addSubview($0) }
        statisticsStack.addArrangedSubview(completedTrackersView)
        statisticLabel.translatesAutoresizingMaskIntoConstraints = false
        mainSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        statisticsStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            statisticLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.1083),
            
            mainSpacePlaceholderStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.495),
            mainSpacePlaceholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statisticsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statisticsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            completedTrackersView.topAnchor.constraint(equalTo: statisticsStack.topAnchor, constant: 228)
        ])
    }
}
