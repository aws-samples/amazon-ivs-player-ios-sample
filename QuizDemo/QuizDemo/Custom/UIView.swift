import UIKit

extension UIView {
    func applyGradientBackground() {
        let gradient: CAGradientLayer = CAGradientLayer()
        let blue = UIColor(red:0.14, green:0.18, blue:0.24, alpha: 1).cgColor
        let red = UIColor(red:0.37, green:0.22, blue:0.25, alpha: 1).cgColor
        gradient.colors = [blue, blue, blue, red]
        gradient.locations = [0, 0.4, 0.8, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.insertSublayer(gradient, at: 0)
    }

    func applyShadow() {
        let shadows = UIView()
        shadows.frame = self.frame
        shadows.clipsToBounds = false
        self.addSubview(shadows)
        let shadowPath = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 10)
        let layer = CALayer()
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.bounds = shadows.bounds
        layer.position = shadows.center
        shadows.layer.addSublayer(layer)
    }
}
