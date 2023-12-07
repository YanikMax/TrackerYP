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
        button.tintColor = .blackDay
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .whiteDay
        datePicker.tintColor = .blue
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.calendar = Calendar(identifier: .iso8601)
        datePicker.addTarget(self, action: #selector(didChangedDatePicker), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchField: UISearchBar = {
        let view = UISearchBar()
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        view.placeholder = (NSLocalizedString("searchField", comment: ""))
        view.searchBarStyle = .minimal
        view.delegate = self
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .whiteDay
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 16
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var nothingFoundView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = NSLocalizedString("nothingFound", comment: "")
        label.textColor = .black
        label.textAlignment = .center
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.isHidden = true
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
    private var trackerStore: TrackerStoreProtocol
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var editingTracker: Tracker?
    
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        configureConstraints()
        trackerLabel.configureLabel(
            text: NSLocalizedString("title.tracker", comment: ""),
            addToView: view,
            ofSize: 34,
            weight: .bold
        )
        view.addSubview(nothingFoundView)
        mainSpacePlaceholderStack.configurePlaceholderStack(imageName: "Plug", text: NSLocalizedString("plug", comment: ""))
        searchSpacePlaceholderStack.configurePlaceholderStack(imageName: "EmojiNothingFound", text: NSLocalizedString("nothingFound", comment: ""))
        checkMainPlaceholderVisability()
        checkPlaceholderVisabilityAfterSearch()
        
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        
        try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        try? trackerRecordStore.loadCompletedTrackers(by: currentDate)
        
        checkNumberOfTrackers()
        
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
        AnalyticsService.shared.sendButtonClickEvent(screen: .main, item: .add_track)
    }
    
    @objc private func didTapFilterButton() {
        // Создание и отображение экрана с вариантами фильтрации (модальное окно)
        let filterViewController = FilterViewController()
        filterViewController.delegate = self // Устанавливаем делегата для получения выбранного фильтра
        present(filterViewController, animated: true)
        AnalyticsService.shared.sendButtonClickEvent(screen: .main, item: .filter)
    }
    
    @objc private func didChangedDatePicker(_ sender: UIDatePicker) {
        if let newDate = Date.from(date: sender.date) {
            currentDate = newDate
            do {
                try trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
                try trackerRecordStore.loadCompletedTrackers(by: currentDate)
            } catch {
                // Показываем пользователю сообщение об ошибке через UIAlertController
                let alert = UIAlertController(title: "Ошибка", message: "Произошла ошибка: \(error)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                present(alert, animated: true)
                return
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
    
    private func checkNumberOfTrackers() {
        filterButton.isHidden = trackerStore.numberOfTrackers == 0
    }
    
    private func presentFormController(
        with data: Tracker.Data? = nil,
        of trackerType: SetTrackersViewController.TrackerType,
        setAction: TrackerFormViewController.ActionType
    ) {
        let trackerFormViewController = TrackerFormViewController(ActionType: setAction, trackerType: trackerType, data: data)
        trackerFormViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerFormViewController)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
    
    private func showFilterViewController() {
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filterViewController)
        present(navigationController, animated: true)
    }
}
// MARK: - EXTENSIONS
//MARK: - Layout methods
private extension TrackersViewController {
    func configureViews() {
        view.backgroundColor = .whiteDay
        [trackerLabel,
         searchField,
         collectionView,
         mainSpacePlaceholderStack,
         searchSpacePlaceholderStack,
         filterButton,
         addButton,
         datePicker, nothingFoundView].forEach { view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
            
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.07019),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            addButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.07019),
            
            nothingFoundView.topAnchor.constraint(equalTo: searchSpacePlaceholderStack.bottomAnchor),
            nothingFoundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nothingFoundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nothingFoundView.bottomAnchor.constraint(equalTo: filterButton.topAnchor)
        ])
    }
}
//MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: UIContextMenuInteractionDelegate {
    // TODO: Декомпонизировать метод в будущем
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            guard
                let location = interaction.view?.convert(location, to: collectionView),
                let indexPath = collectionView.indexPathForItem(at: location),
                let tracker = trackerStore.tracker(at: indexPath)
            else { return nil }
            
            return UIContextMenuConfiguration(actionProvider:  { actions in
                UIMenu(children: [
                    UIAction(title: tracker.pin ? NSLocalizedString("unPin", comment: "") : NSLocalizedString("toPin", comment: "")) { [weak self] _ in
                        try? self?.trackerStore.togglePin(for: tracker)
                    },
                    UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                        let type: SetTrackersViewController.TrackerType = tracker.schedule != nil ? .habit : .irregularEvent
                        self?.editingTracker = tracker
                        self?.presentFormController(with: tracker.data, of: type, setAction: .edit)
                        AnalyticsService.shared.sendButtonClickEvent(screen: .main, item: .edit)
                    },
                    UIAction(title: NSLocalizedString("deleteActionDeleteCategory", comment: ""), attributes: .destructive) { [weak self] _ in
                        AnalyticsService.shared.sendButtonClickEvent(screen: .main, item: .delete)
                        let alert = UIAlertController(
                            title: nil,
                            message: NSLocalizedString("sureDeleteCategory", comment: ""),
                            preferredStyle: .actionSheet
                        )
                        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionDeleteCategory", comment: ""), style: .cancel)
                        let deleteAction = UIAlertAction(title: NSLocalizedString("deleteActionDeleteCategory", comment: ""), style: .destructive) { [weak self] _ in
                            guard let self else { return }
                            try? trackerStore.deleteTracker(tracker)
                            try? trackerStore.deleteTracker(tracker)
                            AnalyticsService.shared.sendButtonClickEvent(screen: .main, item: .filter)
                        }
                        
                        alert.addAction(deleteAction)
                        alert.addAction(cancelAction)
                        
                        self?.present(alert, animated: true)
                    }
                ])
            })
        }
}

