import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapCompleteButton(of cell: TrackerCell, with tracker: Tracker)
}

final class TrackerCell: UICollectionViewCell {
    // MARK: - Layout elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let iconView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        return view
    }()
     
    private let emoji: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var addDayButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(didTapAddDayButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    private var tracker: Tracker?
    private var days = 0 {
        willSet {
            daysCountLabel.text = "\(newValue)"
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tracker = nil
        days = 0
        addDayButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addDayButton.layer.opacity = 1
    }
    
    // MARK: - Methods
    func configure(with tracker: Tracker, days: Int, isCompleted: Bool) {
        self.tracker = tracker
        self.days = days
        cardView.backgroundColor = tracker.color
        emoji.text = tracker.emoji
        trackerLabel.text = tracker.title
        addDayButton.backgroundColor = tracker.color
        switchAddDayButton(to: isCompleted)
    }
    
    func switchAddDayButton(to isCompleted: Bool) {
        if isCompleted {
            addDayButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            addDayButton.layer.opacity = 0.3
        } else {
            addDayButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addDayButton.layer.opacity = 1
        }
    }
    
    func increaseCount() {
        days += 1
    }
    
    func decreaseCount() {
        days -= 1
    }
    
    // MARK: - Actions
    @objc private func didTapAddDayButton() {
        guard let tracker else { return }
        delegate?.didTapCompleteButton(of: self, with: tracker)
    }
}

// MARK: - Layout methods
private extension TrackerCell {
    func configureViews() {
        [cardView, iconView, emoji, trackerLabel, daysCountLabel, addDayButton].forEach { contentView.addSubview($0) }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        emoji.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addDayButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            emoji.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: addDayButton.centerYAnchor),
            daysCountLabel.trailingAnchor.constraint(equalTo: addDayButton.leadingAnchor, constant: -8),
            addDayButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            addDayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addDayButton.widthAnchor.constraint(equalToConstant: 34),
            addDayButton.heightAnchor.constraint(equalTo: addDayButton.widthAnchor),
        ])
    }
}
