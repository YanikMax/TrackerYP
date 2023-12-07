import UIKit

final class StatisticView: UIView {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private var name: String {
        didSet {
            nameLabel.text = name
        }
    }
    
    private var number: Int {
        didSet {
            numberLabel.text = "\(number)"
        }
    }
    
    required init(name: String, number: Int = 0) {
        self.name = name
        self.number = number
        
        super.init(frame: .zero)
        setName(name)
        setNumber(number)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBorder()
    }
    
    func setName(_ name: String) {
        self.name = name
    }
    
    func setNumber(_ number: Int) {
        self.number = number
    }
}

extension StatisticView {
    
    func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        [nameLabel, numberLabel].forEach { addSubview($0) }
    }
    
    func setupBorder() {
        gradientBorder(
            width: 1,
            colors: UIColor.gradient,
            startPoint: .unitCoordinate(.left),
            endPoint: .unitCoordinate(.right),
            andRoundCornersWithRadius: 12
        )
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: numberLabel.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}
