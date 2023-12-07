import UIKit

protocol SetTrackersViewControllerDelegate: AnyObject {
    func didSelectTracker(with: SetTrackersViewController.TrackerType)
}

final class SetTrackersViewController: UIViewController {
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitleColor(.blackNight, for: .normal)
        button.setTitle(NSLocalizedString("habit", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitleColor(.blackNight, for: .normal)
        button.setTitle(NSLocalizedString("irregularEvent", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapIrregularEventButton), for: .touchUpInside)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Properties
    weak var delegate: SetTrackersViewControllerDelegate?
    
    private var labelText = ""
    private var category: String?
    private var schedule: [WeekDay]?
    private var emoji: String?
    private var color: UIColor?
    
    private var isConfirmButtonEnabled: Bool {
        labelText.count > 0 && !isValidationMessageVisible
    }
    
    private var isValidationMessageVisible = false
    private var parameters = [NSLocalizedString("category", comment: ""), NSLocalizedString("schedule", comment: "")]
    private let emojis = EmojiData.emojiArray
    private let colors = UIColor.bunchOfSChoices
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
    
    // MARK: - Actions
    @objc private func didTapHabitButton() {
        title = NSLocalizedString("new.habit", comment: "")
        delegate?.didSelectTracker(with: .habit)
    }
    
    @objc private func didTapIrregularEventButton() {
        title = NSLocalizedString("new.irregularEvent", comment: "")
        delegate?.didSelectTracker(with: .irregularEvent)
    }
}

// MARK: - EXTENSIONS
// MARK: - Choice
extension SetTrackersViewController {
    enum TrackerType {
        case habit, irregularEvent
    }
}

private extension SetTrackersViewController {
    // MARK: - Layout methods
    func configureViews() {
        title = NSLocalizedString("setTrackers", comment: "")
        view.backgroundColor = .whiteDay
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
