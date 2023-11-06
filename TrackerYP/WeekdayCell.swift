import UIKit

protocol WeekdayCellDelegate: AnyObject {
    func didToggleSwitchView(to isSelected: Bool, of weekday: WeekDay)
}

// Таблица с расписанием и переключателем UISwitch
final class WeekdayCell: UITableViewCell {
    // MARK: - Layout elements
    
    private lazy var listItem = ListOfItems()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        let blueColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        switchView.onTintColor = blueColor
        switchView.addTarget(self, action: #selector(didToggleSwitchView), for: .valueChanged)
        return switchView
    }()
    
    // MARK: - Properties
    static let identifier = "WeekdayCell"
    weak var delegate: WeekdayCellDelegate?
    private var weekday: WeekDay?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func didToggleSwitchView(_ sender: UISwitch) {
        guard let weekday else { return }
        delegate?.didToggleSwitchView(to: sender.isOn, of: weekday)
    }
    
    // MARK: - Methods
    func configure(with weekday: WeekDay, isSelected: Bool, position: ListOfItems.Position) {
        self.weekday = weekday
        listItem.configure(with: position)
        nameLabel.text = weekday.rawValue
        switchView.isOn = isSelected
    }
}

private extension WeekdayCell {
    func setupContent() {
        selectionStyle = .none
        [listItem, nameLabel, switchView].forEach { contentView.addSubview($0) }
        
        listItem.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        switchView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            listItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listItem.topAnchor.constraint(equalTo: contentView.topAnchor),
            listItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: listItem.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: listItem.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -83),
            switchView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -16)
        ])
    }
}
