import UIKit

class SourceTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!

    func configure(with title: String) {
        label.textColor = DarkThemeColors.actionSheetItem
        label.text = title
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        selectedBackgroundView = backgroundView
        applyMaskLayer()
    }

    func applyMaskLayer(_ withOffset: CGFloat = 0) {
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 12
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width + withOffset, height: self.bounds.height)
            .insetBy(dx: 15, dy: 0)
        self.layer.masksToBounds = true
        self.layer.mask = maskLayer
    }
}
