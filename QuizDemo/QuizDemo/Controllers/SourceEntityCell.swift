import UIKit

class SourceEntityCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!

    func fill(_ title: String) {
        label.text = title
        label.textColor = UIColor(red: 0.973, green: 0.6, blue: 0.114, alpha: 1)
        backgroundColor = UIColor(red: 0.455, green: 0.455, blue: 0.502, alpha: 0.18)
        let backView = UIView()
        backView.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        selectedBackgroundView = backView
        applyMaskLayer()
    }

    func applyMaskLayer(_ withOffset: CGFloat = 0) {
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 12
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width + withOffset, height: self.bounds.height)
            .insetBy(dx: 16, dy: 0)
        self.layer.masksToBounds = true
        self.layer.mask = maskLayer
    }
}
