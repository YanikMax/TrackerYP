import UIKit

final class CategoryCell: UITableViewCell {
    // MARK: - Layout elements
    private lazy var listOfItem = ListOfItems()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        return imageView
    }()
    
    // MARK: - Properties
    static let identifier = "WeekdayCell"
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with label: String, isSelected: Bool, position: ListOfItems.Position) {
        listOfItem.configure(with: position)
        self.label.text = label
        checkmarkImage.isHidden = !isSelected
    }
}

// MARK: - Layout methods
private extension CategoryCell {
    func configureViews() {
        selectionStyle = .none
        [listOfItem, label, checkmarkImage].forEach { contentView.addSubview($0) }
        
        listOfItem.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            listOfItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listOfItem.topAnchor.constraint(equalTo: contentView.topAnchor),
            listOfItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listOfItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: listOfItem.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: listOfItem.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: listOfItem.trailingAnchor, constant: -83),
            checkmarkImage.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            checkmarkImage.trailingAnchor.constraint(equalTo: listOfItem.trailingAnchor, constant: -16)
        ])
    }
}
