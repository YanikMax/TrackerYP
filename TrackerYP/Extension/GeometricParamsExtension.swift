import UIKit

extension UICollectionView {
    struct GeometricParams {
        let cellCount: CGFloat
        let leftInset: CGFloat
        let rightInset: CGFloat
        let cellSpacing: CGFloat
        let paddingWidth: CGFloat
        let topInset: CGFloat
        let bottomInset: CGFloat
        let height: CGFloat
        
        init(cellCount: CGFloat, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat, topInset: CGFloat, bottomInset: CGFloat, height: CGFloat) {
            self.cellCount = cellCount
            self.leftInset = leftInset
            self.rightInset = rightInset
            self.cellSpacing = cellSpacing
            self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
            self.topInset = topInset
            self.bottomInset = bottomInset
            self.height = height
        }
    }
}
