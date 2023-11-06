import UIKit

protocol SelectionCellProtocol {
    func select()
    func deselect()
}

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EmojiCollectionViewCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(selectionView)
        selectionView.frame = contentView.bounds
        
        selectionView.addSubview(emojiLabel)
        emojiLabel.frame = selectionView.bounds
        
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}

private extension EmojiCollectionViewCell {
    func configureViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(emojiLabel)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

extension EmojiCollectionViewCell: SelectionCellProtocol {
    func select() {
        // Устанавливаем фоновый цвет с прозрачностью и обводку только при выборе ячейки
        selectionView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    func deselect() {
        // Возвращаем фоновый цвет к прозрачности и убираем обводку
        selectionView.backgroundColor = .clear
    }
}

