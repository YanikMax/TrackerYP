import UIKit

// Текстовое поле
final class TextField: UITextField {
    // Отступы к тексту внутри текстового поля
    private let textPadding = UIEdgeInsets(
        top: 0,
        left: 16,
        bottom: 0,
        right: 41
    )
   
    convenience init(placeholder: String) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3) // Устанавливаем цвет фона
        self.placeholder = placeholder
        clearButtonMode = .whileEditing
        layer.cornerRadius = 16
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
