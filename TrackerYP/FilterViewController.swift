import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filters: String)
}

final class FilterViewController: UIViewController {
    private let filterCellReuseIdentifier = "filterCell"
    var filters: [String] = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    var selectedFilter: String = "Все трекеры"
    static var selectedFilterIndex: Int = 0
    private var selectedIndexPath: IndexPath?
    weak var delegate: FilterViewControllerDelegate?
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setupUI()
        setupConstraints()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: filterCellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupUI() {
        view.addSubview(topLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topLabel.heightAnchor.constraint(equalToConstant: 20), // Установите нужную высоту
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: filterCellReuseIdentifier, for: indexPath)
        let categoryName = filters[indexPath.row]
        
        cell.textLabel?.text = categoryName
        cell.backgroundColor = UIColor.backgroundDay
        cell.selectionStyle = .none
        
        if indexPath.row == FilterViewController.selectedFilterIndex {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.blue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstCell && isLastCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        FilterViewController.selectedFilterIndex = indexPath.row
        tableView.reloadData()
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true, completion: nil)
    }
}
