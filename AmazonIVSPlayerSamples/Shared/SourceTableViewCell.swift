import UIKit

class SourceTableViewCell: UITableViewCell {

    static let reuseIdentifier = "SourceTableViewCell"
    static let textColor = UIColor(red: 0.973, green: 0.6, blue: 0.114, alpha: 1)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyMaskLayer()
    }

    func configure(with source: Source) {
        textLabel?.text = source.title
        textLabel?.textColor = Self.textColor
        backgroundColor = UIColor(red: 0.455, green: 0.455, blue: 0.502, alpha: 0.18)
        let backView = UIView()
        backView.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        selectedBackgroundView = backView
    }

    func applyMaskLayer(_ withOffset: CGFloat = 0) {
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 12
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width + withOffset, height: bounds.height)
            .insetBy(dx: 16, dy: 0)
        layer.masksToBounds = true
        layer.mask = maskLayer
    }
}
