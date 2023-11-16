import UIKit

final class TrackersViewController: UIViewController {
    
    private lazy var addButton: UIButton = {
        guard let plusImage = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 18,
                weight: .bold
            )
        ) else {
            return UIButton()
        }
        
        let button = UIButton.systemButton(with: plusImage, target: self, action: #selector(didTapPlusButton))
        button.tintColor = .black
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.tintColor = .blue
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .iso8601)
        datePicker.addTarget(self, action: #selector(didChangedDatePicker), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchField: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Поиск"
        view.searchBarStyle = .minimal
        view.delegate = self
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .white
        view.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        view.register(
            TrackerCategoryNames.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        return view
    }()
    
    //MARK: - Properties
    
    private let mainSpacePlaceholderStack = UIStackView()
    private let searchSpacePlaceholderStack = UIStackView()
    private let trackerLabel = UILabel()
    private var currentDate = Date()
    private let params = UICollectionView.GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 10, topInset: 8, bottomInset: 16, height: 148)
    private var categories = [TrackerCategory]()
    private var completedTrackers: Set<TrackerRecord> = []
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        configureConstraints()
        trackerLabel.configureLabel(
            text: "Трекеры",
            addToView: view,
            ofSize: 34,
            weight: .bold
        )
        mainSpacePlaceholderStack.configurePlaceholderStack(imageName: "Plug", text: "Что будем отслеживать?")
        searchSpacePlaceholderStack.configurePlaceholderStack(imageName: "EmojiNothingFound", text: "Ничего не найдено")
        checkMainPlaceholderVisability()
        checkPlaceholderVisabilityAfterSearch()
        
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        
        try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        try? trackerRecordStore.loadCompletedTrackers(by: currentDate)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func configureNavigationBar() {
        // Создаем UIView и добавляем кнопку как его подпредставление
        let addButtonContainerView = UIView()
        addButtonContainerView.addSubview(addButton)
        
        // Создаем UIBarButtonItem, используя addButtonContainerView как пользовательское представление
        let addButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addButtonItem
        
        // Создаем экземпляр UIBarButtonItem для datePicker
        let datePickerButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerButtonItem
    }
    
    // MARK: - Actions
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func didTapPlusButton() {
        let setTrackersViewController = SetTrackersViewController()
        setTrackersViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: setTrackersViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func didChangedDatePicker(_ sender: UIDatePicker) {
        if let newDate = Date.from(date: sender.date) {
            currentDate = newDate
            do {
                try trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
                try trackerRecordStore.loadCompletedTrackers(by: currentDate)
            } catch {
                print("Произошла ошибка: \(error)")
            }
            collectionView.reloadData()
        }
    }
    
    // MARK: - Methods
    private func checkMainPlaceholderVisability() {
        let isHidden = trackerStore.numberOfTrackers == 0  && searchSpacePlaceholderStack.isHidden
        mainSpacePlaceholderStack.isHidden = !isHidden
    }
    
    private func checkPlaceholderVisabilityAfterSearch() {
        let isHidden = trackerStore.numberOfTrackers == 0  && searchField.text != ""
        searchSpacePlaceholderStack.isHidden = !isHidden
    }
}
// MARK: - EXTENSIONS
//MARK: - Layout methods
private extension TrackersViewController {
    func configureViews() {
        view.backgroundColor = .white
        [trackerLabel, searchField, collectionView, mainSpacePlaceholderStack, searchSpacePlaceholderStack].forEach { view.addSubview($0) }
        
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        mainSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        searchSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.1083),
            trackerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            
            searchField.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            searchField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 34),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            mainSpacePlaceholderStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.495),
            mainSpacePlaceholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchSpacePlaceholderStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.495),
            searchSpacePlaceholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
//MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        checkMainPlaceholderVisability()
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell, let tracker = trackerStore.tracker(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        let isCompleted = completedTrackers.contains { $0.date == currentDate && $0.trackerId == tracker.id }
        trackerCell.configure(with: tracker, days: tracker.daysCount, isCompleted: isCompleted, date: currentDate)
        trackerCell.delegate = self
        return trackerCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let availableSpace = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableSpace / params.cellCount
        return CGSize(width: cellWidth, height: params.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TrackerCategoryNames
        else { return UICollectionReusableView() }
        
        guard let label =  trackerStore.headerLabelInSection(indexPath.section) else { return UICollectionReusableView() }
        view.configure(with: label)
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}
// MARK: - AddTrackerViewControllerDelegate
extension TrackersViewController: SetTrackersViewControllerDelegate {
    func didSelectTracker(with type: SetTrackersViewController.TrackerType) {
        dismiss(animated: true)
        let trackerFormViewController = TrackerFormViewController(type: type)
        trackerFormViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerFormViewController)
        present(navigationController, animated: true)
    }
}

extension TrackersViewController: TrackerFormViewControllerDelegate {
    func didTapConfirmButton(category: TrackerCategory, trackerToAdd: Tracker) {
        dismiss(animated: true)
        try? trackerStore.addTracker(trackerToAdd, with: category)
    }
    
    func didTapCancelButton() {
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        checkPlaceholderVisabilityAfterSearch()
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()
        checkPlaceholderVisabilityAfterSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchText = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        collectionView.reloadData()
        checkPlaceholderVisabilityAfterSearch()
    }
}
// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapCompleteButton(of cell: TrackerCell, with tracker: Tracker) {
        if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate && $0.trackerId == tracker.id }) {
            try? trackerRecordStore.remove(recordToRemove)
            cell.switchAddDayButton(to: false)
            cell.decreaseCount()
        } else {
            let trackerRecord = TrackerRecord(trackerId: tracker.id, date: currentDate)
            try? trackerRecordStore.add(trackerRecord)
            cell.switchAddDayButton(to: true)
            cell.increaseCount()
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate() {
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords(_ records: Set<TrackerRecord>) {
        completedTrackers = records
    }
}