extension TrackersViewController: FilterViewControllerDelegate {
    // Реализация метода делегата FilterViewControllerDelegate
    func didSelectFilter(_ filters: String) {
        applyFilter(for: filters)
    }
    
    private func applyFilter(for filters: String) {
        do {
            switch filters {
            case "Все трекеры":
                // Отображение всех трекеров на выбранный в календаре день
                try trackerRecordStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
            case "Трекеры на сегодня":
                // Отображение трекеров на сегодняшний день
                let today = Date().removeTime() ?? Date()
                currentDate = Date().removeTime() ?? Date()
                datePicker.date = Date().removeTime() ?? Date()
                try trackerRecordStore.loadFilteredTrackers(date: today, searchString: searchText)
                //TODO: РЕАЛИЗОВАТЬ ПОЗЖЕ
//            case "Завершенные":
//                // Отображение завершенных трекеров на выбранную в календаре дату
//                let trackerId = UUID() // Примерное определение trackerId
//                let isCompleted = trackerRecordStore.isTrackerCompleted(trackerId: trackerId, date: currentDate.removeTime() ?? Date())
//            case "Не завершенные":
//                // Отображение незавершенных трекеров на выбранную в календаре дату
//                let trackerId = UUID() // Примерное определение trackerId
//                let isNotCompleted = trackerRecordStore.isTrackerNotCompleted(trackerId: trackerId, date: currentDate.removeTime() ?? Date())
            default:
                break
            }
            collectionView.reloadData()
        } catch {
            print("Ошибка при применении фильтра: \(error)")
        }
    }
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
        
        let isCompleted = completedTrackers.contains { $0.date == currentDate.removeTime() && $0.trackerId == tracker.id }
        let interaction = UIContextMenuInteraction(delegate: self)
        trackerCell.configure(with: tracker, days: tracker.daysCount, isCompleted: isCompleted, date: currentDate, interaction: interaction)
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
        presentFormController(of: type, setAction: .add)
    }
}

extension TrackersViewController: TrackerFormViewControllerDelegate {
    func didAddTracker(category: TrackerCategory, trackerToAdd: Tracker) {
        dismiss(animated: true)
        try? trackerStore.addTracker(trackerToAdd, with: category)
    }
    
    func didUpdateTracker(with data: Tracker.Data) {
        guard let editingTracker else { return }
        dismiss(animated: true)
        try? trackerStore.updateTracker(editingTracker, with: data)
        self.editingTracker = nil
    }
    
    func didTapCancelButton() {
        collectionView.reloadData()
        editingTracker = nil
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
    func didTapAddDayButton(of cell: TrackerCell, with tracker: Tracker) {
        if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate.removeTime() && $0.trackerId == tracker.id }) {
            try? trackerRecordStore.remove(recordToRemove)
            cell.switchAddDayButton(to: false)
            cell.decreaseCount()
        } else {
            let trackerRecord = TrackerRecord(trackerId: tracker.id, date: currentDate.removeTime() ?? Date())
            try? trackerRecordStore.add(trackerRecord)
            cell.switchAddDayButton(to: true)
            cell.increaseCount()
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate() {
        checkNumberOfTrackers()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords(_ records: Set<TrackerRecord>) {
        completedTrackers = records
    }
}
