import UIKit

extension UIColor {
    
    // MARK: - Interface (main) colors
    static let bunchOfSChoices: [UIColor] = [
        UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1.0), // Red
        UIColor(red: 255/255, green: 136/255, blue: 30/255, alpha: 1.0), // Orange
        UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1.0), // Blue
        UIColor(red: 110/255, green: 68/255, blue: 254/255, alpha: 1.0), // Purple
        UIColor(red: 51/255, green: 207/255, blue: 105/255, alpha: 1.0), // Green
        UIColor(red: 230/255, green: 109/255, blue: 212/255, alpha: 1.0), // Pink
        
        UIColor(red: 249/255, green: 212/255, blue: 212/255, alpha: 1.0),
        UIColor(red: 52/255, green: 167/255, blue: 254/255, alpha: 1.0),
        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1.0),
        UIColor(red: 53/255, green: 52/255, blue: 124/255, alpha: 1.0),
        UIColor(red: 255/255, green: 103/255, blue: 77/255, alpha: 1.0),
        UIColor(red: 255/255, green: 153/255, blue: 204/255, alpha: 1.0),
        
        UIColor(red: 246/255, green: 196/255, blue: 139/255, alpha: 1.0),
        UIColor(red: 121/255, green: 148/255, blue: 245/255, alpha: 1.0),
        UIColor(red: 131/255, green: 44/255, blue: 241/255, alpha: 1.0),
        UIColor(red: 173/255, green: 86/255, blue: 218/255, alpha: 1.0),
        UIColor(red: 141/255, green: 114/255, blue: 230/255, alpha: 1.0),
        UIColor(red: 47/255, green: 208/255, blue: 88/255, alpha: 1.0),
    ]
}

final class ColorPalette {
    static func serialize(color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X%02X",
                      Int(r * 0xff),
                      Int(g * 0xff),
                      Int(b * 0xff),
                      Int(a * 0xff))
    }
    
    static func deserialize(hexString: String) -> UIColor? {
        let r, g, b, a: CGFloat
        let start = hexString.index(hexString.startIndex, offsetBy: 1)
        let hexColor = String(hexString[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
