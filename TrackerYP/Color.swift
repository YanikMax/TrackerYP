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
    
    static let gradient = [
        UIColor(named: "gBlue") ?? UIColor.black,
        UIColor(named: "gGreen") ?? UIColor.black,
        UIColor(named: "gRed") ?? UIColor.black,
    ]
    
    static var blackDay: UIColor { UIColor(named: "blackDay") ?? UIColor.black }
    static var blackNight: UIColor { UIColor(named: "blackNight") ?? UIColor.black }
    static var whiteDay: UIColor { UIColor(named: "whiteDay") ?? UIColor.black }
    static var whiteNight: UIColor { UIColor(named: "whiteNight") ?? UIColor.black }
    static var backgroundDay: UIColor { UIColor(named: "backgroundDay") ?? UIColor.black }
    static var backgroundNight: UIColor { UIColor(named: "backgroundNight") ?? UIColor.black }
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

extension UIView {
     private static let kLayerNameGradientBorder = "GradientBorderLayer"

     func gradientBorder(
         width: CGFloat,
         colors: [UIColor],
         startPoint: CGPoint = .init(x: 0.5, y: 0),
         endPoint: CGPoint = .init(x: 0.5, y: 1),
         andRoundCornersWithRadius cornerRadius: CGFloat = 0
     ) {
         let existingBorder = gradientBorderLayer()
         let border = existingBorder ?? .init()
         border.frame = CGRect(
             x: bounds.origin.x,
             y: bounds.origin.y,
             width: bounds.size.width + width,
             height: bounds.size.height + width
         )
         border.colors = colors.map { $0.cgColor }
         border.startPoint = startPoint
         border.endPoint = endPoint

         let mask = CAShapeLayer()
         let maskRect = CGRect(
             x: bounds.origin.x + width/2,
             y: bounds.origin.y + width/2,
             width: bounds.size.width - width,
             height: bounds.size.height - width
         )
         mask.path = UIBezierPath(
             roundedRect: maskRect,
             cornerRadius: cornerRadius
         ).cgPath
         mask.fillColor = UIColor.clear.cgColor
         mask.strokeColor = UIColor.white.cgColor
         mask.lineWidth = width

         border.mask = mask

         let isAlreadyAdded = (existingBorder != nil)
         if !isAlreadyAdded {
             layer.addSublayer(border)
         }
     }

     private func gradientBorderLayer() -> CAGradientLayer? {
         let borderLayers = layer.sublayers?.filter {
             $0.name == UIView.kLayerNameGradientBorder
         }
         if borderLayers?.count ?? 0 > 1 {
             fatalError()
         }
         return borderLayers?.first as? CAGradientLayer
     }
 }

extension CGPoint {

     enum CoordinateSide {
         case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left
     }

     static func unitCoordinate(_ side: CoordinateSide) -> CGPoint {
         let x: CGFloat
         let y: CGFloat

         switch side {
         case .topLeft:      x = 0.0; y = 0.0
         case .top:          x = 0.5; y = 0.0
         case .topRight:     x = 1.0; y = 0.0
         case .right:        x = 0.0; y = 0.5
         case .bottomRight:  x = 1.0; y = 1.0
         case .bottom:       x = 0.5; y = 1.0
         case .bottomLeft:   x = 0.0; y = 1.0
         case .left:         x = 1.0; y = 0.5
         }
         return .init(x: x, y: y)
     }
 }
