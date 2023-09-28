import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didConfirm(_ schedule: [WeekDay])
}

// Создание расписания
final class ScheduleViewController: UIViewController {
    // MARK: - Layout elements
    
    private let weekdaysTableView: UITableView = {
        let table = UITableView()
        table.register(WeekdayCell.self, forCellReuseIdentifier: WeekdayCell.identifier)
        table.separatorStyle = .none
        table.alwaysBounceVertical = true // Включаем прокрутку
        return table
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedWeekdays: Set<WeekDay> = []
    
    // MARK: - Lifecycle
    init(selectedWeekdays: [WeekDay]) {
        self.selectedWeekdays = Set(selectedWeekdays)
        super.init(nibName: nil, bundle: nil)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func didTapConfirmButton() {
        let weekdays = Array(selectedWeekdays).sorted()
        delegate?.didConfirm(weekdays)
    }
}

// MARK: - Layout methods

private extension ScheduleViewController {
    func configureViews() {
        title = "Расписание"
        view.backgroundColor = .white
        [weekdaysTableView, confirmButton].forEach { view.addSubview($0) }
        
        weekdaysTableView.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        weekdaysTableView.dataSource = self
        weekdaysTableView.delegate = self
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            weekdaysTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            weekdaysTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            weekdaysTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            weekdaysTableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: weekdaysTableView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: weekdaysTableView.trailingAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let weekdayCell = tableView.dequeueReusableCell(withIdentifier: WeekdayCell.identifier) as? WeekdayCell else { return UITableViewCell() }
        
        let weekday = WeekDay.allCases[indexPath.row]
        var position: ListOfItems.Position
        
        switch indexPath.row {
        case 0:
            position = .first
        case WeekDay.allCases.count - 1:
            position = .last
        default:
            position = .middle
        }
        
        weekdayCell.configure(
            with: weekday,
            isSelected: selectedWeekdays.contains(weekday),
            position: position
        )
        weekdayCell.delegate = self
        return weekdayCell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListOfItems.height
    }
}

// MARK: - WeekdayCellDelegate

extension ScheduleViewController: WeekdayCellDelegate {
    func didToggleSwitchView(to isSelected: Bool, of weekday: WeekDay) {
        if isSelected {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}
