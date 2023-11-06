import UIKit

final class ListCell: UITableViewCell {
    // MARK: - Layout elements
    
    private lazy var listItem = ListOfItems()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 2
        stack.axis = .vertical
        return stack
    }()
    
    private let disclosureImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    // MARK: - Properties
    static let identifier = "ListCell"
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure(label: String, value: String?, position: ListOfItems.Position) {
        listItem.configure(with: position)
        nameLabel.text = label
    }
}

// MARK: - Layout methods
private extension ListCell {
    func configureViews() {
        selectionStyle = .none
        [listItem, disclosureImageView, labelsStack].forEach { contentView.addSubview($0) }
        labelsStack.addArrangedSubview(nameLabel)
        labelsStack.addArrangedSubview(valueLabel)
        
        listItem.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            listItem.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listItem.topAnchor.constraint(equalTo: contentView.topAnchor),
            listItem.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            labelsStack.leadingAnchor.constraint(equalTo: listItem.leadingAnchor, constant: 16),
            labelsStack.centerYAnchor.constraint(equalTo: listItem.centerYAnchor),
            labelsStack.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -56),
            disclosureImageView.centerYAnchor.constraint(equalTo: listItem.centerYAnchor),
            disclosureImageView.trailingAnchor.constraint(equalTo: listItem.trailingAnchor, constant: -24),
            disclosureImageView.widthAnchor.constraint(equalToConstant: 8),
            disclosureImageView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
}
