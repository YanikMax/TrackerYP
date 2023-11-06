import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    private var color: UIColor?
    static let identifier = "ColorCollectionViewCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        self.color = color
    }
    
    private func configureViews() {
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 10 // Устанавливаем закругленные края на contentView
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor),
        ])
    }
}

extension ColorCollectionViewCell: SelectionCellProtocol {
    func select() {
        contentView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        contentView.layer.borderWidth = 3
    }
    
    func deselect() {
        contentView.layer.borderWidth = 0
    }
}
